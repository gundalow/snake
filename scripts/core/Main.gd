extends Node3D

@onready var snake_head = $SnakeHead
@onready var score_label = $HUD/ScoreLabel
@onready var food_spawner = $FoodSpawner

func _ready() -> void:
	if snake_head:
		snake_head.score_changed.connect(_on_score_changed)
		snake_head.food_eaten.connect(_on_food_eaten)

func _on_score_changed(new_score: int) -> void:
	if score_label:
		score_label.text = "Score: %d" % new_score

func _on_food_eaten() -> void:
	if food_spawner:
		food_spawner.spawn_food()
