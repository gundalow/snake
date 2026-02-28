extends SceneTree

func _init():
	var scene = load("res://assets/models/snake/cobra_animation.glb")
	var instance = scene.instantiate()
	_measure(instance)
	quit()

func _measure(node):
	var aabb = AABB()
	var first = true
	
	for child in _get_all_children(node):
		if child is MeshInstance3D:
			var mesh_aabb = child.get_aabb()
			var global_aabb = child.get_global_transform() * mesh_aabb
			if first:
				aabb = global_aabb
				first = false
			else:
				aabb = aabb.merge(global_aabb)
	
	print("--- MODEL MEASUREMENTS (Internal Scale) ---")
	print("Size: ", aabb.size)
	print("Center: ", aabb.get_center())
	print("Min: ", aabb.position)
	print("Max: ", aabb.position + aabb.size)

func _get_all_children(node):
	var children = []
	for child in node.get_children():
		children.append(child)
		children.append_array(_get_all_children(child))
	return children
