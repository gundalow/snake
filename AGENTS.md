# Warpath Classic Development Guide

This document provides guidance for AI agents and developers working on the Warpath Classic rebirth.

## 🏗 Project Architecture
- **Three.js (WebGL):** Handles the "Space Combat" layer using an `OrthographicCamera` for a flat 2D aesthetic.
- **HTML/CSS (98.css):** Handles the "Command" layer (HUD, menus, stats) as an overlay to mimic Windows 95.
- **Galaxy State:** A central object managing planets, ships, and global economy.

## 🚀 Physics & Movement
- **Inertial Flight:** Ships use velocity and a friction coefficient (0.98) to simulate "space drag."
- **Coordinate System:** All movement is on the XY plane. Z is used for layer ordering (background at -1, game at 0, effects at 1+).
- **Collisions:** Simple distance-squared checks are used for performance instead of a heavy physics engine.

## 🛡 Combat & Systems
- **Drone Swarms:** Managed via `THREE.InstancedMesh` for high-performance rendering of 1,000+ units.
- **Weapon Energy (Charge):** Depletes on fire and recharges over time.
- **Shields:** Protect the ship but require manual repair/purchase at Starbases (Planets) in the current implementation.

## 📱 Mobile Considerations
- **Dual-Stick Controls:** Virtual joysticks for Navigation (left) and Firing (right).
- **Responsive Layout:** CSS media queries handle small screens by scaling HUD meters (0.8x) and shrinking joysticks (90px) to prevent overlap with the ticker.
- **Multi-touch:** Uses `pointerId` to track separate fingers for movement and shooting.

## 🛠 Development Commands
- `npx serve .`: Start a local development server.
- `python3 verify_mobile_v2.py`: Run Playwright verification for mobile layouts.

## 🚫 Anti-Patterns to Avoid
1. **Depth Buffer Issues:** When adding new visual effects, ensure their Z-position doesn't cause flickering or hide the UI.
2. **Direct State Mutation in Render:** Keep game logic (velocity updates, loyalty shifts) separate from Three.js render calls where possible.
3. **Ignoring Mobile Offsets:** The 50px left sidebar is constant; ensure game centering logic accounts for this offset on mobile.
