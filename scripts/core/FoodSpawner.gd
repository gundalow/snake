extends Node2D

@export var food_scene: PackedScene = preload("res://scenes/main/Food.tscn")

var first_spawn: bool = true
var spawn_count: int = 0

func spawn_food() -> void:
	if not is_inside_tree():
		return

	var x: float = 0.0
	var y: float = 0.0
	var attempts: int = 0
	var board_size = GameConstants.BOARD_SIZE
	spawn_count += 1

	if first_spawn:
		x = 640.0
		y = 360.0
		first_spawn = false
		attempts = 1
	else:
		var valid_pos = false
		while not valid_pos and attempts < 50:
			attempts += 1
			# Random position within board size, snapped to grid
			x = snapped(randf_range(100, board_size - 100), GameConstants.GRID_SIZE)
			y = snapped(randf_range(100, 720 - 100), GameConstants.GRID_SIZE)

			valid_pos = true
			var snake_head = get_node_or_null("../SnakeHead")
			if snake_head and snake_head.is_inside_tree():
				var head_pos = snake_head.global_position
				if head_pos.distance_to(Vector2(x, y)) < 100.0:
					valid_pos = false
					continue

		if not valid_pos:
			print("WARNING: No valid food position after ", attempts, " attempts")

	var food = food_scene.instantiate()
	food.position = Vector2(x, y)

	# Every 5th food is Mega
	if spawn_count % 5 == 0:
		food.setup(food.Type.MEGA, "mega_melon")

	# Connect fully_eaten to signal that next food can spawn
	food.fully_eaten.connect(_on_food_fully_eaten)

	add_child(food)

func relocate_all_food() -> void:
	var board_size = GameConstants.BOARD_SIZE
	var snake_head = get_node_or_null("../SnakeHead")

	for food in get_tree().get_nodes_in_group("foods"):
		var valid_pos = false
		var attempts = 0
		var new_x = 0.0
		var new_y = 0.0

		while not valid_pos and attempts < 50:
			attempts += 1
			new_x = snapped(randf_range(100, board_size - 100), GameConstants.GRID_SIZE)
			new_y = snapped(randf_range(100, 720 - 100), GameConstants.GRID_SIZE)

			valid_pos = true
			if snake_head:
				var head_pos = snake_head.global_position
				if head_pos.distance_to(Vector2(new_x, new_y)) < 100.0:
					valid_pos = false
					continue

		if food.has_method("jump_to"):
			food.jump_to(Vector2(new_x, new_y))

func _on_food_fully_eaten() -> void:
	if is_inside_tree():
		spawn_food()
