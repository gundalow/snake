extends Node3D

@export var move_speed: float = 5.0
@export var turn_interpolation_speed: float = 10.0 # 0.1s target

var current_direction: Vector3 = Vector3.FORWARD
var next_direction: Vector3 = Vector3.FORWARD
var target_rotation_y: float = 0.0
var camera_tilt: float = 0.0

@onready var rider_cam: Camera3D = $RiderCam

func _ready() -> void:
	# Initialize rotation based on start direction (North = -Z)
	target_rotation_y = rotation.y

func _process(delta: float) -> void:
	handle_input()
	move_forward(delta)
	update_rotation(delta)

func handle_input() -> void:
	if Input.is_action_just_pressed("turn_left"):
		queue_turn(1.0) # 90 degrees left
	elif Input.is_action_just_pressed("turn_right"):
		queue_turn(-1.0) # 90 degrees right

func queue_turn(direction_sign: float) -> void:
	target_rotation_y += direction_sign * PI / 2.0
	camera_tilt = direction_sign * 0.1 # Slight tilt in radians

func move_forward(delta: float) -> void:
	# We move in the direction the head is facing
	var forward = -transform.basis.z
	global_position += forward * move_speed * delta

func update_rotation(delta: float) -> void:
	# Smoothly interpolate rotation.y to target_rotation_y
	rotation.y = lerp_angle(rotation.y, target_rotation_y, turn_interpolation_speed * delta)
	
	# Smoothly return camera tilt to 0
	camera_tilt = lerp(camera_tilt, 0.0, turn_interpolation_speed * delta)
	rider_cam.rotation.z = camera_tilt
