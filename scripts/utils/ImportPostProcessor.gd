@tool
extends EditorScenePostImport

# This script automates several import tasks:
# 1. Mesh names ending in "-col" get a Simplified Convex Collision.
# 2. Nodes named "Socket_Front" or "Socket_Back" are converted to Marker3D.
# 3. Meshes with "Snake" in their name get the "Snake_Skin" material applied.

func _post_import(scene: Node) -> Object:
	iterate_nodes(scene)
	return scene

func iterate_nodes(node: Node) -> void:
	# 1. Check for "-col" suffix for collision generation
	if node is MeshInstance3D and node.name.to_lower().ends_with("-col"):
		generate_convex_collision(node)

	# 2. Convert "Socket_Front" and "Socket_Back" to Marker3D
	if node.name == "Socket_Front" or node.name == "Socket_Back":
		var marker = Marker3D.new()
		marker.name = node.name
		marker.transform = node.transform

		var parent = node.get_parent()
		if parent:
			parent.add_child(marker)
			marker.owner = node.owner # Crucial for saving in the scene

			# Move children from old node to marker to prevent data loss
			for child in node.get_children():
				node.remove_child(child)
				marker.add_child(child)
				child.owner = node.owner

			parent.remove_child(node)
			node.queue_free()
			node = marker # Continue iteration with the new marker

	# 3. Automated Material Swapper
	if node is MeshInstance3D and "Snake" in node.name:
		apply_snake_skin_material(node)

	# Recursive iteration
	for child in node.get_children():
		iterate_nodes(child)

func generate_convex_collision(mesh_instance: MeshInstance3D) -> void:
	# Godot 4 approach to programmatic collision generation in post-import:
	# Create a StaticBody3D and a CollisionShape3D with a convex shape.
	var mesh = mesh_instance.mesh
	if not mesh: return

	var static_body = StaticBody3D.new()
	static_body.name = mesh_instance.name + "_StaticBody"
	mesh_instance.add_child(static_body)
	static_body.owner = mesh_instance.owner

	var collision_shape = CollisionShape3D.new()
	collision_shape.name = mesh_instance.name + "_CollisionShape"

	# Create a simplified convex shape from the mesh
	var shape = mesh.create_convex_shape(true, true)
	collision_shape.shape = shape

	static_body.add_child(collision_shape)
	collision_shape.owner = mesh_instance.owner

func apply_snake_skin_material(mesh_instance: MeshInstance3D) -> void:
	# Look for "Snake_Skin" material in assets/textures/
	var material_path = "res://assets/textures/Snake_Skin.tres"
	var material: Material

	if ResourceLoader.exists(material_path):
		material = load(material_path)
	else:
		# Fallback: Create a placeholder material if it doesn't exist
		var placeholder = StandardMaterial3D.new()
		placeholder.resource_name = "Snake_Skin_Placeholder"
		placeholder.albedo_color = Color(0.2, 0.8, 0.2) # Neon Green
		material = placeholder

	# Apply to all surface indices
	if mesh_instance.mesh:
		for i in range(mesh_instance.mesh.get_surface_count()):
			mesh_instance.set_surface_override_material(i, material)
