extends SceneTree

func _init():
	var scene = load("res://assets/models/snake/cobra_animation.glb")
	var instance = scene.instantiate()
	_inspect_anim(instance)
	quit()

func _inspect_anim(node):
	if node is AnimationPlayer:
		var anim = node.get_animation("SANKE animations")
		if anim:
			print("Animation: SANKE animations")
			print("  Length: ", anim.length)
			print("  Track count: ", anim.get_track_count())
			for i in range(anim.get_track_count()):
				var path = anim.track_get_path(i)
				if "RootNode" in str(path) or "Sketchfab_Scene" in str(path) or ":position" in str(path):
					print("  Track ", i, ": ", path)
	for child in node.get_children():
		_inspect_anim(child)
