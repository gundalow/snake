# Code Review & Potential Bug Report

This document outlines potential bugs, architectural improvements, and performance considerations identified during a full code review.

## 🔴 Potential Bugs

### 1. Input Overwriting (Input Lag/Dropped Turns)
*   **Location:** `SnakeHead.gd` -> `handle_input()`
*   **Issue:** The `next_heading` system only stores the *last* key pressed before the next grid boundary. If a player presses "Right" and then "Up" very quickly (high APM), the "Right" turn is discarded, and the snake will only attempt the "Up" turn when it hits the grid.
*   **Impact:** Controls feel unresponsive or "slippery" during fast gameplay.
*   **Fix:** Implement an Input Buffer (Array) to store a queue of pending turns.

### 2. Collision Ray Precision (Tunneling)
*   **Location:** `SnakeHead.gd` -> `death_ray`
*   **Issue:** The `DeathRay` length is set to `0.6`. Since the head mesh is `1.0` units wide (0.5 radius), the ray only projects `0.1` units ahead of the collision volume. At high movement speeds or low frame rates, the snake could move >0.1 units in a single frame, entering a wall before the ray detects it.
*   **Impact:** Inconsistent death detection; "ghosting" through walls.
*   **Fix:** Increase ray length or use `shapecast` for better volume detection.

### 3. UFO Mega-Food Speed Trap
*   **Location:** `SnakeHead.gd` -> `_eat_food()` and `UFO.gd`
*   **Issue:** If the Snake eats one bite of a Mega Melon (setting `speed_multiplier` to 0.5) and then a UFO abducts the remaining Melon, the Snake's speed may remain halved forever because `_on_mega_food_fully_eaten` is never triggered.
*   **Impact:** Game becomes permanently slow after a UFO interaction.
*   **Fix:** Ensure `fully_eaten` or `tree_exited` on food resets the snake's speed multiplier if it was the target.

### 4. UFO Disconnect Error
*   **Location:** `UFO.gd` -> `_start_abduction()`
*   **Issue:** The code calls `disconnect` on the `tree_exited` signal without checking `is_connected()`.
*   **Impact:** Potential runtime crash if the signal was already disconnected by another process.
*   **Fix:** Wrap in `if target_food.tree_exited.is_connected(...)`.

---

## 🟡 Common Values to be Constants

*   **SnakeHead.gd:**
    *   `Vector3(0, 1.5, 0)`: Height for dazed particles.
    *   `1.0`: Hardcoded timer for segment `monitorable` toggle.
*   **Food.gd:**
    *   `0.7` and `0.5`: Bobbing height limits.
    *   `5.0`: Jump height during relocation.
    *   `Color(1.0, 1.0, 0.5)` and `Color(1.0, 0.5, 0.0)`: Food light colors.
*   **UFO.gd:**
    *   `0.1`: Distance threshold for reaching target.
    *   `2.0`: Zig-zag frequency/amplitude.

---

## 🔵 False Assumptions

*   **Node Hierarchy:** `SnakeHead.gd` assumes its parent is the main game world in `add_segment()` when calling `get_parent().add_child()`. If the head is nested inside a container, segments will be spawned in the wrong coordinate space.
*   **Collision Shapes:** `Food.gd` assumes the collision shape is always a `BoxShape3D`. If changed to a `SphereShape3D` in the editor, the setup logic will fail to set the size.

---

## ⚪ Edge Cases

*   **Zero Score UFO:** If the UFO steals food when the score is 0, the penalty logic `max(0, score - penalty)` handles it, but the UI might still flash red which could be confusing if no points were actually lost.
*   **Frame-Rate Dependent History:** In `SnakeHead.gd`, if `delta * speed` is significantly larger than `HISTORY_RESOLUTION`, only one history entry is inserted. This can cause "stretched" segments during major lag spikes.
*   **Pause State:** `NamePrompt.gd` uses `get_tree().paused = true`. Ensure all UI elements and the `ScoreManager` are set to `Process Mode: Always` to avoid locking the game.

---

## 🟢 Performance Improvements (Fedora / Integrated Graphics)

*   **Renderer Choice:** The project currently uses `Forward Plus`. For integrated graphics (Intel/AMD iGPU), the `Mobile` or `Compatibility` (Vulkan/OpenGL) renderers provide significantly better frame stability.
*   **Light Count:** Every food item spawns an `OmniLight3D`. While usually only one food exists, if "Earthquake" relocates many or a future power-up spawns more, the draw calls for dynamic lights will tank the iGPU performance.
*   **Shadows:** Ensure `Shadow` is disabled on the Food's `OmniLight3D` as it is the single most expensive feature for integrated graphics.
*   **Physics Layers:** The project uses layers 1-4. Ensure that "Snake Body" (Layer 2) does not check for collisions with itself to save on narrow-phase physics calculations.
