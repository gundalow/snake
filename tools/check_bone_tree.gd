@tool
extends SceneTree

func _init():
	_check_model("res://assets/models/snake_Titanoboa/scene.gltf")
	_check_model("res://assets/models/snake_vasian-digital3d/scene.gltf")
	quit()

func _check_model(path):
	print("\n--- Bone Tree Check: ", path, " ---")
	var scene = load(path)
	if not scene: return
	var root = scene.instantiate()
	var skeleton = _find_skeleton(root)
	if not skeleton: 
		print("No skeleton found")
		return
	
	# Find root-most bone and its immediate children
	for i in range(skeleton.get_bone_count()):
		var parent = skeleton.get_bone_parent(i)
		var b_name = skeleton.get_bone_name(i)
		if parent == -1:
			print("Root Bone: ", b_name)
			_print_children(skeleton, i, 1, 5) # Print deeper to find jaw

func _print_children(skeleton, bone_idx, indent_level, max_depth):
	if indent_level > max_depth: return
	var indent = ""
	for i in range(indent_level): indent += "  "
	for i in range(skeleton.get_bone_count()):
		if skeleton.get_bone_parent(i) == bone_idx:
			print(indent, "- ", skeleton.get_bone_name(i))
			_print_children(skeleton, i, indent_level + 1, max_depth)

func _find_skeleton(node):
	if node is Skeleton3D: return node
	for child in node.get_children():
		var res = _find_skeleton(child)
		if res: return res
	return null
