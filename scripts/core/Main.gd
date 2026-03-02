extends Node3D

@onready var snake_head = $SnakeHead
@onready var hud = $HUD
@onready var food_spawner = $FoodSpawner

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

func _ready() -> void:
	if snake_head:
		snake_head.score_changed.connect(_on_score_changed)
		snake_head.food_eaten.connect(_on_food_eaten)

func _on_score_changed(new_score: int) -> void:
	if hud:
		hud.update_score(new_score)

func _on_food_eaten(type: String, score: int, apples: int) -> void:
	if food_spawner:
		food_spawner.spawn_food()

	_check_achievements(type, score, apples)

func _check_achievements(type: String, score: int, apples: int) -> void:
	if not hud: return

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
