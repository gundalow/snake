extends Node2D

var fruit_puns = [
	"Orange you glad you're playing?",
	"You're one in a melon!",
	"That was berry good!",
	"Lime feeling great about this!",
	"Peachy performance!",
	"A-peel-ing moves!",
	"Grape job!",
	"Cherry-ific!",
	"You're the top banana!",
	"Simply sub-lime!"
]

var snake_puns = [
	"Sssss-pectacular!",
	"Un-boa-lievable!",
	"Hiss-terical!",
	"Fangs for playing!",
	"Scale-ing new heights!",
	"Slither-in' like a pro!",
	"Quite s-s-s-smooth!",
	"Snake it 'til you make it!",
	"You're a total rattle-star!",
	"Totally hiss-tastic!"
]

var name_prompt_scene = preload("res://scenes/ui/NamePrompt.tscn")

@onready var snake_head = $YSortContainer/SnakeChain/SnakeHead
@onready var hud = $HUD
@onready var status_label = $HUD/StatusLabel
@onready var score_label = $HUD/ScoreLabel
@onready var food_spawner = $FoodSpawner
@onready var ufo_manager = $UFOManager

func _ready() -> void:
	ScoreManager.load_scores()
	if snake_head:
		snake_head.hit_obstacle.connect(_on_game_over)
		# For 2.5D, we might want more signals here if we use the PascalCase SnakeHead
	
	if food_spawner:
		food_spawner.spawn_food()

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
	if hud and hud.has_method("update_score"):
		hud.update_score(new_score)

func _on_status_message(text: String) -> void:
	if status_label:
		status_label.text = text

func _on_game_over() -> void:
	var final_score = 0
	var snake_manager = get_node_or_null("YSortContainer/SnakeChain")
	if snake_manager:
		final_score = snake_manager.score
	
	ScoreManager.submit_score(final_score)
	if hud:
		hud.update_leaderboard()
		hud.show_game_over()
