extends Node3D

# --- CONFIGURATION ---
const SNAKE_MODEL_PATH = "res://assets/cobra_animation.glb"

# --- BONE MAPPING (Based on your Audit) ---
# We'll guess Bone 25 or 27 is the head because the tongue (28) is attached near there.
var head_bone_idx: int = 25
var anim_name: String = "SANKE animations"

# --- STATE ---
var snake_scene: Node3D
var snake_skeleton: Skeleton3D
var anim_player: AnimationPlayer
var debug_label: Label

func _ready():
	setup_lighting()
	setup_ui()

	var res = load(SNAKE_MODEL_PATH)
	if not res:
		return

	snake_scene = res.instantiate()
	add_child(snake_scene)

	# Find components
	find_assets(snake_scene)

	if snake_skeleton:
		setup_rider_camera()
		# Play the animation on loop to see what it does
		if anim_player and anim_player.has_animation(anim_name):
			anim_player.play(anim_name)
			print("Playing: ", anim_name)

func find_assets(node: Node):
	if node is Skeleton3D:
		snake_skeleton = node
	if node is AnimationPlayer:
		anim_player = node
	for child in node.get_children():
		find_assets(child)

func setup_rider_camera():
	var cam = Camera3D.new()
	add_child(cam)
	cam.make_current()

func _process(_delta):
	if snake_skeleton:
		var cam = get_viewport().get_camera_3d()
		# Get the global transform of the head bone
		var head_trans = snake_skeleton.global_transform * snake_skeleton.get_bone_global_pose(head_bone_idx)

		# ADJUST THESE to fix your "Rider" view:
		# origin + (UP * height) + (BACK * distance)
		cam.global_position = head_trans.origin + head_trans.basis.y * 0.5 + head_trans.basis.z * 1.0

		# Look slightly ahead of the head
		var look_at_pos = head_trans.origin - head_trans.basis.z * 5.0
		cam.look_at(look_at_pos, head_trans.basis.y)

	debug_label.text = "FPS: %d\nBone [%d] is Head\nAnim: %s" % [Engine.get_frames_per_second(), head_bone_idx, anim_name]

func _input(event):
	# Use keys 1 and 2 to find the head bone manually if my guess was wrong
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			head_bone_idx = clampi(head_bone_idx - 1, 0, 38)
		if event.keycode == KEY_2:
			head_bone_idx = clampi(head_bone_idx + 1, 0, 38)
		if event.keycode == KEY_3:
			head_bone_idx = clampi(35, 0, 38)

func setup_lighting():
	var env = WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_SKY
	env.environment.sky = Sky.new()
	env.environment.sky.sky_material = ProceduralSkyMaterial.new()
	add_child(env)
	var sun = DirectionalLight3D.new()
	add_child(sun)
	sun.position = Vector3(5, 10, 5)
	sun.look_at(Vector3.ZERO)

func setup_ui():
	var cl = CanvasLayer.new()
	add_child(cl)
	debug_label = Label.new()
	debug_label.position = Vector2(30, 30)
	cl.add_child(debug_label)
