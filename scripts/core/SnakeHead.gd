extends Node3D

signal score_changed(new_score)
signal food_eaten
signal game_over(final_score)

enum Dir { NORTH, SOUTH, EAST, WEST }

@export var segment_scene: PackedScene = preload("res://scenes/main/SnakeSegment.tscn")
@export var dazed_scene: PackedScene = preload("res://scenes/effects/dazed_particles.tscn")

var is_alive: bool = true
var invulnerability_timer: float = GameConstants.INVULNERABILITY_TIME
var score: int = 0
var position_history: Array[Transform3D] = []
var segments: Array[Node3D] = []
var distance_traveled: float = 0.0
var grid_distance: float = 0.0
var heading: Dir = Dir.NORTH
var next_heading: Dir = Dir.NORTH
var move_speed: float = GameConstants.INITIAL_MOVE_SPEED

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var mouth_area: Area3D = $MouthArea
@onready var death_ray: RayCast3D = $DeathRay

func _ready() -> void:
	_initialize_history()
	add_segment()
	add_segment()
	mouth_area.area_entered.connect(_on_mouth_area_entered)

func _initialize_history() -> void:
	var needed = 2 * GameConstants.SEGMENT_SPACING + 1
	var behind = transform.basis.z.normalized()
	for i in range(needed):
		var t = global_transform
		t.origin += behind * GameConstants.HISTORY_RESOLUTION * i
		position_history.append(t)

func _process(delta: float) -> void:
	if not is_alive: return

	if death_ray.is_colliding():
		var collider = death_ray.get_collider()
		if collider.is_in_group("walls"):
			die("Wall: " + collider.name)
			return
		if collider.is_in_group("body") and invulnerability_timer <= 0:
			die("Body Segment")
			return

	if invulnerability_timer > 0:
		invulnerability_timer -= delta

	handle_input()
	move_forward(delta)
	update_rotation(delta)

func handle_input() -> void:
	var requested := heading
	var has_input := false

	if Input.is_action_just_pressed("move_up"):
		requested = Dir.NORTH
		has_input = true
	elif Input.is_action_just_pressed("move_down"):
		requested = Dir.SOUTH
		has_input = true
	elif Input.is_action_just_pressed("move_left"):
		requested = Dir.WEST
		has_input = true
	elif Input.is_action_just_pressed("move_right"):
		requested = Dir.EAST
		has_input = true

	if has_input and requested != _opposite(heading):
		next_heading = requested

func _opposite(dir: Dir) -> Dir:
	match dir:
		Dir.NORTH: return Dir.SOUTH
		Dir.SOUTH: return Dir.NORTH
		Dir.EAST: return Dir.WEST
		Dir.WEST: return Dir.EAST
	return dir

func _rotation_for_heading(dir: Dir) -> float:
	match dir:
		Dir.NORTH: return 0.0
		Dir.SOUTH: return PI
		Dir.EAST: return -PI / 2.0
		Dir.WEST: return PI / 2.0
	return 0.0

func move_forward(delta: float) -> void:
	var forward = Vector3.ZERO
	match heading:
		Dir.NORTH: forward = Vector3(0, 0, -1)
		Dir.SOUTH: forward = Vector3(0, 0, 1)
		Dir.EAST:  forward = Vector3(1, 0, 0)
		Dir.WEST:  forward = Vector3(-1, 0, 0)

	var move_vec = forward * move_speed * delta
	global_position += move_vec

	var step = move_vec.length()
	distance_traveled += step
	grid_distance += step

	if grid_distance >= GameConstants.GRID_SIZE:
		grid_distance -= GameConstants.GRID_SIZE
		global_position.x = snapped(global_position.x, GameConstants.GRID_SIZE)
		global_position.z = snapped(global_position.z, GameConstants.GRID_SIZE)

		if next_heading != heading:
			var old_rot = _rotation_for_heading(heading)
			var new_rot = _rotation_for_heading(next_heading)
			var diff = wrapf(new_rot - old_rot, -PI, PI)
			mesh.rotation.y -= diff
			heading = next_heading
			rotation.y = _rotation_for_heading(heading)

	if distance_traveled >= GameConstants.HISTORY_RESOLUTION:
		distance_traveled -= GameConstants.HISTORY_RESOLUTION
		var visual_transform = global_transform
		visual_transform.basis = mesh.global_transform.basis
		position_history.insert(0, visual_transform)
		update_segments()

		var max_history = segments.size() * GameConstants.SEGMENT_SPACING + 1
		if position_history.size() > max_history:
			position_history.resize(max_history)

func update_segments() -> void:
	for i in range(segments.size()):
		var history_index = i * GameConstants.SEGMENT_SPACING
		if history_index < position_history.size():
			segments[i].global_transform = position_history[history_index]

func add_segment() -> void:
	var new_segment = segment_scene.instantiate()
	get_parent().add_child.call_deferred(new_segment)

	var target_index = segments.size() * GameConstants.SEGMENT_SPACING
	if target_index < position_history.size():
		new_segment.global_transform = position_history[target_index]
	elif position_history.size() > 0:
		new_segment.global_transform = position_history.back()
	else:
		new_segment.global_transform = global_transform

	var area = new_segment.get_node_or_null("SegmentArea")
	if area:
		area.monitorable = false
		get_tree().create_timer(1.0).timeout.connect(func(): area.monitorable = true)

	segments.append(new_segment)

func _on_mouth_area_entered(area: Area3D) -> void:
	if is_alive and area.is_in_group("foods"):
		_eat_food(area)

func _eat_food(area: Area3D) -> void:
	area.queue_free()
	food_eaten.emit()
	add_segment()
	move_speed += GameConstants.SPEED_INCREMENT
	score += 1
	score_changed.emit(score)
	play_eat_juice()

func die(reason: String = "Unknown") -> void:
	if not is_alive: return
	is_alive = false
	print("SNAKE DIED! Reason: ", reason)
	game_over.emit(score)

	var dazed = dazed_scene.instantiate()
	add_child.call_deferred(dazed)
	(func():
		dazed.position = Vector3(0, 1.5, 0)
		dazed.emitting = true
	).call_deferred()

func play_eat_juice() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(mesh, "scale", Vector3(1.2, 0.8, 1.2), 0.1)
	tween.tween_property(mesh, "scale", Vector3(1.0, 1.0, 1.0), 0.2)

func update_rotation(delta: float) -> void:
	var rot_speed = GameConstants.TURN_INTERPOLATION_SPEED * delta
	mesh.rotation.y = lerp_angle(mesh.rotation.y, 0.0, rot_speed)
