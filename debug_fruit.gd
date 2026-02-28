extends SceneTree

func _init():
	print("--- Detailed Fruit Debug Script ---")
	var fruit_scene = load("res://scenes/main/Fruit.tscn")
	if not fruit_scene:
		print("ERROR: Could not load Fruit.tscn")
		quit(1)
		return
	
	var fruit = fruit_scene.instantiate()
	root.add_child(fruit)
	
	# Give it a bit of time for _ready to trigger and for any async stuff
	# Though in headless mode it might be immediate.
	# We can use a timer or just wait a few frames.
	
func _process(_delta):
	var fruit = root.get_node_or_null("Fruit")
	if not fruit: return
	
	# Wait for Fruit.gd to have added the model (it happens in _ready)
	# Fruit.gd prints "Spawning fruit: ..." in _ready
	
	var children = fruit.get_children()
	if children.size() < 3: # MeshInstance3D, CollisionShape3D, and the Model
		return
		
	print("\n--- Inspecting Fruit Instance ---")
	print("Fruit Node: ", fruit.name, " [", fruit.get_class(), "]")
	print("Position: ", fruit.position)
	print("Visible: ", fruit.visible)
	
	print("\nTree structure:")
	print_tree_recursive(fruit, "  ")
	
	print("\n--- End Debug ---")
	quit()

func print_tree_recursive(node, indent):
	var info = indent + node.name + " [" + node.get_class() + "]"
	if node is Node3D:
		info += " Pos: " + str(node.position) + " Visible: " + str(node.visible)
		if node is MeshInstance3D:
			info += " Mesh: " + (str(node.mesh) if node.mesh else "NULL")
	print(info)
	for child in node.get_children():
		print_tree_recursive(child, indent + "  ")
