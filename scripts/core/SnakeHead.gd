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
const STEP_DISTANCE: float = 1.0 # Distance between segments
var position_history: Array[Transform3D] = []
var segments: Array[Node3D] = []
var distance_traveled: float = 0.0
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

func _ready() -> void:
	# Initialize rotation based on start direction (North = -Z)
	target_rotation_y = rotation.y
	initial_camera_height = rider_cam.global_position.y
	
	# Find internal nodes (Skeleton, AnimPlayer)
	var skeleton = _find_node_by_class(cobra_model, "Skeleton3D")
	var anim_player = _find_node_by_class(cobra_model, "AnimationPlayer")
	
	# Play snake animation
	if anim_player:
		anim_player.play("SANKE animations")
		
	# Attach Camera to Bone 36
	if skeleton:
		var bone_name = "joint47_036" # Identified as Bone 36 in tool
		var attachment = BoneAttachment3D.new()
		attachment.bone_name = bone_name
		skeleton.add_child(attachment)
		
		var remote = RemoteTransform3D.new()
		remote.remote_path = rider_cam.get_path()
		# Local offset above the head. 
		# Scale in the model is tiny (0.01), so offsets are large (100.0 = 1.0 unit)
		remote.position = Vector3(0, 10, -5) 
		remote.rotation_degrees = Vector3(0, 180, 0) # Flip to look forward
		attachment.add_child(remote)
	
	# Initial segments
	add_segment()
	add_segment()
	
	# Connect collision signals
	mouth_area.area_entered.connect(_on_mouth_area_entered)

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

	# Lethal Collision Check via DeathRay
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
	
	if Engine.get_frames_drawn() % 60 == 0:
		print("Head Pos: ", global_position, " Score: ", score)
		var foods = get_tree().get_nodes_in_group("foods")
		for f in foods:
			print("  Food at: ", f.global_position, " Dist: ", global_position.distance_to(f.global_position))

func handle_input() -> void:
	if Input.is_action_just_pressed("turn_left"):
		queue_turn(1.0) # 90 degrees left
	elif Input.is_action_just_pressed("turn_right"):
		queue_turn(-1.0) # 90 degrees right

func queue_turn(direction_sign: float) -> void:
	var new_heading: Dir
	match target_heading:
		Dir.NORTH: new_heading = Dir.WEST if direction_sign > 0 else Dir.EAST
		Dir.SOUTH: new_heading = Dir.EAST if direction_sign > 0 else Dir.WEST
		Dir.EAST:  new_heading = Dir.NORTH if direction_sign > 0 else Dir.SOUTH
		Dir.WEST:  new_heading = Dir.SOUTH if direction_sign > 0 else Dir.NORTH
	
	target_heading = new_heading
	target_rotation_y += direction_sign * PI / 2.0
	camera_tilt = direction_sign * 0.1 # Slight tilt in radians

func move_forward(delta: float) -> void:
	var forward = -transform.basis.z
	var move_vec = forward * move_speed * delta
	global_position += move_vec
	
	distance_traveled += move_vec.length()
	
	if distance_traveled >= STEP_DISTANCE:
		distance_traveled -= STEP_DISTANCE
		position_history.insert(0, global_transform)
		update_segments()
		if position_history.size() > segments.size() + 1:
			position_history.resize(segments.size() + 1)

func update_segments() -> void:
	for i in range(segments.size()):
		if i < position_history.size():
			segments[i].global_transform = position_history[i]

func add_segment() -> void:
	var new_segment = segment_scene.instantiate()
	get_parent().add_child.call_deferred(new_segment)
	
	if position_history.size() > 0:
		new_segment.global_transform = position_history.back()
	else:
		new_segment.global_transform = global_transform
		
	var area = new_segment.get_node_or_null("SegmentArea")
	if area:
		area.monitorable = false
		get_tree().create_timer(1.0).timeout.connect(func(): area.monitorable = true)
		
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
	
	var anim_player = _find_node_by_class(cobra_model, "AnimationPlayer")
	if anim_player:
		anim_player.stop()
	
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
	var orig_scale = Vector3(-0.003, 0.003, -0.003)
	tween.tween_property(cobra_model, "scale", orig_scale * 1.2, 0.1)
	tween.tween_property(cobra_model, "scale", orig_scale, 0.2)

func update_rotation(delta: float) -> void:
	rotation.y = lerp_angle(rotation.y, target_rotation_y, turn_interpolation_speed * delta)
	camera_tilt = lerp(camera_tilt, 0.0, turn_interpolation_speed * delta)
	rider_cam.rotation.z = camera_tilt
