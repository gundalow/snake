extends Node3D

signal score_changed(new_score)
signal food_eaten(type, total_score, food_counts)
signal status_message(text)
signal game_over(final_score)

enum Dir { NORTH, SOUTH, EAST, WEST }

@export var segment_scene: PackedScene = preload("res://scenes/main/SnakeSegment.tscn")
@export var dazed_scene: PackedScene = preload("res://scenes/effects/dazed_particles.tscn")

var is_alive: bool = true
var invulnerability_timer: float = GameConstants.INVULNERABILITY_TIME
var score: int = 0
var food_counts: Dictionary = {}
var position_history: Array[Transform3D] = []
var segments: Array[Node3D] = []
var body_bones: Array[int] = []
var distance_traveled: float = 0.0
var grid_distance: float = 0.0
var heading: Dir = Dir.NORTH
var next_heading: Dir = Dir.NORTH
var base_move_speed: float = GameConstants.INITIAL_MOVE_SPEED
var speed_multiplier: float = 1.0
var snake_length: int = 10 # Initial number of bones to show

@onready var mouth_area: Area3D = $MouthArea
@onready var death_ray: RayCast3D = $DeathRay
@onready var snake_model: Node3D = $SnakeModel
@onready var skeleton: Skeleton3D = _find_skeleton(snake_model)

func _ready() -> void:
	_initialize_bones()
	_initialize_history()
	# add_segment()
	# add_segment()
	mouth_area.area_entered.connect(_on_mouth_area_entered)

func _find_skeleton(node: Node) -> Skeleton3D:
	if not node: return null
	if node is Skeleton3D: return node
	for child in node.get_children():
		var res = _find_skeleton(child)
		if res: return res
	return null

func _initialize_bones() -> void:
	if not skeleton: return

	for i in range(skeleton.get_bone_count()):
		var b_name = skeleton.get_bone_name(i)
		# From 3D_Plan.md: Body/Spine: Bone.001 through Bone.084
		if b_name.begins_with("Bone"):
			body_bones.append(i)

	# Initial visibility
	update_bone_visibility()

func update_bone_visibility() -> void:
	if not skeleton: return
	for i in range(body_bones.size()):
		var bone_idx = body_bones[i]
		if i < snake_length:
			skeleton.set_bone_pose_scale(bone_idx, Vector3.ONE)
		else:
			skeleton.set_bone_pose_scale(bone_idx, Vector3.ZERO)

func _initialize_history() -> void:
	var needed = body_bones.size() * GameConstants.SEGMENT_SPACING + 1
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

	var move_speed = base_move_speed * speed_multiplier
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
			heading = next_heading
			rotation.y = _rotation_for_heading(heading)

	if distance_traveled >= GameConstants.HISTORY_RESOLUTION:
		distance_traveled -= GameConstants.HISTORY_RESOLUTION
		position_history.insert(0, global_transform)
		update_segments()
		update_skeleton()

		var max_history = body_bones.size() * GameConstants.SEGMENT_SPACING + 1
		if position_history.size() > max_history:
			position_history.resize(max_history)

func update_segments() -> void:
	for i in range(segments.size()):
		var history_index = (i + 1) * GameConstants.SEGMENT_SPACING * 5 # Offset segments to be further back if still using them
		if history_index < position_history.size():
			segments[i].global_transform = position_history[history_index]

func update_skeleton() -> void:
	if not skeleton: return

	var inv_skeleton_transform = skeleton.global_transform.affine_inverse()

	for i in range(snake_length):
		if i >= body_bones.size(): break

		var bone_idx = body_bones[i]
		var history_index = (i + 1) * GameConstants.SEGMENT_SPACING

		if history_index < position_history.size():
			var target_transform = position_history[history_index]
			var local_transform = inv_skeleton_transform * target_transform
			skeleton.set_bone_global_pose_override(bone_idx, local_transform, 1.0, true)

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
	var type = ""
	if "food_name" in area:
		type = area.food_name

	if type != "":
		food_counts[type] = food_counts.get(type, 0) + 1

	var is_fully_eaten = true
	if area.has_method("take_bite"):
		is_fully_eaten = area.take_bite()
		if area.food_type == area.Type.MEGA:
			speed_multiplier = GameConstants.MEGA_FOOD_SPEED_MULTIPLIER
			var msg = "You've eaten too much\nand have slowed down"
			status_message.emit.call_deferred(msg)
			if is_fully_eaten:
				if not area.fully_eaten.is_connected(_on_mega_food_fully_eaten):
					area.fully_eaten.connect(_on_mega_food_fully_eaten)

	# EVERY bite adds a segment and increases score
	# add_segment()
	snake_length = min(body_bones.size(), snake_length + 1)
	update_bone_visibility()

	base_move_speed += GameConstants.SPEED_INCREMENT
	score += 1
	score_changed.emit.call_deferred(score)

	if is_fully_eaten:
		food_eaten.emit.call_deferred(type, score, food_counts)

	play_eat_juice()

func _on_mega_food_fully_eaten() -> void:
	speed_multiplier = 1.0
	status_message.emit.call_deferred("") # Clear message

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
	var model = get_node_or_null("SnakeModel")
	if not model: return

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	var original_scale = model.transform.basis.get_scale()
	var new_scale = Vector3(original_scale.x, original_scale.y * 0.8, original_scale.z * 1.2)
	tween.tween_property(model, "scale", new_scale, 0.1)
	tween.tween_property(model, "scale", original_scale, 0.2)
