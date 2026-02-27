### Milestone 1: Init
# Role: Lead Godot 4.6 Developer (3D Specialization)

## Task
Expand the 3D Snake project. The core mechanic is "Snake Riding" (First-Person Perspective) with high-engagement visuals for a young audience (vibrant colors, juicy animations).

## 1. Snake Logic & Movement (The "Train" System)
- **Head Logic:** Constant forward movement on the XZ plane. 
- **Turning:** Implement "Snap Turning." Pressing Left/Right turns the head exactly 90 degrees relative to its current heading. Prevent 180-degree "suicide" turns.
- **Body Segments:** Use a "Position History" system. Every time the head moves a certain distance, spawn or move `MeshInstance3D` segments to the previous coordinates of the head.
- **Growth:** When a fruit is eaten, add a new segment to the tail and slightly increase the `move_speed`.

## 2. Dual-Camera System
- **Rider Cam (Default):** A `Camera3D` attached to the Snake Head. Positioned slightly behind/above the eyes for a "rollercoaster" feel. Use a slight "tilt" effect when turning.
- **Overhead Cam:** A fixed `Camera3D` providing a top-down bird's-eye view of the board.
- **Toggle Logic:** Pressing "C" must smoothly (or instantly) switch between these two cameras using the `make_current()` method.

## 3. Visual Style & Assets
- **The Fruit:** Script a "Fruit Spawner" that picks a random mesh (Sphere for Apple, Capsule for Banana) with bright, realistic PBR colors (High Saturation). 
- **Juice:** Add a simple "Squash and Stretch" tween when the snake eats a fruit.
- **Environment:** Walls should be thick, colorful barriers with a "glowing" emission texture.

## 4. The "Death Sequence" (Physics & Animation)
On collision with a wall or self:
1. **Freeze:** Set `set_process(false)` for movement.
2. **Camera Tumble:** - Detach the Rider Camera from the Head (reparent to root).
    - Convert it into/attach it to a `RigidBody3D`.
    - Apply a random `angular_velocity` and upward `impulse` so it tumbles across the floor.
    - Why: By reparenting the camera to a RigidBody3D upon death, you get that "realistic tumble" without having to animate it by hand. It feels chaotic and funny to a 10-year-old—the "rollercoaster" suddenly crashing.
3. **Dazed Effect:** Spawn a "Dazed" node above the snake head. 
    - Use a `GPUParticles3D` or a spinning `Sprite3D` of stars/birds circling the head.
4. **UI:** Fade in a "Game Over" screen with "Restart" (R) and "Quit" (Esc) options.

## 5. Technical Rigor (Fedora/Linux)
- **Validation:** Update the `validate.py` script to check for:
    - Input Map actions: "turn_left", "turn_right", "toggle_camera".
    - Existence of the "Dazed" particle resource.
    - Presence of `WorldBoundaryShape3D` for wall collisions.
- **Performance:** Ensure the FPS counter stays above 60 FPS on Fedora's Vulkan Forward+ renderer.

## Output Requirements:
- Updated `SnakeHead.gd` with segment logic and camera switching.
- `DeathManager.gd` to handle the physics transition.
- The updated Python validation script.


### Milestone 2: The Body & Fruit
*   [ ] **Snake Body:** Implement trailing body segments that follow the head's path.
*   [ ] **Fruit:** Add fruit objects (stationary blocks) to the world.
*   [ ] **Interaction:** Implement collision detection for eating fruit.
*   [ ] **Growth:** Snake grows longer when fruit is eaten.

### Milestone 3: Juice & Polish (The "Cool" Features)
*   [ ] **Animation:** Implement "Jaw moving" animation when eating.
*   [ ] **Camera Dynamics:** Camera sway/movement during eating.
*   [ ] **Death Mechanic:**
    *   Collision detection with self/walls.
    *   "Thrown off" physics effect for the camera.
    *   "Circling birdies" dazed animation/particle effect.
*   [ ] **Assets:** Replace basic blocks with AI-generated or imported 3D models.

## Ideas for Enhancements
*   Power-ups (Speed boost, Slow motion).
*   Different biomes/floor textures.
*   First-person vs. Third-person toggle.

## 3. Gameplay Mechanics

### 3.1. Movement
*   **Plane:** The snake moves on the horizontal plane (XZ).
*   **Controls:**
    *   `Up`: Unused (Snake moves forward automatically).
    *   `Down`: Unused (Can't reverse).
    *   `Left`/`Right`: Turn 90 degrees relative to current direction.
*   **Speed:** Constant speed, potentially increasing with difficulty.

### 3.2. Camera
*   **Default:** Attached to the `SnakeHead` node, slightly offset (behind and above).
*   **Dynamic:** When eating, the camera might bob or zoom slightly to emphasize the action.
*   **Death:** Detaches from the head and simulates physics (falling/rolling) to mimic the rider being "thrown off".

### 3.3. The Snake
*   **Head:** A `CharacterBody3D` or `Node3D` controlled by Go logic.
    *   **Visuals:** Initially a cube. Later, a modeled head with a hinged jaw.
*   **Body:** A list of segments (`MeshInstance3D`) that follow the head's history of positions.
*   **Growth:** When fruit is eaten, a new segment is added to the tail.

### 3.4. Fruit
*   **Behavior:** Stationary objects spawned randomly on the grid.
*   **Visuals:** Brightly colored blocks (Red/Gold).

### 3.5. Death
*   **Trigger:** Collision with own body or walls.
*   **Sequence:**
    1.  Movement stops abruptly.
    2.  Camera detaches and runs a physics simulation (rigid body) to tumble.
    3.  Snake head plays a "Dazed" animation (e.g., circling stars/birdies).
    4.  "Game Over" UI appears.


