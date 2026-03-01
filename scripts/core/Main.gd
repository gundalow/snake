extends Node3D

@onready var snake_head = $SnakeHead
@onready var score_label = $HUD/ScoreLabel
@onready var food_spawner = $FoodSpawner

func _ready() -> void:
	if snake_head:
		snake_head.score_changed.connect(_on_score_changed)
		# We'll stop connecting food_eaten to spawn_food,
		# instead let the FoodSpawner manage its own next-spawn logic
		# based on the Food's fully_eaten signal.
		# However, SnakeHead still needs to tell Main/HUD about score etc.

func _on_score_changed(new_score: int) -> void:
	if score_label:
		score_label.text = "Score: %d" % new_score
