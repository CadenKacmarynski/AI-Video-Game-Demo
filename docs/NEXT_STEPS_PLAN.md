# Next Steps Plan

## Overview
Three main features to implement:
1. **Phase 1**: Add more FBX character assets
2. **Phase 2**: Character swapping system
3. **Phase 3**: Emote wheel UI

---

## Phase 1: Add More FBX Character Assets

### Goal
Import additional playable characters (e.g., Lebron, Jake Paul, Mike Tyson).

### Steps
1. **Acquire/Create Character FBX files**
   - Source from Mixamo, custom models, or other assets
   - Ensure characters use the same skeleton rig (Mixamo standard) for animation compatibility

2. **Import Characters**
   - Drop FBX into `assets/characters/{CharacterName}/`
   - Include textures/materials in same folder
   - Verify mesh is visible when dragged into scene

3. **Create Inherited Scenes** (Recommended)
   - Right-click FBX → "New Inherited Scene"
   - Save as `scenes/characters/{character_name}.tscn`
   - This allows per-character material/scale tweaks

4. **Test Each Character**
   - Drag into Player scene temporarily
   - Verify animations work (same Mixamo rig = compatible)
   - Note any scale differences

### Folder Structure
```
assets/characters/
├── Fortnite-Guy/
│   ├── Fortnite-guy.fbx
│   └── Fortnite-guy_0.png (texture)
├── Lebron/
│   ├── lebron.fbx
│   └── lebron_texture.png
├── Jake-Paul/
│   └── jake-paul.fbx
└── Mike-Tyson/
    └── mike-tyson.fbx
```

### Deliverables
- [ ] All character FBX files imported
- [ ] Each character visible with correct textures
- [ ] Inherited scenes created for each

---

## Phase 2: Character Swapping System

### Goal
Allow runtime character switching via Tab key (already partially implemented) and future character select screen.

### Current State
- `character_skins: Array[PackedScene]` exists in player.gd
- `next_character()` and `switch_character()` functions exist
- Currently unused because character is manually placed in scene

### Implementation Plan

#### Option A: Use Skin Array (Recommended)
Best for multiple pre-configured characters.

1. **Populate `character_skins` array in Inspector**
   - Add each character's inherited scene (.tscn) to the array
   - Order determines Tab cycling order

2. **Modify `_ready()` to use array by default**
   ```gdscript
   func _ready() -> void:
       if character_skins.size() > 0:
           _load_character(current_skin_index)
       else:
           # Fallback to manual child node
           _find_existing_character()
   ```

3. **Remove manual character from scene**
   - Delete the Fortnite-guy node from player.tscn
   - Let script instantiate from array

4. **Ensure animations transfer**
   - Animations are imported fresh for each character
   - Same Mixamo rig = same animation paths = works automatically

#### Option B: Preload All Characters
For faster switching (no instantiation lag).

1. Preload all character scenes at startup
2. Keep inactive characters hidden
3. Swap visibility instead of instantiating

### Character Select Screen (Future)
- Create `scenes/ui/character_select.tscn`
- Grid of character portraits
- Click to select, confirm to start
- Pass selected index to Player on scene load

### Deliverables
- [ ] Character skins array populated with all characters
- [ ] Tab key cycles through characters at runtime
- [ ] Animations work on all characters
- [ ] (Optional) Character select UI

---

## Phase 3: Emote Wheel UI

### Goal
Fortnite-style radial menu that opens on **B** key, allowing mouse selection of emotes.

### Design
```
        [Wave]
    [Salsa]   [Swing]
  [HipHop]  ●  [YMCA]
    [Flair]   [Arrow]
      [PunchBag] [Dribble]
```

### Implementation Plan

#### Step 1: Create Emote Wheel Scene
**File**: `scenes/ui/emote_wheel.tscn`

```
EmoteWheel (Control)
├── Background (ColorRect or TextureRect) - semi-transparent circle
├── Segments (Control) - container for wedges
│   ├── Segment1 (TextureButton)
│   ├── Segment2 (TextureButton)
│   └── ... (one per emote)
├── CenterIcon (TextureRect) - shows selected emote
└── EmoteLabel (Label) - shows emote name
```

