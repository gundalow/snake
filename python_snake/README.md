# Python 2D Snake

A 2D re-implementation of the Godot 3D Snake game using Pygame.

## Features
- **Classic Snake Gameplay:** Grid-based movement with 90-degree snap turning.
- **Dynamic Segment History:** Body segments follow the exact path of the head.
- **Special Food Types:**
  - Apples, Lychees, Sweet Potatoes.
  - **Mega-Melon:** Requires 3 bites to consume, slows down the snake during consumption.
- **Random Events (30-50s intervals):**
  - **UFO:** Appears and attempts to abduct a fruit. If successful, points are penalized.
  - **World Stomper:** A giant foot that stomps the board, causing screen shake and relocating all food items.
- **Persistent Leaderboard:** High scores and player names are saved to `highscores.json`.
- **Juicy Visuals:**
  - Cartoon-style graphics with scale-pop animations.
  - "Dazed" stars upon death.
  - "Hinged Jaw" animation when near food.
  - "New High Score" celebration with confetti.
- **Audio:** Full sound effects for eating, spawning, burping, and event transitions.
- **HUD:** Real-time score, player name, and achievement pop-ups with puns.

## Controls
- **WASD / Arrow Keys:** Move Snake
- **P:** Pause
- **R:** Restart
- **Esc / Q:** Quit
- **Enter (on Name Screen):** Confirm Name
- **Up/Down (on Name Screen):** Select previous names

## Requirements
- Python 3.12+
- Pygame

## How to Run
```bash
pip install pygame
python python_snake/main.py
```
