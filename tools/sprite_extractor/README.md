# Sprite Extractor

Automatically detect and extract character poses from sprite sheets. Optimized for images with solid color backgrounds (green screen, etc.).

## Setup

```powershell
cd tools/sprite_extractor
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

## Usage

### Process all images in `input/` folder

```powershell
python extract_sprites.py
```

### Process a single image

```powershell
python extract_sprites.py "path/to/image.png"
```

### Options

| Flag | Description | Default |
|------|-------------|---------|
| `--remove-bg` | Remove background (transparent) | Off (keeps background) |
| `-p`, `--padding` | Padding around sprites in pixels | 10 |
| `-m`, `--min-area` | Minimum sprite area in pixels | 1000 |
| `-o`, `--output` | Output directory | `output` |

### Examples

```powershell
# Extract with transparent background
python extract_sprites.py --remove-bg

# Custom padding (20px) and minimum area (500px)
python extract_sprites.py -p 20 -m 500

# Process single file with transparent background
python extract_sprites.py "C:\path\to\spritesheet.png" --remove-bg
```

## Output Structure

```
output/
└── {image_name}/
    ├── pose_0.png
    ├── pose_1.png
    └── pose_2.png
```

Sprites are named `pose_0.png`, `pose_1.png`, etc., sorted left-to-right from the source image.

## Configuration

Edit the top of `extract_sprites.py` to change defaults:

```python
REMOVE_BACKGROUND = False  # Set to True to remove background by default
```

## Features

- **Auto background detection** - Samples corners to detect background color
- **HSV color matching** - Robust detection across lighting variations
- **Watermark filtering** - Automatically removes small artifacts (logos, watermarks)
- **Lossless output** - PNG format preserves full quality
- **No downscaling** - Output resolution matches source
