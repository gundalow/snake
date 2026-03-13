# Code Review & Bug Report - 3D Snake GDScript

This document details potential bugs, edge cases, performance concerns, and architectural improvements identified during a full code review.

## 🐛 Potential Bugs

### 1. Input Overwriting (Race Condition)
In `SnakeHead.gd`, the `handle_input()` function directly overwrites `next_heading`.
- **Issue**: If a player performs two quick turns (e.g., "Right" then "Up") within a single grid cell, the first input ("Right") is discarded before the snake reaches the next grid boundary.
- **Impact**: Controls feel "dropped" or unresponsive during fast play.
- **Fix**: Implement an input buffer (queue) for turns.

### 2. High-Speed Grid Skipping
In `SnakeHead.gd`, `move_forward()` uses `grid_distance += step`.
- **Issue**: If `move_speed * delta` exceeds `GameConstants.GRID_SIZE` (1.0), the logic might skip a grid boundary entirely or result in inaccurate snapping.
- **Impact**: The snake could "teleport" through walls or miss food at extremely high speeds.
- **Fix**: Use a `while` loop or sub-stepping for movement when `delta * speed` is large.

### 3. Collision Precision at Speed
The `DeathRay` in `SnakeHead.tscn` has a fixed length.
- **Issue**: At high speeds, the snake's `global_position` might advance into a wall's collision volume between frames before the `RayCast3D` registers a hit.
- **Impact**: Intermittent "tunneling" through walls or segments.
- **Fix**: Scale the `DeathRay` length based on current `move_speed` or use `Shapecast3D`.

### 4. UFO/Snake Interaction Race
In `UFO.gd`, the UFO starts a tween to lift the food.
- **Issue**: If the snake eats the food during the `abduction_time` (while the food is rising), both `SnakeHead._eat_food` and `UFO._on_abduction_finished` might attempt to process the same food node.
- **Impact**: Potential null instance errors or double-scoring.
- **Fix**: Add a `is_being_abducted` flag to `Food.gd` to prevent the snake from eating it, or vice versa.

### 5. History Buffer Desync
`SnakeHead.gd` records history based on `distance_traveled >= HISTORY_RESOLUTION`.
- **Issue**: If a frame is very long (lag spike), `distance_traveled` could be 5x the resolution, but only one transform is recorded.
- **Impact**: Tail segments appear to "snap" or stretch incorrectly after a lag spike.
- **Fix**: While `distance_traveled >= HISTORY_RESOLUTION`, record a transform and decrement `distance_traveled` by the resolution.

---

## 💎 Constants to Centralize (`GameConstants.gd`)

The following values are currently hardcoded in scripts and should be moved to `GameConstants.gd` for easier tuning:

- **SnakeHead.gd**:
    - `1.5` (Dazed particle height)
    - `1.0` (Segment invulnerability timeout)
- **Food.gd**:
    - `0.7` / `0.5` (Bobbing height offsets)
    - `5.0` (Jump height during relocation)
    - `0.75` (Growth animation duration)
    - `10.0` (OmniLight range)
    - `3.0` (OmniLight energy)
- **UFO.gd**:
    - `0.1` (Arrival distance threshold)
    - `2.0` (Zig-zag frequency/amplitude)
- **WorldStomper.gd**:
    - `30.0` (Stomp interval)
    - `18.0` (Spawn distance from center)
- **HUD.gd**:
    - `1.3` (Score pop scale)
    - `0.1` (Tween durations)
    - `2.0` (Achievement display duration)

---

## ⚠️ False Assumptions

### 1. Parent Node Dependency
`SnakeHead.gd` uses `get_parent().add_child.call_deferred(new_segment)`.
- **Assumption**: The `SnakeHead` is always a direct child of the main game world. If it's nested (e.g., inside a `Player` container), segments will be spawned in the wrong coordinate space.

### 2. Food Spawner Node Path
`FoodSpawner.gd` uses `get_node_or_null("../SnakeHead")`.
- **Assumption**: The `SnakeHead` is a sibling of the `FoodSpawner`. This breaks if the scene tree is reorganized for better categorization.

### 3. Audio Bus Existence
`Food.gd` and `UFO.gd` attempt to set `bus = &"SFX"`.
- **Assumption**: A bus named "SFX" exists in the `default_bus_layout.tres`. If missing, Godot throws an error.

### 4. UI Node Stability
`Main.gd` assumes `$HUD/StatusLabel` and `$HUD/ScoreLabel` exist.
- **Assumption**: Rigid UI hierarchy. Renaming these nodes in the editor will crash the game logic.

---

## 🏔 Edge Cases

### 1. The "Packed" Board
- **Scenario**: The snake grows so long it occupies almost every grid cell.
- **Issue**: `FoodSpawner.gd` retries 50 times to find a valid spot. If it fails, it prints a warning but doesn't actually stop or handle the failure gracefully (it might spawn food on the snake).
- **Impact**: Game becomes unplayable or food spawns inside the snake's body.

### 2. Rapid 180-Degree Turns
- **Scenario**: The snake turns North -> West -> South in 2 frames.
- **Issue**: The 180-degree check only prevents *immediate* reversals. A quick "U-turn" can still cause the head to collide with the very first segment before the `invulnerability_timer` (0.5s) expires if the snake is fast.

### 3. Window Resizing
- **Scenario**: Player resizes the window on Fedora.
- **Issue**: The HUD uses fixed offsets for many elements.
- **Impact**: UI elements might overlap or disappear off-screen.

---

## ⚡ Performance Improvements (Fedora / Integrated Graphics)

### 1. Rendering Method
- **Observation**: The project uses `Forward Plus`.
- **Recommendation**: For laptops with integrated graphics (Intel/AMD), the `Mobile` or `Compatibility` (Vulkan/OpenGL) renderers provide much better frame stability and battery life with minimal visual loss for a stylized game like Snake.

### 2. Excessive OmniLights
- **Observation**: Every food item (and every bite of Mega Food) has an `OmniLight3D`.
- **Issue**: Multiple dynamic lights with shadows or high range can quickly bottle-neck integrated GPUs.
- **Optimization**: Limit the number of active lights or use a single "Target" light that moves to the current food.

### 3. Collision Layer Optimization
- **Observation**: `SnakeHead` checks collisions in `_process`.
- **Optimization**: Ensure `CollisionMask` is strictly set to only layers it needs to hit (Walls and Body). Currently, it relies on `is_in_group` checks *after* the physics engine has already done the heavy lifting of detecting the collision.

### 4. Signal vs. Call_Deferred
- **Observation**: High frequency of `emit.call_deferred`.
- **Optimization**: While safe, over-reliance on deferred calls can slightly delay logic feedback. Use standard `emit()` for logic-critical signals unless thread safety or frame-timing is an issue.
