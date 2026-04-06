extends CharacterBody2D

@export var speed: float = 300.0
var target_velocity: Vector2 = Vector2.ZERO

@onready var visuals = $Visuals

func _input(event: InputEvent) -> void:
    if event is InputEventScreenDrag:
        target_velocity = event.relative.normalized() * speed

func _physics_process(delta: float) -> void:
    # Smooth lerp for a heavy feel
    velocity = velocity.lerp(target_velocity, 10.0 * delta)
    move_and_slide()

    # Rotate visuals based on current movement direction
    if velocity.length() > 10.0:
        visuals.rotation = velocity.angle()
