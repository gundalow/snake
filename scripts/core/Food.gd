extends Area3D

const MODELS = {
	"apple": preload("res://assets/models/food/apple/food_apple_01_4k.gltf"),
	"lychee": preload("res://assets/models/food/lychee/food_lychee_01_4k.gltf"),
	"sweet_potato": preload("res://assets/models/food/sweet_potato/sweet_potato_4k.gltf")
}

@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var food_type: String = ""
var bob_tween: Tween

func _ready() -> void:
	var keys = MODELS.keys()
	var random_key = keys[randi() % keys.size()]
	food_type = random_key
	var model_scene = MODELS[random_key]

	var model = model_scene.instantiate()
	add_child(model)

	_reset_all_node_positions(model)
	model.scale = Vector3.ONE * GameConstants.FOOD_VISUAL_SCALE

	if collision_shape.shape is BoxShape3D:
		collision_shape.shape.size = Vector3.ONE

	var light = OmniLight3D.new()
	light.light_color = Color(1.0, 1.0, 0.5)
	light.omni_range = 10.0
	light.light_energy = 3.0
	add_child(light)
	light.position = Vector3(0, 0.5, 0)

	model.rotation_degrees = Vector3(0, randf_range(0, 360), 0)

	start_bobbing()

func start_bobbing() -> void:
	if bob_tween:
		bob_tween.kill()
	bob_tween = create_tween().set_loops()
	bob_tween.tween_property(self, "position:y", 0.7, 1.0).set_trans(Tween.TRANS_SINE)
	bob_tween.tween_property(self, "position:y", 0.5, 1.0).set_trans(Tween.TRANS_SINE)

func jump_to(new_pos: Vector3) -> void:
	if bob_tween:
		bob_tween.kill()

	var tween = create_tween().set_parallel(false)

	# Jump Up and Move
	var mid_pos = (global_position + new_pos) / 2.0
	mid_pos.y = 5.0 # Jump height

	tween.tween_property(self, "global_position", mid_pos, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", new_pos, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# Add a little scale pop
	var original_scale = scale
	tween.parallel().tween_property(self, "scale", original_scale * 1.5, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", original_scale, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	tween.finished.connect(start_bobbing)

func _reset_all_node_positions(node: Node) -> void:
	if node is Node3D:
		node.position = Vector3.ZERO
	for child in node.get_children():
		_reset_all_node_positions(child)
