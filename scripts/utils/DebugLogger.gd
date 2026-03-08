extends Node
@onready var snake_head = get_parent()
var head_box: MeshInstance3D
var tail_box: MeshInstance3D
@onready var snake_model: Node3D = snake_head.get_node_or_null("SnakeModel")

var teeth_node: Node3D
var tail_bone_node: Node3D 

func _ready():
	head_box = snake_head.get_node_or_null("HeadDebug")
	tail_box = snake_head.get_node_or_null("TailDebug")

	if snake_model:
		teeth_node = snake_model.find_child("Object_11", true, false) 
		tail_bone_node = snake_model.find_child("Object_7", true, false)

		if is_instance_valid(teeth_node):
			add_arrow_hat_to(teeth_node)

func add_arrow_hat_to(node: Node3D):
	var arrow_hat = MeshInstance3D.new()

	var arrow_mesh = PrismMesh.new()
	arrow_mesh.size = Vector3(0.5, 0.5, 1.0)
	arrow_hat.mesh = arrow_mesh

	var arrow_mat = StandardMaterial3D.new()
	arrow_mat.albedo_color = Color.MAGENTA
	arrow_mat.emission_enabled = true
	arrow_mat.emission = Color.MAGENTA
	arrow_hat.material_override = arrow_mat

	arrow_hat.transform = Transform3D(Basis.from_euler(Vector3(0, PI/2, 0)), Vector3(-0.5, 0.2, 0))

	node.add_child(arrow_hat)
	print("DEBUG: Arrow Hat added to teeth node.")

func log_positions(label: String):
	print("\n--- ", label, " ---")
	print("SnakeHead (Pivot) Global Pos: ", snake_head.global_position)
	if is_instance_valid(head_box):
		print("Head Box (Red)    Global Pos: ", head_box.global_position)
	if is_instance_valid(tail_box):
		print("Tail Box (Yellow) Global Pos: ", tail_box.global_position)
	if is_instance_valid(teeth_node):
		print("Model Teeth       Global Pos: ", teeth_node.global_position)
		# In Godot, -Z is forward.
		var teeth_forward = -teeth_node.global_transform.basis.z.normalized()
		print("Model Teeth Forward Vector: ", teeth_forward)
	if is_instance_valid(tail_bone_node):
		print("Model Body/Tail   Global Pos: ", tail_bone_node.global_position)
	print("--------------------")

func _input(event):
	if event is InputEventKey and event.is_pressed():
		var key = event.get_keycode_with_modifiers()
		if key == KEY_UP or key == KEY_DOWN or key == KEY_LEFT or key == KEY_RIGHT:
			get_tree().create_timer(0.02).timeout.connect(func(): log_positions("After Move"))
