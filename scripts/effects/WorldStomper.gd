extends Node3D

signal stomped

const SPAWN_DISTANCE = 18.0

@onready var animation_player = $AnimationPlayer
@onready var timer = $Timer

func _ready() -> void:
	timer.wait_time = 30.0
	timer.start()
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	start_stomp_cycle()

func start_stomp_cycle() -> void:
	# Pick a random side (North, South, East, West)
	var side = randi() % 4
	var spawn_pos = Vector3.ZERO

	match side:
		0: # North
			spawn_pos = Vector3(randf_range(-10, 10), 0, -SPAWN_DISTANCE)
		1: # South
			spawn_pos = Vector3(randf_range(-10, 10), 0, SPAWN_DISTANCE)
		2: # West
			spawn_pos = Vector3(-SPAWN_DISTANCE, 0, randf_range(-10, 10))
		3: # East
			spawn_pos = Vector3(SPAWN_DISTANCE, 0, randf_range(-10, 10))

	global_position = spawn_pos

	# Look at center of board for better visual
	look_at(Vector3(0, 0, 0), Vector3.UP)
	# Correct for model rotation (usually legs are vertical, so we want the foot flat on ground)
	# This depends on the mesh orientation

	animation_player.play("stomp")

func _on_impact() -> void:
	stomped.emit()
