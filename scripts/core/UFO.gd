extends Node3D

signal abduction_completed
signal food_stolen

enum State { IDLE, APPROACHING, ABDUCTING, LEAVING }

var state: State = State.IDLE
var target_food: Node3D = null
var speed: float = GameConstants.UFO_SPEED
var flight_height: float = GameConstants.UFO_FLIGHT_HEIGHT
var abduction_time: float = 2.0
var score_penalty: int = GameConstants.UFO_SCORE_PENALTY

@onready var beam: MeshInstance3D = $TractorBeam

func _process(delta: float) -> void:
	match state:
		State.APPROACHING:
			_state_approaching(delta)
		State.LEAVING:
			_state_leaving(delta)

func start_hunt(food: Node3D) -> void:
	target_food = food
	state = State.APPROACHING
	# Connect to tree_exited to know if snake ate it
	target_food.tree_exited.connect(_on_food_vanished)

func _state_approaching(delta: float) -> void:
	if not is_instance_valid(target_food):
		state = State.LEAVING
		return

	var target_pos = target_food.global_position
	target_pos.y = flight_height

	var dir = (target_pos - global_position).normalized()
	var dist = global_position.distance_to(target_pos)

	if dist < 0.1:
		global_position = target_pos
		_start_abduction()
	else:
		global_position += dir * speed * delta

func _start_abduction() -> void:
	state = State.ABDUCTING
	beam.visible = true

	if is_instance_valid(target_food):
		# Disconnect so we don't trigger State.LEAVING while we are the ones removing it
		if target_food.tree_exited.is_connected(_on_food_vanished):
			target_food.tree_exited.disconnect(_on_food_vanished)

		var tween = create_tween()
		tween.tween_property(target_food, "global_position:y", flight_height, 1.0)
		tween.finished.connect(_on_abduction_finished)

func _on_abduction_finished() -> void:
	if is_instance_valid(target_food):
		target_food.queue_free()

	food_stolen.emit()

	await get_tree().create_timer(1.0).timeout
	beam.visible = false
	state = State.LEAVING

func _on_food_vanished() -> void:
	if state == State.APPROACHING:
		state = State.LEAVING

func _state_leaving(delta: float) -> void:
	# Fly off screen in a zig-zag
	var board_size = GameConstants.BOARD_SIZE
	var exit_pos = Vector3(board_size, flight_height, board_size) # Default

	if global_position.x < 0:
		exit_pos.x = -board_size
	if global_position.z < 0:
		exit_pos.z = -board_size

	var dir = (exit_pos - global_position).normalized()
	# Zig-zag effect
	var side_dir = Vector3(-dir.z, 0, dir.x)
	var zig_zag = side_dir * sin(Time.get_ticks_msec() * 0.01) * 2.0

	global_position += (dir + zig_zag).normalized() * speed * 2.0 * delta

	if global_position.length() > board_size * 2.0:
		queue_free()
