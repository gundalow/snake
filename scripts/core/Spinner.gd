extends CSGPolygon3D

@export var rotation_speed: float = 2.0

func _process(delta: float) -> void:
	rotation.y += delta * rotation_speed
	rotation.x += delta * (rotation_speed * 0.5)
