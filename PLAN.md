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
*   **Mobile Support:** Capacitor for Android deployment, with custom touch-to-keyboard mapping and virtual joystick.
*   **Performance:** `THREE.InstancedMesh` for large-scale unit swarms (drones).

---

## 3. Game Mechanics

### A. Flight Physics (Inertia & Friction)
*   **Thrust:** Applying force in the direction the ship is facing.
*   **Rotation:** Turning the ship on its center axis.
*   **Friction:** A constant coefficient (0.98) applied to velocity every frame.
*   **Initial Facing:** Ship starts facing the nearest primary objective.

### B. The Loyalty System
*   **Influence Radius:** Every planet has a capture radius (default: 150 units).
*   **Loyalty Value:** Ranges from -100 to 100.
*   **Capture Logic:** Orbiting shifts loyalty toward your faction (+0.1 per frame).
*   **Ownership:** At 100 loyalty, the planet mesh changes to Cyan (Player) or Red (Rival).

### C. The Empire Engine (Economy)
*   **Population Growth:** Owned planets grow population exponentially.
*   **Tax Revenue:** Credits are generated based on `TotalPopulation * TaxRate`.
*   **Upgrades:** Spend Credits at the Starbase Shop for speed, damage, and shield capacity.

### D. Drone Swarms (Planetary Defense)
*   **Swarm Logic:** Each owned planet maintains a swarm of drones.
*   **Orbit/Intercept:** Drones orbit planets and break away to chase enemies within range.

---

## 4. Development Milestones (ALL COMPLETE)

### Milestone 1: The Kinetic Loop (Done)
- [x] Three.js scene setup with Orthographic Camera.
- [x] Player ship with inertia/friction physics.
- [x] Basic planet capture logic.
- [x] HUD with 98.css styles.

### Milestone 2: The Empire Engine (Done)
- [x] Exponential population growth and taxation system.
- [x] Drone swarm defense using `InstancedMesh`.
- [x] Virtual Joystick and Fire Button mobile controls.
- [x] Scrolling Galactic Ticker UI.

### Milestone 3: The Rival Path (Done)
- [x] AI-controlled rival ship (Red).
- [x] AI state machine: Search -> Convert -> Defend.
- [x] Ship health (HP/Shields) and hit flicker VFX.

### Milestone 4: The Galactic Theater (Done)
- [x] Starbase Shop for ship upgrades.
- [x] Win/Loss conditions (Timed rounds & destruction).
- [x] Sound effects (8-bit square wave blips).
- [x] Particle destruction effects.
