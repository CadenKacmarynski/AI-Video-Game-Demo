
# Project Roadmap: AI Sandbox Demo

**Goal:** Build a Godot 4.x sandbox that demonstrates the impact of AI on game development (Creation, Quality, Intelligence) via a progressive implementation strategy.

---

## Phase 1: The Foundation (Sandbox V1)
**Objective:** A stable, standalone executable with a functional 3D environment and one high-quality, AI-generated character.
**Status:** *Critical / Must Have*

### 1.1 Asset Pipeline (Pre-Baked)
*Manual execution of the "AI Workflow" to generate the core assets.*
* **Concept:** Generate character sheet via NanoBanana/Midjourney.
* **Modeling:** Convert 2D image to `.glb` via Tripo3D or Meshy.ai.
* **Rigging:** Auto-rig via Mixamo.
* **Animation:** Download `Idle.fbx` and `Run.fbx` (Linear Loop).
* **Godot Import:**
    * Target Folder: `res://assets/player/`
    * Import Settings: Set Animation Loop Mode to Linear.

### 1.2 Core Godot Setup
* **Scene:** `Main.tscn`
    * `WorldEnvironment`: Panorama Sky (Standard).
    * `DirectionalLight3D`: Shadow mapping enabled.
    * `CSGBox3D` Floor: 50x50m static ground.
* **Player Controller:**
    * Node: `CharacterBody3D`
    * Script: Standard FPS/3rd Person movement.
    * **Requirement:** Expose `SPEED`, `JUMP`, and `GRAVITY` as `@export` variables for Phase 2.

### 1.3 Definition of Done
* [ ] Game runs in Windowed Mode (1280x720).
* [ ] Player can move, jump, and collide with walls.
* [ ] Character model plays animations correctly (no gliding).

---

## Phase 2: The "Cursor Driven" Demo (Live Edit)
**Objective:** Enable "Hot Reloading" workflows to demonstrate AI-assisted coding live on stage.
**Status:** *High Priority*

### 2.1 Editor Configuration
* **Settings:** `Editor -> Editor Settings -> Run -> Auto Save` = **ON**.
* **Window:** `Project Settings -> Display -> Window` = **Windowed**.

### 2.2 The "Backdoor" Input
* **Task:** Add a debug listener to `Player.gd` to trigger experimental code.
* **Code Spec:**
    ```gdscript
    func _input(event):
        if event is InputEventKey and event.pressed and event.keycode == KEY_P:
            _execute_demo_logic() # We will edit this function live
    
    func _execute_demo_logic():
        pass # Cursor target
    ```

### 2.3 The "Cheat Sheet" (Planned Edits)
*Pre-planned prompts to use with Cursor Cmd+K during the demo:*
1.  **Physics:** *"Update `_physics_process` to include a double jump mechanic."*
2.  **Spawning:** *"Update `_execute_demo_logic` to spawn a RigidBody cube 2 meters in front of the player."*
3.  **Visuals:** *"Change the `WorldEnvironment` background energy to 2.0 (bright) when Shift is held."*

---

## Phase 3: The AI Director (Integrated Logic)
**Objective:** In-game text bar that controls game state via OpenAI API (The "Wizard of Oz" Machine).
**Status:** *Nice to Have*

### 3.1 Architecture
* **Script:** `res://scripts/core/GameDirector.gd` (Autoload).
* **Logic:** HTTPRequest -> OpenAI Chat Completion -> JSON Response -> Game State Change.

### 3.2 JSON Schema
The AI must return strict JSON to avoid runtime errors:
```json
{
  "action": "spawn | physics | skybox",
  "asset_key": "robot | monster | crate", 
  "value": "float (for physics) or hex_code (for color)"
}

```

### 3.3 The Asset Registry (`AssetLibrary.gd`)

* **Why:** To prevent spawning files that don't exist.
* **Structure:**
```gdscript
const LIBRARY = {
    "robot": "res://assets/player/robot_skin.tscn",
    "monster": "res://assets/enemies/pizza_monster.tscn"
}

```



---

## Phase 4: Full Pipeline (Automated)

**Objective:** End-to-end generation where text creates a texture/model at runtime.
**Status:** *Stretch Goal / Future*

* **Skybox Gen:** Connect `GameDirector` to DALL-E 3 API to download textures at runtime.
* **Texture Swapping:** `StandardMaterial3D.albedo_texture = new_downloaded_image`.

---

## Technical Appendix

### Directory Structure

```text
res://
├── assets/
│   ├── characters/       # .glb and .fbx source files
│   └── materials/        # StandardMaterial3D resources
├── scenes/
│   ├── Main.tscn         # The Sandbox
│   └── prefabs/          # .tscn files ready to spawn
└── scripts/
    ├── Player.gd         # Phase 2 Target
    ├── GameDirector.gd   # Phase 3 Target
    └── AssetLibrary.gd   # Phase 3 Target

```

### Agent Instructions (for Cursor)

* **Context:** "We are building a stable demo. Do not use `Expression` or runtime code compilation. Use Parameter Tuning (changing variables) and Scene Instantiation (spawning prefabs)."
* **Networking:** "Use Godot's `HTTPRequest` node. Connect the `request_completed` signal dynamically."

