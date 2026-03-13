@tool
extends SceneTree

func _init():
	var args = OS.get_cmdline_args()
	var model_path = "res://assets/models/snake_Titanoboa/scene.gltf"
	
	for i in range(args.size()):
		if args[i].ends_with(".gltf"):
			model_path = args[i]
			if not model_path.begins_with("res://"):
				model_path = "res://" + model_path
			break

	print("\n====================================================")
	print("DEEP INSPECTION: ", model_path)
	print("====================================================\n")

	var scene = load(model_path)
	if not scene:
		print("Error: Could not load scene")
		quit()
		return
	
	var root = scene.instantiate()
	
	print("[1] Morph Target (Blend Shape) Analysis")
	_find_all_morphs(root)
	
	print("\n[2] Jaw & Head Bone Analysis")
	var skeleton = _find_skeleton(root)
	if skeleton:
		_analyze_bones_for_mouth(skeleton)
	
	print("\n[3] Animation Analysis")
	var anim_player = _find_node_of_type(root, "AnimationPlayer")
	if anim_player:
		for anim_name in anim_player.get_animation_list():
			var anim = anim_player.get_animation(anim_name)
			print("  Animation: '", anim_name, "' (Length: ", anim.length, "s)")
			print("    Tracks: ", anim.get_track_count())
			# Look for tracks that might be mouth related
			for t in range(anim.get_track_count()):
				var path = str(anim.track_get_path(t))
				if "morph" in path.to_lower() or "blend" in path.to_lower() or "jaw" in path.to_lower() or "mouth" in path.to_lower():
					print("      - Found relevant track: ", path)
	
	quit()

func _find_all_morphs(node):
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			var morph_count = mesh.get_blend_shape_count()
			if morph_count > 0:
				print("  Mesh '", node.name, "' has ", morph_count, " morph targets:")
				for i in range(morph_count):
					print("    - Index ", i, ": '", mesh.get_blend_shape_name(i), "'")
	for child in node.get_children():
		_find_all_morphs(child)

func _analyze_bones_for_mouth(skeleton):
	print("  Skeleton: ", skeleton.name)
	var found_any = false
	var keywords = ["jaw", "mouth", "head", "teeth", "tongue", "upper", "lower"]
	for i in range(skeleton.get_bone_count()):
		var b_name = skeleton.get_bone_name(i).to_lower()
		for kw in keywords:
			if kw in b_name:
				print("    - Found Bone: '", skeleton.get_bone_name(i), "' at index ", i)
				found_any = true
				break
	if not found_any:
		print("    No bones matching mouth/jaw keywords found.")

func _find_skeleton(node):
	if node is Skeleton3D: return node
	for child in node.get_children():
		var res = _find_skeleton(child)
		if res: return res
	return null

func _find_node_of_type(node, type_name):
	if node.get_class() == type_name:
		return node
	for child in node.get_children():
		var found = _find_node_of_type(child, type_name)
		if found:
			return found
	return null
