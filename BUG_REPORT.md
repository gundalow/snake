# Bug Report - 3D Snake GDScript

## 1. 180-Degree "Suicide" Turn Exploit
- **Bug**: Rapidly pressing two opposite turn directions (e.g., Left then Right) allows the snake to perform a 180-degree turn within a single grid step.
- **Why it's a bug**: The game logic is intended to prevent 180-degree turns to avoid immediate self-collision. However, because `queue_turn` updates the `target_heading` immediately upon input, multiple inputs can be stacked before the snake has actually moved to the next grid cell.
- **Suggested Fix**: Implement an input queue. Only process one turn from the queue when the snake completes a `STEP_DISTANCE` (1.0 unit) of movement.

## 2. Food Spawning Overlap
- **Bug**: Food can spawn directly inside the snake's body or head.
- **Why it's a bug**: This makes the food impossible to see or leads to "teleporting" growth that feels glitchy.
- **Suggested Fix**: In `FoodSpawner.gd`, add a check to ensure the randomly generated coordinates are not within a certain threshold of the `SnakeHead` or any `SnakeSegment`.

## 3. Incomplete "Rider Thrown" Death Sequence
- **Bug**: The death sequence is significantly less "chaotic" than described in the `PROJECT_PLAN.md`. It currently only performs a simple vertical bounce.
- **Why it's a bug**: It fails to deliver the promised "rollercoaster" crash feel.
- **Suggested Fix**: Add random angular velocity or rotation tweens to the camera when it is detached from the head during the `die()` function.

## 4. Legacy / Unused Variables
- **Bug**: Variables `current_direction`, `next_direction`, and `heading` are defined in `SnakeHead.gd` but never used.
- **Why it's a bug**: It clutters the codebase and can confuse future developers about which variables represent the actual state.
- **Suggested Fix**: Remove the unused variable declarations.

## 5. Brittle Hardcoded Node Paths
- **Bug**: `SnakeHead.gd` uses absolute paths like `/root/Main/FoodSpawner` and `/root/Main/HUD/ScoreLabel`.
- **Why it's a bug**: If the scene hierarchy changes or nodes are renamed, the script will crash. It makes the `SnakeHead` scene less reusable.
- **Suggested Fix**: Use signals (e.g., `signal food_eaten(new_score)`) or exported `@export` variables to reference these nodes.
