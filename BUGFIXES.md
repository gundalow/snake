# Code Review & Bug Report: Python 2D Snake

This document tracks fixes and improvements made during the transition from Godot 3D to Python 2D.

## 🟢 Critical Logic Fixes
- **Broken Imports:** Fixed `ImportError` by standardizing on absolute imports relative to the `src` directory and correctly configuring `sys.path` in `main.py`.
- **UFO Physics:** Fixed "teleportation" bug where UFO moved instantly due to missing `delta_time` scaling in movement vectors.
- **Mega-Melon Consumption:** Fixed "instant eat" bug by implementing a `bite_cooldown`. Previously, the snake could take 3 bites in 3 frames, effectively bypassing the challenge.
- **Scoring Desync:** Fixed logic where score and segments were incremented even if a bite was on cooldown.
- **Leaderboard Persistence:** Fixed high-score celebration where the "Personal Best" check was performed after the current score was already submitted, causing it to always return false.

## 🟡 Visual & Animation Fixes
- **Grid Drawing Shake:** Fixed grid lines not following the screen shake offset, causing visual tearing during World Stomper events.
- **Snake Pathing:** Resolved history buffer initialization errors that caused segments to spawn at `(0,0)` on game start.
- **Confetti Flicker:** Improved the high-score celebration by increasing the particle count and adding size variety to the "cartoon confetti."

## 🔵 UI & Interaction Improvements
- **Name Selection:** Enhanced the `NamePrompt` to support arrow-key selection of previous player names from the JSON history.
- **HUD Alerts:** Added a "flash red" effect to the score display when a UFO successfully steals food.
- **Status Messages:** Implemented the "Too much melon!" warning message when the snake is slowed down.

## 🟣 Audio Fixes
- **Asset Pathing:** Fixed brittle relative paths in `AudioManager` to use a robust `PROJECT_ROOT` base path, ensuring sounds play correctly regardless of launch directory.
- **Burp Variety:** Added logic to randomly select from multiple burp sound files for the Mega-Melon conclusion.
- **Graceful Failover:** Implemented try-except blocks to prevent game crashes if audio files are missing or corrupted.
