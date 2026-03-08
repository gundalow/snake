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

	print("Testing bending on ", skeleton.name)
	
	# Apply a simple sine wave bend to the bones
	for i in range(skeleton.get_bone_count()):
		var pose = skeleton.get_bone_rest(i)
		var origin = pose.origin
		
		# Offset Y based on X position to create a 'wave'
		var wave = sin(origin.x * 0.5) * 2.0
		pose.origin.y += wave
		
		# Rotate slightly to match the slope
		var angle = cos(origin.x * 0.5) * 0.5
		pose.basis = pose.basis.rotated(Vector3(0, 0, 1), angle)
		
		skeleton.set_bone_pose_position(i, pose.origin)
		skeleton.set_bone_pose_rotation(i, pose.basis.get_rotation_quaternion())
		
	print("Bend poses applied to ", skeleton.get_bone_count(), " bones.")
	
	# In a real game, these would be applied via set_bone_global_pose_override
	# but for a quick script check, pose properties are enough.
	
	# We can't visually see it here, but we can verify the poses are set
	var test_bone = 45
	print("Bone ", test_bone, " pose position: ", skeleton.get_bone_pose_position(test_bone))
	
	quit()

func _find_skeleton(node):
	if node is Skeleton3D: return node
	for child in node.get_children():
		var res = _find_skeleton(child)
		if res: return res
	return null
