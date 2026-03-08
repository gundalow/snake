@tool
extends SceneTree

func _init():
	var path = "res://assets/models/snake_Titanoboa/scene.gltf"
	var scene = load(path).instantiate()
	
	print("\n=== TITANOBOA MORPH ANALYSIS ===\n")
	
	_find_and_test_morphs(scene)
	quit()

func _find_and_test_morphs(node):
	if node is MeshInstance3D:
		var mesh = node.mesh
		var count = mesh.get_blend_shape_count()
		if count > 0:
			print("Mesh: ", node.name)
			for i in range(count):
				print("  - Morph %d: '%s'" % [i, mesh.get_blend_shape_name(i)])
	
	for child in node.get_children():
		_find_and_test_morphs(child)
