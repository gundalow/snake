# 3D Snake GDScript Project Plan

## Overview
**Objective:** A high-engagement 3D Snake prototype with vibrant colors, juicy animations, and photorealistic food assets.

---

## Milestone 1: The Foundation (Inputs & Overhead View)
*Core dependencies: Input mapping must exist before movement can be implemented.*

1. [x] **Input Map Configuration:**
    - Define actions in `project.godot`: `move_up` (W/Up), `move_down` (S/Down), `move_left` (A/Left), `move_right` (D/Right), `restart` (R), and `quit` (Esc).
2. [x] **Overhead Camera System:**
    - **Overhead Cam (Default):** A `Camera3D` providing a clear view of the entire 30x30 play area.
3. [x] **Initial Environment:**
    - Replace the temporary floor with a larger board.
    - **Glowing Walls:** Thick, colorful barriers using a `StandardMaterial3D` with high `emission_energy` to define the play area. Use `BoxShape3D` for collision.

## Milestone 2: Snake Head & Snap-Turning
*Core dependencies: Requires the Input Map and Environment from Milestone 1.*

1. [x] **Forward Movement:** 
    - Implement constant forward movement on the XZ plane. The snake never stops until it dies.
2. [x] **Snap Turning Logic:**
    - Classic screen-relative controls: WASD / Arrow Keys set absolute NSEW direction.
    - **Safety Check:** 180-degree reversals are rejected (e.g., if heading North, pressing Down/S is ignored).
3. [x] **Visuals:**
    - Update the `SnakeHead` mesh. Start with a vibrant cube; eventually, move to a modeled head with a hinged jaw for the "eating" animation.

## Milestone 3: The "Train" System (Body & Food)
*Core dependencies: Requires a moving Head to generate position history.*

1. [x] **Position History System:**
    - The head records its global position and rotation into an array/buffer every time it moves a certain distance (the "step size").
2. [x] **Body Segments:**
    - Spawn `MeshInstance3D` segments that follow the head's history. Each segment "occupies" a previous coordinate slot from the history buffer.
3. [x] **Food Spawner & Interaction:**
    - [x] **Spawner:** Randomly picks from high-quality realistic food models (Apple, Lychee, Sweet Potato).
    - [x] **Interaction:** Detect collision with food. 
    - [x] **Growth:** On eat, add a new segment to the tail, slightly increase `move_speed`, and play a "Squash and Stretch" tween on the head.

## Milestone 4: The Death Sequence (Physics & UI)
*Core dependencies: Requires functional collisions with walls and segments.*

1. [x] **Collision Logic:**
    - Detect collision with boundary walls or the snake's own body segments.
2. [x] **Dazed Animation:**
    - Spawn a "Dazed" node above the head. Use `GPUParticles3D` with box emission.
3. [x] **Game Over UI:**
    - Fade in a HUD with "Restart" and "Quit" options.

## Milestone 5: Technical Rigor & Validation
1. [x] **Validation Script (`validate.py`):**
    - Checks for:
        - Required Input Map actions.
        - Existence of the "Dazed" particle resource.
        - Proper collision layer/mask setup.
        - Headless execution for common GDScript errors.
2. [x] **Performance Optimization:**
    - Maintain 60+ FPS on Fedora's Vulkan Forward+ renderer.
    - Optimized `GPUParticles3D` for integrated graphics.

## Milestone 7: Realistic Graphics for Food
1. [x] **Model Integration:**
    - Replaced basic meshes in `Food.tscn` with high-quality 3D scans.
    - Assets: Use photorealistic GLTF models for Apple, Lychee, and Sweet Potato.
    - Automatic recursion logic to center meshes within their scene origin.
2. [x] **Visual Polishing:**
    - Apply PBR materials for vibrancy.
    - Implemented glowing `OmniLight3D` on each food item to ensure visibility in all lighting conditions.
    - Scale set to `10.0` for high-impact visual presence.

## Milestone 8: Realistic Garden Environment
1. [x] **Grass Floor:**
    - Replaced the checkered floor with a realistic grass shader.
    - Uses noise-based color variations to simulate natural terrain.
2. [x] **Garden Fence Walls:**
    - Replaced glowing walls with a garden fence visual.
    - Implemented a wooden plank shader for the boundaries.

## Milestone 9: Position History & Tail Following
*Core dependencies: Requires the body segment system from Milestone 3.*

