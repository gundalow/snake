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
	print("Spawning fruit: ", random_key)

	# Instantiate the model
	var model = model_scene.instantiate()
	add_child(model)

	# Hide the placeholder mesh
	if mesh_instance:
		mesh_instance.visible = false
		print("Placeholder mesh hidden")

	# Adjust scale based on the fruit type - making them much larger for visibility
	model.scale = Vector3(1.5, 1.5, 1.5)
	
	# Add a glowing light to make it very obvious where the fruit is
	var light = OmniLight3D.new()
	light.light_color = Color(1.0, 1.0, 0.5) # Yellowish glow
	light.omni_range = 5.0
	light.light_energy = 2.0
	add_child(light)
	light.position = Vector3(0, 1.0, 0)
	
	print("Model scale: ", model.scale, " - Added light at: ", light.position)

	# Apply a simple rotation - but keep it upright initially to see it better
	model.rotation_degrees = Vector3(0, randf_range(0, 360), 0)
