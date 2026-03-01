# AGENTS.md

This document provides essential instructions and guidelines for AI Agents (Google Jules, Google Gemini, Google Gemini CLI, etc.) working on the **3D Snake GDScript** project.

## 🎯 Target Audience
This file is primarily for AI Agents to ensure efficient, consistent, and high-quality contributions to the codebase.

**Target Operating Systems**: Linux (Fedora, Debian-based).

## 🚀 Efficient Development & Testing

To minimize token usage and maximize speed, follow these testing procedures:

### 1. Local Validation (`validate.py`)
Always run the validation script before submitting any changes. It performs headless checks for:
- Required file existence.
- **Linting** (via `gdlint` if available).
- Input Map configurations.
- Physics layer names.
- Missing external resources in `.tscn` files.
- GDScript syntax errors.
- Basic runtime execution (20 frames) to catch common crashes.

```bash
python3 validate.py
```

### 2. Linting (`gdlint`)
Use `gdlint` (if available in the environment) to ensure GDScript follows style standards.
*Note: If `gdlint` is not in the PATH, prioritize the syntax checks in `validate.py`.*

### 3. Quick Iteration (`run.sh`)
Use `run.sh` to refresh the Godot cache and launch the game for manual verification if needed.

```bash
./run.sh
```

## 📂 Directory Structure

| Path | Description |
| :--- | :--- |
| `assets/` | Raw assets including 3D models and textures. |
| `assets/models/food/` | Photorealistic 3D scans of food items (Apple, Lychee, etc.). |
| `scenes/` | Godot scene files (`.tscn`). |
| `scenes/main/` | Core game scenes: `main.tscn`, `SnakeHead.tscn`, `Food.tscn`, `SnakeSegment.tscn`. |
| `scenes/ui/` | UI-related scenes: `hud.tscn`. |
| `scenes/effects/` | Visual effects: `dazed_particles.tscn`. |
| `scripts/` | GDScript source files. |
| `scripts/core/` | Principal game logic: `SnakeHead.gd`, `Main.gd`, `FoodSpawner.gd`, `CameraManager.gd`. |
| `scripts/utils/` | Utility scripts: `FPSCounter.gd`. |
| `tools/` | **Subdirectory for AI Tools**: Store task-specific debug or helper scripts here. Use one subdirectory per task (e.g., `tools/mesh_fixer/`). |
| `project.godot` | Main Godot project configuration. |
| `validate.py` | Primary validation script for AI agents. |
| `run.sh` | Bash script to clear cache and run the project. |
| `PROJECT_PLAN.md` | Roadmap and milestones. |

## 🎮 Godot 3D Best Practices

### Collision Detection
- **RayCast3D**: Use for high-speed or critical "lethal" checks (e.g., `DeathRay` in `SnakeHead.gd`). This prevents "tunneling" or side-collisions during 90-degree snap turns.
- **Area3D**: Use for non-physics-based triggers like eating food or entering zones.
- **Layers & Masks**: Always use named physics layers (see `project.godot`). Ensure `collision_layer` and `collision_mask` are correctly assigned to avoid unnecessary collision checks.

### Scene Organization
- Keep logic in `.gd` scripts and visuals/structure in `.tscn` files.
- Use `unique_name_in_owner` (%) for accessing key nodes in scripts to make them resilient to hierarchy changes.
- Prefer `instantiate()` over `duplicate()` for spawning objects like segments or food.

### Performance
- **Asset Preloading**: Always use `preload()` for models (`.gltf`, `.tscn`) and audio files (`.mp3`, `.ogg`, `.wav`) at the top of scripts or in a central Autoload (e.g., `GameConstants.gd`). Avoid using `load()` during gameplay (e.g., inside `_on_area_entered`), as it causes noticeable frame stutters.
- **Signal Emission**: For signals that trigger heavy logic (like `spawn_food()`), use `emit.call_deferred()` to ensure the current frame logic completes without synchronous blocking.
- **Particles**: For visual effects, use `GPUParticles3D` for better performance on modern hardware.
- **Forward Plus**: Use the `Forward Plus` renderer for high-quality visuals on supported hardware.

## 🛠 Workflow Guidelines
1. **Always Verify**: Run `python3 validate.py` after *any* change to the codebase.
2. **Task Tools**: If you need to perform a complex automated task (e.g., batch-updating materials), create a Python script in `tools/<task_name>/`.
3. **Token Efficiency**: Focus on reading only the files necessary for the current task. Use `list_files` to locate assets before attempting to read or modify them.
