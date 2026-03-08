@tool
extends SceneTree

func _init():
	var path = "res://assets/models/snake_vasian-digital3d/scene.gltf"
	var scene = load(path).instantiate()
	
	# 1. Force the straight pose (the game's baseline)
	var skeleton: Skeleton3D = _find_skeleton(scene)
	for i in range(skeleton.get_bone_count()):
		skeleton.set_bone_pose_position(i, skeleton.get_bone_rest(i).origin)
		skeleton.set_bone_pose_rotation(i, Quaternion.IDENTITY)
		skeleton.set_bone_pose_scale(i, Vector3.ONE)
	
	# 2. Find the world-space tip of the snout in this straight pose
	var bone_idx = skeleton.find_bone("b_f_tongue_05_017")
	# global_pose is relative to Skeleton node
	var tip_pos_skeleton_local = skeleton.get_bone_global_pose(bone_idx).origin
	# Convert to model-root-local
	var tip_pos_model_local = _get_total_local_transform(skeleton) * tip_pos_skeleton_local
	
	print("\n=== SNOUT CALCULATION (STRAIGHT POSE) ===\n")
	print("Snout Tip (Model Local): ", tip_pos_model_local)
	
	# 3. Calculate the required offset
	# We want our 'verified_basis' which is:
	var basis = Basis(Vector3(0,0,1), Vector3(0,1,0), Vector3(-1,0,0))
	
	# To get the tip to (0,0,0) after rotation, we need:
	# RotatedTip + Offset = 0  =>  Offset = -(Basis * tip_pos_model_local)
	var offset = -(basis * tip_pos_model_local)
	
	print("\n=== FINAL PRODUCTION TRANSFORM ===\n")
	print("Transform3D(0, 0, 1, 0, 1, 0, -1, 0, 0, ", offset.x, ", ", -0.05, ", ", offset.z, ")")
	print("\n==========================================\n")
	quit()

func _find_skeleton(node):
	if node is Skeleton3D: return node
	for child in node.get_children():
		var res = _find_skeleton(child)
		if res: return res
	return null

func _get_total_local_transform(node: Node3D) -> Transform3D:
	var xform = node.transform
	var p = node.get_parent()
	while p and p.name != "Sketchfab_Scene" and p is Node3D:
		xform = p.transform * xform
		p = p.get_parent()
	return xform
