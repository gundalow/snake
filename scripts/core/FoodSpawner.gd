extends Node3D

@export var food_scene: PackedScene = preload("res://scenes/main/Food.tscn")

var first_spawn: bool = true
var spawn_count: int = 0

func _ready() -> void:
	spawn_food()

func spawn_food() -> void:
	if not is_inside_tree():
		return

	var x: float = 0.0
	var z: float = 0.0
	var attempts: int = 0
	var board_size = GameConstants.BOARD_SIZE
	spawn_count += 1

	if first_spawn:
		x = 0.0
		z = -7.0
		first_spawn = false
		attempts = 1
	else:
		var valid_pos = false
		while not valid_pos and attempts < 50:
			attempts += 1
			x = snapped(randf_range(-board_size / 2.0, board_size / 2.0), 1.0)
			z = snapped(randf_range(-board_size / 2.0, board_size / 2.0), 1.0)

			valid_pos = true
			var snake_head = get_node_or_null("../SnakeHead")
			if snake_head and snake_head.is_inside_tree():
				var head_pos = Vector2(snake_head.global_position.x, snake_head.global_position.z)
				if Vector2(x, z).distance_to(head_pos) < 2.0:
					valid_pos = false
					continue

				for segment in snake_head.segments:
					if segment and segment.is_inside_tree():
						var seg_pos = Vector2(segment.global_position.x, segment.global_position.z)
						if Vector2(x, z).distance_to(seg_pos) < 1.0:
							valid_pos = false
							break

		if not valid_pos:
			print("WARNING: No valid food position after ", attempts, " attempts")

	var food = food_scene.instantiate()
	food.position = Vector3(x, 0.5, z)

	# Every 5th food is Mega
	if spawn_count % 5 == 0:
		var mega_keys = GameConstants.MEGA_FOOD_MODELS.keys()
		var random_mega = mega_keys[randi() % mega_keys.size()]
		food.setup(food.Type.MEGA, random_mega)

	# Connect fully_eaten to signal that next food can spawn
	food.fully_eaten.connect(_on_food_fully_eaten)

	add_child(food)

	if attempts > 5:
		print("Spawned food at: ", food.position, " after ", attempts, " attempts")

func _on_food_fully_eaten() -> void:
	if is_inside_tree():
		spawn_food()
