extends Node

@onready var snake_head = get_parent()
var head_box: MeshInstance3D
var tail_box: MeshInstance3D
@onready var snake_model: Node3D = snake_head.get_node_or_null("SnakeModel")

var teeth_node: Node3D
var mouth_mesh_node: Node3D
var tongue_mesh_node: Node3D

var bone_spheres: Array[MeshInstance3D] = []

func _ready():
	head_box = snake_head.get_node_or_null("HeadDebug")
	tail_box = snake_head.get_node_or_null("TailDebug")

	if snake_model:
		teeth_node = snake_model.find_child("Object_11", true, false) # teeth.001
		mouth_mesh_node = snake_model.find_child("Object_12", true, false) # mouth.001
		tongue_mesh_node = snake_model.find_child("Object_10", true, false) # tongue

		_add_truth_arrows.call_deferred()
		_setup_skeleton_debug.call_deferred()

func _setup_skeleton_debug():
	var skeleton = _find_skeleton(snake_model)
	if not skeleton: return

	# Create spheres for the first 10 and last 10 bones
	var bone_count = skeleton.get_bone_count()
	for i in range(bone_count):
		if i < 10 or i > bone_count - 10:
			var sphere = MeshInstance3D.new()
			var m = SphereMesh.new()
			m.radius = 0.1
			m.height = 0.2
			sphere.mesh = m
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color.YELLOW if i < 10 else Color.PURPLE
			mat.no_depth_test = true
			sphere.material_override = mat
			get_tree().root.add_child(sphere) # Add to root so they stay at global pos
			bone_spheres.append(sphere)

func _process(_delta):
	var skeleton = _find_skeleton(snake_model)
	if not skeleton: return

	var bone_count = skeleton.get_bone_count()
	var sphere_idx = 0
	for i in range(bone_count):
		if i < 10 or i > bone_count - 10:
			if sphere_idx < bone_spheres.size():
				var pose = skeleton.get_bone_global_pose(i)
				bone_spheres[sphere_idx].global_position = skeleton.global_transform * pose.origin
				sphere_idx += 1

func _add_truth_arrows():
	_create_arrow(Vector3(0, 0, -2), Color.BLUE) # BLUE = Node Forward (-Z)
	_create_arrow(Vector3(2, 0, 0), Color.RED)   # RED = Node Right (+X)
	_create_arrow(Vector3(0, 2, 0), Color.GREEN) # GREEN = Node Up (+Y)

func _create_arrow(dir: Vector3, color: Color):
	var mesh_instance = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(
		abs(dir.x) if dir.x != 0 else 0.05,
		abs(dir.y) if dir.y != 0 else 0.05,
		abs(dir.z) if dir.z != 0 else 0.05
	)
	mesh_instance.mesh = mesh
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.no_depth_test = true
	mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	mesh_instance.material_override = mat
	mesh_instance.position = dir / 2.0
	snake_head.add_child(mesh_instance)

func log_positions(label: String):
	print("\n--- ", label, " ---")
	print("SnakeHead (Pivot) Global Pos: ", snake_head.global_position)
	if snake_model:
		print("Model Local Transform: ", snake_model.transform)

	var skeleton = _find_skeleton(snake_model)
	if skeleton:
		var min_pos = Vector3(1e9, 1e9, 1e9)
		var max_pos = Vector3(-1e9, -1e9, -1e9)
		var min_bone = ""
		var max_bone = ""

		for i in range(skeleton.get_bone_count()):
			var g_pos = skeleton.global_transform * skeleton.get_bone_global_pose(i).origin
			if g_pos.z < min_pos.z:
				min_pos = g_pos
				min_bone = skeleton.get_bone_name(i)
			if g_pos.z > max_pos.z:
				max_pos = g_pos
				max_bone = skeleton.get_bone_name(i)

		print("  --- SKELETON WORLD EXTREMES (Z-AXIS) ---")
		print("  Furthest NORTH (-Z): %s at %s" % [min_bone, min_pos])
		print("  Furthest SOUTH (+Z): %s at %s" % [max_bone, max_pos])
		print("  Z-Length: %f" % (max_pos.z - min_pos.z))

		print("  --- FRONT BONES ---")
		for i in range(10):
			var b_name = skeleton.get_bone_name(i)
			var pose = skeleton.get_bone_global_pose(i)
			var g_pos = skeleton.global_transform * pose.origin
			print("  Bone [%d]: '%s' | Global: %s" % [i, b_name, g_pos])

		var head_keywords = ["head", "tongue", "mouse", "eye", "teeth", "bone.086"]
		for i in range(skeleton.get_bone_count()):
			var b_name = skeleton.get_bone_name(i).to_lower()
			for kw in head_keywords:
				if kw in b_name:
					var pose = skeleton.get_bone_global_pose(i)
					var g_pos = skeleton.global_transform * pose.origin
					print("  Bone: '%s' | Global: %s" % [skeleton.get_bone_name(i), g_pos])
					break

	print("--------------------")

func _input(event):
	if event is InputEventKey and event.is_pressed():
		var key = event.get_keycode_with_modifiers()
		if key == KEY_UP or key == KEY_DOWN or key == KEY_LEFT or key == KEY_RIGHT:
			get_tree().create_timer(0.02).timeout.connect(func(): log_positions("After Move"))

func _find_skeleton(node):
	if node is Skeleton3D: return node
	for child in node.get_children():
		var res = _find_skeleton(child)
		if res: return res
	return null
