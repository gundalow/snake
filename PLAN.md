# Warpath Classic: Rebirth Plan & Specification

## 1. Vision & Design Philosophy
**Warpath Classic** is a modern web-based rebirth of the 1994 space conquest classic. It is a high-speed, 2D real-time strategy game where the player controls a single ship—representing an entire empire's "Path"—to conquer the galaxy through proximity, investment, and tactical defense.

### Core Pillars
*   **Vector Aesthetic:** Neon geometry on a pitch-black background.
*   **Operating System UI:** A "Dual-Layer" approach where WebGL handles combat and HTML/98.css handles the "command terminal" interface.
*   **Inertial Flight:** Physics-based movement that prioritizes drift and momentum.
*   **Passive Conquest:** Capturing planets by orbiting them and winning "hearts and minds" rather than landing troops.

---

## 2. Technical Stack
*   **Engine:** Three.js (WebGL) for the space scene.
*   **UI Framework:** 98.css (Retro Windows 95 stylesheet) for the HUD and menus.
*   **Physics:** Custom 2D Euler integration (Inertia + Friction).
*   **Mobile Support:** Capacitor for Android deployment, with custom touch-to-keyboard mapping.
*   **Performance:** `THREE.InstancedMesh` for large-scale unit swarms (drones).

---

## 3. Game Mechanics

### A. Flight Physics (Inertia & Friction)
*   **Thrust:** Applying force in the direction the ship is facing.
*   **Rotation:** Turning the ship on its center axis.
*   **Friction:** A constant coefficient (0.98) applied to velocity every frame to simulate "space drag" and ensure the player doesn't drift infinitely.
*   **Initial Facing:** At game start, the ship should be oriented toward the nearest primary objective.

### B. The Loyalty System
*   **Influence Radius:** Every planet has a capture radius (default: 150 units).
*   **Loyalty Value:** Ranges from -100 to 100.
*   **Capture Logic:** If a ship orbits within the influence radius, loyalty shifts toward that ship's faction (+0.1 per frame).
*   **Ownership:** At 100 loyalty, the planet mesh changes to the faction's color (Cyan for Player, Red for Rival).

### C. The Empire Engine (Economy)
*   **Population Growth:** Owned planets grow population exponentially ($Pop = Pop * 1.0001$ per frame).
*   **Tax Revenue:** Credits are generated every second based on `TotalPopulation * TaxRate`.
*   **Capture Cost:** Actively influencing a planet drains credits to simulate the "investment" in loyalty.

### D. Drone Swarms (Planetary Defense)
*   **Swarm Logic:** Each owned planet maintains a swarm of 5 triangle drones.
*   **Orbit Behavior:** Drones circle their parent planet at varying speeds and distances.
*   **Intercept Behavior:** If a non-aligned ship enters the system (within 300 units), drones break orbit to intercept and chase the target.

---

## 4. Implementation Details

### Coordinate System & Rendering
*   **Camera:** `OrthographicCamera` looking down the Z-axis. XY plane is the field of play.
*   **Units:** View size of 1000 units. Ships are ~20-30 units; Planets are ~30-60 units.
*   **Rendering Loop:** 60 FPS target.

### Control Mapping
*   **Desktop:** `W` (Thrust), `A/D` (Rotate), `Space` (Fire).
*   **Mobile:**
    *   `touchstart`: Enable Thrust.
    *   `touchmove`: Map horizontal delta to Rotation (Left/Right).
    *   `touchend`: Disable Thrust, Trigger Fire.

### UI Architecture
*   **Layer 0 (WebGL):** The Starfield, Planets, Drones, and Ships.
*   **Layer 1 (HTML Overlay):** 98.css windows for "Ship Comms" (stats) and a scrolling "Galactic News Ticker" for flavor and alerts.

---

## 5. Development Milestones

### Milestone 1: The Kinetic Loop (Done)
- [x] Three.js scene setup with Orthographic Camera.
- [x] Player ship with inertia/friction physics.
- [x] Basic planet capture logic.
- [x] HUD with 98.css styles.

### Milestone 2: The Empire Engine (Done)
- [x] Exponential population growth and taxation system.
- [x] Drone swarm defense using `InstancedMesh`.
- [x] Mobile touch control integration.
- [x] Scrolling Galactic Ticker UI.

### Milestone 3: The Rival Path (Done)
- [x] AI-controlled rival ship (Red).
- [x] AI state machine: Search -> Convert -> Defend.
- [x] Ship health (HP/Shields) and hit flicker VFX.

### Milestone 4: The Galactic Theater (Pending)
- [ ] Starbase Shop for ship upgrades (Speed, Damage, Shields).
- [ ] Win/Loss conditions (5-minute timed rounds).
- [ ] Sound effects (8-bit square wave blips).
