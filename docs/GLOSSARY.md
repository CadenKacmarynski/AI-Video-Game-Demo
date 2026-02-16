# Glossary

Short definitions for terms you’ll see in the labs and in Godot. If a word isn’t here, ask your instructor or look it up in the [Godot documentation](https://docs.godotengine.org/).

**API** – A way for one program (or service) to talk to another. The game talks to the OpenAI API by sending your text and receiving back instructions.

**Export** – In Godot, a variable marked with `@export` shows up in the **Inspector**. That lets you change its value without editing the script. The movement variables (Walk Speed, Jump Velocity, etc.) are exported.

**Function** – A named block of code that runs when something calls it. For example, `_on_lab_key_pressed()` is a function that runs when you press P.

**Godot** – The game engine used in this project. It’s free and open source.

**Inspector** – The panel on the right in Godot that shows properties of the node you selected (e.g. Player’s speed, jump height). You can edit numbers and options there.

**Node** – A single piece of the game (a character, a light, a camera, etc.). The game is built as a tree of nodes. The **Player** node is the character you control.

**Scene** – A file (`.tscn`) that contains a tree of nodes. The main scene is the whole level/world that runs when you press Play.

**Script** – Code (in this project, written in GDScript) that controls how a node behaves. `player.gd` is the script that controls the Player node.

**Variable** – A named value the script uses (e.g. walk speed, gravity). Variables can be numbers, text, or other data. Changing a variable changes how the game behaves.
