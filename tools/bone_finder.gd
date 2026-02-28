extends SceneTree

func _init():
	var scene = load("res://assets/models/snake/cobra_animation.glb")
	if not scene:
		print("FAILED TO LOAD SNAKE MODEL")
		quit()
		return
		
	var instance = scene.instantiate()
	
	print("--- SKELETON ANALYSIS ---")
	_find_skeletons(instance)
	quit()

func _find_skeletons(node):
	if node is Skeleton3D:
		print("Found Skeleton: ", node.name)
		for i in range(node.get_bone_count()):
			var bone_name = node.get_bone_name(i)
			if "36" in str(i) or "36" in bone_name:
				print("  BONE INDEX ", i, ": ", bone_name)
	for child in node.get_children():
		_find_skeletons(child)
