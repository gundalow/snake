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

## Milestone 12: Juice & Achievements
1. [x] **Score "Pop" Animation:**
    - Implemented a `Tween`-based animation that scales the score and turns it neon green for 0.2s on every point.
2. [x] **Achievement System:**
    - Created a fun, bouncy achievement pop-up system.
    - Added a queue to handle multiple achievements appearing at once.
    - Implemented milestones for score (every 10 points) and apple consumption (10, 20, 30, 50).
    - Included a library of snake and fruit puns for celebrations.

---

## Ideas for Future Enhancements

### Persistent Leaderboard
*   **Details:** On game startup, prompt the player for a name via a simple UI popup. Save scores (name + score) locally in `user://highscores.json`. If they beat a high score, celebrate it on the HUD!
*   **Why it's fun:** 10-year-olds love competing with friends or siblings to see their name at the top of a list.
*   **Questions:** How many scores should we keep? (Top 5? Top 10?)
*   **AI Vibe Codeable?** Yes, very easy with JSON storage and Godot's `FileAccess`.

### Circling Birdies & Daze Effect
*   **Details:** When the snake hits a wall, spawn 3D "birdie" or "star" icons that rotate in a circle above the head with a "chirp" sound.
*   **Why it's fun:** It adds a cartoonish "looney tunes" feel to the failure, making losing feel funny instead of frustrating.
*   **Questions:** Should they fade out after a few seconds or stay until restart?
*   **AI Vibe Codeable?** Yes, simple orbital math and an `AudioStreamPlayer3D`.

### Distinct Eating Audio (Munch vs. Crunch)
*   **Details:** Different foods have unique sounds. Apples = "Crunch", Lychees = "Slurp/Gulp", Sweet Potato = "Munch". For "yucky" foods like Broccoli or Sprouts, the snake makes "Urgh!", "Disgusting!", or even a hilarious "Vomit/Gag" sound.
*   **Why it's fun:** Adds sensory variety and hilarious "gross-out" humor that kids love.
*   **Questions:** Should we have a "Yuck" meter?
*   **AI Vibe Codeable?** Yes.

### The "Ouch!" Wall Collision
*   **Details:** A loud, cartoonish "Thud!" or "Bonk!" sound when the head hits a wall, accompanied by a quick camera shake and a "Cracked Glass" overlay effect on the screen (making it look like the snake hit the camera lens).
*   **Why it's fun:** It gives the impact physical weight and a funny visual consequence.
*   **Questions:** Should different walls have different crack patterns?
*   **AI Vibe Codeable?** Yes, a simple texture overlay and shake.

### Golden Apple Power-Up
*   **Details:** A rare 5% chance to spawn a glowing Golden Apple that gives +5 points and makes the snake glow rainbow for 5 seconds.
*   **Why it's fun:** Rare "jackpot" moments create excitement and high-value targets.
*   **Questions:** Should it disappear if not eaten quickly?
*   **AI Vibe Codeable?** Yes, just a rare spawn condition in `FoodSpawner`.

### Freeze/Slow-Mo Power-Up
*   **Details:** An "Ice Cube" item that slows down the snake's movement speed by 50% for 5 seconds, allowing for easier navigation.
*   **Why it's fun:** Gives the player a "tactical" advantage when the game gets too fast.
*   **Questions:** Should the music slow down too? (Yes, for effect!)
*   **AI Vibe Codeable?** Yes, modifying `Engine.time_scale` or just `move_speed`.

### Magnet Power-Up
*   **Details:** A "Magnet" item that pulls nearby food towards the snake's mouth from 3 units away.
*   **Why it's fun:** Makes it easier to "vacuum" up points without perfect precision.
*   **Questions:** How long should the magnet effect last?
*   **AI Vibe Codeable?** Yes, using `Area3D` to find foods and `move_toward` them.

### Ghost Mode (Intangible Tail)
*   **Details:** A "Ghost" item that lets the snake pass through its own tail for 5 seconds without dying.
*   **Why it's fun:** A "get out of jail free" card for when the snake is dangerously long.
*   **Questions:** Should the snake become semi-transparent?
*   **AI Vibe Codeable?** Yes, temporarily disabling collision mask 2.

### Rainbow Trail Particles
*   **Details:** The tail emits colorful sparkling particles that stay on the path for a second.
*   **Why it's fun:** High visual reward; it makes the snake look like a magical trail.
*   **Questions:** Will this impact performance if the snake is very long? (Use `GPUParticles3D`).
*   **AI Vibe Codeable?** Yes, simple particle emitter on the last tail segment.

