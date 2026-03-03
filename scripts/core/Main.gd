extends Node3D

@onready var snake_head = $SnakeHead
@onready var hud = $HUD
@onready var food_spawner = $FoodSpawner

var name_prompt_scene = preload("res://scenes/ui/NamePrompt.tscn")

func _ready() -> void:
	if snake_head:
		snake_head.score_changed.connect(_on_score_changed)
		snake_head.food_eaten.connect(_on_food_eaten)
		snake_head.game_over.connect(_on_game_over)

	# Show name prompt on startup
	get_tree().paused = true
	var name_prompt = name_prompt_scene.instantiate()
	if hud:
		hud.add_child(name_prompt)
	else:
		add_child(name_prompt)
	name_prompt.name_selected.connect(_on_name_selected)

func _on_name_selected(player_name: String) -> void:
	get_tree().paused = false
	if hud:
		hud.update_player_name(player_name)

func _on_score_changed(new_score: int) -> void:
	if hud:
		hud.update_score(new_score)

func _on_food_eaten() -> void:
	if food_spawner:
		food_spawner.spawn_food()

func _on_game_over(final_score: int) -> void:
	ScoreManager.submit_score(final_score)
	if hud:
		hud.update_leaderboard()
