extends Node3D

@export var fruit_scene: PackedScene = preload("res://scenes/main/Fruit.tscn")
@export var spawn_interval: float = 3.0
@export var board_size: float = 28.0 # Slightly smaller than 30 to avoid walls

var spawn_timer: float = 0.0
var first_spawn: bool = true

func _ready() -> void:
	# Initial spawn
	spawn_fruit()

func _process(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_fruit()

func spawn_fruit() -> void:
	var x: float
	var z: float
	
	if first_spawn:
		# First fruit is halfway between snake (0,0,0) and North wall (-15)
		x = 0.0
		z = -7.5
		first_spawn = false
		print("Placing first fruit at guaranteed position: (0, 0.5, -7.5)")
	else:
		# Random position on XZ plane
		x = randf_range(-board_size / 2.0, board_size / 2.0)
		z = randf_range(-board_size / 2.0, board_size / 2.0)
	
	var fruit = fruit_scene.instantiate()
	fruit.position = Vector3(x, 0.5, z)
	add_child(fruit)
	print("Spawned fruit at: ", fruit.position)
