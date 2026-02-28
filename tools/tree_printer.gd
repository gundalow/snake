extends SceneTree

func _init():
	var scene = load("res://assets/models/snake/cobra_animation.glb")
	var instance = scene.instantiate()
	_print_tree(instance, "")
	quit()

func _print_tree(node, indent):
	print(indent + node.name + " (" + node.get_class() + ")")
	for child in node.get_children():
		_print_tree(child, indent + "  ")
