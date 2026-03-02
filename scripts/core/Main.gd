extends Node3D

@onready var snake_head = $SnakeHead
@onready var score_label = $HUD/ScoreLabel
@onready var food_spawner = $FoodSpawner
@onready var ufo_manager = $UFOManager

func _ready() -> void:
	if snake_head:
		snake_head.score_changed.connect(_on_score_changed)
		snake_head.food_eaten.connect(_on_food_eaten)

	if food_spawner:
		food_spawner.spawn_food()
		var initial_food = food_spawner.get_child(food_spawner.get_child_count() - 1)
		if ufo_manager:
			ufo_manager.on_food_spawned(initial_food)

func _on_score_changed(new_score: int) -> void:
	if score_label:
		score_label.text = "Score: %d" % new_score

func _on_food_eaten() -> void:
	if food_spawner:
		food_spawner.spawn_food()
		var new_food = food_spawner.get_child(food_spawner.get_child_count() - 1)
		if ufo_manager:
			ufo_manager.on_food_spawned(new_food)

func _on_food_stolen() -> void:
	snake_head.score -= 5
	snake_head.score_changed.emit(snake_head.score)
	_flash_score_red()

	if food_spawner:
		await get_tree().create_timer(2.0).timeout
		food_spawner.spawn_food()
		var new_food = food_spawner.get_child(food_spawner.get_child_count() - 1)
		if ufo_manager:
			ufo_manager.on_food_spawned(new_food)

func _flash_score_red() -> void:
	if score_label:
		var tween = create_tween()
		tween.tween_property(score_label, "modulate", Color.RED, 0.1)
		tween.tween_property(score_label, "modulate", Color.WHITE, 0.1)
		tween.set_loops(3)
