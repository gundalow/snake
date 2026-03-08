extends SpecialEvent

signal food_stolen

@export var ufo_scene: PackedScene = preload("res://scenes/main/UFO.tscn")

func start_event() -> void:
	var foods = get_tree().get_nodes_in_group("foods")
	var main = get_tree().root.get_node_or_null("Main")
	var special_event_manager = null
	if main:
		special_event_manager = main.get_node_or_null("SpecialEventManager")

	while foods.is_empty():
		# If no food, wait a second then retry
		await get_tree().create_timer(1.0).timeout
		if special_event_manager and not special_event_manager.is_running:
			return
		foods = get_tree().get_nodes_in_group("foods")

	var target_food = foods.pick_random()
	if is_instance_valid(target_food):
		spawn_ufo(target_food)
	else:
		start_event()

func spawn_ufo(food: Node3D) -> void:
	var ufo = ufo_scene.instantiate()
	ufo.food_stolen.connect(_on_ufo_food_stolen)
	ufo.tree_exited.connect(_on_ufo_exited)
	# Spawn far away
	var board_size = GameConstants.BOARD_SIZE
	ufo.position = Vector3(board_size * 1.5, 5.0, board_size * 1.5)
	if randf() > 0.5: ufo.position.x *= -1
	if randf() > 0.5: ufo.position.z *= -1

	add_child(ufo)
	ufo.start_hunt(food)

func _on_ufo_food_stolen() -> void:
	food_stolen.emit()

func _on_ufo_exited() -> void:
	event_finished.emit()
