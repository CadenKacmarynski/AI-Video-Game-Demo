# Product Requirements Document: AI Sandbox Demo

## 1. Project Overview
**Goal:** Create a "Progressive" Sandbox Demo for a high school career fair that demonstrates AI in three distinct stages:
1.  **Creation:** Rapid asset integration (Pre-baked AI assets).
2.  **Coding:** Live AI-assisted programming (Cursor Hot-Reload).
3.  **Intelligence:** Runtime AI control (Text-to-Game Logic).

**Constraint:** The system must be modular. Phase 1 & 2 must work completely offline. Phase 3 (OpenAI API) is an additive layer.

## 2. Technical Architecture
- **Engine:** Godot 4.x (Standard Edition).
- **IDE:** Cursor / VS Code (Required for Phase 2).
- **Language:** GDScript.
- **Data Flow:**
    - *Phase 2:* Cursor -> File Save -> Godot Hot Reload -> Game State Update.
    - *Phase 3:* User Input -> HTTP Request -> OpenAI API -> JSON -> Game State Update.

---

## 3. Phase 1: The Foundation (Core Systems)
*Priority: Critical / Must Have*

### A. The Player Controller (`Player.gd`)
*Responsibility:* Robust movement that can be easily modified later.
* **Base Features:** WASD Movement, Jump, Collision.
* **Technical Requirement:**
    * Must use `_physics_process` for movement.
    * Must expose variables (`SPEED`, `JUMP_VELOCITY`, `GRAVITY`) as `@export` for inspector tweaking.
    * **Animation Hook:** Must play "Idle" and "Run" animations from the `AnimationPlayer` based on velocity.

### B. The Asset Pipeline (Static)
*Responsibility:* Display AI-generated content.
* **Storage:** `res://assets/player/` and `res://assets/enemies/`.
* **Format:** `.glb` (GLTF) or `.tscn` (PackedScene) with embedded materials.
* **Requirement:** Assets must have "Linear" loop mode set on import to prevent animation glitches.

---

## 4. Phase 2: Live Edit Support (Cursor Integration)
*Priority: High / Demo Core*

### A. The "Backdoor" Debugger
*Responsibility:* Allow the presenter to trigger new code without restarting the game.
* **Implementation:**
    * Add `func _input(event)` to `Player.gd`.
    * Listen for `KEY_P` (or similar unused key).
    * Trigger a specific function `_execute_demo_logic()` that is initially empty.
* **Usage:** This function serves as the target for Cursor's `Cmd+K` generation (e.g., "Make the P key spawn a cube").

### B. Editor Configuration
* **Auto-Save:** The agent/developer must ensure `Editor Settings -> Run -> Auto Save` is ON.
* **Window Mode:** Game must launch in Windowed mode (1280x720) to allow split-screen visibility with Cursor.

---

## 5. Phase 3: The AI Director (Logic Engine)
*Priority: Nice to Have / "Wizard of Oz"*

### A. The "Game Director" (`GameDirector.gd`)
*Responsibility:* Orchestrate API calls and state changes.
* **Type:** Autoload (Singleton) or Main Scene Node.
* **Functions:**
    1.  `submit_command(text)`: Sends HTTP POST to OpenAI.
    2.  `_on_response(json)`: Validates and applies logic.
* **System Prompt:**
    > "You are a Game Engine API. Translate user requests into JSON.
    > Keys: { 'action': 'spawn'|'physics', 'asset_key': 'string', 'value': float }."

### B. The "Asset Library" (`AssetLibrary.gd`)
*Responsibility:* Prevent "Hallucinated" file paths.
* **Structure:** Static Dictionary mapping semantic keys to physical paths.
    ```gdscript
    const LIBRARY = {
        "robot": "res://assets/player/robot.tscn",
        "monster": "res://assets/enemies/monster.tscn"
    }
    ```
* **Logic:** `get_asset(key)` returns the resource or a fallback "Error Cube".

---

## 6. Stability & Safety Guidelines

### For Live Editing (Phase 2):
* **Simplicity:** Live edits should focus on logic changes (physics math, spawning) rather than complex scene tree manipulation.
* **Syntax Recovery:** If Cursor generates a syntax error, use `Ctrl+Z` immediately. Do not try to debug live.

### For AI Director (Phase 3):
* **No Runtime Compilation:** Do not use `Expression` or dynamic script loading. Use **Parameter Tuning** only.
* **Async Handling:** HTTP requests must not block the main thread.
* **Fallback:** If the API fails (timeout/error), the `GameDirector` should log to console but keep the game running.