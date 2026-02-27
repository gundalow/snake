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

# --- Position History & Body Segments ---
const STEP_DISTANCE: float = 1.0 # Distance between segments
var position_history: Array[Transform3D] = []
var segments: Array[Node3D] = []
var distance_traveled: float = 0.0
@export var segment_scene: PackedScene = preload("res://scenes/main/SnakeSegment.tscn")
# ----------------------------------------

# Using an enum or constants for directions to prevent 180-degree turns
enum Dir { NORTH, SOUTH, EAST, WEST }
var heading: Dir = Dir.NORTH
var target_heading: Dir = Dir.NORTH

@onready var rider_cam: Camera3D = $RiderCam
@onready var head_area: Area3D = $HeadArea

func _ready() -> void:
	# Initialize rotation based on start direction (North = -Z)
	target_rotation_y = rotation.y
	
	# Initial segments
	add_segment()
	add_segment()
	
	# Connect collision
	head_area.area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	if not is_alive: return
	if invulnerability_timer > 0:
		invulnerability_timer -= delta
	handle_input()
	move_forward(delta)
	update_rotation(delta)

func handle_input() -> void:
	if Input.is_action_just_pressed("turn_left"):
		queue_turn(1.0) # 90 degrees left
	elif Input.is_action_just_pressed("turn_right"):
		queue_turn(-1.0) # 90 degrees right

func queue_turn(direction_sign: float) -> void:
	# Determine the new heading based on current target_heading and turn direction
	var new_heading: Dir
	match target_heading:
		Dir.NORTH: new_heading = Dir.WEST if direction_sign > 0 else Dir.EAST
		Dir.SOUTH: new_heading = Dir.EAST if direction_sign > 0 else Dir.WEST
		Dir.EAST:  new_heading = Dir.NORTH if direction_sign > 0 else Dir.SOUTH
		Dir.WEST:  new_heading = Dir.SOUTH if direction_sign > 0 else Dir.NORTH
	
	# Since it's a 90-degree turn, 180-degree "suicide" is naturally prevented
	# as we only ever move 90 degrees from the current target.
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
		# Store the current head transform as the "newest" history point
		position_history.insert(0, global_transform)
		
		# If we have segments, position them according to history
		update_segments()
		
		# Keep history from growing indefinitely; only need enough for all segments
		if position_history.size() > segments.size() + 1:
			position_history.resize(segments.size() + 1)

func update_segments() -> void:
	# Segment 0 follows the head's previous transform, Segment 1 follows Segment 0's previous, etc.
	for i in range(segments.size()):
		if i < position_history.size():
			segments[i].global_transform = position_history[i]

func add_segment() -> void:
	var new_segment = segment_scene.instantiate()
	get_parent().add_child.call_deferred(new_segment)
	
	# Initial placement at the last recorded history point or head's current if none
	if position_history.size() > 0:
		new_segment.global_transform = position_history.back()
	else:
		new_segment.global_transform = global_transform
		
	segments.append(new_segment)

func _on_area_entered(area: Area3D) -> void:
	if not is_alive: return
	if area.is_in_group("fruits"):
		area.queue_free()
		add_segment()
		move_speed += 0.2
		score += 1
		update_score_ui()
		play_eat_juice()
	elif area.is_in_group("walls"):
		die()
	elif area.is_in_group("body") and invulnerability_timer <= 0:
		die()

func update_score_ui() -> void:
	var score_label = get_node_or_null("/root/Main/HUD/ScoreLabel")
	if score_label:
		score_label.text = "Score: %d" % score

func die() -> void:
	if not is_alive: return
	is_alive = false
	
	# Rider Thrown Effect
	var cam = rider_cam
	var old_transform = cam.global_transform
	
	# Detach camera first
	remove_child(cam)
	
	# Create RigidBody3D at the root
	var rb = RigidBody3D.new()
	var collision = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 0.5
	collision.shape = sphere
	
	rb.add_child(collision)
	rb.add_child(cam)
	
	# Reset local camera transform so it stays inside the RB sphere
	cam.transform = Transform3D.IDENTITY
	
	# Add RB to the scene and place it where the camera was
	get_tree().root.add_child.call_deferred(rb)
	
	# We must use call_deferred to set global_transform after it's in the tree
	(func(): 
		rb.global_transform = old_transform
		# Ensure we don't drop through floor by giving it an initial upward kick
		rb.apply_central_impulse(Vector3(randf_range(-5, 5), 10.0, randf_range(-5, 5)))
		rb.apply_torque_impulse(Vector3(randf(), randf(), randf()) * 10.0)
	).call_deferred()
	
	# Ensure the camera is current after reparenting
	cam.make_current()
	
	# Dazed effect for the head
	var stars = Node3D.new()
	add_child.call_deferred(stars)
	(func(): 
		stars.position = Vector3(0, 1.5, 0)
		# Simple spinning stars using Sprite3D (placeholders for particles)
		for i in range(2):
			var star = Sprite3D.new()
			star.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			star.modulate = Color(1, 1, 0, 1) # Yellow
			stars.add_child(star)
			star.position = Vector3(cos(i * PI), 0, sin(i * PI)) * 0.5
		
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(stars, "rotation:y", PI * 2.0, 1.0).as_relative()
	).call_deferred()
	
	print("Snake Died!")

func play_eat_juice() -> void:
	# Squash and stretch tween
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($MeshInstance3D, "scale", Vector3(1.2, 0.8, 1.2), 0.1)
	tween.tween_property($MeshInstance3D, "scale", Vector3(1.0, 1.0, 1.0), 0.2)

func update_rotation(delta: float) -> void:
	# Smoothly interpolate rotation.y to target_rotation_y
	rotation.y = lerp_angle(rotation.y, target_rotation_y, turn_interpolation_speed * delta)
	
	# Smoothly return camera tilt to 0
	camera_tilt = lerp(camera_tilt, 0.0, turn_interpolation_speed * delta)
	rider_cam.rotation.z = camera_tilt
