extends Node3D

@export var food_scene: PackedScene = preload("res://scenes/main/Food.tscn")
@export var spawn_interval: float = 3.0
@export var board_size: float = 28.0 # Slightly smaller than 30 to avoid walls

var spawn_timer: float = 0.0
var first_spawn: bool = true

func _ready() -> void:
	# Initial spawn
	spawn_food()

func _process(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_food()

func spawn_food() -> void:
	var x: float
	var z: float
	
	if first_spawn:
		# First food is halfway between snake (0,0,0) and North wall (-15)
		x = 0.0
		z = -7.5
		first_spawn = false
		print("Placing first food at guaranteed position: (0, 0.5, -7.5)")
	else:
		# Random position on XZ plane
		x = randf_range(-board_size / 2.0, board_size / 2.0)
		z = randf_range(-board_size / 2.0, board_size / 2.0)
	
	var food = food_scene.instantiate()
	food.position = Vector3(x, 0.5, z)
	add_child(food)
	print("Spawned food at: ", food.position)
