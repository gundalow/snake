extends CharacterBody2D

signal score_changed(new_score)
signal food_eaten(type, total_score, food_counts)
signal status_message(text)
signal hit_obstacle

enum Dir { NORTH, SOUTH, EAST, WEST }

@export var speed: float = GameConstants.INITIAL_MOVE_SPEED
@export var turn_speed: float = GameConstants.TURN_INTERPOLATION_SPEED

var is_alive: bool = true
var heading: Dir = Dir.NORTH
var next_heading: Dir = Dir.NORTH
var target_velocity: Vector2 = Vector2.ZERO

@onready var visual: Node2D = $Visuals
@onready var sparks: CPUParticles2D = $Sparks

func _ready() -> void:
	heading = Dir.NORTH
	next_heading = Dir.NORTH

func _input(event: InputEvent) -> void:
	if not is_alive: return

	if Input.is_action_just_pressed("move_up"):
		if heading != Dir.SOUTH: next_heading = Dir.NORTH
	elif Input.is_action_just_pressed("move_down"):
		if heading != Dir.NORTH: next_heading = Dir.SOUTH
	elif Input.is_action_just_pressed("move_left"):
		if heading != Dir.EAST: next_heading = Dir.WEST
	elif Input.is_action_just_pressed("move_right"):
		if heading != Dir.WEST: next_heading = Dir.EAST

func _physics_process(delta: float) -> void:
	if not is_alive: return

	# Update heading at grid boundaries (2.5D snap turning)
	_update_heading()

	var direction = Vector2.ZERO
	match heading:
		Dir.NORTH: direction = Vector2.UP
		Dir.SOUTH: direction = Vector2.DOWN
		Dir.EAST:  direction = Vector2.RIGHT
		Dir.WEST:  direction = Vector2.LEFT

	target_velocity = direction * speed
	velocity = velocity.lerp(target_velocity, turn_speed * delta)
	
	move_and_slide()

	if get_slide_collision_count() > 0:
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			if collision.get_collider().is_in_group("walls"):
				die()

	if velocity.length() > 10.0:
		visual.rotation = lerp_angle(visual.rotation, velocity.angle(), turn_speed * delta)

func _update_heading() -> void:
	# Simplified grid snapping for 2.5D
	if next_heading != heading:
		var grid = GameConstants.GRID_SIZE
		if fmod(position.x, grid) < 5.0 and fmod(position.y, grid) < 5.0:
			heading = next_heading

func die() -> void:
	if not is_alive: return
	is_alive = false
	velocity = Vector2.ZERO
	sparks.emitting = true
	hit_obstacle.emit()
