# Code Review Findings: 3D Snake GDScript

This document outlines potential bugs, performance improvements, and architectural concerns discovered during the full code review.

## 🐛 Potential Bugs

### 1. Input Overwriting (High Speed / High APM)
- **File:** `scripts/core/SnakeHead.gd`
- **Issue:** The `next_heading` system only stores one pending turn. If a player presses "Right" then "Up" extremely quickly (before the snake reaches the next grid boundary), the "Right" turn is overwritten and lost.
- **Impact:** Controls feel "unresponsive" or "slippery" during fast gameplay.

### 2. Negative Score Possibility
- **File:** `scripts/core/Main.gd`
- **Issue:** When a UFO steals food, `_on_food_stolen` subtracts 5 points: `snake_head.score -= 5`.
- **Impact:** If the player has fewer than 5 points, the score becomes negative, which is generally undesirable for a classic arcade game.

### 3. Food Spawn Stalling Logic
- **File:** `scripts/core/FoodSpawner.gd` & `scripts/core/Main.gd`
- **Issue:** `FoodSpawner` relies on the `fully_eaten` signal from `Food.gd` to spawn the next item. However, the UFO simply `queue_free()`s the food in `UFO.gd`, which never emits `fully_eaten`.
- **Risk:** While `Main.gd` manually calls `spawn_food()` after a timeout in `_on_food_stolen`, this creates a fragile dependency where the spawner doesn't handle the loss of its own managed objects.

### 4. Collision "Tunneling" at High Speeds
- **File:** `scripts/core/SnakeHead.gd`
- **Issue:** The `DeathRay` length is hardcoded to `0.6`. Since the head mesh is 1.0 units wide, the ray only extends 0.1 units beyond the mesh.
- **Impact:** If `move_speed` is high enough that `delta * move_speed > 0.1`, the snake could penetrate a wall or body segment before the ray detects the collision.

### 5. Fragile Node References
- **File:** `scripts/core/FoodSpawner.gd`, `scripts/core/Main.gd`, `scripts/core/InputHandler.gd`
- **Issue:** Multiple scripts use `get_node("../SnakeHead")` or `get_parent().get_node("HUD")`.
- **Impact:** If the scene tree structure is slightly modified (e.g., nesting nodes for organization), these scripts will crash. Use of `%UniqueNames` or signals via a singleton would be more robust.

---

## 🚀 Performance Improvements (Fedora / Integrated Graphics)

### 1. 4K Texture Memory Pressure
- **File:** `scripts/core/GameConstants.gd`
- **Issue:** Food models are loading `4k.gltf` variants (e.g., `food_apple_01_4k.gltf`).
- **Improvement:** 4K textures are excessive for a stylized snake game and will quickly saturate VRAM on integrated graphics, leading to stuttering or crashes. Using 1K or 2K textures is recommended.

### 2. Draw Call Optimization for Snake Body
- **File:** `scripts/core/SnakeHead.gd`
- **Issue:** Every snake segment is a separate `MeshInstance3D` and `Area3D`.
- **Improvement:** For very long snakes, this significantly increases draw calls. Using a `MultiMeshInstance3D` for the body visuals would be much more efficient.

### 3. Collision Complexity
- **Issue:** Each segment has its own `Area3D`.
- **Improvement:** Consider using a single `Area3D` for the entire body with multiple `CollisionShape3D` children, or a simplified proximity check for the tail.

---

## ⚙️ Constants to be Centralized

The following hardcoded values should be moved to `GameConstants.gd` for easier tuning:

- **SnakeHead.gd:**
    - `1.5` (Dazed particle Y-offset)
    - `1.0` (Invulnerability timer for new segments)
- **Food.gd:**
    - `0.7` / `0.5` (Bobbing heights)
    - `0.75` (Growth animation duration)
    - `10.0` / `3.0` (OmniLight range and energy)
- **UFO.gd:**
    - `5.0` (Flight height - currently matches `GameConstants` but re-declared)
    - `2.0` (Abduction duration)

---

## ✅ Solved Bugs (Milestone 1)

### 1. 180-Degree Snake Orientation
- **Issue:** The Titanoboa model's internal forward axis was Local $+X$, but the game logic assumed $-Z$.
- **Fix:** Applied a custom `Transform3D` basis mapping `Basis.x` to World $+Z$ and `Basis.z` to World $-X$.
- **Lesson:** Never assume GLTF models follow standard Forward/-Z conventions. Use visual debug markers immediately.

### 2. Snout Pivot Misalignment
- **Issue:** The rotation pivot was at the model's center, causing the head to "swing" in a wide arc during turns.
- **Fix:** Applied a `0.46` unit offset to the model's translation to align the visual snout with the parent node's $(0,0,0)$ origin.
- **Lesson:** Skeleton origins and visual mesh tips rarely align. Always verify snout position via inspection scripts.

### 3. Smooth Turn Logic Conflict
- **Issue:** `SnakeHead.gd` was counter-rotating the visual mesh to create a smooth turn effect, which scrambled the pre-calculated calibration transform.
- **Fix:** Removed the visual smoothing logic until the base alignment was 100% verified. Visuals should inherit parent rotation directly when using complex rigged models.

---

## 🧐 False Assumptions & Edge Cases

- **Grid Alignment:** The movement logic assumes `delta` will always be small enough that `grid_distance` doesn't skip a full `GRID_SIZE` in one frame. At very low FPS or extreme speeds, the snake might miss a turn opportunity.
- **Empty Names:** `NamePrompt.gd` prevents empty names, but doesn't prevent names consisting only of spaces, which can mess up the leaderboard UI.
- **UFO vs. Mega Food:** If a UFO abducts a Mega Food, the "slow down" effect applied to the snake is never cleared because the `fully_eaten` signal is never received.
- **Invulnerability Window:** The 0.5s invulnerability assumes the snake will have moved far enough away from its own head-spawn point. At very slow speeds, the snake might still be "inside" its first segment when invulnerability expires.
