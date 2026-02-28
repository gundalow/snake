extends Area3D

# Realistic food models from assets/models/food/
const MODELS = {
	"apple": preload("res://assets/models/food/apple/food_apple_01_4k.gltf"),
	"lychee": preload("res://assets/models/food/lychee/food_lychee_01_4k.gltf"),
	"sweet_potato": preload("res://assets/models/food/sweet_potato/sweet_potato_4k.gltf")
}

@export var visual_scale: float = 10.0
@export var collision_size: Vector3 = Vector3.ONE

@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	# Randomly pick one of the realistic food items
	var keys = MODELS.keys()
	var random_key = keys[randi() % keys.size()]
	var model_scene = MODELS[random_key]
	
	# Instantiate the model
	var model = model_scene.instantiate()
	add_child(model)
	
	# Recursively reset all local positions in the imported scene to (0,0,0)
	_reset_all_node_positions(model)

	# Apply exported scales
	model.scale = Vector3.ONE * visual_scale
	
	if collision_shape.shape is BoxShape3D:
		collision_shape.shape.size = collision_size
	
	# Add a glowing light
	var light = OmniLight3D.new()
	light.light_color = Color(1.0, 1.0, 0.5)
	light.omni_range = 10.0
	light.light_energy = 3.0
	add_child(light)
	light.position = Vector3(0, 0.5, 0)
	
	# Apply a simple rotation
	model.rotation_degrees = Vector3(0, randf_range(0, 360), 0)

# Recursively reset child positions to identity for imported scenes
func _reset_all_node_positions(node: Node) -> void:
	if node is Node3D:
		node.position = Vector3.ZERO
	for child in node.get_children():
		_reset_all_node_positions(child)
