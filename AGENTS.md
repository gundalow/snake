# AGENTS.md

This document provides essential instructions and guidelines for AI Agents (Google Jules, Google Gemini, Google Gemini CLI, etc.) working on the **Python 2D Snake** project.

## 🎯 Target Audience
This file is primarily for AI Agents to ensure efficient, consistent, and high-quality contributions to the codebase.

**Target Operating Systems**: Linux (Fedora, Debian-based).

## 🚀 Efficient Development & Testing

To minimize token usage and maximize speed, follow these testing procedures:

### 1. Local Validation
Always run the unit tests before submitting any changes.

```bash
python3 python_snake/tests/test_game.py
```

### 2. Linting
Use `ruff` or `flake8` if available in the environment to ensure Python style standards.

## 📂 Directory Structure

| Path | Description |
| :--- | :--- |
| `assets/` | Raw assets including sound effects and music. |
| `python_snake/` | Root of the Python project. |
| `python_snake/core/` | Core logic: `snake.py`, `food.py`, `events.py`. |
| `python_snake/ui/` | UI components: `hud.py`. |
| `python_snake/utils/` | Utilities: `constants.py`, `score_manager.py`, `audio_manager.py`. |
| `python_snake/tests/` | Unit tests. |
| `requirements.txt` | Python dependencies. |

## 🎮 Pygame Best Practices

### Movement
- **Delta Time:** Always multiply movement vectors by `delta_time` (seconds) to ensure frame-rate independent physics.
- **History Buffer:** Use the `Snake.position_history` to allow segments to follow the path of the head smoothly.

### UI & UX
- Use `pygame.font` for text rendering.
- Implement "juice" via procedural animations (scaling, bouncing) using `math.sin` and time-based interpolation.

### Audio
- Use `pygame.mixer` for sound. Handle missing assets gracefully to prevent crashes in CI environments.

## 🛠 Workflow Guidelines
1. **Always Verify**: Run tests after *any* change to the codebase.
2. **Token Efficiency**: Focus on reading only the files necessary for the current task.
