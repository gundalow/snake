# Python 2D Snake: Feature Overview

This document provides a detailed breakdown of the functionality and mechanics implemented in the Python re-implementation of the Snake game.

## 🐍 Core Gameplay Mechanics
- **Grid-Based Movement:** The snake moves on a strict 30x30 unit grid. Movement is constant, and the snake never stops until it hits a wall or itself.
- **Snap Turning:** Controls (WASD/Arrows) trigger 90-degree turns that are snapped to the grid boundaries. 180-degree reversals are automatically rejected.
- **History-Based Segments:** The body segments follow the head using a high-resolution history buffer. This ensures the tail follows the exact path of the head, including curves, rather than cutting corners.
- **Progressive Speed:** Every food item eaten increases the `base_move_speed` of the snake, making the game progressively more challenging.

## 🍎 Dynamic Food System
- **Standard Food:** Spawns randomly on the grid.
    - **Apple:** Classic red fruit.
    - **Lychee:** Pink tropical fruit.
    - **Sweet Potato:** Purple root vegetable.
- **Mega-Melon (Special):** Spawns every 5th food item.
    - **Multi-Bite Logic:** Requires 3 individual bites to fully consume.
    - **Bite Cooldown:** A 0.5s delay is enforced between bites to prevent instant consumption.
    - **Speed Reduction:** While the Mega-Melon is being eaten (from the first bite to the last), the snake's speed is reduced by 50%.
    - **The Burp:** Upon finishing the final bite, a 0.5s delay occurs before the snake lets out a massive "BURP!" sound and returns to normal speed.

## 🛸 Environmental Events
One random event triggers every 30-50 seconds to keep the gameplay dynamic.
- **UFO Abduction:**
    - A UFO flies onto the board and targets a specific food item.
    - It uses a tractor beam to abduct the fruit.
    - If successful, the player's score is penalized by 5 points, and the score display flashes red.
    - The UFO exits the board in a stylized zig-zag pattern.
- **World Stomper (Earthquake):**
    - A giant shadow appears on the board as a warning.
    - A massive cartoon foot stomps down, causing an intense screen shake.
    - The impact causes all active food items to "jump" to new random locations on the grid.

## 🏆 UI and Persistence
- **Name Entry System:** On startup, players can enter a new name or use arrow keys to select from a history of previous names.
- **Persistent Leaderboard:** Scores and names are saved to a local `highscores.json` file. The top 10 scores are displayed on the Game Over screen.
- **Achievement System:**
    - Real-time pop-ups for milestones (every 10 points).
    - Includes a library of snake and fruit puns (e.g., "Sssss-pectacular!", "You're one in a melon!").
    - Special milestones for apple consumption (10, 20, 30, 50 apples).
- **Juicy Feedback:**
    - **Scale-Pops:** The head and food items have elastic scale animations when spawning or being eaten.
    - **Dazed Stars:** Circling stars appear above the head when the snake dies.
    - **Celebration:** A "NEW HIGH SCORE!" banner with animated confetti appears when a personal record is broken.

## 🔊 Audio and Visual Polish
- **Sound Manager:** Handles all game audio, including eat sounds, mega-chews, burps, whooshes, and impact shakes.
- **Cartoon Aesthetics:** Primitive-based graphics with rounded corners and high-contrast colors, optimized for performance on laptops with integrated graphics.
- **Screen Shake:** Smooth camera vibration logic used during World Stomper events.
