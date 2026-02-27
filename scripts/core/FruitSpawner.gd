extends Node3D

@export var fruit_scene: PackedScene = preload("res://scenes/main/Fruit.tscn")
@export var spawn_interval: float = 3.0
@export var board_size: float = 28.0 # Slightly smaller than 30 to avoid walls

var spawn_timer: float = 0.0

func _ready() -> void:
	# Initial spawn
	spawn_fruit()

func _process(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_fruit()

func spawn_fruit() -> void:
	# Random position on XZ plane
	var x = randf_range(-board_size / 2.0, board_size / 2.0)
	var z = randf_range(-board_size / 2.0, board_size / 2.0)
	
	var fruit = fruit_scene.instantiate()
	add_child.call_deferred(fruit)
	# Wait for the next frame to ensure it's in the tree before setting global_position
	(func(): fruit.global_position = Vector3(x, 0.5, z)).call_deferred()
