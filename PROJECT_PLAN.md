# Python 2D Snake Project Plan

## Milestone: Python Foundation
- [x] Create `requirements.txt` with Pygame.
- [x] Initialize project structure (`src/core`, `src/utils`, `src/ui`).
- [x] Setup unit testing framework in `tests/`.

## Milestone: Core Mechanics
- [x] **Snake Movement:** Smooth grid-based movement with history buffer.
- [x] **Segment System:** Tail segments follow the head's exact path.
- [x] **Food System:** Different types (Apple, Lychee, Sweet Potato).
- [x] **Mega-Melon:** 3-bite mechanic with speed reduction.

## Milestone: Events & Interaction
- [x] **Event Manager:** Randomly triggers events every 30-50 seconds.
- [x] **UFO Event:** Steals food and penalizes score.
- [x] **World Stomper:** Screen shake and food relocation.
- [x] **Persistence:** JSON leaderboard and name entry.

## Milestone: Visual Juice & Audio
- [x] **Cartoon Graphics:** Primitive-based cartoon style with scale-pops.
- [x] **Audio Integration:** Sfx for eating, burping, and spawning.
- [x] **Death Feedback:** Dazed stars and game over UI.

## Milestone: CI/CD
- [x] **GitHub Actions:** Automated unit tests on push/pull request.
- [x] **Project Metadata:** Updated README and AGENTS.md.
