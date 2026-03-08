@tool
extends SceneTree

func _init():
	var scene_path = "res://assets/models/snake_Titanoboa/scene.gltf"
	var scene = load(scene_path)
	if not scene:
		print("Error: Could not load scene at ", scene_path)
		quit()
		return
	
	var root = scene.instantiate()
	print("--- Deep Model Inspection ---")

	var skeleton = _find_node_of_type(root, "Skeleton3D")
	if skeleton:
		_analyze_skeleton(skeleton)
	else:
		print("  No Skeleton3D node found in the scene.")

	quit()

func _find_node_of_type(node, type_name):
	if node.get_class() == type_name:
		return node
	for child in node.get_children():
		var found = _find_node_of_type(child, type_name)
		if found:
			return found
	return null

func _analyze_skeleton(skeleton):
	var bone_count = skeleton.get_bone_count()
	print("  Found skeleton with ", bone_count, " bones.")
	
	var min_x = 1e9
	var max_x = -1e9
	var min_x_idx = -1
	var max_x_idx = -1

	for i in range(bone_count):
		var pos = skeleton.get_bone_global_pose(i).origin
		if pos.x < min_x:
			min_x = pos.x
			min_x_idx = i
		if pos.x > max_x:
			max_x = pos.x
			max_x_idx = i
	
	var min_x_bone_name = skeleton.get_bone_name(min_x_idx) if min_x_idx != -1 else "N/A"
	var max_x_bone_name = skeleton.get_bone_name(max_x_idx) if max_x_idx != -1 else "N/A"
	
	print("  Bone X-Axis Extremes:")
	print("    Min X: ", min_x, " (Bone: '", min_x_bone_name, "')")
	print("    Max X: ", max_x, " (Bone: '", max_x_bone_name, "')")
	
	print("\n  Bone Hierarchy Path from Max-X bone ('" + max_x_bone_name + "') to root:")
	var current_idx = max_x_idx
	while current_idx != -1:
		var bone_name = skeleton.get_bone_name(current_idx)
		var parent_idx = skeleton.get_bone_parent(current_idx)
		var parent_name = skeleton.get_bone_name(parent_idx) if parent_idx != -1 else "ROOT"
		print("    - '" + bone_name + "' (Parent: '" + parent_name + "') at " + str(skeleton.get_bone_global_pose(current_idx).origin))
		current_idx = parent_idx
