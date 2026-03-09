# Code Review Findings: 3D Snake GDScript

This document provides a detailed code review of the 3D Snake project, focusing on potential bugs, architectural improvements, and performance considerations for integrated graphics.

## 🐛 Potential Bugs

### 1. Input Overwriting (Input Lag/Loss)
- **File:** `scripts/core/SnakeHead.gd`
- **Logic:** The `handle_input()` function updates `next_heading` every time a key is pressed.
- **Issue:** Only one "next" direction is stored. If a player performs two rapid turns (e.g., "Right" then "Up") before the snake reaches the next grid boundary, the first turn ("Right") is overwritten by "Up".
- **Impact:** The snake will appear to skip the first turn, making the controls feel unresponsive during high-speed gameplay.
- **Recommended Fix:** Implement an input buffer (Queue) to store pending turns and process them sequentially at each grid boundary.

### 2. Mega Food Speed Lock
- **File:** `scripts/core/SnakeHead.gd` & `scripts/core/UFO.gd`
- **Issue:** When eating Mega Food, `speed_multiplier` is set to `0.5`. It is only reset to `1.0` when the `fully_eaten` signal is received. However, if a UFO abducts the Mega Food while the snake is still eating it, the `fully_eaten` signal is never emitted (UFO uses `queue_free()` directly).
- **Impact:** The snake remains slowed down for the rest of the game.
- **Recommended Fix:** Ensure `SnakeHead` resets its speed multiplier if its current "target" food is destroyed or stolen, or have the UFO trigger a "stolen" signal that the snake listens to.

### 3. Collision Tunneling at High Speed
- **File:** `scripts/core/SnakeHead.gd`
- **Issue:** The `DeathRay` target position is `(0, 0, -0.6)`. The head is `1.0` unit wide. This means the ray only extends `0.1` units beyond the front of the mesh.
- **Impact:** As `move_speed` increases (starting at 5.0 and increasing by 0.2 per food), it may eventually exceed a speed where `delta * move_speed > 0.1`. At this point, the snake could move through a wall or body segment in a single frame without the raycast ever detecting a collision.
- **Recommended Fix:** Scale the `target_position` of the `DeathRay` based on the current `move_speed` to ensure it always looks far enough ahead.

### 4. Fragile Node Paths
- **Files:** `scripts/core/FoodSpawner.gd`, `scripts/core/InputHandler.gd`, `scripts/core/UFOManager.gd`
- **Issue:** Extensive use of `get_node("../SnakeHead")` or `get_parent().get_node("HUD")`.
- **Impact:** If the scene hierarchy is changed (e.g., placing the SnakeHead inside a "World" node or the HUD inside a "UI" container), these scripts will break and cause runtime crashes.
- **Recommended Fix:** Use `%UniqueNames` in the editor or define a central `GameManager` / `GlobalEventBus` to handle references and communication.

---

## 💎 Common Values that should be Constants

To improve maintainability and facilitate game balancing, the following hardcoded values should be moved to `scripts/core/GameConstants.gd`:

- **SnakeHead.gd:**
  - `Vector3(0, 1.5, 0)`: Vertical offset for dazed particles.
  - `1.0`: Duration for new segment collision invulnerability.
- **Food.gd:**
  - `0.7` / `0.5`: Sine wave heights for the bobbing animation.
  - `0.75`: Duration of the growth/spawn animation.
  - `10.0` / `3.0`: OmniLight range and energy.
- **UFO.gd:**
  - `2.0`: Duration of the abduction tween.
- **UFOManager.gd:**
  - `0.5`: Delay before spawning a UFO after food appears.
- **Main.gd:**
  - `2.0`: Timeout before spawning new food after a UFO theft.
- **WorldStomper.gd:**
  - `30.0`: Stomp cycle interval.
  - `18.0`: Spawn distance from center.

---

## 🧐 False Assumptions

### 1. Perfect Frame Timing
- **File:** `scripts/core/SnakeHead.gd`
- **Assumption:** The logic `if grid_distance >= GameConstants.GRID_SIZE` assumes that the snake will not travel significantly more than 1.0 unit in a single frame.
- **Risk:** At very low frame rates (e.g., a lag spike on a laptop), `grid_distance` could theoretically be `2.1`, causing the snake to skip a grid-snap and potentially miss its turn window entirely.

### 2. Fixed Start Orientation
- **File:** `scripts/core/SnakeHead.gd`
- **Assumption:** `_initialize_history` calculates "behind" the snake based on `transform.basis.z`. While technically correct, the initial history filling doesn't account for the snake potentially starting at an angle not aligned with the global axes.

### 3. Collision Type Safety
- **File:** `scripts/core/Food.gd`
- **Assumption:** Assumes the `collision_shape` is always a `BoxShape3D`. While it checks `is BoxShape3D`, if it were changed to a `SphereShape3D` for a specific fruit, the size setting logic would fail silently.

---

## ⚠️ Edge Cases

### 1. The "Eternal Pause"
- **File:** `scripts/ui/NamePrompt.gd`
- **Issue:** The game is paused when the NamePrompt is shown. If the player clicks "Accept" with an empty name (or just spaces), the `if chosen_name != ""` check fails, and the prompt remains visible while the game stays paused.
- **Impact:** The player is effectively soft-locked if they don't know they *must* enter at least one character.

### 2. High Score JSON Growth
- **File:** `scripts/core/ScoreManager.gd`
- **Issue:** `submit_score` appends every single score to the `high_scores` array.
- **Impact:** Over months of play, `highscores.json` will grow indefinitely. While only the top 10 are displayed, loading a multi-megabyte JSON file on startup could cause a noticeable hitch.

### 3. Rapid Restart Race Condition
- **File:** `scripts/core/InputHandler.gd`
- **Issue:** `get_tree().reload_current_scene()` is called immediately.
- **Impact:** In complex scenes, rapid restarts can sometimes lead to "Object was deleted while in use" errors if signals are still in flight.

---

## 🚀 Performance Improvements (Integrated Graphics Focus)

### 1. Rendering Backend
- **Project Setting:** Currently using `Forward Plus`.
- **Suggestion:** `Forward Plus` is the most demanding renderer. For a Fedora laptop with integrated graphics, switching to the `Mobile` renderer (Vulkan Mobile) or even `Compatibility` (OpenGL) would significantly improve battery life and thermal performance without sacrificing the "Snake" aesthetic.

### 2. Draw Call Bottleneck (Snake Body)
- **File:** `scripts/core/SnakeHead.gd`
- **Issue:** Every snake segment is a unique `Node3D` with its own `MeshInstance3D` and `Area3D`.
- **Improvement:** As the snake grows to 50+ segments, the draw call count and physics overhead will rise linearly. Using a `MultiMeshInstance3D` for the body segments would reduce the entire snake's visual representation to a single draw call.

### 3. Shadow Map Optimization
- **File:** `scenes/main/main.tscn`
- **Issue:** `DirectionalLight3D` has shadows enabled.
- **Improvement:** Shadow mapping is expensive on integrated GPUs. Reducing the shadow atlas size or using "Distance Fade" for shadows would help maintain a stable 60 FPS.

### 4. Area3D Monitoring
- **File:** `scenes/main/SnakeSegment.tscn`
- **Issue:** Every segment has an `Area3D` that is `monitorable`.
- **Improvement:** While necessary for collision, having dozens of `Area3D` nodes in a small space can stress the Godot physics engine. Ensure `monitoring` is set to `false` on segments, as they only need to be *detected* by the head, not detect other things themselves.
