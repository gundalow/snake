extends Node3D

@export var move_speed: float = 5.0
@export var turn_interpolation_speed: float = 10.0 # 0.1s target

var current_direction: Vector3 = Vector3.FORWARD
var next_direction: Vector3 = Vector3.FORWARD
var target_rotation_y: float = 0.0
var camera_tilt: float = 0.0
var is_alive: bool = true
var invulnerability_timer: float = 0.5 # Give segments time to spread
var score: int = 0
var initial_camera_height: float

# --- Position History & Body Segments ---
const HISTORY_RESOLUTION: float = 0.1 # Every 0.1 units
const SEGMENT_SPACING: int = 10 # 10 * 0.1 = 1.0 unit spacing
var position_history: Array[Transform3D] = []
var segments: Array[Node3D] = []
var distance_traveled_since_last_history: float = 0.0

@export var segment_scene: PackedScene = preload("res://scenes/main/SnakeSegment.tscn")
@export var dazed_scene: PackedScene = preload("res://scenes/effects/dazed_particles.tscn")
# ----------------------------------------

# Using an enum or constants for directions to prevent 180-degree turns
enum Dir { NORTH, SOUTH, EAST, WEST }
var heading: Dir = Dir.NORTH
var target_heading: Dir = Dir.NORTH

@onready var rider_cam: Camera3D = $RiderCam
@onready var head_area: Area3D = $HeadArea
@onready var mouth_area: Area3D = $MouthArea
@onready var death_ray: RayCast3D = $DeathRay
@onready var cobra_model: Node3D = $CobraModel

var current_model_scale: Vector3 = Vector3.ONE
var model_offset: Vector3 = Vector3.ZERO

func _ready() -> void:
	# Initialize rotation based on start direction (North = -Z)
	target_rotation_y = rotation.y
	initial_camera_height = rider_cam.global_position.y
	
	# Find internal nodes (Skeleton)
	var skeleton = _find_node_by_class(cobra_model, "Skeleton3D")
	
	# Dynamic Scaling - BIGGER FOR VISIBILITY
	_fit_to_size(5.0)
	
	# VISIBILITY VERIFICATION: Add a bright green marker
	var marker = MeshInstance3D.new()
	marker.mesh = BoxMesh.new()
	marker.mesh.size = Vector3(1, 1, 1)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0, 1, 0, 1) # Full bright green
	mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED # Glows in dark
	marker.material_override = mat
	add_child(marker)
		
	# Attach Camera to Bone 36
	if skeleton:
		var bone_name = "joint47_036" # Identified as Bone 36 in tool
		var attachment = BoneAttachment3D.new()
		attachment.bone_name = bone_name
		skeleton.add_child(attachment)
		
		var remote = RemoteTransform3D.new()
		remote.remote_path = rider_cam.get_path()
		remote.position = Vector3(0, 2, 0)
		remote.rotation_degrees = Vector3(-10, 0, 0)
		attachment.add_child(remote)
	
	# Seed initial history
	for i in range(100):
		position_history.push_back(global_transform)
	
	# Initial segments
	add_segment()
	add_segment()
	
	mouth_area.area_entered.connect(_on_mouth_area_entered)

func _fit_to_size(target_units: float) -> void:
	var aabb = AABB()
	var first = true
	var meshes = _get_all_meshes(cobra_model)
	for m in meshes:
		var m_aabb = m.get_aabb()
		if first:
			aabb = m_aabb
			first = false
		else:
			aabb = aabb.merge(m_aabb)
	
	if aabb.size.z == 0: return
	
	var s = target_units / aabb.size.z
	cobra_model.scale = Vector3(s, s, s)
	current_model_scale = cobra_model.scale
	
	# Align so the "Head" (Z max) is at the node origin
	model_offset.y = -aabb.position.y * s
	model_offset.z = -aabb.end.z * s
	cobra_model.position = model_offset

func _get_all_meshes(root: Node) -> Array[MeshInstance3D]:
	var results: Array[MeshInstance3D] = []
	if root is MeshInstance3D:
		results.append(root)
	for child in root.get_children():
		results.append_array(_get_all_meshes(child))
	return results

func _find_node_by_class(root: Node, target_class: String) -> Node:
	if root.is_class(target_class):
		return root
	for child in root.get_children():
		var found = _find_node_by_class(child, target_class)
		if found:
			return found
	return null

