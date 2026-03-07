# Code Review and Bug Report - 3D Snake

This document outlines identified bugs, potential issues, false assumptions, and recommended improvements for the 3D Snake project.

## Potential Bugs

### Input Overwriting (Input Lag)
- **File:** scripts/core/SnakeHead.gd
- **Issue:** The handle input function updates the next heading every time an action is pressed. If a player presses Left and then Up extremely quickly before the snake reaches the next grid boundary, the Left turn is completely lost.
- **Impact:** Controls feel unresponsive or slippery during fast gameplay.
- **Recommendation:** Implement an input queue to store pending turns and process them sequentially at each grid boundary.

### One-Hundred-And-Eighty Degree Turn Bug
- **File:** scripts/core/SnakeHead.gd
- **Issue:** The check to prevent opposite directions only accounts for the current heading. If a turn is already pending, the player can currently input a direction that is the opposite of that pending turn.
- **Example:** Snake is heading NORTH. Player presses EAST. Before reaching the grid boundary, player presses WEST. Since WEST is not the opposite of NORTH, the pending turn becomes WEST. The intended EAST turn is lost, and depending on timing, it might allow a full reversal.

### UFO and Mega Food Race Condition
- **Files:** scripts/core/UFO.gd and scripts/core/SnakeHead.gd
- **Issue:** If the snake eats a Mega Food while it is being abducted by the UFO, several issues occur. The abduction animation might continue on a food item that is being eaten, and if the snake takes the final bite while the UFO is abducting, the node might be freed multiple times. Additionally, the snake might stay slowed down forever if the UFO steals the food midway, as the signal to reset speed is never emitted.

### Negative Score Handling
- **Files:** scripts/core/Main.gd and scripts/core/ScoreManager.gd
- **Issue:** Score subtraction from UFO theft can result in a score below zero.
- **Impact:** The high score leaderboard might show negative values, and the score manager may allow a negative score to be recorded as a personal best.

### Inadequate Death Ray Length
- **File:** scenes/main/SnakeHead.tscn
- **Issue:** The Death Ray target position is very close to the head. The snake head has a certain width, and the ray only extends a tiny fraction beyond the head.
- **Impact:** At high speeds, the snake might penetrate a wall or its own body before the ray detects the collision, leading to clipping deaths.

### Hardcoded Reset of Speed Multiplier
- **File:** scripts/core/SnakeHead.gd
- **Issue:** When Mega Food is fully eaten, the speed multiplier is hard-reset to one point zero.
- **Impact:** If future power-ups also modify the speed multiplier, this hard reset will overwrite them, causing bugs.

### Food Relocation while Eating
- **File:** scripts/core/FoodSpawner.gd
- **Issue:** The function to relocate all food moves all nodes in the foods group.
- **Impact:** If the snake is currently taking bites of a Mega Food, the food might suddenly vanish, preventing the snake from finishing the meal and potentially leaving it in a slowed state.

### High-Speed Grid Skipping
- **File:** scripts/core/SnakeHead.gd
- **Issue:** If movement speed increases significantly, the distance traveled in a single frame might exceed the grid size.
- **Impact:** The snake could theoretically teleport past a grid boundary without triggering a turn or a position snap correctly.

### Position History Desync
- **File:** scripts/core/SnakeHead.gd
- **Issue:** If the game frame rate drops significantly, distance traveled might exceed the history resolution by a large margin in a single frame, but only one history entry is recorded per frame.
- **Impact:** This could cause segments to appear to stretch or lag behind during lag spikes.

### Food Spawner Dependency
- **File:** scripts/core/FoodSpawner.gd
- **Issue:** The food spawner looks for the SnakeHead node at a specific relative path.
- **Impact:** If the SnakeHead node is renamed or moved in the scene tree, food spawning will fail silently.

### Invulnerability Window
- **File:** scripts/core/SnakeHead.gd
- **Issue:** The invulnerability timer is a fixed duration.
- **Impact:** At very slow speeds, this might not be enough time for the tail segments to clear the starting position of the head.

---

## Common Values that should be Constants

To improve maintainability, the following hardcoded values should be moved to GameConstants:

- **SnakeHead.gd:** The vertical offset for dazed particles, tween durations for animations, and squash and stretch scale values.
- **Food.gd:** Growth animation duration, bobbing height limits, bobbing duration, jump animation duration, and scale multipliers.
- **FoodSpawner.gd:** Distance thresholds for spawning away from the head and body segments, maximum retry attempts for spawning, and initial food coordinates.
- **UFO.gd:** Abduction duration and the delay before the UFO leaves after abduction.
- **WorldStomper.gd:** Stomp cycle interval and spawn distance.

---

## False Assumptions

### Node Hierarchy Stability
- **Issue:** Multiple scripts use relative node paths to find other nodes.
- **Assumption:** Assumes the scene tree structure will never change.
- **Reality:** If the scene tree is refactored, these scripts will break.

### Frame Rate Independence for Grid Alignment
- **Issue:** Movement logic assumes the time between frames will always be small enough to detect grid boundaries.
- **Reality:** On a significant lag spike, the snake could skip a grid cell entirely.

### Achievement Uniqueness
- **Issue:** Milestone checks use a modulo operation on the score.
- **Assumption:** Assumes the score increases by exactly one at a time.
- **Reality:** If a bonus item is added that gives multiple points, the player might skip the milestone check entirely.

---

## Edge Cases

### The Zero-Point Theft
- **Scenario:** Player has zero points and the UFO steals the first food.
- **Result:** Score becomes negative. The user interface might behave unexpectedly.

### Mega Food Burp Delay
- **Scenario:** Player dies during the short delay between finishing a Mega Food and the burp sound.
- **Result:** The SnakeHead is dead, but the food node is still in the tree waiting to emit a signal that will try to trigger a new food spawn.

### Name Prompt Focus
- **Scenario:** Player uses a controller or keyboard only.
- **Issue:** If the name input field loses focus, there may be no clear way to regain focus without a mouse.
