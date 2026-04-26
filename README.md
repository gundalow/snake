# Warpath Classic (Modern Web Rebirth)

A high-speed, 2D real-time strategy game where you control a single ship to "flip" planets to your cause.

## Core Features
- **Vector-style Graphics:** Clinical 2D wireframe geometry and neon colors on a black void.
- **Inertia Physics:** Floaty, momentum-based flight with "space drag" (0.98 friction).
- **Dual-Layer UI:** High-speed WebGL space combat with a **98.css** retro Windows overlay for command and control.
- **Conquest & Economy:** Proximity-based planet loyalty system. Captured planets grow population and generate credits via taxation.
- **Living Galaxy:** High-performance drone swarms (1,000+ units) orbit planets and defend against intruders.
- **AI Rival:** A Red ship that competes for planetary control using the same capture logic.
- **Ship Systems:** Managed Energy, Charge, Cargo, and Shields. Upgrade your ship at Starbases.

## Controls
### Desktop
- `W`: Thrust forward
- `A` / `D`: Rotate ship
- `Space`: Fire Phaser
- `C`, `G`, `O`, `T`: Switch UI panels (Comm, Galaxy, Orbit, Tactical)

### Mobile
- **Left Joystick (NAV):** Thrust and steering.
- **Right Joystick (FIRE):** Directional firing.
- **Sidebar Buttons:** Tap icons to switch views.

## Technical Stack
- Three.js (Rendering)
- 98.css (UI)
- Vanilla JavaScript (Game Logic)

## Development
To run locally:
1. Use a local development server (e.g., `npx serve .`).
2. Open the URL in your browser.
