extends Node3D

@export var food_scene: PackedScene = preload("res://scenes/main/Food.tscn")

var first_spawn: bool = true

func _ready() -> void:
	spawn_food()

func spawn_food() -> void:
	var x: float = 0.0
	var z: float = 0.0
	var attempts: int = 0
	var board_size = GameConstants.BOARD_SIZE

	if first_spawn:
		x = 0.0
		z = -7.0
		first_spawn = false
		attempts = 1
		print("Placing first food at guaranteed position: (0, 0.5, -7.0)")
	else:
		var valid_pos = false
		while not valid_pos and attempts < 50:
			attempts += 1
			x = snapped(randf_range(-board_size / 2.0, board_size / 2.0), 1.0)
			z = snapped(randf_range(-board_size / 2.0, board_size / 2.0), 1.0)

			valid_pos = true
			var snake_head = get_node_or_null("../SnakeHead")
			if snake_head:
				var head_pos = Vector2(snake_head.global_position.x, snake_head.global_position.z)
				if Vector2(x, z).distance_to(head_pos) < 2.0:
					valid_pos = false
					continue

				for segment in snake_head.segments:
					var seg_pos = Vector2(segment.global_position.x, segment.global_position.z)
					if Vector2(x, z).distance_to(seg_pos) < 1.0:
						valid_pos = false
						break

		if not valid_pos:
			print("WARNING: No valid food position after ", attempts, " attempts")

	var food = food_scene.instantiate()
	food.position = Vector3(x, 0.5, z)
	add_child(food)
	print("Spawned food at: ", food.position, " after ", attempts, " attempts")
