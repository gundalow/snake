extends Camera3D

var shake_intensity = 0.0
var shake_decay = 0.9

func _process(_delta: float) -> void:
	if shake_intensity > 0.01:
		var offset = Vector3(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		h_offset = offset.x
		v_offset = offset.y
		shake_intensity *= shake_decay
	else:
		h_offset = 0
		v_offset = 0
		shake_intensity = 0

func shake(intensity: float = 1.0) -> void:
	shake_intensity = intensity
