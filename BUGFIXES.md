# Code Review Findings: 3D Snake GDScript

This document outlines potential bugs, performance improvements, and architectural concerns discovered during the full code review.

## 🐛 Potential Bugs

### 1. Input Overwriting (High Speed / High APM)
- **File:** `scripts/core/SnakeHead.gd`
- **Issue:** The `next_heading` system only stores one pending turn. If a player presses "Right" then "Up" extremely quickly (before the snake reaches the next grid boundary), the "Right" turn is overwritten by "Up" and lost.
- **Impact:** Controls feel "unresponsive" or "slippery" during fast gameplay when making rapid successive turns.

### 2. UFO vs. Mega Food State Leak
- **File:** `scripts/core/SnakeHead.gd` & `scripts/core/UFO.gd`
- **Issue:** When eating Mega Food, the snake's `speed_multiplier` is set to `0.5`. This is only reset to `1.0` when the `fully_eaten` signal is received from the food. If a UFO abducts a Mega Food while it is being eaten, the food is `queue_free()`'d by the UFO without emitting `fully_eaten` (or the snake might not be connected to the new one).
- **Impact:** The snake could be permanently stuck at 50% speed.

### 3. Collision "Tunneling" at High Speeds
- **File:** `scripts/core/SnakeHead.gd`
- **Issue:** The `DeathRay` length is hardcoded to `0.6` in the scene. Since the head mesh is 1.0 units wide (0.5 radius), the ray only extends 0.1 units beyond the mesh.
- **Impact:** If `move_speed` is high enough (or a frame spike occurs) such that `delta * move_speed > 0.1`, the snake could penetrate a wall or body segment collision volume before the ray detects the collision.

### 4. Signal Connection Leak / Double Connection
- **File:** `scripts/core/SnakeHead.gd`
- **Issue:** In `_eat_food`, the `_on_mega_food_fully_eaten` signal is connected every time a bite is taken if it's the final bite:
  ```gdscript
  if is_fully_eaten:
      if not area.fully_eaten.is_connected(_on_mega_food_fully_eaten):
          area.fully_eaten.connect(_on_mega_food_fully_eaten)
  ```
  While guarded, if the UFO abducts the food, this connection might persist in the snake's memory if not handled. More importantly, the `fully_eaten` signal in `Food.gd` is emitted *before* `queue_free`, but if the snake is the one that triggered the final bite, it might be safer to handle the speed reset immediately.

### 5. Fragile Food Spawn Dependency
- **File:** `scripts/core/FoodSpawner.gd`
- **Issue:** The spawner relies on the `fully_eaten` signal from the food items to spawn the next one. UFOs destroy food without emitting this signal.
- **Impact:** While `Main.gd` currently has a workaround to call `spawn_food()` after a UFO theft, this splits the spawning logic across two different classes, making the system harder to maintain and prone to "empty board" bugs if other destruction methods are added.

---

## ⚙️ Constants to be Centralized

The following hardcoded values should be moved to `GameConstants.gd` for easier balancing:

- **SnakeHead.gd:**
    - `1.0` (Invulnerability timer for new segments)
    - `Vector3(0, 1.5, 0)` (Dazed particles Y-offset)
    - `2 * GameConstants.SEGMENT_SPACING + 1` (Initial history buffer size)
- **Food.gd:**
    - `0.7` / `0.5` (Bobbing heights)
    - `1.0` (Bobbing duration)
    - `0.75` (Growth animation duration)
    - `10.0` / `3.0` (OmniLight range and energy)
- **UFO.gd:**
    - `2.0` (Abduction duration)
    - `1.0` (Post-abduction exit delay)
- **WorldStomper.gd:**
    - `30.0` (Stomp interval)
    - `18.0` (Spawn distance)

---

## 🧐 False Assumptions & Edge Cases

- **Frame-Rate Dependent Grid Snapping:** `move_forward` handles grid snapping by checking `grid_distance >= GameConstants.GRID_SIZE`. If a massive frame lag occurs, `grid_distance` could exceed 2.0x `GRID_SIZE`, but the logic only performs one turn and one snap, potentially causing a visual "jump" or misaligned segments.
- **Unbounded Name Length:** `NamePrompt.gd` strips edges but does not limit the character count. Extremely long names will overflow the HUD and Leaderboard UI elements.
- **UFO Target Invalidity:** `UFO.gd` checks `is_instance_valid(target_food)` in `_process`, but `_start_abduction` also performs checks. There is a small window where if the snake eats the food exactly as the UFO arrives, the UFO might still try to tween a null object.
- **Invulnerability Window:** The 0.5s invulnerability assumes the snake moves fast enough to clear its own starting segments. At very low speeds, the snake might still be overlapping its tail when the timer expires.

---

## 🚀 Performance Improvements (Integrated Graphics Focus)

- **Renderer Choice:** The project is set to `Forward Plus`. For Fedora laptops with integrated graphics, the `Mobile` or `Compatibility` renderer might provide a more stable frame rate, especially as the snake grows and draw calls increase.
- **Snake Body Draw Calls:** Each snake segment is a unique `Node3D` with its own `MeshInstance3D` and `Area3D`. For a long snake (e.g., score 100+), this results in over 200 draw calls just for the snake.
    - **Improvement:** Use `MultiMeshInstance3D` for the snake body visuals to reduce draw calls to a single batch.
- **Collision Overhead:** Every tail segment has an active `Area3D` monitoring for the head.
    - **Improvement:** Use a single `Area3D` for the head and only check for `body` group overlaps, or disable monitoring on segments that are not currently "reachable" by the head.
- **Physics Layer Efficiency:** Ensure `collision_mask` and `collision_layer` are as restrictive as possible (e.g., the floor should not be on any layer that the snake head checks if not needed). Currently, the snake head `MouthArea` checks layer 4 (foods), which is correct.
