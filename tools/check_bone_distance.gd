@tool
extends SceneTree

func _init():
	var model_path = "res://assets/models/snake_Titanoboa/scene.gltf"
	var scene = load(model_path)
	if not scene:
		print("Error: Could not load scene")
		quit()
		return

	var root = scene.instantiate()
	var skeleton: Skeleton3D = _find_skeleton(root)
	if not skeleton:
		print("Error: No Skeleton3D found")
		quit()
		return

	var body_bones = []
	for i in range(skeleton.get_bone_count()):
		var b_name = skeleton.get_bone_name(i)
		if b_name.begins_with("Bone"):
			body_bones.append(i)

	print("Found ", body_bones.size(), " body bones.")

	if body_bones.size() > 1:
		var b1 = body_bones[0]
		var b2 = body_bones[1]
		var p1 = skeleton.get_bone_rest(b1).origin
		var p2 = skeleton.get_bone_rest(b2).origin
		print("Bone 0 rest: ", p1)
		print("Bone 1 rest: ", p2)
		print("Distance: ", p1.distance_to(p2))

	quit()

func _find_skeleton(node):
	if node is Skeleton3D: return node
	for child in node.get_children():
		var res = _find_skeleton(child)
		if res: return res
	return null
