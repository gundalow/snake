# Python 2D Snake Project Plan

## Overview
**Objective:** A high-engagement 2D Snake game re-implemented in Python/Pygame, featuring cartoon-style graphics, juicy animations, and dynamic environmental events tailored for a 10-year-old audience.

---

## Completed Milestones
- [x] **Core Python Engine:** Pygame setup, `requirements.txt`, and modular project structure.
- [x] **Smooth Movement:** Grid-locked snap turning with a high-resolution history buffer for path-accurate tail following.
- [x] **Food System:** Normal foods (Apple, Lychee, Sweet Potato) and the complex Mega-Melon (3 bites, speed reduction, burp delay).
- [x] **Random Events (30-50s):**
    - **UFO:** Abducts fruit and penalizes score.
    - **World Stomper:** Shadow warning, screen shake, and food relocation.
- [x] **Persistence:** JSON-based leaderboard and name selection with entry history.
- [x] **Juice & Visuals:** Scale-pop animations, dazed death stars, score flashing, and cartoon confetti.
- [x] **Audio:** Integrated `AudioManager` for eating, spawning, and event transitions.
- [x] **CI/CD:** GitHub Actions workflow with automated Python unit tests.

---

## Future Enhancements & Next Steps

### 🎨 Visual Variety (Cartoon Juice)
- **Hinged Jaw Animation:**
  - *Implementation:* When the head is within 60px (2 grids) of a food item, swap the head rectangle for one with a "mouth open" polygon or wider scale.
- **Rainbow Trail Power-up:**
  - *Implementation:* Add a rare "Star Fruit" that, when eaten, cycles the `COLOR_SNAKE` constant through a list of bright hues for 10 seconds.
- **Impact Dust Clouds:**
  - *Implementation:* On 90-degree turns, spawn a list of small gray circles that fade out (`alpha` decrease) and expand over 0.5s.

### 🔊 Sound & Feedback
- **Tail Rattling:**
  - *Implementation:* Play a looped "shake" sound whose volume is mapped to `snake.num_segments`.
- **Dynamic Music Tempo:**
  - *Implementation:* Use `pygame.mixer.music` to play a track and increase `pitch_scale` (if supported by library) or swap tracks at higher `base_move_speed`.

### 🎮 New Game Dynamics
- **Balloon Mode (Power-up):**
  - *Implementation:* Eating a "Balloon Berry" makes the snake invulnerable to wall collisions for 5s. If it hits a wall, reverse the `heading` vector and play a "squeak" sound.
- **Hayfever Hazard (Sneezing):**
  - *Implementation:* A "Flower" item that triggers a massive screen shake (`screen_shake = 50`) and a 1s 3x speed boost forward.
- **Sentient Snacks:**
  - *Implementation:* Add a `velocity` to certain food items that moves them away from `snake.pos` if the distance is less than 150px.

### 🛠 Technical Rigor
- **Level System:** Increase `BOARD_SIZE` or add "Gnome" obstacles as the player hits score milestones (20, 50, 100).
- **Controller Support:** Add support for `pygame.JOYAXISMOTION` to allow playing with a gamepad.
