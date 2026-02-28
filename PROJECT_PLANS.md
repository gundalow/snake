# Project Plans - Future Enhancements

## 1. Entertainment for 10-Year-Olds
To make the game more "juicy" and entertaining:

- **"Fever Mode"**: When the player eats 5 foods in rapid succession, the snake should turn neon and move faster, leaving a rainbow trail of light.
- **"Fruit Explosion"**: Instead of food just disappearing, it should burst into colorful particles (e.g., apple juice splashes, lychee seeds) when consumed.
- **"Dynamic Screen Shake"**: Add a subtle "punchy" camera shake when the snake eats and a "chaotic" one during the crash sequence.
- **"High-Five" Pop-ups**: Use floating 2D text labels like "AWESOME!", "JUICY!", or "WHOA!" that pop up near the snake's head upon eating.
- **"Collectable Trails"**: Add rare "Golden Cherries" that give the snake a temporary glowing aura or trail.

## 2. Maintenance & Code Quality
- **Decoupling**: Remove hardcoded node paths in `SnakeHead.gd` and use signals to communicate with the `HUD` and `FoodSpawner`.
- **Snake Scene Independence**: Ensure `SnakeHead` can be tested in isolation by providing optional or default references.
- **Grid-Aligned Movement**: Solidify the move-then-turn logic to ensure the snake always turns exactly at the center of a grid cell.

## 3. Advanced Features
- **First-Person Camera Dynamics**: Add subtle "leaning" during turns (already partially implemented with `camera_tilt`).
- **Jaw Animations**: Model the `SnakeHead` with a mouth that opens as it approaches food.
- **Thematic Biomes**: Create different "Gardens" or "Kitchens" as levels with unique music and lighting.