### Fever Mode (Combo System)
*   **Details:** Eat 3 foods in under 10 seconds to enter "Fever Mode" where points are doubled and the screen has a colorful border.
*   **Why it's fun:** Encourages fast, aggressive play for higher scores.
*   **Questions:** What's the best visual indicator for the combo timer?
*   **AI Vibe Codeable?** Yes, using a simple timer and multiplier variable.

### Confetti Blast on Level Up
*   **Details:** Every 10 points, a huge burst of 3D confetti pops from the center of the board.
*   **Why it's fun:** Celebratory milestones keep morale high.
*   **Questions:** Should it be purely visual or have a sound effect?
*   **AI Vibe Codeable?** Yes, one-shot particle system.

### Floating Text ("Yum!", "Speed Up!")
*   **Details:** When eating food, a 2D text label pops up in 3D space, floats up, and fades out.
*   **Why it's fun:** Gives instant, quirky feedback.
*   **Questions:** Should the text be random or based on the food type?
*   **AI Vibe Codeable?** Yes, using \`Label3D\` and a \`Tween\`.

### Dynamic Music Tempo
*   **Details:** The background music starts slow and speeds up as the \`move_speed\` increases.
*   **Why it's fun:** Heightens the tension and excitement as the game progresses.
*   **Questions:** Does Godot's \`AudioStreamPlayer\` support real-time pitch/speed shifting? (Yes, via \`pitch_scale\`).
*   **AI Vibe Codeable?** Yes, trivial.

### Environmental Obstacles (Garden Gnomes)
*   **Details:** Randomly placed 3D obstacles like Garden Gnomes or rocks that the snake must dodge.
*   **Why it's fun:** Adds variety beyond just walls and tail-dodging.
*   **Questions:** Should obstacles move?
*   **AI Vibe Codeable?** Yes, similar to food spawning but with collision.


### Hinged Jaw Animation
*   **Details:** The snake head mesh has a "mouth" that opens wide when it gets within 1.5 units of a food item.
*   **Why it's fun:** Makes the snake feel "alive" and hungry.
*   **Questions:** Can we achieve this with simple mesh rotation or do we need bones? (Rotation is easier).
*   **AI Vibe Codeable?** Yes, check distance to \`foods\` group in \`_process\`.

### Tail Rattling Sound
*   **Details:** A subtle "rattlesnake" sound that gets louder as the snake gets longer.
*   **Why it's fun:** Adds a thematic, slightly spooky vibe for a long snake.
*   **Questions:** Should it only play when moving?
*   **AI Vibe Codeable?** Yes, simple volume mapping.

### Victory Lap Slow-Mo
*   **Details:** On death, if it's a new high score, the game enters 20% slow motion for 2 seconds before showing the menu.
*   **Why it's fun:** Gives the player a moment to process their epic accomplishment.
*   **Questions:** Will this interfere with the restart button?
*   **AI Vibe Codeable?** Yes, \`Engine.time_scale\`.


### Voice Lines ("Oops!", "Whoa!")
*   **Details:** Cute, high-pitched voice clips that play on eat or hit.
*   **Why it's fun:** Gives the snake a personality.
*   **Questions:** Should we use a child's voice or a synthesized cartoon voice?
*   **AI Vibe Codeable?** Yes, just triggering an \`AudioStreamPlayer\`.

### Food Particle Trails
*   **Details:** A faint trail of sparkles leading from the snake's head to the current food item.
*   **Why it's fun:** Helps younger kids find the food on a big 30x30 board.
*   **Questions:** Should this be an optional "Easy Mode" toggle?
*   **AI Vibe Codeable?** Yes, using a \`GPUParticles3D\` with \`target_position\`.

### Bouncing/Bobbing Food
*   **Details:** Food items gently float up and down and rotate.
*   **Why it's fun:** Makes them easier to see and more "video-gamey."
*   **Questions:** Sine wave or Tween? (Sine wave in \`_process\` is best).
*   **AI Vibe Codeable?** Yes, trivial.

### Impact Dust Clouds
*   **Details:** Small brown "poof" particles appear at the snake's head when it makes a 90-degree turn.
*   **Why it's fun:** Adds "weight" to the turn, making it feel like a drifting car.
*   **Questions:** Should the clouds be larger at higher speeds?
*   **AI Vibe Codeable?** Yes, trigger a one-shot particle system on turn.

### Day/Night Cycle
*   **Details:** The sun (\`DirectionalLight3D\`) slowly moves across the sky over 2 minutes, turning the grass orange at "sunset."
*   **Why it's fun:** Makes the world feel dynamic and alive.
*   **Questions:** Should night mode make it harder to see? (Probably not for 10-year-olds).
*   **AI Vibe Codeable?** Yes, rotating the light node.

### Rainy Weather Effect
*   **Details:** Rare chance for it to rain. Adds raindrop particles and a "pitter-patter" sound.
*   **Why it's fun:** Changes the mood and makes the game feel "fresh."
*   **Questions:** Should the grass look "shiny" (low roughness) when wet?
*   **AI Vibe Codeable?** Yes, simple environment/particle swap.

### Fluttering Butterflies
*   **Details:** Small, colorful butterfly meshes that fly around randomly and dash away if the snake gets close.
*   **Why it's fun:** "Distractions" that make the garden feel real.
*   **Questions:** Use a path-follow or simple random walk?
*   **AI Vibe Codeable?** Yes, simple AI behavior.

### High-Five Pop-ups
*   **Details:** Floating labels like "COOL!", "AWESOME!", "JUICY!" when eating 3 fruits in a row.
*   **Why it's fun:** Constant positive reinforcement.
*   **Questions:** How many variants do we need?
*   **AI Vibe Codeable?** Yes, random string from an array.

### Tail-Wagging Idle
*   **Details:** When the snake stops (if we ever add a pause/stop mechanic), the tail wags like a dog's.
*   **Why it's fun:** Cute and expressive.
*   **Questions:** Does it fit a constant-movement game?
*   **AI Vibe Codeable?** Yes.

### Speedometer Gauge
*   **Details:** A cool UI dial in the corner showing the current \`move_speed\`.
*   **Why it's fun:** Gives a sense of technical progression.
*   **Questions:** Analog or digital style?
*   **AI Vibe Codeable?** Yes, rotating a UI sprite based on a variable.

### Food Growth Spawn
*   **Details:** When a new food item spawns, it scales up from 0 to 1.0 with an "elastic" bounce.
*   **Why it's fun:** Much better than just "appearing" instantly.
*   **Questions:** Use a 0.2s tween?
*   **AI Vibe Codeable?** Yes, trivial.

### Blob Shadows
*   **Details:** A simple, dark circle sprite on the ground below the head and segments.
*   **Why it's fun:** Helps "ground" the 3D models and makes the depth easier to read.
*   **Questions:** Use a \`Decal\` or a \`Sprite3D\`? (Decal is better).
*   **AI Vibe Codeable?** Yes.

### Screen Flash on Eat
*   **Details:** A very subtle, 0.05s white flash on the HUD when food is eaten.
*   **Why it's fun:** Provides "impact" that feels like a camera flash.
*   **Questions:** Should it be colored based on the fruit? (Green for apple, red for lychee).
*   **AI Vibe Codeable?** Yes.

### Mini-Map Radar
*   **Details:** A small circle in the corner with a dot for the snake and a dot for the food.
*   **Why it's fun:** Helps with navigation on a large field.
*   **Questions:** Is it needed if the camera is already overhead?
*   **AI Vibe Codeable?** Yes.

### Snake Eyes Expressions
*   **Details:** Eyes change from dots to "X_X" on death, or wide circles when near food.
*   **Why it's fun:** Easy way to add character emotion.
*   **Questions:** Swap textures or change mesh scale?
*   **AI Vibe Codeable?** Yes, simple mesh swap.

### Exploding Fruit on Eat
*   **Details:** When eaten, the fruit mesh is hidden and replaced by 5-10 "chunks" (smaller meshes) that fly out in random directions.
*   **Why it's fun:** Very satisfying visual "destruction."
*   **Questions:** Will this clutter the board? (Make them fade quickly).
*   **AI Vibe Codeable?** Yes, spawning small physics bodies.

### 20 "Outside the Box" Weird Ideas

#### 1. Hayfever Hazard (Snake Sneezing)
*   **Details:** Rare "Flower" items spawn. If eaten, the snake lets out a giant "ACHOO!" sound, the screen shakes violently, and the snake get a 1-second 3x speed boost forward.
*   **Why it's fun:** It’s funny, unexpected, and adds a "danger" element to certain items.
*   **Questions:** Can the sneeze push the snake through a wall? (Maybe it should be a "super-jump").
*   **AI Vibe Codeable?** Yes, simple timer and speed multiplier.

#### 2. Sassy Barriers (Talking Walls)
*   **Details:** When the snake gets within 2 units of a wall, a speech bubble pops up from the wall saying things like "Watch it, buddy!" or "Going somewhere?".
*   **Why it's fun:** Gives the environment a "living" personality.
*   **Questions:** Will too many bubbles be annoying? (Limit to one at a time).
*   **AI Vibe Codeable?** Yes, distance check + \`Label3D\`.

#### 3. Accessory Apple (Snake Hats)
*   **Details:** Eating a special "Bowtie" or "Crown" item puts a random 3D hat on the snake's head for the rest of the run.
*   **Why it's fun:** 10-year-olds love customizing characters and collecting "skins."
*   **Questions:** Do hats stack? (A tower of hats would be hilarious).
*   **AI Vibe Codeable?** Yes, just parent a mesh to the head.

#### 4. Inflatable Mode (Balloon Snake)
*   **Details:** A power-up that turns the snake into a balloon. If you hit a wall, you don't die—you just bounce off like a pinball for 3 seconds before turning back.
*   **Why it's fun:** Flips the "don't hit walls" rule on its head.
*   **Questions:** Does the snake "deflate" with a squeaky sound? (Must have!).
*   **AI Vibe Codeable?** Yes, using \`bounce\` physics or simple vector reflection.

#### 5. Graffiti Glider (Paint Trail)
*   **Details:** The snake leaves a permanent neon paint trail on the grass. You can "draw" shapes on the board while playing.
*   **Why it's fun:** Adds a creative "drawing" aspect to the movement.
*   **Questions:** Does the trail cause lag if it never disappears? (Use a simple plane mesh with limited segments).
*   **AI Vibe Codeable?** Yes, similar to the history system but spawning static meshes.

#### 6. Sentient Snacks (Food Fight)
*   **Details:** Food items have little legs and try to run away when you get within 5 units.
*   **Why it's fun:** Turns a "collecting" task into a "hunting" task.
*   **Questions:** Should they be able to run out of bounds?
*   **AI Vibe Codeable?** Yes, simple \`move_toward\` (away from snake).

#### 7. Dimensional Warp (Wormholes)
*   **Details:** Two swirling portals spawn. Enter one, come out the other.
*   **Why it's fun:** Creates "teleportation" shortcuts and mind-bending paths.
*   **Questions:** What happens if the tail is still halfway through a portal?
*   **AI Vibe Codeable?** Yes, coordinate offset.

#### 8. Propulsion Pear (Jetpack)
*   **Details:** A "Pear" with a rocket on it. Gives the snake 3 seconds of "flight," hovering 2 units above the ground (and its own tail).
*   **Why it's fun:** It’s a literal jetpack for a snake.
*   **Questions:** Does the camera zoom out during flight?
*   **AI Vibe Codeable?** Yes, modifying \`global_position.y\`.

#### 9. Galactic Greed (UFO Abduction)
*   **Details:** A UFO randomly appears and tries to tractor-beam a fruit before you can get to it. You have to "race" the aliens.
*   **Why it's fun:** Adds a "rival" character to the game.
*   **Questions:** Can the snake be abducted? (Maybe it just gets a "lift").
*   **AI Vibe Codeable?** Yes, simple NPC behavior.

#### 10. Step-Sequencer Grass (Musical Floor)
*   **Details:** Each grid square (1.0 x 1.0) plays a different musical note when the head passes over it.
*   **Why it's fun:** You can "compose" a song by choosing your path.
*   **Questions:** Will it sound like "noise"? (Lock it to a specific musical scale like Pentatonic).
*   **AI Vibe Codeable?** Yes, \`AudioStreamPlayer\` with pitch shifts.

#### 11. Stealth Slither (Invisible Mode)
*   **Details:** Power-up makes the snake's body invisible, leaving only two floating, glowing eyes.
*   **Why it's fun:** It feels "sneaky" and mysterious.
*   **Questions:** Is it too hard to see where the tail is? (Add a faint particle "ghost" trail).
*   **AI Vibe Codeable?** Yes, toggling \`visible\` property.

### The Mega-Melon (Giant Food)
*   **Details:** A "Watermelon" that is 5x the size of normal food. It takes 3 "bites" (passes) to fully eat it, giving 5 segments. After the final bite, there is a 1-second silence, followed by a massive, earth-shaking "BURP!" sound.
*   **Why it's fun:** Giant things and burps are a guaranteed win for 10-year-olds.
*   **Questions:** Does the burp push nearby food away?
*   **AI Vibe Codeable?** Yes.


#### 13. Confusion Carrot (Reverse Controls)
*   **Details:** Eating a "Purple Carrot" reverses your controls (Left becomes Right, etc.) for 5 seconds.
*   **Why it's fun:** It’s a "troll" item that creates hilarious panic.
*   **Questions:** Should the UI also flip upside down? (That might be too much!).
*   **AI Vibe Codeable?** Yes, simple input logic flip.

#### 14. Tectonic Tussle (Earthquake)
*   **Details:** Every 30 seconds, a giant "World-Stomper" foot appears in the background (outside the fence) and stomps, or giant mole hills pop up, causing the board to shake. All food items "jump" to new random locations due to the impact.
*   **Why it's fun:** It gives a reason for the randomness and makes the world feel larger and more dangerous.
*   **Questions:** Can the stomper foot hit the snake? (Probably too hard for now).
*   **AI Vibe Codeable?** Yes, timer + \`spawn_food()\` calls.

#### 15. The Mimic Menace (Clone Snake)
*   **Details:** A "Mirror" item spawns a ghost snake that exactly replicates your movements 2 seconds later. If you hit the ghost, you die.
*   **Why it's fun:** You are literally playing against your own past self.
*   **Questions:** Does the ghost disappear after a while?
*   **AI Vibe Codeable?** Yes, using a second history-based follower.

#### 16. Black Hole Banana (Gravity Well)
*   **Details:** A "Black Hole Banana" that pulls the snake slightly toward it as you pass by, making turning harder.
*   **Why it's fun:** Adds a "physics" challenge to the steering.
*   **Questions:** Can it pull the snake into a wall?
*   **AI Vibe Codeable?** Yes, adding a force vector to movement.

#### 17. Celebration Celery (Fireworks)
*   **Details:** Eating "Celery" causes the tail to launch 3 fireworks into the sky.
*   **Why it's fun:** Pure visual "wow" factor.
*   **Questions:** Can fireworks hit the UFO? (Bonus points!).
*   **AI Vibe Codeable?** Yes, one-shot particle burst.

#### 18. Drone POV (Camera Swap)
*   **Details:** A rare power-up that detaches the camera and makes it "follow" the snake from a cinematic, drifting FPV perspective for 10 seconds.
*   **Why it's fun:** Changes the "look" of the game completely for a short burst.
*   **Questions:** Is it too disorienting?
*   **AI Vibe Codeable?** Yes, lerping camera position.

#### 19. Disco Dance Floor
*   **Details:** Every time the snake eats, the grass tiles switch colors randomly for 5 seconds like a disco floor.
*   **Why it's fun:** High-energy visual reward.
*   **Questions:** Use a shader or change material colors? (Shader is better).
*   **AI Vibe Codeable?** Yes.

#### 20. Snake Slinky Physics
*   **Details:** A "Slinky" item that makes the segments "stretch" and "contract" like a spring as you move.
*   **Why it's fun:** It looks goofy and tactile.
*   **Questions:** Will it break the grid alignment? (Only visually, keep logic snapped).
*   **AI Vibe Codeable?** Yes, lerping segment positions with an "elastic" curve.

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
# POSSIBLE BUGS

1. **Input Overwriting:** The `next_heading` system only stores one pending turn. If a player presses "Right" then "Up" extremely quickly before the next grid boundary, the "Right" turn is lost, making the controls feel "unresponsive" during high-APM play.
2. **High-Speed Grid Skipping:** If `move_speed` increases to the point where `delta * move_speed > GameConstants.GRID_SIZE`, the snake could theoretically teleport past a grid boundary without triggering a turn or a position snap.
3. **Food Spawner Dependency:** `FoodSpawner.gd` uses `get_node_or_null("../SnakeHead")`. If the `SnakeHead` node is renamed or moved in the scene tree, food spawning will fail silently or crash.
4. **Collision Precision:** The `DeathRay` length is `0.6`. Since the head is `1.0` units wide (0.5 radius), a ray of `0.6` only extends `0.1` units beyond the mesh. At very high speeds, the snake might penetrate a wall's collision volume before the ray detects it.
5. **Position History Desync:** If the game frame rate drops significantly, `distance_traveled` might exceed `HISTORY_RESOLUTION` by a large margin in a single frame, but only one history entry is recorded per frame. This could cause segments to appear to "stretch" or lag behind during lag spikes.
6. **Invulnerability Window:** The `invulnerability_timer` is hardcoded to `0.5s`. At very slow speeds (if implemented later), this might not be enough time for the first segments to clear the head's start position.
