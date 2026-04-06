extends Node2D

signal stomped

const SPAWN_DISTANCE = 500.0

@onready var timer = $Timer

func _ready() -> void:
	timer.wait_time = 30.0
	timer.start()
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	start_stomp_cycle()

func start_stomp_cycle() -> void:
	# Pick a random side (North, South, East, West in 2D coordinates)
	var side = randi() % 4
	var spawn_pos = Vector2.ZERO

	match side:
		0: # Top
			spawn_pos = Vector2(randf_range(100, 1100), -SPAWN_DISTANCE)
		1: # Bottom
			spawn_pos = Vector2(randf_range(100, 1100), 720 + SPAWN_DISTANCE)
		2: # Left
			spawn_pos = Vector2(-SPAWN_DISTANCE, randf_range(100, 600))
		3: # Right
			spawn_pos = Vector2(1280 + SPAWN_DISTANCE, randf_range(100, 600))

	global_position = spawn_pos
	
	# In 2.5D, we'll just move the foot into position and play an animation
	# For now, we'll just simulate it with a tween
	var target_pos = Vector2(randf_range(200, 1000), randf_range(150, 550))
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, 1.0)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	tween.finished.connect(_on_impact)

func _on_impact() -> void:
	stomped.emit()
	# Shake effect would go here
	# Retreat
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(self, "position:y", position.y - 1000, 1.0)
