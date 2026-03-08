extends Node3D

var snake: Node3D
var cam_pivot: Node3D
var cam: Camera3D
var label: Label

var pos := Vector3.ZERO
var rot := Vector3.ZERO
var model_scale := 1.0
var morph_val := 0.0

func _ready():
	# 1. Setup Environment
	var sky = WorldEnvironment.new()
	sky.environment = Environment.new()
	sky.environment.background_mode = Environment.BG_COLOR
	sky.environment.background_color = Color(0.05, 0.05, 0.05)
	add_child(sky)

	var light = DirectionalLight3D.new()
	light.transform = Transform3D(Basis.from_euler(Vector3(-PI/4, PI/4, 0)), Vector3(0, 10, 0))
	add_child(light)

	# 2. Visual Truth Aids
	_create_ground()
	_create_compass()
	
	# 3. Origin Marker (Target Snout Position)
	var pivot = MeshInstance3D.new()
	pivot.mesh = SphereMesh.new()
	pivot.mesh.radius = 0.1
	pivot.mesh.height = 0.2
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.WHITE
	mat.no_depth_test = true
	pivot.material_override = mat
	add_child(pivot)

	# 4. Instantiate Snake (BACK TO TITANOBOA)
	snake = load("res://assets/models/snake_Titanoboa/scene.gltf").instantiate()
	add_child(snake)
	
	# 5. UI Setup
	_setup_ui()
	
	# 6. Camera
	cam_pivot = Node3D.new()
	add_child(cam_pivot)
	cam = Camera3D.new()
	cam.position = Vector3(0, 5, 10)
	cam_pivot.add_child(cam)
	cam.look_at(Vector3.ZERO)

func _setup_ui():
	var canvas = CanvasLayer.new()
	add_child(canvas)
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_MINSIZE, 20)
	canvas.add_child(vbox)
	
	label = Label.new()
	label.text = "CALIBRATING TITANOBOA"
	vbox.add_child(label)
	
	vbox.add_child(_create_slider("Pos X", -25, 25, func(v): pos.x = v))
	vbox.add_child(_create_slider("Pos Y", -5, 5, func(v): pos.y = v))
	vbox.add_child(_create_slider("Pos Z", -25, 25, func(v): pos.z = v))
	vbox.add_child(_create_slider("Rot X (Deg)", -180, 180, func(v): rot.x = deg_to_rad(v)))
	vbox.add_child(_create_slider("Rot Y (Deg)", -180, 180, func(v): rot.y = deg_to_rad(v)))
	vbox.add_child(_create_slider("Rot Z (Deg)", -180, 180, func(v): rot.z = deg_to_rad(v)))
	vbox.add_child(_create_slider("Scale", 0.01, 10, func(v): model_scale = v))
	vbox.add_child(_create_slider("Test Morph", 0, 1, func(v): morph_val = v))

func _create_slider(name: String, min_v: float, max_v: float, callback: Callable) -> HBoxContainer:
	var hbox = HBoxContainer.new()
	var l = Label.new()
	l.text = name
	l.custom_minimum_size.x = 100
	hbox.add_child(l)
	var s = HSlider.new()
	s.min_value = min_v
	s.max_value = max_v
	s.step = 0.01
	s.custom_minimum_size.x = 300
	s.value_changed.connect(callback)
	hbox.add_child(s)
	return hbox

func _process(_delta):
	if snake:
		snake.position = pos
		snake.rotation = rot
		snake.scale = Vector3.ONE * model_scale
		
		# Apply Morph
		_apply_morph(snake, morph_val)
		
		label.text = "FINAL TRANSFORM:\nTransform3D(Basis.from_euler(Vector3(%f, %f, %f)), Vector3(%f, %f, %f))\nScale: %f" % [
			rot.x, rot.y, rot.z, pos.x, pos.y, pos.z, model_scale
		]

func _apply_morph(node, val):
	if node is MeshInstance3D:
		if node.mesh.get_blend_shape_count() > 0:
			node.set("blend_shapes/morph_0", val)
	for child in node.get_children():
		_apply_morph(child, val)

func _unhandled_input(event):
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
		cam_pivot.rotate_y(-event.relative.x * 0.005)
		cam.rotate_x(-event.relative.y * 0.005)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: cam.position.z -= 0.5
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: cam.position.z += 0.5

func _create_ground():
	var plane = MeshInstance3D.new()
	plane.mesh = PlaneMesh.new()
	plane.mesh.size = Vector2(50, 50)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.1, 0.1, 0.1)
	plane.material_override = mat
	add_child(plane)

func _create_compass():
	_create_world_label("NORTH (-Z)", Vector3(0, 0, -10), Color.CYAN)
	_create_world_label("SOUTH (+Z)", Vector3(0, 0, 10), Color.BLUE)
	_create_world_label("EAST (+X)", Vector3(10, 0, 0), Color.RED)
	_create_world_label("WEST (-X)", Vector3(-10, 0, 0), Color.ORANGE)

func _create_world_label(text: String, l_pos: Vector3, color: Color):
	var l = Label3D.new()
	l.text = text
	l.font_size = 64
	l.modulate = color
	l.position = l_pos
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(l)