#### Step 2: Wheel Script Logic
**File**: `scripts/ui/emote_wheel.gd`

```gdscript
extends Control

signal emote_selected(emote_name: String)

var _emotes: Array[String] = [
    "Wave", "SwingDance", "YMCA", "Salsa",
    "HipHop", "Flair", "Arrow", "PunchingBag", "Dribble"
]
var _selected_index: int = -1

func _ready() -> void:
    visible = false
    _create_segments()

func open() -> void:
    visible = true
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    get_tree().paused = true  # Optional: pause game

func close() -> void:
    visible = false
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    get_tree().paused = false

func _input(event: InputEvent) -> void:
    if not visible:
        return
    
    if event is InputEventMouseMotion:
        _update_selection(event.position)
    
    if event is InputEventMouseButton and event.pressed:
        if _selected_index >= 0:
            emote_selected.emit(_emotes[_selected_index])
            close()

func _update_selection(mouse_pos: Vector2) -> void:
    var center: Vector2 = size / 2
    var direction: Vector2 = mouse_pos - center
    var angle: float = direction.angle()
    # Convert angle to segment index
    _selected_index = _angle_to_segment(angle)
    _highlight_segment(_selected_index)
```

#### Step 3: Integrate with Player
**In player.gd:**

```gdscript
@onready var emote_wheel: Control = $EmoteWheel  # Or get_node()

func _input(event: InputEvent) -> void:
    # ... existing code ...
    
    if event is InputEventKey:
        if event.keycode == KEY_B:
            if event.pressed:
                emote_wheel.open()
            else:  # Released
                emote_wheel.close()

func _on_emote_wheel_selected(emote_name: String) -> void:
    _play_action(emote_name)
```

#### Step 4: Visual Polish
- Add emote icons/thumbnails to each segment
- Highlight effect on hover
- Smooth fade in/out animation
- Sound effect on selection

### Alternative: Simple List UI
If radial is too complex, start with a simple vertical list:
```
┌─────────────┐
│ 1. Wave     │
│ 2. Swing    │
│ 3. YMCA     │
│ ...         │
└─────────────┘
```

### Deliverables
- [ ] Emote wheel scene created
- [ ] B key opens/closes wheel
- [ ] Mouse position selects segment
- [ ] Selection triggers emote
- [ ] Visual feedback (highlight, label)
- [ ] (Optional) Icons for each emote

---

## Recommended Order of Operations

### Week 1: Characters
1. Import remaining character FBX files
2. Create inherited scenes with correct materials/scale
3. Test animations on each character
4. Populate character_skins array
5. Verify Tab switching works

### Week 2: Emote Wheel
1. Create basic emote wheel scene (rectangles, no art)
2. Implement open/close with B key
3. Add mouse selection logic
4. Connect to player emote system
5. Polish with proper visuals

---

## Technical Considerations

### Animation Compatibility
- All characters MUST use Mixamo skeleton hierarchy
- Bone names must match: `mixamorig:Hips`, `mixamorig:Spine`, etc.
- If using non-Mixamo characters, retargeting is required

### Performance
- Character instantiation has a small lag
- Consider preloading for smoother swaps
- Emote wheel should be lightweight (no 3D rendering)

### Input Handling
- Emote wheel needs to capture mouse
- Consider pausing game or restricting movement while wheel open
- B key: press to open, release to close (hold behavior)

---

## Files to Create/Modify

### New Files
- `scenes/characters/*.tscn` - Inherited character scenes
- `scenes/ui/emote_wheel.tscn` - Wheel UI scene
- `scripts/ui/emote_wheel.gd` - Wheel logic

### Modified Files
- `scripts/entities/player.gd` - Character swap fixes, wheel integration
- `scenes/player.tscn` - Remove manual character, add wheel instance

---

## Success Criteria

### Phase 1 Complete When:
- 3+ characters imported and visible
- All characters compatible with existing animations

### Phase 2 Complete When:
- Tab key switches between all characters
- Animations play correctly on all characters
- No visual glitches during swap

### Phase 3 Complete When:
- B key opens radial emote wheel
- Mouse can select any emote
- Selected emote plays on character
- Wheel closes after selection
