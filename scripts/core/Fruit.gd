extends Area3D

const MODELS = {
	"apple": preload("res://assets/models/apple.glb"),
	"banana": preload("res://assets/models/banana.glb"),
	"orange": preload("res://assets/models/orange.glb")
}

func _ready() -> void:
	# Randomly select a fruit model
	var keys = MODELS.keys()
	var random_key = keys[randi() % keys.size()]
	var model_scene = MODELS[random_key]
	print("--- Spawning fruit: ", random_key, " ---")

	# Instantiate the model
	var model = model_scene.instantiate()
	add_child(model)
	
	# Recursively reset all local positions in the imported scene to (0,0,0)
	# This fixes cases where the fruit mesh is far from its own scene origin
	_reset_all_node_positions(model)

	# Use a reasonable scale for gameplay
	model.scale = Vector3(2.0, 2.0, 2.0)
	
	# Add a glowing light to ensure they are visible even in shadow
	var light = OmniLight3D.new()
	light.light_color = Color(1.0, 1.0, 0.5)
	light.omni_range = 10.0
	light.light_energy = 3.0
	add_child(light)
	light.position = Vector3(0, 0.5, 0)
	
	# Apply a simple rotation
	model.rotation_degrees = Vector3(0, randf_range(0, 360), 0)
	
	# Final check of positions
	print("Fruit Node (Area3D) Global Pos: ", global_position)
	_print_mesh_positions(model, 0)

# Recursively reset child positions to identity for imported scenes
func _reset_all_node_positions(node: Node) -> void:
	if node is Node3D:
		if node.position != Vector3.ZERO:
			print("  Resetting offset: ", node.name, " from ", node.position, " to (0,0,0)")
			node.position = Vector3.ZERO
	for child in node.get_children():
		_reset_all_node_positions(child)

# Debug print to verify where the meshes are actually located
func _print_mesh_positions(node: Node, depth: int) -> void:
	if node is MeshInstance3D:
		print("  " + "  ".repeat(depth) + "MeshInstance: " + node.name + " at Global Pos: " + str(node.global_position))
	for child in node.get_children():
		_print_mesh_positions(child, depth + 1)
