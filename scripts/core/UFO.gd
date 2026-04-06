extends Node2D

signal abduction_completed
signal food_stolen

enum State { IDLE, APPROACHING, ABDUCTING, LEAVING }

var state: State = State.IDLE
var target_food: Node2D = null
var speed: float = GameConstants.UFO_SPEED
var flight_height: float = 100.0 # Visual height in 2D pixels
var abduction_time: float = 2.0
var score_penalty: int = GameConstants.UFO_SCORE_PENALTY

@onready var beam: Polygon2D = $TractorBeam
@onready var visual: Polygon2D = $Visual

func _process(delta: float) -> void:
	match state:
		State.APPROACHING:
			_state_approaching(delta)
		State.LEAVING:
			_state_leaving(delta)

func start_hunt(food: Node2D) -> void:
	target_food = food
	state = State.APPROACHING
	target_food.tree_exited.connect(_on_food_vanished)

func _state_approaching(delta: float) -> void:
	if not is_instance_valid(target_food):
		state = State.LEAVING
		return

	var target_pos = target_food.global_position
	# For 2.5D, the UFO "hovers" above the target
	var hover_pos = target_pos + Vector2(0, -flight_height)

	var dir = (hover_pos - global_position).normalized()
	var dist = global_position.distance_to(hover_pos)

	if dist < 5.0:
		global_position = hover_pos
		_start_abduction()
	else:
		global_position += dir * speed * delta

func _start_abduction() -> void:
	state = State.ABDUCTING
	beam.visible = true

	if is_instance_valid(target_food):
		if target_food.tree_exited.is_connected(_on_food_vanished):
			target_food.tree_exited.disconnect(_on_food_vanished)

		var tween = create_tween()
		# Lift the food into the air (2.5D visual)
		tween.tween_property(target_food, "position:y", target_food.position.y - flight_height, 1.0)
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
	var board_size = GameConstants.BOARD_SIZE
	var exit_pos = Vector2(board_size * 1.5, -500)

	var dir = (exit_pos - global_position).normalized()
	# Zig-zag effect in 2D
	var zig_zag = Vector2(-dir.y, dir.x) * sin(Time.get_ticks_msec() * 0.01) * 20.0

	global_position += (dir * speed * 2.0 + zig_zag) * delta

	if global_position.y < -400 or global_position.x > board_size * 2.0:
		queue_free()
