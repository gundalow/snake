# Game Specification: 3D Snake

This document provides a detailed, programming language-agnostic specification for re-implementing the 3D Snake game.

## 1. Overview
The goal of the game is to control a snake in a 3D environment, eating food to grow longer and increase the score, while avoiding collisions with boundaries and the snake's own body.

## 2. Game World
- **Grid System**: The game operates on a 1.0-unit grid. Both the snake's movement and food placement are snapped to this grid.
- **Board**: A flat 3D plane (the garden) surrounded by boundaries (fences).
- **Coordinate System**:
  - **Ground Plane**: XZ plane (Y is up).
  - **Playable Area**: Centered at (0, 0, 0).
  - **Boundaries**: Walls are placed at a distance of approximately 15.5 units from the center.

## 3. Snake Mechanics
### 3.1 Movement
- **Constant Forward**: The snake always moves forward at a constant base speed.
- **Directional Control**: Four absolute directions: North, South, East, West.
  - North: Negative Z direction.
  - South: Positive Z direction.
  - East: Positive X direction.
  - West: Negative X direction.
- **Snap-Turning**: Direction changes are requested by the player but only applied when the snake head reaches a grid boundary (every 1.0 unit).
- **180-Degree Reversal Prevention**: The snake cannot immediately turn 180 degrees (e.g., if moving North, a South input is ignored).

### 3.2 Growth and Body Segments
- **History-Following System**: The snake's body consists of segments that follow the exact path taken by the head.
  - The head records its global transform (position and rotation) into a high-resolution history buffer every 0.1 units traveled.
  - Each body segment is placed at a specific index in this history (e.g., every 10 history entries, which corresponds to 1.0 unit of distance).
- **Adding Segments**: Eating food adds a new segment to the tail.

### 3.3 Speed Progression
- **Initial Speed**: The snake starts at a base move speed (e.g., 5.0 units/sec).
- **Incremental Increase**: Every time food is eaten, the base move speed increases by a small amount (e.g., 0.2 units/sec).

## 4. Gameplay Features
### 4.1 Food and Items
- **Normal Food**:
  - Spawns at a random valid grid position (not overlapping with the snake).
  - Types: Apple, Lychee, Sweet Potato.
  - Effect: Increases score by 1, adds 1 segment, and increases speed.
- **Mega-Melon**:
  - Spawns every 5th food item.
  - **Multi-Bite**: Requires 3 bites to be fully consumed. Each bite adds a segment and increases score.
  - **Scale Progression**: The model scales down after each bite (Initial -> Mid -> Min).
  - **Slow-Down Effect**: While the snake is in the process of eating a Mega-Melon (from the first to the last bite), its movement speed is reduced by 50%.
  - **Burp Delay**: After the final bite, there is a 0.5-second delay followed by a "burp" sound before the snake's speed returns to normal and the next food item spawns.

### 4.2 Hazards and Events
- **Galactic Greed (UFO)**:
  - Appears randomly (e.g., every 30 seconds).
  - Targets the current food item on the board.
  - Approaches the food, activates a tractor beam, and abducts the food.
  - **Penalty**: If the UFO successfully steals the food, the player's score is decreased by 5 points.
- **Tectonic Tussle (World-Stomper)**:
  - A giant foot appears outside the fence every 30 seconds.
  - **Stomp Event**: A shadow appears, followed by the foot stomping the ground.
  - **Effect**: Causes a screen shake and relocates all active food items to new random valid positions on the grid.

### 4.3 Death Conditions
- **Wall Collision**: The game ends if the snake's head collides with the boundary fences.
- **Self-Collision**: The game ends if the snake's head collides with any of its own body segments.
- **Invulnerability**: The snake has a short window of invulnerability (e.g., 0.5 seconds) at the start or after certain events to prevent immediate self-collision.

## 5. Meta-Systems
### 5.1 Achievement System
- **Milestones**: Achievements are triggered based on total score (e.g., every 10 points) or specific food counts (e.g., eating 10, 20, 30, or 50 apples).
- **Juice**: Achievements are displayed with bouncy UI animations and accompanied by fruit or snake-themed puns.

### 5.2 Leaderboard and Persistence
- **Name Selection**: Players can enter a name or select from a list of previous names at the start of the game.
- **Data Storage**: High scores and unique player names are stored persistently in a JSON file.
- **Leaderboard Display**: The top 10 scores are displayed on the game over screen.

## 6. Technical Constants
| Constant | Value | Description |
| :--- | :--- | :--- |
| `HISTORY_RESOLUTION` | 0.1 | Distance between recorded path points. |
| `SEGMENT_SPACING` | 10 | Number of history points between segments. |
| `GRID_SIZE` | 1.0 | Logical grid unit for snapping and turning. |
| `INITIAL_MOVE_SPEED` | 5.0 | Starting units per second. |
| `SPEED_INCREMENT` | 0.2 | Speed increase per food item. |
| `INVULNERABILITY_TIME`| 0.5s | Initial grace period for self-collision. |
| `BOARD_SIZE` | 28.0 | Width/Length of the playable area. |
| `WALL_DISTANCE` | 15.5 | Distance from center to boundary. |
| `UFO_SPAWN_INTERVAL` | 30.0s | Time between UFO appearances. |
| `UFO_SPEED` | 10.0 | Movement speed of the UFO. |
| `UFO_SCORE_PENALTY` | 5 | Points lost when food is stolen. |
| `MEGA_FOOD_BITES` | 3 | Bites required to finish a Mega-Melon. |
| `MEGA_FOOD_SPEED_MULT`| 0.5 | Speed multiplier while eating Mega-Melon. |

## 7. Assets
### 7.1 3D Models (GLTF/GLB)
- **Snake**: Head and Segment models.
- **Food**: `apple`, `lychee`, `sweet_potato`, `mega_melon`.
- **Environment**: Garden fence, grass plane.
- **Effects**: UFO, World-Stomper foot, Dazed particles.

### 7.2 Audio Assets
- **UI**: Name selection, buttons.
- **Gameplay**:
  - `assets/audio/whoosh.wav`: Food spawning.
  - `assets/sounds/foods/apple.ogg`: Eating normal food.
  - `assets/sounds/foods/mega_melon/chew.ogg`: Eating Mega-Melon.
  - `assets/sounds/foods/mega_burps/burp1...3.ogg`: Finishing Mega-Melon (randomized).
  - `assets/sounds/stomper/impact.wav`: World-Stomper impact. (Example path)
  - `assets/sounds/ufo/tractor_beam.wav`: UFO abduction. (Example path)
  - `assets/sounds/game_over.wav`: Death sound. (Example path)

## 8. Input Mapping
- **move_up**: `W` or `Up Arrow`
- **move_down**: `S` or `Down Arrow`
- **move_left**: `A` or `Left Arrow`
- **move_right**: `D` or `Right Arrow`
- **restart**: `R`
- **pause**: `P`
- **quit**: `Escape`
