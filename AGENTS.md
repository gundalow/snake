# VibeSnake 2.5D Development Guide

This document provides guidance for AI agents and developers working on this codebase.

## 🏗 Project Architecture
- **Vanilla JS + Three.js:** The game uses Three.js for rendering and vanilla JavaScript for game logic.
- **2.5D View:** Uses an `OrthographicCamera` positioned at `(30, 30, 30)` to achieve an isometric look.
- **Capacitor Integration:** Uses `@capacitor/haptics` for mobile feedback. Always provide a fallback for browser environments.

## 🐍 Snake Logic
- **Grid Coordinates:** The game logic operates on a 2D grid (`x`, `z`). Rendering converts these to 3D space (`x - GRID_SIZE/2 + 0.5`, `0.5`, `z - GRID_SIZE/2 + 0.5`).
- **Input Handling:** To prevent self-collision via rapid input, always validate `nextDirection` against the current `direction`. Only the last valid input per tick is processed.
- **Food Spawning:** Always use the `emptySlots` method to spawn food to avoid infinite recursion when the grid is full.

## 🚫 Anti-Patterns to Avoid
1.  **Direct DOM for Game Objects:** Never use DOM elements for snake segments or food. Use Three.js meshes.
2.  **`setInterval` for Game Loop:** Use `requestAnimationFrame` with a time-delta check for consistent movement speed across different refresh rates.
3.  **Recursive Spawning:** Avoid simple `Math.random` recursion for food spawning; it's unreliable as the snake grows.
4.  **Excessive Object Creation:** While the current implementation recreates snake meshes for simplicity, in larger games, reuse `Geometry` and `Material` instances.
5.  **Hardcoded Initial State:** When resetting, ensure all state variables (including `gameStarted`, `isGameOver`, and `lastMoveTime`) are correctly reset to their initial values.

## 📱 Mobile Considerations
- **Touch Events:** Use `passive: false` and `preventDefault()` on `touchmove` to prevent browser scrolling during gameplay.
- **Haptics:** Wrap haptic calls in `try/catch` blocks to ensure the game remains playable in environments where the Capacitor plugin is missing or fails.
- **UI Scaling:** Ensure the `OrthographicCamera` frustum is updated on window resize to maintain the correct "vibe" across different screen sizes.

## 🛠 Development Commands
- `npx serve .`: Start a local development server.
- `npm run build`: Placeholder for web asset optimization.
