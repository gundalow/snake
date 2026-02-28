extends Node3D

@onready var snake_head = $SnakeHead
@onready var score_label = $HUD/ScoreLabel

func _ready() -> void:
	if snake_head:
		snake_head.score_changed.connect(_on_score_changed)

func _on_score_changed(new_score: int) -> void:
	if score_label:
		score_label.text = "Score: %d" % new_score
