@tool
extends SceneTree

func _init():
	var scene = load("res://assets/models/snake_Titanoboa/scene.gltf").instantiate()
	if not scene:
		print("Failed to load scene")
		quit()
		return

	print("--- All Mesh Instances ---")
	_print_meshes(scene, Transform3D())

	print("\n--- Skeleton & Bone Hierarchy ---")
	var skeleton = _find_skeleton(scene)
	if skeleton:
		print("Skeleton found: ", skeleton.name)
		var bone_count = skeleton.get_bone_count()
		var head_bones = []
		var tail_bones = []
		
		# Find bones by name and position
		var min_x = 1e9
		var max_x = -1e9
		var min_x_idx = -1
		var max_x_idx = -1

		for i in range(bone_count):
			var b_name = skeleton.get_bone_name(i)
			var pose = skeleton.get_bone_global_pose(i).origin
			if pose.x < min_x:
				min_x = pose.x
				min_x_idx = i
			if pose.x > max_x:
				max_x = pose.x
				max_x_idx = i
			
			if "head" in b_name.to_lower() or "teeth" in b_name.to_lower():
				head_bones.append({"name": b_name, "pos": pose})
		
		print("Bone X Range: ", min_x, " (", skeleton.get_bone_name(min_x_idx), ") to ", max_x, " (", skeleton.get_bone_name(max_x_idx), ")")
		print("Potential Head Bones:")
		for hb in head_bones:
			print("  ", hb.name, " at ", hb.pos)
			
		# Check if parent of min_x_bone is towards max_x or vice-versa
		var current = min_x_idx
		print("\nPath from Min-X bone to root:")
		while current != -1:
			print("  ", skeleton.get_bone_name(current), " at ", skeleton.get_bone_global_pose(current).origin)
			current = skeleton.get_bone_parent(current)
			
	quit()

func _print_meshes(node, accum_transform):
	var local_transform = accum_transform
	if node is Node3D:
		local_transform = accum_transform * node.transform
	
	if node is MeshInstance3D:
		var aabb = node.mesh.get_aabb()
		var center = local_transform * aabb.get_center()
		var min_corner = local_transform * aabb.position
		var max_corner = local_transform * (aabb.position + aabb.size)
		print("Mesh: ", node.name, " | Center: ", center, " | X-Range: ", min_corner.x, " to ", max_corner.x)
	
	for child in node.get_children():
		_print_meshes(child, local_transform)

func _find_skeleton(node):
	if node is Skeleton3D: return node
	for child in node.get_children():
		var res = _find_skeleton(child)
		if res: return res
	return null
