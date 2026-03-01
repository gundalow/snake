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

# Mega Food
const MEGA_FOOD_INITIAL_SCALE: float = 6.0
const MEGA_FOOD_BITES_TO_FINISH: int = 3
const MEGA_FOOD_SPEED_MULTIPLIER: float = 0.5

const FOOD_MODELS = {
	"apple": preload("res://assets/models/food/apple/food_apple_01_4k.gltf"),
	"lychee": preload("res://assets/models/food/lychee/food_lychee_01_4k.gltf"),
	"sweet_potato": preload("res://assets/models/food/sweet_potato/sweet_potato_4k.gltf")
}

const MEGA_FOOD_MODELS = {
	"mega_melon": preload("res://assets/models/food/mega_melon/scene.gltf")
}