func _process(delta: float) -> void:
	if not is_alive: return

	if death_ray.is_colliding():
		var collider = death_ray.get_collider()
		if collider.is_in_group("walls"):
			die("Wall: " + collider.name)
			return
		elif collider.is_in_group("body") and invulnerability_timer <= 0:
			die("Body Segment")
			return

	if invulnerability_timer > 0:
		invulnerability_timer -= delta
		
	handle_input()
	move_forward(delta)
	update_rotation(delta)
	
	cobra_model.position = model_offset

	if Engine.get_frames_drawn() % 60 == 0:
		print("--- SNAKE DEBUG ---")
		print("  Head Node Global Pos: ", global_position)
		print("  Head Model Global Pos: ", cobra_model.global_position)

func handle_input() -> void:
	if Input.is_action_just_pressed("turn_left"):
		queue_turn(1.0)
	elif Input.is_action_just_pressed("turn_right"):
		queue_turn(-1.0)

func queue_turn(direction_sign: float) -> void:
	var new_heading: Dir
	match target_heading:
		Dir.NORTH: new_heading = Dir.WEST if direction_sign > 0 else Dir.EAST
		Dir.SOUTH: new_heading = Dir.EAST if direction_sign > 0 else Dir.WEST
		Dir.EAST:  new_heading = Dir.NORTH if direction_sign > 0 else Dir.SOUTH
		Dir.WEST:  new_heading = Dir.SOUTH if direction_sign > 0 else Dir.NORTH
	
	target_heading = new_heading
	target_rotation_y += direction_sign * PI / 2.0
	camera_tilt = direction_sign * 0.1

func move_forward(delta: float) -> void:
	var forward = -transform.basis.z
	var move_vec = forward * move_speed * delta
	global_position += move_vec
	
	distance_traveled_since_last_history += move_vec.length()
	
	if distance_traveled_since_last_history >= HISTORY_RESOLUTION:
		distance_traveled_since_last_history -= HISTORY_RESOLUTION
		position_history.insert(0, global_transform)
		var max_history = (segments.size() + 1) * SEGMENT_SPACING
		if position_history.size() > max_history:
			position_history.resize(max_history)
		update_segments()

func update_segments() -> void:
	for i in range(segments.size()):
		var history_index = (i + 1) * SEGMENT_SPACING
		if history_index < position_history.size():
			segments[i].global_transform = position_history[history_index]

func add_segment() -> void:
	var new_segment = segment_scene.instantiate()
	get_parent().add_child.call_deferred(new_segment)
	
	var history_index = (segments.size() + 1) * SEGMENT_SPACING
	if history_index < position_history.size():
		new_segment.global_transform = position_history[history_index]
	else:
		new_segment.global_transform = global_transform
		
	var area = new_segment.get_node_or_null("SegmentArea")
	if area:
		area.monitorable = false
		var timer = get_tree().create_timer(1.0)
		timer.timeout.connect(func():
			if is_instance_valid(area):
				area.monitorable = true
		)
		
	segments.append(new_segment)

func _on_mouth_area_entered(area: Area3D) -> void:
	if not is_alive: return
	if area.is_in_group("foods"):
		_eat_food(area)

func _eat_food(area: Area3D) -> void:
	print("EATING FOOD!")
	area.queue_free()
	var spawner = get_node_or_null("/root/Main/FoodSpawner")
	if spawner:
		spawner.spawn_food()
	add_segment()
	move_speed += 0.2
	score += 1
	update_score_ui()
	play_eat_juice()

func update_score_ui() -> void:
	var score_label = get_node_or_null("/root/Main/HUD/ScoreLabel")
	if score_label:
		score_label.text = "Score: %d" % score

func die(reason: String = "Unknown") -> void:
	if not is_alive: return
	is_alive = false
	print("SNAKE DIED! Reason: ", reason)
	
	var cam = rider_cam
	var old_global_pos = cam.global_position
	var old_global_rot = cam.global_rotation
	
	remove_child(cam)
	get_tree().root.add_child(cam)
	cam.global_position = old_global_pos
	cam.global_rotation = old_global_rot
	
	var bounce_tween = create_tween()
	var start_y = initial_camera_height
	bounce_tween.tween_property(cam, "global_position:y", start_y + 3.0, 0.5)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(cam, "global_position:y", start_y, 0.6)\
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	cam.make_current()
	
	var dazed = dazed_scene.instantiate()
	add_child.call_deferred(dazed)
	(func(): 
		dazed.position = Vector3(0, 1.5, 0)
		dazed.emitting = true
	).call_deferred()

func play_eat_juice() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(cobra_model, "scale", current_model_scale * 1.2, 0.1)
	tween.tween_property(cobra_model, "scale", current_model_scale, 0.2)

func update_rotation(delta: float) -> void:
	rotation.y = lerp_angle(rotation.y, target_rotation_y, turn_interpolation_speed * delta)
	camera_tilt = lerp(camera_tilt, 0.0, turn_interpolation_speed * delta)
	rider_cam.rotation.z = camera_tilt
