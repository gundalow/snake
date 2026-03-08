extends Node3D

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

@onready var snake_head = $SnakeHead
@onready var hud = $HUD
@onready var status_label = $HUD/StatusLabel
@onready var score_label = $HUD/ScoreLabel
@onready var food_spawner = $FoodSpawner
@onready var world_stomper = $WorldStomper
@onready var camera = $OverheadCam
@onready var ufo_manager = $UFOManager

func _ready() -> void:
	ScoreManager.load_scores()
	if snake_head:
		snake_head.score_changed.connect(_on_score_changed)
		snake_head.food_eaten.connect(_on_food_eaten)
		snake_head.status_message.connect(_on_status_message)
		snake_head.game_over.connect(_on_game_over)

	if world_stomper:
		world_stomper.stomped.connect(_on_world_stomped)

	if ufo_manager:
		ufo_manager.food_stolen.connect(_on_food_stolen)

	if food_spawner:
		food_spawner.spawn_food()
		var initial_food = food_spawner.get_child(food_spawner.get_child_count() - 1)
		if ufo_manager:
			ufo_manager.on_food_spawned(initial_food)

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
	elif hud and hud.has_node("ScoreLabel"):
		hud.get_node("ScoreLabel").text = "Score: %d" % new_score

func _on_status_message(text: String) -> void:
	if status_label:
		status_label.text = text

func _on_food_eaten(type: String, score: int, food_counts: Dictionary) -> void:
	# FoodSpawner now spawns its own food via signal from Food.gd
	_check_achievements(type, score, food_counts)

func _check_achievements(type: String, score: int, food_counts: Dictionary) -> void:
	if not hud: return

	var apples = food_counts.get("apple", 0)

	# Apple achievements
	if type == "apple":
		if apples == 10:
			hud.show_achievement("An apple a day keeps the doctor away!")
		elif apples == 20:
			hud.show_achievement("Really keeping those doctors away now!")
		elif apples == 30:
			hud.show_achievement("The doctors have gone into hiding!")
		elif apples == 50:
			hud.show_achievement("Apple Overlord!")

	# Score milestones every 10
	if score > 0 and score % 10 == 0:
		if score == 20:
			hud.show_achievement("Snaaake Master!")
		else:
			var puns = fruit_puns + snake_puns
			var random_pun = puns[randi() % puns.size()]
			hud.show_achievement("%d Points: %s" % [score, random_pun])

func _on_world_stomped() -> void:
	if camera:
		camera.shake(1.5)

	if food_spawner:
		food_spawner.relocate_all_food()

func _on_food_stolen() -> void:
	snake_head.score = max(0, snake_head.score - GameConstants.UFO_SCORE_PENALTY)
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

func _on_game_over(final_score: int) -> void:
	ScoreManager.submit_score(final_score)
	if hud:
		hud.update_leaderboard()
