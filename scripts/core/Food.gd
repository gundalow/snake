extends Area3D

const MODELS = {
	"apple": preload("res://assets/models/food/apple/food_apple_01_4k.gltf"),
	"lychee": preload("res://assets/models/food/lychee/food_lychee_01_4k.gltf"),
	"sweet_potato": preload("res://assets/models/food/sweet_potato/sweet_potato_4k.gltf")
}

@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	var keys = MODELS.keys()
	var random_key = keys[randi() % keys.size()]
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

func _reset_all_node_positions(node: Node) -> void:
	if node is Node3D:
		node.position = Vector3.ZERO
	for child in node.get_children():
		_reset_all_node_positions(child)
