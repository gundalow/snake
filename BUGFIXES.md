# Code Review & Bug Report - 3D Snake

This document outlines identified bugs, potential issues, false assumptions, and recommended improvements for the 3D Snake project.

## 1. Potential Bugs

### 1.1. Input Overwriting (Input Lag)
- **File:** `scripts/core/SnakeHead.gd`
- **Issue:** The `handle_input` function updates `next_heading` every time an action is pressed. If a player presses "Left" and then "Up" very quickly before the snake reaches the next grid boundary, the "Left" turn is completely lost.
- **Impact:** Controls feel unresponsive or "slippery" during fast gameplay.
- **Recommendation:** Implement an input queue to store pending turns and process them sequentially at each grid boundary.

### 1.2. 180-Degree Turn Bug
- **File:** `scripts/core/SnakeHead.gd`
- **Issue:** The check `requested != _opposite(heading)` prevents turning directly backward relative to the *current* heading. However, if a turn is already pending in `next_heading`, the player can currently input a direction that is the opposite of `next_heading` (but not the opposite of `heading`).
- **Example:** Snake is heading NORTH. Player presses EAST (`next_heading` becomes EAST). Before reaching the grid boundary, player presses WEST. Since WEST is not the opposite of NORTH, `next_heading` becomes WEST. The snake effectively stays on its original line but the intended EAST turn is lost, or worse, if timing is frame-perfect, it might allow a 180-degree reversal depending on when the boundary is hit.

### 1.3. UFO / Mega Food Race Condition
- **Files:** `scripts/core/UFO.gd`, `scripts/core/SnakeHead.gd`
- **Issue:** If the SnakeHead eats a Mega Food while it is being abducted by the UFO, multiple issues occur:
    - The UFO's abduction tween might continue moving a food item that is being eaten.
    - If the snake takes the final bite while the UFO is abducting, `queue_free()` might be called multiple times.
    - The snake's `speed_multiplier` is set to `0.5` when biting Mega Food. If the UFO steals the food midway, the snake might stay slowed down forever because the `fully_eaten` signal (which resets speed) is never emitted by the food (it's called by the UFO instead).

### 1.4. Negative Score Handling
- **File:** `scripts/core/Main.gd`, `scripts/core/ScoreManager.gd`
- **Issue:** `_on_food_stolen` subtracts 5 from the score. If the player has fewer than 5 points, the score becomes negative.
- **Impact:** High score leaderboard might show negative values, and `ScoreManager.is_new_high_score` only checks `score <= 0`, potentially allowing a negative score to be recorded if it's "better" than no score.

### 1.5. Inadequate DeathRay Length
- **File:** `scenes/main/SnakeHead.tscn`
- **Issue:** The `DeathRay` has a `target_position` of `(0, 0, -0.6)`. The snake head mesh is 1.0 units wide (0.5 radius). This means the ray only extends 0.1 units beyond the head's front face.
- **Impact:** At high speeds, the snake might penetrate a wall or its own body before the ray detects the collision, leading to "clipping" deaths or failed detections.

### 1.6. Hardcoded Reset of Speed Multiplier
- **File:** `scripts/core/SnakeHead.gd`
- **Issue:** `_on_mega_food_fully_eaten` sets `speed_multiplier = 1.0`.
- **Impact:** If future power-ups (e.g., a "Speed Boost" item) are added that also modify `speed_multiplier`, this hard reset will overwrite them, causing bugs.

### 1.7. Food Relocation while Eating
- **File:** `scripts/core/FoodSpawner.gd`
- **Issue:** `relocate_all_food()` (triggered by World Stomper) moves all nodes in the "foods" group.
- **Impact:** If the snake is currently inside a Mega Food's area taking bites, the food might suddenly vanish from "under" its mouth, preventing the snake from finishing the meal and potentially leaving it in a "slowed" state.

---

## 2. Common Values that should be Constants

To improve maintainability, the following hardcoded values should be moved to `GameConstants.gd`:

- **SnakeHead.gd:**
    - `Vector3(0, 1.5, 0)`: Dazed particle offset.
    - `0.1` and `0.2`: Tween durations for "eat juice" animation.
    - `Vector3(1.2, 0.8, 1.2)`: Squash and stretch scales.
- **Food.gd:**
    - `0.75`: Growth animation duration.
    - `0.7` and `0.5`: Bobbing height limits.
    - `1.0`: Bobbing duration.
    - `0.25`: Jump animation duration in `jump_to`.
    - `1.5`: Scale multiplier during jump.
- **FoodSpawner.gd:**
    - `2.0`: Distance threshold for spawning away from head.
    - `1.0`: Distance threshold for spawning away from segments.
    - `50`: Max retry attempts for spawning.
    - `-7.0`: Initial food Z position.
- **UFO.gd:**
    - `2.0`: Abduction time/timer.
    - `1.0`: Delay before UFO leaves after abduction.
- **WorldStomper.gd:**
    - `30.0`: Stomp cycle interval.
    - `18.0`: Spawn distance.

---

## 3. False Assumptions

### 3.1. Node Hierarchy Stability
- **Issue:** `FoodSpawner.gd` and other scripts use `get_node_or_null("../SnakeHead")`.
- **Assumption:** Assumes the `SnakeHead` will always be a sibling of the `FoodSpawner`.
- **Reality:** If the scene tree is refactored (e.g., putting all "Managers" under a single node), these scripts will break.

### 3.2. Frame Rate Independence for Grid Alignment
- **Issue:** `move_forward` assumes `delta` will never be so large that `move_vec.length()` exceeds `GameConstants.GRID_SIZE`.
- **Reality:** On a significant lag spike (e.g., loading assets or OS background task), `delta` could be large enough to skip a grid cell entirely, causing the snake to miss a turn or snap incorrectly.

### 3.3. Achievement Uniqueness
- **Issue:** `_check_achievements` in `Main.gd` uses `score % 10 == 0`.
- **Assumption:** Assumes score increases by exactly 1 at a time.
- **Reality:** If a "Bonus Item" is added that gives +2 points, or if the UFO penalty (-5) happens right before a milestone, the player might skip the `score % 10 == 0` check entirely.

---

## 4. Edge Cases

### 4.1. The "Zero-Point" Theft
- **Scenario:** Player has 0 points and the UFO steals the first food.
- **Result:** Score becomes -5. The HUD might look strange, and internal logic for achievements might behave unexpectedly.

### 4.2. Invulnerability Window vs. Speed
- **Scenario:** Player increases speed significantly.
- **Issue:** The `INVULNERABILITY_TIME` is a constant `0.5s`. If the snake is moving very fast, it might collide with its tail later than 0.5s, but if it's moving very slow, 0.5s might not be enough to clear the starting segments.

### 4.3. Mega Food "Burp" Delay
- **Scenario:** Player dies during the 0.5s delay before the "Burp" sound and `fully_eaten` signal.
- **Result:** The `SnakeHead` is dead, but the `Food` node is still in the tree waiting to emit a signal that will try to trigger a new food spawn on a dead game state.

### 4.4. Name Prompt Focus
- **Scenario:** Player uses a controller or keyboard only.
- **Issue:** If `new_name_input` loses focus, there's no clear way to get it back without a mouse if the `selected_index` logic doesn't perfectly handle wrap-around or "None" selection.
