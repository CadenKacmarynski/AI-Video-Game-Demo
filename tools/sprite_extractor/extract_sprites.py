"""
Sprite Extractor - Automatically detect and extract character poses from sprite sheets.
Optimized for images with solid color backgrounds (green screen, etc.)
"""

import cv2
import numpy as np
from PIL import Image
from pathlib import Path
import argparse
import sys

# ============== CONFIGURATION ==============
REMOVE_BACKGROUND = False  # Set to True to remove background by default
# ===========================================


def detect_background_color(image: np.ndarray) -> tuple[int, int, int]:
    """Auto-detect the background color by sampling corners."""
    h, w = image.shape[:2]
    corners = [
        image[0, 0],
        image[0, w - 1],
        image[h - 1, 0],
        image[h - 1, w - 1],
    ]
    # Average the corner colors (BGR format)
    avg_color = np.mean(corners, axis=0).astype(int)
    return tuple(avg_color)


def create_background_mask(image: np.ndarray, tolerance: int = 30) -> np.ndarray:
    """Create a mask of the background using auto-detected color."""
    bg_color = detect_background_color(image)
    
    # Convert to HSV for better color matching
    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    bg_hsv = cv2.cvtColor(np.uint8([[bg_color]]), cv2.COLOR_BGR2HSV)[0][0]
    
    # Cast to int to prevent overflow
    h, s, v = int(bg_hsv[0]), int(bg_hsv[1]), int(bg_hsv[2])
    
    # Create range around detected background color (tight on hue, looser on sat/val)
    lower = np.array([max(0, h - 8), max(0, s - tolerance), max(0, v - tolerance)])
    upper = np.array([min(179, h + 8), min(255, s + tolerance), min(255, v + tolerance)])
    
    # Mask where background IS (white = background)
    bg_mask = cv2.inRange(hsv, lower, upper)
    
    # Dilate the background mask to ensure clean separation between sprites
    dilate_kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
    bg_mask = cv2.dilate(bg_mask, dilate_kernel, iterations=2)
    
    # Invert to get foreground mask (white = sprite)
    fg_mask = cv2.bitwise_not(bg_mask)
    
    # Clean up with morphological operations
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
    fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_CLOSE, kernel)
    fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_OPEN, kernel)
    
    return fg_mask


def find_sprite_regions(mask: np.ndarray, min_area: int = 1000) -> list[tuple[int, int, int, int]]:
    """Find bounding boxes for each sprite in the mask."""
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    boxes = []
    for contour in contours:
        area = cv2.contourArea(contour)
        if area < min_area:
            continue
        
        x, y, w, h = cv2.boundingRect(contour)
        boxes.append((x, y, w, h))
    
    # Sort left to right
    boxes.sort(key=lambda b: b[0])
    
    # If only 1 box found but it's very wide, try to split it using vertical projection
    if len(boxes) == 1:
        x, y, w, h = boxes[0]
        aspect = w / h
        if aspect > 1.5:  # Wide image, likely multiple sprites merged
            boxes = split_wide_region(mask, boxes[0], min_area)
    
    # Filter out watermarks/small artifacts (anything < 15% of the largest sprite area)
    boxes = filter_watermarks(boxes)
    
    return boxes


def filter_watermarks(boxes: list[tuple[int, int, int, int]]) -> list[tuple[int, int, int, int]]:
    """Remove small regions that are likely watermarks or artifacts."""
    if len(boxes) <= 1:
        return boxes
    
    # Calculate areas
    areas = [(b[2] * b[3], b) for b in boxes]
    max_area = max(a[0] for a in areas)
    
    # Keep only boxes that are at least 15% of the largest
    threshold = max_area * 0.15
    filtered = [b for area, b in areas if area >= threshold]
    
    return filtered if filtered else boxes


def split_wide_region(mask: np.ndarray, bbox: tuple[int, int, int, int], min_area: int) -> list[tuple[int, int, int, int]]:
    """Split a wide region by finding vertical gaps in the mask."""
    x, y, w, h = bbox
    region = mask[y:y+h, x:x+w]
    
    # Vertical projection - sum pixels in each column
    projection = np.sum(region, axis=0)
    
    # Find gaps (columns with very few foreground pixels)
    threshold = h * 255 * 0.05  # Less than 5% coverage = gap
    is_gap = projection < threshold
    
    # Find continuous gap regions
    gaps = []
    in_gap = False
    gap_start = 0
    
    for i, gap in enumerate(is_gap):
        if gap and not in_gap:
            gap_start = i
            in_gap = True
        elif not gap and in_gap:
            if i - gap_start > 5:  # Gap must be at least 5 pixels wide
                gaps.append((gap_start, i))
            in_gap = False
    
    if not gaps:
        return [(x, y, w, h)]  # No gaps found, return original
    
    # Split at gap centers
    split_points = [0] + [int((g[0] + g[1]) / 2) for g in gaps] + [w]
    
    boxes = []
    for i in range(len(split_points) - 1):
        x1 = split_points[i]
        x2 = split_points[i + 1]
        
        # Find actual content bounds in this slice
        slice_mask = region[:, x1:x2]
        cols = np.any(slice_mask > 0, axis=0)
        rows = np.any(slice_mask > 0, axis=1)
        
        if not np.any(cols) or not np.any(rows):
            continue
            
        col_indices = np.where(cols)[0]
        row_indices = np.where(rows)[0]
        
        bx = x + x1 + col_indices[0]
        by = y + row_indices[0]
        bw = col_indices[-1] - col_indices[0] + 1
        bh = row_indices[-1] - row_indices[0] + 1
        
        if bw * bh >= min_area:
            boxes.append((bx, by, bw, bh))
    
    return boxes if boxes else [(x, y, w, h)]


