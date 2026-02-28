extends Node3D

@export var move_speed: float = 5.0
@export var turn_interpolation_speed: float = 10.0 # 0.1s target

var target_rotation_y: float = 0.0
var camera_tilt: float = 0.0
var turn_queue: Array[float] = []
var is_alive: bool = true
var invulnerability_timer: float = 0.5 # Give segments time to spread
var score: int = 0
var initial_camera_height: float

signal score_changed(new_score)

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
var target_heading: Dir = Dir.NORTH

@onready var rider_cam: Camera3D = $RiderCam
@onready var head_area: Area3D = $HeadArea
@onready var mouth_area: Area3D = $MouthArea
@onready var death_ray: RayCast3D = $DeathRay

func _ready() -> void:
	# Initialize rotation based on start direction (North = -Z)
	target_rotation_y = rotation.y
	initial_camera_height = rider_cam.global_position.y
	
	# Initial segments
	add_segment()
	add_segment()
	
	# Connect collision signals
	mouth_area.area_entered.connect(_on_mouth_area_entered)

func _process(delta: float) -> void:
	if not is_alive: return

	# Lethal Collision Check via DeathRay
	# This prevents "side-collision" death during 90-degree snap turns
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
		if turn_queue.size() < 2:
			turn_queue.append(1.0) # 90 degrees left
	elif Input.is_action_just_pressed("turn_right"):
		if turn_queue.size() < 2:
			turn_queue.append(-1.0) # 90 degrees right

func _apply_turn(direction_sign: float) -> void:
	# Determine the new heading based on current target_heading and turn direction
	var new_heading: Dir
	match target_heading:
		Dir.NORTH: new_heading = Dir.WEST if direction_sign > 0 else Dir.EAST
		Dir.SOUTH: new_heading = Dir.EAST if direction_sign > 0 else Dir.WEST
		Dir.EAST:  new_heading = Dir.NORTH if direction_sign > 0 else Dir.SOUTH
		Dir.WEST:  new_heading = Dir.SOUTH if direction_sign > 0 else Dir.NORTH
	
	# Since it's a 90-degree turn, 180-degree "suicide" is naturally prevented
	target_heading = new_heading
	target_rotation_y += direction_sign * PI / 2.0
	camera_tilt = direction_sign * 0.1 # Slight tilt in radians

func move_forward(delta: float) -> void:
	# We move in the direction the head is facing
	var forward = -transform.basis.z
	var move_vec = forward * move_speed * delta
	global_position += move_vec
	
	distance_traveled += move_vec.length()
	
	# Every time we travel STEP_DISTANCE, record the history and update segments
	if distance_traveled >= STEP_DISTANCE:
		distance_traveled -= STEP_DISTANCE

		# Process pending turn if any
		if not turn_queue.is_empty():
			_apply_turn(turn_queue.pop_front())

		# Store the current head transform as the "newest" history point
		position_history.insert(0, global_transform)
		
		# If we have segments, position them according to history
		update_segments()
		
		# Keep history from growing indefinitely
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
		
	# Disable collision for a moment to prevent immediate death
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
	
	# Juice: Screen shake effect
	var shake_tween = create_tween().set_parallel(true)
	shake_tween.tween_property(rider_cam, "h_offset", randf_range(-0.2, 0.2), 0.05)
	shake_tween.tween_property(rider_cam, "v_offset", randf_range(-0.2, 0.2), 0.05)
	shake_tween.chain().tween_property(rider_cam, "h_offset", 0.0, 0.05)
	shake_tween.tween_property(rider_cam, "v_offset", 0.0, 0.05)

	# Spawn new food
	var main = get_tree().root.get_node_or_null("Main")
	if main:
		var spawner = main.get_node_or_null("FoodSpawner")
		if spawner:
			spawner.spawn_food()
		
	add_segment()
	move_speed += 0.2
	score += 1
	score_changed.emit(score)
	play_eat_juice()

func die(reason: String = "Unknown") -> void:
	if not is_alive: return
	is_alive = false
	print("SNAKE DIED! Reason: ", reason)
	
	# Camera Bounce Effect
	var cam = rider_cam
	var old_global_pos = cam.global_position
	var old_global_rot = cam.global_rotation
	
	remove_child(cam)
	get_tree().root.add_child(cam)
	cam.global_position = old_global_pos
	cam.global_rotation = old_global_rot
	
	var bounce_tween = create_tween().set_parallel(true)
	var start_y = initial_camera_height
	bounce_tween.tween_property(cam, "global_position:y", start_y + 3.0, 0.5)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Add chaotic rotation
	bounce_tween.tween_property(cam, "rotation:x", randf_range(-PI, PI), 0.5)
	bounce_tween.tween_property(cam, "rotation:y", randf_range(-PI, PI), 0.5)
	bounce_tween.chain().tween_property(cam, "global_position:y", start_y, 0.6)\
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
	tween.tween_property($MeshInstance3D, "scale", Vector3(1.2, 0.8, 1.2), 0.1)
	tween.tween_property($MeshInstance3D, "scale", Vector3(1.0, 1.0, 1.0), 0.2)

func update_rotation(delta: float) -> void:
	rotation.y = lerp_angle(rotation.y, target_rotation_y, turn_interpolation_speed * delta)
	camera_tilt = lerp(camera_tilt, 0.0, turn_interpolation_speed * delta)
	rider_cam.rotation.z = camera_tilt
