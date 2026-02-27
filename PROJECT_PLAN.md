# 3D Snake GDScript Project Plan

## Overview
**Objective:** A "Snake Riding" first-person prototype with high-engagement visuals, vibrant colors, and juicy animations for a young audience.

---

## Milestone 1: The Foundation (Inputs & Dual-Camera)
*Core dependencies: Input mapping must exist before movement/toggling can be implemented.*

1. **Input Map Configuration:**
    - Define actions in `project.godot`: `turn_left`, `turn_right`, `toggle_camera` (C), `restart` (R), and `quit` (Esc).
2. **Dual-Camera System:**
    - **Rider Cam (Default):** A `Camera3D` attached to the Snake Head. Positioned slightly behind/above the eyes for a "rollercoaster" feel. Implement a slight "tilt/lean" effect when turning to enhance the sense of speed.
    - **Overhead Cam:** A fixed `Camera3D` in the main scene providing a bird's-eye view.
    - **Toggle Logic:** Use `make_current()` to switch between cameras. The switch should feel snappy but can be smoothed later with tweens.
3. **Initial Environment:**
    - Replace the temporary floor with a larger board.
    - **Glowing Walls:** Thick, colorful barriers using a `StandardMaterial3D` with high `emission_energy` to define the play area. Use `WorldBoundaryShape3D` or `BoxShape3D` for collision.

## Milestone 2: Snake Head & Snap-Turning
*Core dependencies: Requires the Input Map and Environment from Milestone 1.*

1. **Forward Movement:** 
    - Implement constant forward movement on the XZ plane. The snake never stops until it dies.
2. **Snap Turning Logic:**
    - Pressing Left/Right turns the head exactly 90 degrees relative to its current heading.
    - **Safety Check:** Implement logic to prevent 180-degree "suicide" turns (e.g., if moving North, the "South" input is ignored).
3. **Visuals:**
    - Update the `SnakeHead` mesh. Start with a vibrant cube/capsule; eventually, move to a modeled head with a hinged jaw for the "eating" animation.

## Milestone 3: The "Train" System (Body & Fruit)
*Core dependencies: Requires a moving Head to generate position history.*

1. **Position History System:**
    - The head records its global position and rotation into an array/buffer every time it moves a certain distance (the "step size").
2. **Body Segments:**
    - Spawn `MeshInstance3D` segments that follow the head's history. Each segment "occupies" a previous coordinate slot from the history buffer.
3. **Fruit Spawner & Interaction:**
    - **Spawner:** Randomly picks meshes (Sphere for Apple, Capsule for Banana) with high-saturation PBR colors.
    - **Interaction:** Detect collision with fruit. 
    - **Growth:** On eat, add a new segment to the tail, slightly increase `move_speed`, and play a "Squash and Stretch" tween on the head.

## Milestone 4: The Death Sequence (Physics & UI)
*Core dependencies: Requires functional collisions with walls and segments.*

1. **Collision Logic:**
    - Detect collision with boundary walls or the snake's own body segments.
2. **The "Rider Thrown" Effect:**
    - **Freeze:** Set `set_process(false)` for all movement logic.
    - **Camera Tumble:** Detach the Rider Camera from the Head (reparent to root). Attach it to a `RigidBody3D` and apply a random `angular_velocity` and upward `impulse`. This creates a chaotic, funny "crash" effect as the camera tumbles across the floor.
3. **Dazed Animation:**
    - Spawn a "Dazed" node above the head. Use `GPUParticles3D` or a spinning `Sprite3D` of stars/birds.
4. **Game Over UI:**
    - Fade in a HUD with "Restart" and "Quit" options.

## Milestone 5: Technical Rigor & Validation
1. **Validation Script (`validate.py`):**
    - Update to check for:
        - Required Input Map actions.
        - Existence of the "Dazed" particle resource.
        - Proper collision layer/mask setup.
2. **Performance Optimization:**
    - Ensure the game maintains 60+ FPS on Fedora's Vulkan Forward+ renderer.
    - Review `GPUParticles3D` impact on integrated graphics.

---

## Ideas for Future Enhancements
- Power-ups (Speed boost, Slow motion).
- Different biomes (Neon Grid, Jungle, Candy Land).
- Jaw-moving animations synced with fruit consumption.
- First-person vs. Third-person (Chase) camera toggle.
- **Camera Dynamics:** Add centrifugal force/inertia effects (e.g., subtle wobble or overshoot) during turns to simulate the "rollercoaster" feel more intensely.

---

## REQUIREMENTS & ASSUMPTIONS

### 1. Board & Space
- **Board Size:** 30x30 units.
- **Grid Unit:** 1.0 (Snake segments are placed 1 unit apart).
- **Start Position:** Middle of the board `(0, 0, 0)`.
- **Start Direction:** North (Negative Z axis).

### 2. Movement & Physics
- **Initial Speed:** 5.0 units per second (5 grid units/sec).
- **Snap Turning:** Instant 90-degree logic for the snake body, with a **0.1s interpolation** for the camera lean to smooth the visual transition.
- **Collision Strategy:** Use `Area3D` for detection (Eating/Death) to ensure clean, non-physics-based logic for the core movement.

### 3. Controls & Inputs
- **Turning:** Mapped to `WASD` (A/D) and `Arrow Keys` (Left/Right).
- **Camera Toggle:** Mapped to `C`.
- **Game State:** `R` for Restart, `Esc` for Quit.

### 4. Visual Aesthetic
- **Color Palette:** Specific high-saturation palette for a "young audience" vibe (e.g., Neon Green, Cyan, Magenta).
- **Materials:** High-emission "glowing" textures for boundary walls.
- **Cam:** Rider Cam (FPV) is the primary "hero" perspective.
