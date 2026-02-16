# AI Video Game Demo

A Godot 4.5 demo showcasing AI in game development: AI-generated 3D assets from Mixamo/Tripo3D, live AI-assisted coding with hot-reload, and runtime gameplay control via OpenAI API. Features character controller, animations, combat system, and natural language game modifications.

## Overview

This project demonstrates how AI can transform game development through three progressive phases:

1. **Creation** - AI-generated 3D models, textures, and animations
2. **Coding** - Live AI-assisted programming with hot-reload capabilities
3. **Intelligence** - Runtime AI control that modifies gameplay via natural language

## Software & Tools Used

### Game Development
- **Game Engine**: [Godot 4.5](https://godotengine.org/)
- **Code Editor**: [Cursor](https://cursor.sh/)

### AI Asset Creation
- **Image Generation**: Google Gemini (Nano Banana Pro model)
- **3D Modeling**: [Replicate](https://replicate.com/) (Hyper3D/Rodin model)
- **Animation & Rigging**: [Mixamo](https://www.mixamo.com/)

## Features

- Third-person character controller with WASD movement
- Multiple playable characters with full animation sets
- Combat actions (punch, dodge, block, headbutt)
- Emote system with dance animations
- Interactive obstacles (moving platforms, bounce pads, rotating hazards)
- Emote wheel UI for quick gesture selection
- Optional OpenAI integration for dynamic gameplay modifications

## Getting Started

### Prerequisites

1. **Godot 4.5 or later**
   - Download from [godotengine.org](https://godotengine.org/download)
   - No installation required - just extract and run

2. **Git** (for cloning the repository)
   - Download from [git-scm.com](https://git-scm.com/)

3. **OpenAI API Key** (Optional - only needed for Phase 3 AI features)
   - Sign up at [platform.openai.com](https://platform.openai.com/)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/CadenKacmarynski/AI-Video-Game-Demo.git
   cd AI-Video-Game-Demo
   ```

2. **Open the project in Godot**
   - Launch Godot
   - Click "Import"
   - Navigate to the cloned folder
   - Select the `project.godot` file
   - Click "Import & Edit"

3. **Run the game**
   - Press `F5` or click the "Play" button in the top-right corner
   - The game will launch in a 1280x720 window

### Optional: Enable OpenAI Features

To use the AI Director (Phase 3 features):

1. **Set up your API key** (choose one method):

   **Option A: Environment Variable**
   ```bash
   # Windows (PowerShell)
   $env:OPENAI_API_KEY="your-api-key-here"

   # macOS/Linux
   export OPENAI_API_KEY="your-api-key-here"
   ```

   **Option B: Config File**
   - Create a file at `user://openai_config.cfg` (in Godot's user data folder)
   - Add the following:
     ```ini
     [api]
     key=your-api-key-here
     ```

2. **Test the AI Director**
   - Run the game
   - Use the in-game text input to send commands like:
     - "Make gravity lower"
     - "Change the sky to purple"
     - "Spawn a robot"

## Controls

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
| F | Punch |
| G | Boxing |
| H | Block |
| V | Dodge |
| R | Headbutt |
| Q | Backflip |
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
| B | Open Emote Wheel (hold) |

## Project Structure

```
res://
├── assets/
│   ├── animations/      # FBX animation files from Mixamo
│   ├── characters/      # 3D character models
│   └── materials/       # Textures and materials
├── scenes/
│   ├── main.tscn        # Main game scene
│   ├── player.tscn      # Player controller
│   └── ui/              # UI components
├── scripts/
│   ├── entities/        # Player and character scripts
│   ├── obstacles/       # Interactive object scripts
│   └── ui/              # UI scripts
├── autoloads/
│   └── game_director.gd # OpenAI API integration
└── docs/                # Additional documentation
```

## STEM Camp Labs

This repo includes a **lab series for middle-school STEM camps**. Students install Godot, explore the game, tweak physics in the Inspector, add a key in code, and (instructor-led) see the AI Director change the game from natural language.

- **[Labs overview](labs/README.md)** – Lab order, time estimates, and what you need
- **[Instructor guide](labs/INSTRUCTOR.md)** – Setup, timing, pitfalls, and discussion prompts
- **[Glossary](docs/GLOSSARY.md)** – Age-appropriate definitions for scene, node, script, export, etc.

## Documentation

- [Character Animation Guide](docs/CHARACTER_ANIMATION_GUIDE.md) - How to add new characters and animations
- [Project Specifications](PROJECT_SPECS.md) - Technical requirements and architecture
- [Project Roadmap](PROJECT_ROADMAP.md) - Development phases and implementation plan
- [Next Steps Plan](docs/NEXT_STEPS_PLAN.md) - Future features and improvements

## How It Was Built

This project showcases AI-assisted game development:

1. **Character Design**: Concept art generated with Google Gemini
2. **3D Modeling**: 2D images converted to 3D models using Replicate's Hyper3D/Rodin
3. **Rigging**: Characters auto-rigged with Mixamo
4. **Animations**: Downloaded from Mixamo's animation library
5. **Code**: Written with AI assistance using Cursor
6. **Game Logic**: Optionally controlled by OpenAI API at runtime

## Troubleshooting

### Game Won't Launch
- Ensure you're using Godot 4.5 or later
- Check that `scenes/main.tscn` is set as the main scene

### Character Not Visible
- Character scale might be too small - check the Inspector
- Ensure textures are in the same folder as the FBX files

### Animations Not Playing
- Verify FBX files are in `assets/animations/`
- Check that animation slots are populated in the Player Inspector

### OpenAI Features Not Working
- Verify your API key is set correctly
- Check the console for error messages
- Ensure you have internet connectivity

## License

This project is open source. Feel free to use, modify, and learn from it.

## Contributing

Contributions are welcome! Feel free to:
- Add new characters or animations
- Improve the AI Director functionality
- Add new gameplay features
- Fix bugs or improve documentation

## Acknowledgments

- **Godot Engine** - Open-source game engine
- **Mixamo** - Character rigging and animations
- **OpenAI** - AI-powered game control
- **Replicate** - 3D model generation
- **Google Gemini** - Image generation

---

**Note**: This is a demonstration project showcasing AI tools in game development. It's intended for educational purposes and as a starting point for your own AI-powered games.
