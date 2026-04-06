extends Node

# Movement & Logic (2.5D Pixel-based)
const INVULNERABILITY_TIME: float = 0.5
const INITIAL_MOVE_SPEED: float = 300.0
const SEGMENT_SPACING: int = 15
const HISTORY_RESOLUTION: float = 1.0
const GRID_SIZE: float = 32.0
const SPEED_INCREMENT: float = 10.0
const TURN_INTERPOLATION_SPEED: float = 10.0
const MEGA_FOOD_SPEED_MULTIPLIER: float = 0.5
const BOARD_SIZE: float = 1000.0

# Food (2.5D Logic)
const MEGA_FOOD_BITES_TO_FINISH: int = 3
const FOOD_VISUAL_SCALE: float = 1.0
const MEGA_FOOD_INITIAL_SCALE: float = 2.0
const MEGA_FOOD_MID_SCALE: float = 1.5
const MEGA_FOOD_MIN_SCALE: float = 1.0

# UFO (2.5D Logic)
const UFO_SPEED: float = 200.0
const UFO_FLIGHT_HEIGHT: float = 0.0
const UFO_SCORE_PENALTY: int = 5
const UFO_SPAWN_INTERVAL: float = 30.0

# UI
const FUEL_INCREMENT: int = 1

# Resource Dictionaries (Fixed syntax for scripts)
const FOOD_MODELS = {}
const MEGA_FOOD_MODELS = {}
const FOOD_MODEL_SCALES = {}
