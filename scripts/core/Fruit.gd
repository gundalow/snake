extends Area3D

const MODELS = {
	"apple": preload("res://assets/models/apple.glb"),
	"banana": preload("res://assets/models/banana.glb"),
	"orange": preload("res://assets/models/orange.glb")
}

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	# Randomly select a fruit model
	var keys = MODELS.keys()
	var random_key = keys[randi() % keys.size()]
	var model_scene = MODELS[random_key]

	# Instantiate the model
	var model = model_scene.instantiate()
	add_child(model)

	# Hide the placeholder mesh if it exists
	if mesh_instance:
		mesh_instance.visible = false

	# Adjust scale if necessary (assuming original models might be large)
	# We want them to fit roughly in a 0.8x0.8x0.8 box
	model.scale = Vector3(0.5, 0.5, 0.5) # Adjust based on actual model size if known

	# Apply a simple rotation to make them look interesting
	model.rotation_degrees = Vector3(randf_range(0, 360), randf_range(0, 360), randf_range(0, 360))
