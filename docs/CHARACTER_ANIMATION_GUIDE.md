# Character & Animation System Guide

This document covers the complete setup for characters and animations in the AI Sandbox Demo.

---

## Table of Contents
1. [Character Setup](#character-setup)
2. [Animation Folder Structure](#animation-folder-structure)
3. [Importing FBX from Mixamo](#importing-fbx-from-mixamo)
4. [Rigging Animations to Player](#rigging-animations-to-player)
5. [Keybindings](#keybindings)
6. [Troubleshooting](#troubleshooting)

---

## Character Setup

### Initial Problem
When importing a Mixamo FBX character with animations, the character mesh was **invisible**. The skeleton and animations existed, but no visible mesh appeared.

### Solution
1. **Manually drag the character FBX** into the scene as a child of the Player node
2. The Player script (`scripts/entities/player.gd`) automatically detects child Node3D nodes
3. Set **Character Scale** to `100.0` in the Inspector (Mixamo FBX default scale is very small)

### Player Scene Structure
```
Player (CharacterBody3D)
├── Fortnite-guy (Node3D) ← Your character FBX
├── CollisionShape3D
└── CameraPivot
    └── Camera3D
```

---

## Animation Folder Structure

```
assets/animations/
├── locomotion/          # Movement animations
│   ├── Happy Idle.fbx
│   ├── Walking.fbx
│   ├── Catwalk Walking.fbx
│   ├── Running.fbx
│   ├── Jumping.fbx
│   ├── Running Jump.fbx
│   ├── Running Forward Flip.fbx
│   └── Backflip.fbx
│
├── actions/             # Combat animations
│   ├── Punching.fbx
│   ├── Body Block.fbx
│   ├── Dodging.fbx
│   ├── Headbutt.fbx
│   └── Boxing.fbx
│
└── emotes/              # Dance & gesture animations
    ├── Waving.fbx
    ├── Swing Dancing.fbx
    ├── Ymca Dance.fbx
    ├── Salsa Dancing.fbx
    ├── Wave Hip Hop Dance.fbx
    ├── Flair.fbx
    ├── Shooting Arrow.fbx
    ├── Punching Bag.fbx
    └── Dribble.fbx
```

---

## Importing FBX from Mixamo

### Step 1: Download from Mixamo
1. Go to [mixamo.com](https://www.mixamo.com)
2. Upload your character or use a Mixamo character
3. Browse animations and click **Download**
4. Settings:
   - **Format**: FBX Binary (.fbx)
   - **Skin**: With Skin (for character) / Without Skin (for animations only)
   - **Frames per Second**: 30
   - **Keyframe Reduction**: None
   - ⚠️ **IMPORTANT**: Check **"In Place"** for locomotion animations to prevent teleporting

### Step 2: Import into Godot
1. Drag the `.fbx` file into the appropriate `assets/animations/` subfolder
2. Godot will automatically create a `.import` file
3. The FBX appears as a PackedScene in the FileSystem

### Step 3: Configure Import Settings (Optional)
1. Double-click the FBX in FileSystem
2. Go to **Import** tab
3. Adjust settings if needed:
   - Animation > Loop Mode (for looping animations)
   - Skeleton > Retarget (if using different skeleton)

---

## Rigging Animations to Player

### Method: Inspector Slots
The Player script uses **exported PackedScene slots** for each animation.

1. Select the **Player** node in the scene
2. In the **Inspector**, find the animation groups:
   - **Locomotion Animations**
   - **Action Animations**
   - **Emote Animations**
3. Drag each FBX file into its corresponding slot

### Animation Slots Reference

| Slot Name | FBX File | Description |
|-----------|----------|-------------|
| **Locomotion** |||
| `anim_idle` | Happy Idle.fbx | Standing idle |
| `anim_walk` | Walking.fbx | Normal walking |
| `anim_catwalk` | Catwalk Walking.fbx | Ctrl + walk |
| `anim_run` | Running.fbx | Shift + walk |
| `anim_jump` | Jumping.fbx | Space (idle) |
| `anim_run_jump` | Running Jump.fbx | Space (running) |
| `anim_flip` | Running Forward Flip.fbx | E key |
| `anim_backflip` | Backflip.fbx | Q key |
| **Actions** |||
| `anim_punch` | Punching.fbx | F key |
| `anim_block` | Body Block.fbx | H key |
| `anim_dodge` | Dodging.fbx | V key |
| `anim_headbutt` | Headbutt.fbx | R key |
| `anim_boxing` | Boxing.fbx | G key |
| **Emotes** |||
| `anim_wave` | Waving.fbx | 1 key |
| `anim_swing_dance` | Swing Dancing.fbx | 2 key |
| `anim_ymca` | Ymca Dance.fbx | 3 key |
| `anim_salsa` | Salsa Dancing.fbx | 4 key |
| `anim_hip_hop` | Wave Hip Hop Dance.fbx | 5 key |
| `anim_flair` | Flair.fbx | 6 key |
| `anim_arrow` | Shooting Arrow.fbx | 7 key |
| `anim_punching_bag` | Punching Bag.fbx | 8 key |
| `anim_dribble` | Dribble.fbx | 9 key |

### Y-Offset Configuration
Mixamo animations may have different root positions. Adjust in Inspector:
- **Idle Y Offset**: Vertical position during idle (try `1.0`)
- **Action Y Offset**: Vertical position during other animations (try `1.0`)

---

## Keybindings

### Movement
| Key | Action |
|-----|--------|
| W/A/S/D | Move |
| Shift + Move | Run |
| Ctrl + Move | Catwalk |
| Space | Jump |
| Space (while running) | Running Jump |

### Combat Actions
| Key | Action |
|-----|--------|
| Q | Backflip |
| F | Punch |
| G | Boxing |
| H | Block |
| V | Dodge |
| R | Headbutt |
| E | Flip |

### Emotes
| Key | Emote |
|-----|-------|
| 1 | Wave |
| 2 | Swing Dance |
| 3 | YMCA Dance |
| 4 | Salsa Dance |
| 5 | Hip Hop Dance |
| 6 | Flair (Breakdance) |
| 7 | Shooting Arrow |
| 8 | Punching Bag |
| 9 | Dribble |

### Other
| Key | Action |
|-----|--------|
| Tab | Switch Character |

---

## Troubleshooting

### Character is Invisible
**Cause**: FBX imported without mesh, or mesh has no material.

**Fix**:
1. Manually drag the FBX into the scene as a child of Player
2. Check if materials/textures are in the same folder as the FBX
3. Set Character Scale to `100.0` in Inspector

### Character Sinks Into Ground
**Cause**: Y-offset not configured for animation.

**Fix**:
1. Select Player node
2. In Inspector, find **Animation Fixes**
3. Adjust `Idle Y Offset` and `Action Y Offset` (try `1.0`)

### Animation Teleports/Jumps on Loop
**Cause**: Mixamo animation has root motion (character moves forward in animation).

**Fix** (Best): Re-download from Mixamo with **"In Place"** checked.

**Fix** (Code): The script strips root motion automatically by removing position tracks from Hip bones during import.

### Animation Not Playing
**Cause**: FBX not assigned to slot, or animation name mismatch.

**Fix**:
1. Ensure FBX is dragged into the correct slot in Inspector
2. Check console for `[Player] Loaded animations:` to see what was imported

### Emotes Don't Stop
**Cause**: Animation finished signal not connected.

**Fix**: The script connects `animation_finished` signal automatically. If issues persist, check that `_on_animation_finished` is being called.

### Character Doesn't Face Movement Direction
**Cause**: Character rotation not being updated.

**Fix**: The script automatically rotates the character to face movement direction using `lerp_angle`. Adjust the `0.15` value for faster/slower turning.

---

## Technical Notes

### How Animation Import Works
1. Script loads each FBX as a temporary scene
2. Finds the AnimationPlayer in the FBX
3. Duplicates animations and strips root motion (position tracks on Hips)
4. Adds cleaned animations to the character's AnimationLibrary

### Root Motion Stripping
```gdscript
func _strip_root_motion(anim: Animation) -> void:
    for i in range(anim.get_track_count() - 1, -1, -1):
        var path: String = String(anim.track_get_path(i))
        if anim.track_get_type(i) == Animation.TYPE_POSITION_3D:
            if "Hips" in path or "mixamorig" in path:
                anim.remove_track(i)
```

### Position Locking
To prevent animation drift, the character's XZ position is locked every frame:
```gdscript
_current_character.position.x = _locked_xz.x
_current_character.position.z = _locked_xz.y
```

---

## Adding New Animations

1. Download FBX from Mixamo (with "In Place" if locomotion)
2. Drop into appropriate `assets/animations/` subfolder
3. Add new `@export var anim_name: PackedScene` to player script
4. Add `const ANIM_NAME: String = "AnimName"` constant
5. Add to `_import_all_animations()`: `_import_anim(anim_name, ANIM_NAME)`
6. Add to appropriate array (`_action_anims`, `_emote_anims`, or `_jump_anims`)
7. Add keybind in `_input()` function
8. Drag FBX into new slot in Inspector