1. [x] **High-Resolution History Buffer:**
    - Replaced the coarse 1.0-unit step distance with a `HISTORY_RESOLUTION` of `0.1` units, recording transforms 10x more frequently.
    - `SEGMENT_SPACING = 10` slots places segments 1.0 units apart (10 * 0.1).
2. [x] **Curved Path Following:**
    - Segments now follow the exact path taken by the head, including smooth curves around 90-degree turns.
    - Eliminates "corner-cutting" where segments would skip diagonally between two discrete points.
3. [x] **History Buffer Initialization:**
    - Buffer is seeded at startup with positions projected behind the head, preventing segments from spawning at `(0,0,0)`.
    - New segments are placed at the correct history index based on `SEGMENT_SPACING`.
4. [x] **Buffer Management:**
    - History is capped at `segments.size() * SEGMENT_SPACING + 1` entries to prevent unbounded growth.

## Milestone 10: Juice, Bug Fixes & Decoupling
*Core dependencies: Requires Milestones 3 and 4.*

1. [x] **Classic Screen-Relative Controls:**
    - Replaced head-relative left/right turning with absolute NSEW directional input (WASD + Arrow Keys).
    - Direction changes are applied at grid boundaries (every 1.0 unit via `grid_distance` tracker).
    - 180-degree reversals are rejected at input time.
2. [x] **Food Spawn Overlap Prevention:**
    - Food spawner checks distance to snake head (2.0 units) and all body segments (1.0 units).
    - Retries up to 50 times; warns and uses last attempted position on exhaustion.
3. [x] **Signal Decoupling:**
    - `SnakeHead` emits `score_changed` and `food_eaten` signals instead of using hardcoded node paths.
    - `Main.gd` orchestrates connections between `SnakeHead`, `HUD`, and `FoodSpawner`.
4. [x] **Unused Variable Cleanup:**
    - Removed `current_direction` and `next_direction` from `SnakeHead.gd`.

## Milestone 11: Grid Alignment & Refactoring
1. [x] **Logical Movement Decoupling:**
    - Separated logical movement (strict axis-aligned) from visual rotation (smoothly lerped).
    - Ensures 100% precision in grid alignment for food collection.
2. [x] **Centralized Constants:**
    - Created `GameConstants.gd` Autoload for global tuning (speed, grid size, resolutions).
3. [x] **Camera Consolidation:**
    - Removed Rider Camera and associated FPV effects (tilt, shake, death tumble).
    - Standardized on a single Overhead Camera.
4. [x] **Code Cleanup:**
    - Refactored project to remove legacy scripts (`CameraManager.gd`) and update validation logic.

---

## Ideas for Future Enhancements

- Power-ups (Speed boost, Slow motion).
- Different biomes (Neon Grid, Jungle, Candy Land).
- Jaw-moving animations synced with food consumption.
- First-person vs. Third-person (Chase) camera toggle.
- **"Fever Mode"**: Neon snake with rainbow trail after rapid food collection.
- **"Fruit Explosion"**: Colorful particle bursts when food is consumed.
- **"High-Five" Pop-ups**: Floating text labels ("AWESOME!", "JUICY!") on eat.

---

## REQUIREMENTS & ASSUMPTIONS

### 1. Board & Space
- **Board Size:** 30x30 units.
- **Grid Unit:** 1.0 (Snake segments are placed 1 unit apart).
- **Start Position:** Middle of the board `(0, 0.5, 0)`.
- **Start Direction:** North (Negative Z axis).

### 2. Movement & Physics
- **Initial Speed:** 5.0 units per second (5 grid units/sec).
- **Snap Turning:** Instant 90-degree logic for the snake body.
- **Collision Strategy:** Use `Area3D` for detection (Eating/Death) to ensure clean, non-physics-based logic for the core movement.

### 3. Controls & Inputs
- **Direction:** Classic screen-relative. `W`/Up = North, `S`/Down = South, `A`/Left = West, `D`/Right = East. 180-degree reversals are rejected.
- **Game State:** `R` for Restart, `Esc` for Quit.

### 4. Visual Aesthetic
- **Color Palette:** High-saturation PBR textures for food; stylized shaders for environment.
- **Cam:** Overhead perspective.

### 5. Asset Formats
- **Models:** `.glb` or `.gltf` (Binary GLTF preferred).
- **Pivot:** Origin `(0,0,0)` at the center of the mesh.
- **Scale:** Standardized to ~1.0 unit in the source file (scaled in-engine as needed).
- **Topology:** Photorealistic 3D scans preferred over basic primitives.
- **Materials:** Standard PBR (Albedo, Normal, Roughness) for realistic interaction with the Forward+ renderer.
