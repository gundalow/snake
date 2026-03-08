extends Node3D

var snake: Node3D
var cam_pivot: Node3D
var cam: Camera3D

var pos := Vector3(1.30139, -0.05, -3.10679) # Current game position
var verified_basis := Basis(Vector3(0,0,1), Vector3(0,1,0), Vector3(-1,0,0))

func _ready():
	# 1. Setup Environment
	var sky = WorldEnvironment.new()
	sky.environment = Environment.new()
	sky.environment.background_mode = Environment.BG_COLOR
	sky.environment.background_color = Color(0.05, 0.05, 0.05)
	add_child(sky)

	var light = DirectionalLight3D.new()
	light.transform = Transform3D(Basis.from_euler(Vector3(-PI/3, PI/4, 0)), Vector3(0, 10, 0))
	light.shadow_enabled = true
	add_child(light)
	
	var fill_light = DirectionalLight3D.new()
	fill_light.transform = Transform3D(Basis.from_euler(Vector3(PI/3, -PI/4, 0)), Vector3(0, 10, 0))
	fill_light.light_energy = 0.5
	add_child(fill_light)

	# 2. Origin Marker
	var pivot_sphere = MeshInstance3D.new()
	pivot_sphere.mesh = SphereMesh.new()
	pivot_sphere.mesh.radius = 0.1
	pivot_sphere.mesh.height = 0.2
	var pivot_mat = StandardMaterial3D.new()
	pivot_mat.albedo_color = Color.WHITE
	pivot_mat.no_depth_test = true
	pivot_sphere.material_override = pivot_mat
	add_child(pivot_sphere)

	# 3. Ground
	var ground = MeshInstance3D.new()
	ground.mesh = PlaneMesh.new()
	ground.mesh.size = Vector2(50, 50)
	var ground_mat = StandardMaterial3D.new()
	ground_mat.albedo_color = Color(0.1, 0.1, 0.1)
	ground.material_override = ground_mat
	add_child(ground)

	# 4. Measurement Dots
	for i in range(-15, 16):
		for j in range(-15, 16):
			if i == 0 and j == 0: continue
			var dot = MeshInstance3D.new()
			dot.mesh = SphereMesh.new()
			dot.mesh.radius = 0.02
			dot.mesh.height = 0.04
			var dot_mat = StandardMaterial3D.new()
			dot_mat.albedo_color = Color.GRAY if (abs(i) % 5 != 0 and abs(j) % 5 != 0) else Color.WHITE
			dot.material_override = dot_mat
			dot.position = Vector3(i, 0.01, j)
			add_child(dot)

	# 5. Instantiate Snake
	var model_path = "res://assets/models/snake_vasian-digital3d/scene.gltf"
	snake = load(model_path).instantiate()
	add_child(snake)
	snake.transform = Transform3D(verified_basis, pos)
	
	var skeleton = _find_skeleton(snake)
	if skeleton:
		for i in range(skeleton.get_bone_count()):
			skeleton.set_bone_pose_position(i, skeleton.get_bone_rest(i).origin)
			skeleton.set_bone_pose_rotation(i, Quaternion.IDENTITY)
			skeleton.set_bone_pose_scale(i, Vector3.ONE)
			
			var g_pos = skeleton.global_transform * skeleton.get_bone_global_pose(i).origin
			_create_label(skeleton.get_bone_name(i), g_pos, Color.CYAN)

	_label_meshes(snake)

	# 6. Setup Camera
	cam_pivot = Node3D.new()
	add_child(cam_pivot)
	cam = Camera3D.new()
	cam.position = Vector3(0, 5, 10)
	cam_pivot.add_child(cam)
	cam.look_at(Vector3.ZERO)
	cam.current = true

var labels_visible := true
var all_labels: Array[Label3D] = []

func _unhandled_input(event):
	# Toggle Labels
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_L:
		labels_visible = !labels_visible
		for l in all_labels:
			l.visible = labels_visible
		print("Labels: ", "Visible" if labels_visible else "Hidden")

	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
		cam_pivot.rotate_y(-event.relative.x * 0.005)
		cam.rotate_x(-event.relative.y * 0.005)
		cam.rotation.x = clamp(cam.rotation.x, -PI/2.1, PI/2.1)
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			cam.position.z = max(0.1, cam.position.z - 0.2)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			cam.position.z += 0.2

func _create_label(text: String, l_pos: Vector3, color: Color):
	var l = Label3D.new()
	l.text = text
	l.font_size = 24
	l.modulate = color
	l.modulate.a = 0.5 # 50% transparent
	l.position = l_pos
	l.no_depth_test = true
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(l)
	all_labels.append(l)

func _label_meshes(node):
	if node is MeshInstance3D:
		_create_label(node.name + " (Mesh)", node.global_transform.origin, Color.YELLOW)
	for child in node.get_children():
		_label_meshes(child)

func _find_skeleton(node):
	if node is Skeleton3D: return node
	for child in node.get_children():
		var res = _find_skeleton(child)
		if res: return res
	return null
