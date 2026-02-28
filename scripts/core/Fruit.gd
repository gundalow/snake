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
	
	# Attempt to center the model if it has weird offsets
	# GLB imports often have nested nodes with large offsets (e.g. banana at -11, -7, 7)
	_reset_child_positions(model)

	# Hide the placeholder mesh
	if mesh_instance:
		mesh_instance.visible = false
		print("Placeholder mesh hidden")

	# Use a reasonable scale for gameplay
	model.scale = Vector3(2.0, 2.0, 2.0)
	
	# Add a glowing light to ensure they are visible even in shadow
	var light = OmniLight3D.new()
	light.light_color = Color(1.0, 1.0, 0.5)
	light.omni_range = 5.0
	light.light_energy = 2.0
	add_child(light)
	light.position = Vector3(0, 0.5, 0)
	
	print("Fruit initialized: ", random_key, " Scale: ", model.scale)

	# Apply a simple rotation
	model.rotation_degrees = Vector3(0, randf_range(0, 360), 0)

# Recursively reset child positions to identity for imported scenes
# This handles the case where the fruit model is far from its own scene origin
func _reset_child_positions(node: Node) -> void:
	for child in node.get_children():
		if child is Node3D:
			child.position = Vector3.ZERO
			# Only go 2 levels deep to avoid breaking models with complex structures
			# Usually fruit is just a few nodes deep
			for subchild in child.get_children():
				if subchild is Node3D:
					subchild.position = Vector3.ZERO
