# Code Review & Potential Bug Report

This document details identified bugs, missing constants, false assumptions, edge cases, and performance improvement opportunities in the **3D Snake GDScript** project.

## 🐛 Potential Bugs

### 1. Input Overwriting (Input Lag/Loss)
*   **File**: `scripts/core/SnakeHead.gd`
*   **Issue**: The `next_heading` variable only stores the *most recent* input. If a player performs a quick double-turn (e.g., "Right" then "Up") before the snake reaches the next grid boundary, the "Right" turn is completely discarded.
*   **Consequence**: The snake feels unresponsive or "skips" turns during fast gameplay.
*   **Fix**: Implement an input queue to store at least two pending turns.

### 2. Initial Segment Overlap
*   **File**: `scripts/core/SnakeHead.gd` -> `add_segment()`
*   **Issue**: In `_ready()`, `add_segment()` is called twice. The logic uses `segments.size() * GameConstants.SEGMENT_SPACING` to pick a history index. For the first segment, `size()` is 0, so it picks index 0 (the head's position).
*   **Consequence**: The first body segment spawns exactly inside the snake's head mesh, causing visual flickering (Z-fighting).
*   **Fix**: Offset the initial segment index to `(segments.size() + 1) * GameConstants.SEGMENT_SPACING`.

### 3. UFO Abduction Race Condition
*   **File**: `scripts/core/UFO.gd`
*   **Issue**: The UFO disconnects from the food's `tree_exited` signal *after* starting the abduction tween. If the snake eats the food in the exact same frame that the UFO starts its abduction, the `target_food` reference might become invalid or trigger double-free logic.
*   **Fix**: Check for `is_instance_valid(target_food)` immediately before and during the abduction sequence.

### 4. High-Speed Grid Skipping
*   **File**: `scripts/core/SnakeHead.gd` -> `move_forward()`
*   **Issue**: The grid boundary check `if grid_distance >= GameConstants.GRID_SIZE` assumes that `move_speed * delta` will not exceed `GRID_SIZE`. If speed is increased significantly, the snake could skip a grid intersection entirely.
*   **Fix**: Use a `while` loop or a more robust distance-remaining calculation to ensure every grid intersection triggers a turn check.

### 5. Persistent Data Growth
*   **File**: `scripts/core/ScoreManager.gd`
*   **Issue**: `submit_score()` appends every single game's score to the `high_scores` array and saves it to disk. There is no pruning mechanism.
*   **Consequence**: Over thousands of games, `highscores.json` will grow indefinitely, slowing down startup and saving.
*   **Fix**: Limit the `high_scores` array to the top 100 or 500 entries before saving.

---

## 💎 Common Values to be Constants

The following "magic numbers" should be moved to `scripts/core/GameConstants.gd`:

### `SnakeHead.gd`
*   `Vector3(0, 1.5, 0)`: Dazed particle spawn offset.
*   `Vector3(1.2, 0.8, 1.2)`: Squash and stretch scale values.
*   `0.1` and `0.2`: Eat animation tween durations.
*   `1.0`: Invulnerability timer default (different from `GameConstants.INVULNERABILITY_TIME` which is 0.5).

### `Food.gd`
*   `0.75`: Growth animation duration.
*   `10.0`: `OmniLight3D` range.
*   `3.0`: `OmniLight3D` energy.
*   `0.7` and `0.5`: Bobbing animation height offsets.
*   `5.0`: Jump height during relocation.
*   `0.25`: Jump animation duration.

---

## ❓ False Assumptions

1.  **Node Hierarchy**: `FoodSpawner.gd` and `UFO.gd` use `get_node("../SnakeHead")` or similar relative paths. This assumes the `SnakeHead` will always be a direct sibling in the `Main` scene. If the project is refactored to use a `GameWorld` sub-node, these will break.
2.  **Frame Rate Independence**: While movement is multiplied by `delta`, the input handling and turning are locked to grid boundaries. At extremely low FPS, the "snapping" logic might cause the snake to appear to teleport backwards to the grid center.
3.  **Physics Layers**: Logic assumes `layer_3` is always "walls" and `layer_4` is "foods". If these are changed in `project.godot` without updating scripts, the game will fail silently.

---

## 边缘 Case (Edge Cases)

1.  **The "Tail-Bite" Paradox**: If the snake is long enough to circle back and hit its own neck within the `INVULNERABILITY_TIME` (0.5s), it won't die. This is rare but possible at very high speeds.
2.  **UFO Staling**: If the UFO is approaching a food item and the snake eats it, the UFO enters `LEAVING` state. If another food spawns immediately in the same spot, the UFO does not re-target it.
3.  **Mega Food Speed**: If the player eats a Mega Food and dies before finishing it, the `speed_multiplier` might remain at `0.5` on the next run if not reset in `_ready()` (currently it is initialized to 1.0, so this is safe).

---

## ⚡ Performance Improvements

**Target Environment**: Fedora Laptop with Integrated Graphics.

1.  **Renderer Down-grade**: The project is currently using `Forward Plus`. For integrated graphics, switching to the **Mobile** or **Compatibility** renderer would significantly improve frame stability and reduce thermal throttling.
2.  **Light Optimization**: Every food item has an `OmniLight3D`. While only 1-2 items are usually on screen, these lights are dynamic. Using `OmniLight3D` with "Static" or "Baked" shadows (or no shadows) is essential.
3.  **Particle Count**: The `dazed_particles` and `whoosh` effects should use a fixed, low number of particles.
4.  **Mesh Complexity**: Ensure the photorealistic food scans in `assets/models/food/` have LODs (Level of Detail) or are low-poly enough for integrated GPUs. 1k textures are fine, but the vertex count should be monitored.