def extract_sprite(image: np.ndarray, mask: np.ndarray, bbox: tuple[int, int, int, int], padding: int = 10, remove_bg: bool = True) -> np.ndarray:
    """Extract a single sprite, optionally with transparency."""
    x, y, w, h = bbox
    img_h, img_w = image.shape[:2]
    
    # Apply padding (clamped to image bounds)
    x1 = max(0, x - padding)
    y1 = max(0, y - padding)
    x2 = min(img_w, x + w + padding)
    y2 = min(img_h, y + h + padding)
    
    # Crop the region
    cropped_img = image[y1:y2, x1:x2].copy()
    cropped_mask = mask[y1:y2, x1:x2].copy()
    
    # Clean mask: remove small disconnected blobs (watermarks, artifacts)
    cropped_mask = remove_small_blobs(cropped_mask)
    
    # Convert BGR to RGBA
    rgba = cv2.cvtColor(cropped_img, cv2.COLOR_BGR2BGRA)
    
    if remove_bg:
        # Apply mask as alpha channel (transparent background)
        rgba[:, :, 3] = cropped_mask
    else:
        # Keep full opacity (preserve background)
        rgba[:, :, 3] = 255
    
    return rgba


def remove_small_blobs(mask: np.ndarray, min_ratio: float = 0.02) -> np.ndarray:
    """Remove small disconnected blobs from a mask (watermarks, etc.)."""
    # Find connected components
    num_labels, labels, stats, _ = cv2.connectedComponentsWithStats(mask, connectivity=8)
    
    if num_labels <= 1:
        return mask
    
    # Find the largest component (excluding background which is label 0)
    areas = stats[1:, cv2.CC_STAT_AREA]  # Skip background
    if len(areas) == 0:
        return mask
        
    max_area = np.max(areas)
    threshold = max_area * min_ratio
    
    # Create new mask keeping only components above threshold
    clean_mask = np.zeros_like(mask)
    for i in range(1, num_labels):
        if stats[i, cv2.CC_STAT_AREA] >= threshold:
            clean_mask[labels == i] = 255
    
    return clean_mask


def process_image(input_path: Path, output_dir: Path, padding: int = 10, min_area: int = 1000, remove_bg: bool = True) -> int:
    """Process a single image and extract all sprites."""
    print(f"Processing: {input_path.name}")
    
    # Load image at full resolution
    image = cv2.imread(str(input_path), cv2.IMREAD_UNCHANGED)
    if image is None:
        print(f"  ERROR: Could not load image")
        return 0
    
    # Handle images with alpha channel
    if image.shape[2] == 4:
        image = cv2.cvtColor(image, cv2.COLOR_BGRA2BGR)
    
    print(f"  Resolution: {image.shape[1]}x{image.shape[0]}")
    
    # Create mask
    mask = create_background_mask(image)
    
    # Find sprite regions
    boxes = find_sprite_regions(mask, min_area)
    print(f"  Found {len(boxes)} sprites")
    
    if not boxes:
        print("  WARNING: No sprites detected. Try adjusting tolerance.")
        return 0
    
    # Create output subdirectory
    output_subdir = output_dir / input_path.stem
    output_subdir.mkdir(parents=True, exist_ok=True)
    
    # Extract and save each sprite
    for i, bbox in enumerate(boxes):
        sprite = extract_sprite(image, mask, bbox, padding, remove_bg)
        
        # Convert to PIL and save as PNG (lossless)
        pil_image = Image.fromarray(cv2.cvtColor(sprite, cv2.COLOR_BGRA2RGBA))
        output_path = output_subdir / f"pose_{i}.png"
        pil_image.save(output_path, "PNG", compress_level=1)
        
        print(f"  Saved: {output_path.name} ({sprite.shape[1]}x{sprite.shape[0]})")
    
    return len(boxes)


def main():
    parser = argparse.ArgumentParser(description="Extract sprites from sprite sheets")
    parser.add_argument("input", nargs="?", help="Input image path (or process all in input/)")
    parser.add_argument("-p", "--padding", type=int, default=10, help="Padding around sprites (default: 10)")
    parser.add_argument("-m", "--min-area", type=int, default=1000, help="Minimum sprite area in pixels (default: 1000)")
    parser.add_argument("-o", "--output", type=str, default="output", help="Output directory (default: output)")
    parser.add_argument("--remove-bg", action="store_true", help="Remove background (make transparent)")
    
    args = parser.parse_args()
    
    # CLI flag overrides config
    remove_bg = args.remove_bg or REMOVE_BACKGROUND
    
    script_dir = Path(__file__).parent
    output_dir = script_dir / args.output
    output_dir.mkdir(exist_ok=True)
    
    if args.input:
        # Process single file
        input_path = Path(args.input)
        if not input_path.exists():
            print(f"Error: File not found: {input_path}")
            sys.exit(1)
        process_image(input_path, output_dir, args.padding, args.min_area, remove_bg)
    else:
        # Process all images in input/
        input_dir = script_dir / "input"
        if not input_dir.exists():
            print(f"Error: Input directory not found: {input_dir}")
            sys.exit(1)
        
        extensions = {".png", ".jpg", ".jpeg", ".webp", ".bmp"}
        images = [f for f in input_dir.iterdir() if f.suffix.lower() in extensions]
        
        if not images:
            print("No images found in input/")
            sys.exit(1)
        
        total = 0
        for img_path in images:
            total += process_image(img_path, output_dir, args.padding, args.min_area, remove_bg)
        
        print(f"\nDone! Extracted {total} sprites from {len(images)} images.")


if __name__ == "__main__":
    main()
