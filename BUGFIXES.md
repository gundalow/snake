# Code Review & Bug Report

This document details the findings from a full code review of the 3D Snake project.

## 🐛 Potential Bugs

### 1. Input Overwriting (Input Lag)
**Location:** `scripts/core/SnakeHead.gd` -> `handle_input()`
**Description:** The current system only stores a single `next_heading`. If a player performs two quick turns (e.g., "Right" then "Up") within one grid cell, the "Right" input is overwritten and lost. The snake will only register the "Up" turn, making the controls feel unresponsive at high speeds or for skilled players.
**Recommended Fix:** Implement an input queue to store multiple pending turns.

### 2. UFO & Mega Food Softlock
**Location:** `scripts/core/SnakeHead.gd` and `scripts/core/UFO.gd`
**Description:** When eating a Mega Food, the snake's `speed_multiplier` is set to 0.5. This multiplier is only reset to 1.0 when the `fully_eaten` signal is emitted. If a UFO steals the Mega Food while the snake is in the middle of eating it (after at least one bite), the `fully_eaten` signal is emitted by the UFO's abduction logic, but the `SnakeHead` might not be correctly notified to reset the speed if the connection was only to the specific food instance that was just freed. More critically, if the snake is slowed and the food vanishes, there's a risk the state doesn't reset.
**Recommended Fix:** Ensure `SnakeHead` resets `speed_multiplier` whenever a food item it was eating is destroyed or stolen.

### 3. Destructive Model Centering
**Location:** `scripts/core/Food.gd` -> `_reset_all_node_positions()`
**Description:** This function recursively sets `node.position = Vector3.ZERO` for all children of a loaded model. This assumes all parts of a 3D model should be centered at the origin. If a model (like the Apple or Lychee) consists of multiple offset parts (stems, leaves, etc.), this logic will collapse all parts into the center, effectively breaking the model's visual structure.
**Recommended Fix:** Center the root node only, or use the model's bounding box to calculate a center offset without zeroing out internal relative transforms.

### 4. Frame-Rate Dependent History Recording
**Location:** `scripts/core/SnakeHead.gd` -> `move_forward()`
**Description:** Position history is recorded based on `distance_traveled` in `_process`. If the frame rate drops significantly and `distance_traveled` exceeds `HISTORY_RESOLUTION` by a large margin (e.g., 2x or 3x), only one history entry is added for that frame. This causes the snake's body segments to "stretch" or skip parts of the path during lag spikes.
**Recommended Fix:** Use a `while` loop to catch up on history entries if `distance_traveled` is much larger than `HISTORY_RESOLUTION`.

### 5. Death Ray Precision
**Location:** `scenes/main/SnakeHead.tscn` -> `DeathRay`
**Description:** The `DeathRay` has a `target_position` of `(0, 0, -0.6)`. Since the head is a `1.0` unit cube and the ray starts at the center, it only extends `0.1` units beyond the front face. At high speeds (e.g., 10+ units/sec), the snake could potentially move more than `0.1` units in a single frame, passing through a wall's collision boundary before the raycast triggers.
**Recommended Fix:** Increase the ray length or use a `Shapecast3D` for more robust collision detection.

---

## 🔢 Constants to be Defined

The following values are hardcoded and should be moved to `GameConstants.gd`:

*   **Audio Bus Names:** The string `&"SFX"` is used in `Food.gd`.
*   **Animation Durations:** `0.75` (growth), `1.0` (bobbing), and `0.25` (jump) in `Food.gd`.
*   **UI Thresholds:** `0.01` for shake intensity decay in `CameraShake.gd`.
*   **Default Altitudes:** UFO flight height `5.0` is used as a default in `UFO.gd` despite being in constants.
*   **Collision Layers:** Physics layers are referenced by integers in some scenes/scripts instead of using the named layer constants.

---

## ❓ False Assumptions

1.  **Grid Alignment:** The code assumes the grid is always aligned to global `0.0` coordinates. If the board is moved, the `snapped()` logic in `move_forward` will fail to align the snake correctly with the environment.
2.  **Y-Axis Consistency:** Many scripts assume the floor is exactly at `Y=0` and items should be at `Y=0.5`. This makes the game fragile if verticality is added or if the environment meshes are changed.
3.  **Single Food Item:** `FoodSpawner.gd` assumes only one food item exists at a time for its `_on_food_fully_eaten` logic. While `relocate_all_food` handles multiple, the core spawn loop is strictly linear.

---

## ⚠️ Edge Cases

1.  **Zero Score Highscore:** `ScoreManager.gd` returns `false` for `is_new_high_score` if the score is `0`. This prevents a player's first run from being recorded if they die immediately, which might be confusing.
2.  **Rapid Speed Boosts:** If `base_move_speed` becomes extremely high, `grid_distance` could exceed `GameConstants.GRID_SIZE` by more than double in one frame. The current logic only subtracts `GRID_SIZE` once, leading to a permanent desync from the grid.
3.  **UFO Target Loss:** If a UFO is hunting a food item and the player eats it first, the UFO enters a "Leaving" state. However, if a new food spawns immediately in the same spot (unlikely but possible), the UFO's state machine might behave unexpectedly.

---

## 🚀 Performance Improvements
*Target: Fedora Laptop with Integrated Graphics*

1.  **Circular Buffer for History:** `position_history.insert(0, ...)` is an `O(n)` operation. As the snake grows very long, shifting thousands of elements every `0.1` units of movement will cause CPU spikes. Use a fixed-size circular buffer (Array with a pointer).
2.  **Shadow Optimization:** The `DirectionalLight3D` has shadows enabled. On integrated graphics, reducing shadow resolution or using `Shadow Atlas` settings in the Project Settings is critical.
3.  **Particle Systems:** `GPUParticles3D` are used for the dazed effect. While visually superior, `CPUParticles3D` are significantly lighter for integrated Intel/AMD graphics.
4.  **Collision Masking:** Ensure `MouthArea` and `HeadArea` have their `collision_mask` strictly limited to exactly what they need to detect to minimize broad-phase physics calculations.
5.  **Forward Plus vs. Compatibility:** `Forward Plus` is the most demanding renderer in Godot 4. For a laptop with integrated graphics, the `Mobile` (Vulkan) or `Compatibility` (OpenGL) renderers would provide a much more stable framerate.
