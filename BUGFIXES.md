# Code Review & Bug Report: 3D Snake GDScript

This document details potential bugs, performance concerns, and architectural improvements identified during a full code review.

## 🐛 Potential Bugs

### 1. Input Overwriting (Input Buffering)
*   **File**: `scripts/core/SnakeHead.gd`
*   **Issue**: The `next_heading` variable only stores the most recent input. If a player presses "Right" and then "Up" within the same grid cell, the "Right" turn is completely lost.
*   **Impact**: Controls feel "dropped" or unresponsive during high-speed gameplay where precision turns are required in quick succession.
*   **Fix**: Implement an input queue (Array) to store pending turns and process them one-by-one at each grid boundary.

### 2. Collision Detection "Tunneling"
*   **File**: `scenes/main/SnakeHead.tscn` (DeathRay), `scripts/core/SnakeHead.gd`
*   **Issue**: The `DeathRay` length is 0.6 units. With a head radius of 0.5, the ray only checks 0.1 units ahead.
*   **Impact**: At speeds > 6.0 units/sec (standard 60 FPS), the head can "tunnel" into a wall before the raycast reports a collision. As speed increases via `SPEED_INCREMENT`, this becomes a guaranteed failure state.
*   **Fix**: Dynamically scale the `DeathRay` length based on the current `move_speed`.

### 3. Mega Food "Insta-Munch"
*   **File**: `scripts/core/SnakeHead.gd` (`_on_mouth_area_entered`)
*   **Issue**: Collision detection for eating doesn't have a debounce or timer.
*   **Impact**: The snake consumes all 3 "bites" of a Mega Food in 3 consecutive frames (approx. 0.05s). This negates the gameplay intent of the snake being slowed down while "struggling" to eat the giant fruit.
*   **Fix**: Add a small `bite_cooldown` or require the snake to exit and re-enter the area.

### 4. UFO vs. WorldStomper Race Condition
*   **Files**: `scripts/core/UFO.gd`, `scripts/core/Food.gd`
*   **Issue**: Both the UFO abduction logic and the WorldStomper relocation logic use `create_tween()` on the same `global_position` property of the food.
*   **Impact**: If an earthquake happens during an abduction, the food will jitter between the UFO and its new random location.
*   **Fix**: Check `is_abducting` state in `Food.gd` before allowing a `jump_to` relocation.

## 🧱 Constants & Magic Numbers

### 1. Hardcoded UI Timings
*   **File**: `scripts/ui/HUD.gd`
*   **Issue**: Durations for score pops (0.1s), achievement fades (0.5s), and intervals (2.0s) are hardcoded.
*   **Suggestion**: Move these to `GameConstants.gd`.

### 2. Model Centering Assumption
*   **File**: `scripts/core/Food.gd` (`_reset_all_node_positions`)
*   **Issue**: Recursively sets all sub-node positions to `Vector3.ZERO`.
*   **Impact**: This will break any 3D model that isn't a single combined mesh.
*   **Fix**: Only center the root MeshInstance or use the model's AABB.

### 3. Coordinate Snapping
*   **File**: `scripts/core/FoodSpawner.gd`
*   **Issue**: Uses `snapped(..., 1.0)` instead of `GameConstants.GRID_SIZE`.
*   **Impact**: If the grid size is ever changed in constants, food will spawn off-grid.

## 🧐 False Assumptions

### 1. Invulnerability Window
*   **File**: `scripts/core/SnakeHead.gd`
*   **Assumption**: 0.5 seconds is always enough time for the head to clear its starting position.
*   **Risk**: If speed is lowered, the snake might die instantly on spawn.

### 2. Unbounded JSON Storage
*   **File**: `scripts/core/ScoreManager.gd`
*   **Assumption**: The local `highscores.json` can grow indefinitely without impact.
*   **Impact**: Potential stutters on the "Game Over" screen as it writes an increasingly large JSON string.

## ⚠️ Edge Cases

### 1. Rapid Death & UI Focus
*   **Issue**: If the snake dies while the Name Prompt is still active or just closing, the `is_alive` check might prevent game over logic, but the UI might get stuck in an inconsistent state.
*   **Fix**: Ensure `game_over` signal handling in `Main.gd` accounts for game state transitions.

### 2. UFO Abduction of "Eaten" Food
*   **Issue**: There is a 0.5s delay in `UFOManager.gd` before `spawn_ufo` is called. If the snake eats the food during this 0.5s window, `spawn_ufo` receives a reference to a node that is about to be `queue_free()`'d.
*   **Impact**: Potential "null instance" errors in `UFO.gd`.
*   **Fix**: Use `is_instance_valid(food)` checks (partially implemented) and handle `tree_exited` gracefully.

### 3. Empty Player Name
*   **File**: `scripts/ui/NamePrompt.gd`
*   **Issue**: If a player enters an empty string or just spaces, the game proceeds.
*   **Impact**: High score board shows entries with no names.

## 🏎 Performance Improvements

### 1. Rendering Backend (Forward Plus)
*   **Hardware**: Fedora Laptop with Integrated Graphics.
*   **Concern**: `Forward Plus` is optimized for high-end GPUs.
*   **Suggestion**: Switch to `GL Compatibility` or `Mobile` renderer.

### 2. OmniLight3D Overuse
*   **File**: `scripts/core/Food.gd`
*   **Concern**: Every food item spawns an `OmniLight3D`.
*   **Suggestion**: Limit the number of concurrent lights or disable shadows for food lights.

### 3. History Buffer Insertion
*   **File**: `scripts/core/SnakeHead.gd`
*   **Concern**: `position_history.insert(0, visual_transform)` is O(n). As the snake gets very long (e.g., 100 segments * 10 history points = 1000 entries), this becomes expensive to run every 0.1 units of movement.
*   **Suggestion**: Use a `CircularBuffer` or `Array` with a fixed size and a pointer to the "head" index.
