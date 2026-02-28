extends SceneTree

func _init():
	var scene = load("res://assets/models/snake/cobra_animation.glb")
	var instance = scene.instantiate()
	_find_anim_player(instance)
	quit()

func _find_anim_player(node):
	if node is AnimationPlayer:
		print("Found AnimationPlayer: ", node.name)
		for anim_name in node.get_animation_list():
			print("  Animation: ", anim_name)
	for child in node.get_children():
		_find_anim_player(child)
