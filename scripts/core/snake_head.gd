extends CharacterBody2D

signal hit_obstacle

@export var speed: float = 300.0
var target_velocity: Vector2 = Vector2.ZERO
var is_active: bool = true

@onready var visuals = $Visuals
@onready var sparks = $Sparks

func _input(event: InputEvent) -> void:
    if not is_active: return
    if event is InputEventScreenDrag:
        target_velocity = event.relative.normalized() * speed

func _physics_process(delta: float) -> void:
    if not is_active: return

    # Smooth lerp for a heavy feel
    velocity = velocity.lerp(target_velocity, 10.0 * delta)
    move_and_slide()

    # Visual Juice: sparks on collision
    if get_slide_collision_count() > 0:
        sparks.emitting = true
        # Check if we hit a StaticBody2D (Obstacle) or another Area2D (Segment)
        for i in range(get_slide_collision_count()):
            var collision = get_slide_collision(i)
            var collider = collision.get_collider()
            if collider is StaticBody2D:
                die()

    # Rotate visuals based on current movement direction
    if velocity.length() > 10.0:
        visuals.rotation = velocity.angle()

func die() -> void:
    if not is_active: return
    is_active = false
    target_velocity = Vector2.ZERO
    hit_obstacle.emit()
