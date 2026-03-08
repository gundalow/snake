@tool
extends SceneTree

func _init():
	var scene = load("res://assets/models/snake_Titanoboa/scene.gltf").instantiate()
	var meshes = ["Object_10", "Object_11", "Object_12"] # Mouth/Teeth area
	
	for m_name in meshes:
		var node = scene.find_child(m_name, true, false)
		if node and node is MeshInstance3D:
			var aabb = node.mesh.get_aabb()
			# Local to the MeshInstance, but these nodes are under Skeleton
			var global_aabb = node.transform * aabb
			print("Node: ", m_name)
			print("  Center: ", global_aabb.get_center())
			print("  Min X: ", global_aabb.position.x)
			print("  Max X: ", global_aabb.position.x + global_aabb.size.x)
			print("  Z Range: ", global_aabb.position.z, " to ", global_aabb.position.z + global_aabb.size.z)

	quit()
