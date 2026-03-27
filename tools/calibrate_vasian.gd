@tool
extends SceneTree

func _init():
	var path = "res://assets/models/snake_vasian-digital3d/scene.gltf"
	var scene = load(path).instantiate()
	var skeleton: Skeleton3D = _find_skeleton(scene)
	
	var bone_name = "b_f_tongue_05_017" # The furthest tip
	var bone_idx = skeleton.find_bone(bone_name)
	
	# This is the transform of the bone relative to the Skeleton node
	var bone_pose = skeleton.get_bone_global_pose(bone_idx)
	
	# This is the transform of the Skeleton relative to the GLTF root
	var skeleton_local_xform = _get_total_local_transform(skeleton)
	
	# The actual position of the tongue tip relative to the GLTF root is:
	var tip_local_pos = skeleton_local_xform * bone_pose.origin
	
	print("\n=== DEFINITIVE VASIAN ALIGNMENT ===\n")
	print("Tongue Tip Local Position: ", tip_local_pos)
	
	# To center this tip at (0,0,0), we need to translate by -tip_local_pos
	# But we ALSO need to account for rotation.
	# Let's find the tail tip too.
	var tail_bone = "b_f_body_28_045"
	var tail_pose = skeleton.get_bone_global_pose(skeleton.find_bone(tail_bone))
	var tail_local_pos = skeleton_local_xform * tail_pose.origin
	
	var local_dir = (tip_local_pos - tail_local_pos).normalized()
	print("Intrinsic Local Direction (Tail to Tip): ", local_dir)
	
	# Calculate basis to point local_dir to North (-Z)
	var b = Basis.looking_at(local_dir, Vector3.UP)
	# Basis.looking_at(target, up) points -Z towards target.
	# So this basis already points -Z towards the tip. Correct.
	
	# But wait, we want to align the model so its internal 'local_dir' faces North.
	# So we need the rotation R that makes R * local_dir = (0, 0, -1).
	var rotation_needed = b.inverse()
	
	# Final Offset: after rotation, where does the tip end up?
	var rotated_tip = rotation_needed * tip_local_pos
	var final_offset = -rotated_tip
	
	# Unit Scaling:
	# The distance from tip to tail in local units is:
	var local_len = tip_local_pos.distance_to(tail_local_pos)
	print("Local Model Length: ", local_len)
	# Target length is ~17.6 units. 
	var scale_factor = 17.6 / local_len
	print("Required Scale Factor: ", scale_factor)

	print("\n=== PRODUCTION TRANSFORM ===\n")
	var final_basis = rotation_needed.scaled(Vector3.ONE * scale_factor)
	var final_pos = final_offset * scale_factor
	final_pos.y -= 0.05 # floor
	
	print("Transform3D(")
	print("    ", final_basis.x.x, ", ", final_basis.x.y, ", ", final_basis.x.z, ",")
	print("    ", final_basis.y.x, ", ", final_basis.y.y, ", ", final_basis.y.z, ",")
	print("    ", final_basis.z.x, ", ", final_basis.z.y, ", ", final_basis.z.z, ",")
	print("    ", final_pos.x, ", ", final_pos.y, ", ", final_pos.z)
	print(")")

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
