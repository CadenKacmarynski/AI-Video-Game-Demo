# STEM Camp Instructor Guide

This guide helps you run the AI & Game Development labs for middle-school aged students (roughly 11–14).

## Before the Camp

### Software

1. **Godot 4.5** (or later)
   - Download from [godotengine.org/download](https://godotengine.org/download).
   - Use the **Standard** version (not .NET).
   - No installer: extract and run the executable.

2. **This project**
   - Clone or download the repo so each machine (or pair) has a copy.
   - Open the folder in Godot via **Import** → select `project.godot` → **Import & Edit**.

3. **Optional: Cursor** (for Lab 3 if you want to show AI-assisted editing)
   - Not required for students to complete Lab 3; they can edit in Godot’s script editor.

### Lab 4 (AI Director) – Instructor only

- **API key:** Only the instructor (or one camp machine) should have an OpenAI API key.
- Set it via environment variable `OPENAI_API_KEY` or the config file `user://openai_config.cfg` (see main [README](../README.md)).
- Run Lab 4 as a **demo**: instructor drives, or one volunteer types pre-approved commands. Do not give students API keys or unrestricted access.

### Homework / take-home sheets

Each lab folder has an optional **HOMEWORK.md** (e.g. `labs/01-explore/HOMEWORK.md`). Tasks are short (5–10 min), work without a computer for the main part, and reinforce that lab’s idea. There is also **labs/TAKE_HOME.md** for an optional end-of-camp recap (explain two ways we changed the game, or try one thing in Godot at home). Hand out per lab or only at the end, as you prefer; no need to collect or grade.

### Suggested setup

- One computer per student or per pair.
- Project open in Godot and run once (F5) before Lab 1 to confirm no errors.
- For Lab 4: one machine with API key and game visible on a projector or shared screen.

---

## Lab-by-lab notes

### Lab 0: Setup (~15–20 min)

- **Goal:** Godot installed, project opens, game runs (F5).
- **Common issues:** Wrong Godot version (must be 4.x); opening the wrong file (must be `project.godot`, not a folder). If the game window is tiny, check **Project → Project Settings → Display → Window**.
- **Tip:** Do a quick “raise your hand when your game is running” check before moving on.

### Lab 1: Explore (~20–30 min)

- **Goal:** Play the game, try movement, combat, emotes, obstacles, character switch. No coding.
- **Discussion:** “What do you think had to be built to make the character move? What about the dances?” (Leads into: code for movement, artists/animators or AI for animations.)

### Lab 2: Tweak Physics (~25–35 min)

- **Goal:** Change `WALK_SPEED`, `JUMP_VELOCITY`, or `GRAVITY` in the Inspector and test.
- **Where:** Scene tree → **Player** node → Inspector → **Movement** group.
- **Common issues:** Editing the wrong node (must be **Player**); changing a different scene than the one that runs (main scene must be `scenes/main.tscn`). If values seem to have no effect, confirm they’re editing the Player in the main scene.
- **Discussion:** “Why use numbers in the Inspector instead of hardcoding them in the script?” (Easier to experiment, no code to write, same idea as variables in math.)

### Lab 3: Add a Key (~30–40 min)

- **Goal:** Add the **P** key so it does something (e.g. print a message or play an action).
- **Where:** `scripts/entities/player.gd` – add one case in the `match event.keycode:` block and one new function.
- **Common issues:** Typos (`KEY_P` not `Key_P`); forgetting to add the new function; not saving the script before running. If P does nothing, check the **Output** panel at the bottom of Godot for errors.
- **Differentiation:** Fast finishers can add a second key or make P do something fancier (e.g. play an emote). Provide a short copy-paste snippet if needed (see Lab 3 README).
- **Discussion:** “How do you think the other keys (F for punch, Tab for character) were added?” (Same pattern: key → function.)

### Lab 4: AI Director (~20–30 min)

- **Goal:** See how typing a sentence (e.g. “make the sky blue”) changes the game via an AI API.
- **Format:** Instructor-led demo. Use 3–5 pre-approved commands (e.g. change sky color, lower gravity). No student API keys.
- **Prep:** Ensure API key is set and game has UI/input for the AI Director (see main README). Test one command before the session.
- **Discussion:** “What did the AI need to understand? What did the game need to do with that?” (Language → meaning; game code that changes sky, physics, etc.)

---

## Timing and pacing

- **Half-day (3–4 hours):** Labs 0–3; skip or shorten Lab 4.
- **Full day (5–6 hours):** All labs including Lab 4, with short breaks and exploration time.
- If students finish a lab early, they can re-run the game, try more values (Lab 2), or add another key (Lab 3).

---

## Glossary and help

- Point students to [docs/GLOSSARY.md](../docs/GLOSSARY.md) for terms (scene, node, script, export, etc.).
- Main project docs: [README](../README.md), [PROJECT_ROADMAP.md](../PROJECT_ROADMAP.md).

---

## Safety and API use

- **No student API keys.** Only the instructor (or camp account) uses the OpenAI key for Lab 4.
- Keep Lab 4 commands simple and pre-approved to avoid unexpected behavior or cost.
- If you prefer not to use the internet during the camp, run only Labs 0–3; the game works fully offline except for the AI Director.
