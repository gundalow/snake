extends Node

# Movement & Grid
const HISTORY_RESOLUTION: float = 0.1
const SEGMENT_SPACING: int = 10
const GRID_SIZE: float = SEGMENT_SPACING * HISTORY_RESOLUTION # 1.0

# Gameplay
const INITIAL_MOVE_SPEED: float = 5.0
const SPEED_INCREMENT: float = 0.2
const INVULNERABILITY_TIME: float = 0.5

# Board
const BOARD_SIZE: float = 28.0
const WALL_DISTANCE: float = 15.5

# Visuals
const TURN_INTERPOLATION_SPEED: float = 10.0
const FOOD_VISUAL_SCALE: float = 10.0

# UFO
const UFO_SPAWN_INTERVAL: float = 30.0
const UFO_SPEED: float = 10.0
const UFO_FLIGHT_HEIGHT: float = 5.0
const UFO_SCORE_PENALTY: int = 5
