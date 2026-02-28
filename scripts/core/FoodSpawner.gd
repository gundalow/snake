extends Node3D

@export var food_scene: PackedScene = preload("res://scenes/main/Food.tscn")
@export var board_size: float = 28.0 # Slightly smaller than 30 to avoid walls

var first_spawn: bool = true

func _ready() -> void:
	# Initial spawn
	spawn_food()

func spawn_food() -> void:
	var x: float
	var z: float
	var attempts: int = 0
	
	if first_spawn:
		# First food is halfway between snake (0,0,0) and North wall (-15)
		x = 0.0
		z = -7.5
		first_spawn = false
		attempts = 1
		print("Placing first food at guaranteed position: (0, 0.5, -7.5)")
	else:
		# Random position on XZ plane, ensuring it's not on the snake
		var valid_pos = false
		while not valid_pos and attempts < 50:
			attempts += 1
			x = snapped(randf_range(-board_size / 2.0, board_size / 2.0), 1.0)
			z = snapped(randf_range(-board_size / 2.0, board_size / 2.0), 1.0)

			valid_pos = true
			var snake_head = get_node_or_null("../SnakeHead")
			if snake_head:
				# Check distance to head
				if Vector2(x, z).distance_to(Vector2(snake_head.global_position.x, snake_head.global_position.z)) < 2.0:
					valid_pos = false
					continue

				# Check distance to segments
				for segment in snake_head.segments:
					if Vector2(x, z).distance_to(Vector2(segment.global_position.x, segment.global_position.z)) < 1.0:
						valid_pos = false
						break
	
	var food = food_scene.instantiate()
	food.position = Vector3(x, 0.5, z)
	add_child(food)
	print("Spawned food at: ", food.position, " after ", attempts, " attempts")
