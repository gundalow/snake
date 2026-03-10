extends Node3D

@export var enabled: bool = true

func _process(_delta: float) -> void:
	if not enabled: return

	# Draw forward vector (Blue)
	var forward = -global_transform.basis.z.normalized()
	DebugDraw.draw_line(global_position, global_position + forward * 2.0, Color.BLUE)

	# Draw right vector (Red)
	var right = global_transform.basis.x.normalized()
	DebugDraw.draw_line(global_position, global_position + right * 1.5, Color.RED)

# Simple debug draw singleton-like helper if not exists
# For now we will just use a simple MeshInstance3D based approach or similar if needed,
# but Godot's ImmediateMesh is better.
# Actually, let's just use two MeshInstance3Ds for simple visual arrows.
