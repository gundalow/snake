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
	var spawn_pos = Vector3(x, 0.5, z)
	
	# Basic check for existing snake segments or fruits at this position
	# In a real Godot project, we might use PhysicsDirectSpaceState3D.intersect_ray
	# or similar, but since we're Area3D-based, we'll instantiate and check for overlapping
	var fruit = fruit_scene.instantiate()
	add_child.call_deferred(fruit)

	(func():
		fruit.global_position = spawn_pos
		# Give physics engine one frame to update overlapping areas
		await get_tree().process_frame
		if fruit.has_method("get_overlapping_areas"):
			if fruit.get_overlapping_areas().size() > 0:
				# Spawned inside something, try again next time
				fruit.queue_free()
	).call_deferred()
