extends Area3D

signal fully_eaten

enum Type { NORMAL, MEGA }

const MEGA_AUDIO = {
	"mega_melon": {
		"chew": preload("res://assets/sounds/foods/mega_melon/chew.mp3"),
		"burp": preload("res://assets/sounds/foods/mega_melon/burp.mp3")
	}
}

var food_type: Type = Type.NORMAL
var food_name: String = ""
var bites_remaining: int = 1
var model: Node3D
var audio_chew: AudioStreamPlayer3D
var audio_burp: AudioStreamPlayer3D

@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func setup(type: Type, name: String) -> void:
	food_type = type
	food_name = name
	if food_type == Type.MEGA:
		bites_remaining = GameConstants.MEGA_FOOD_BITES_TO_FINISH

func _ready() -> void:
	var model_scene: PackedScene
	if food_type == Type.MEGA:
		model_scene = GameConstants.MEGA_FOOD_MODELS[food_name]
		_setup_audio()
	else:
		if food_name == "":
			var keys = GameConstants.FOOD_MODELS.keys()
			food_name = keys[randi() % keys.size()]
		model_scene = GameConstants.FOOD_MODELS[food_name]

	model = model_scene.instantiate()
	add_child(model)

	_reset_all_node_positions(model)
	_update_visuals()

	if collision_shape.shape is BoxShape3D:
		collision_shape.shape.size = Vector3.ONE

	var light = OmniLight3D.new()
	light.light_color = Color(1.0, 1.0, 0.5)
	if food_type == Type.MEGA:
		light.light_color = Color(1.0, 0.5, 0.0)
	light.omni_range = 10.0
	light.light_energy = 3.0
	add_child(light)
	light.position = Vector3(0, 0.5, 0)

	model.rotation_degrees = Vector3(0, randf_range(0, 360), 0)

func _setup_audio() -> void:
	if MEGA_AUDIO.has(food_name):
		audio_chew = AudioStreamPlayer3D.new()
		audio_chew.stream = MEGA_AUDIO[food_name]["chew"]
		add_child(audio_chew)

		audio_burp = AudioStreamPlayer3D.new()
		audio_burp.stream = MEGA_AUDIO[food_name]["burp"]
		add_child(audio_burp)

func _update_visuals() -> void:
	if food_type == Type.MEGA:
		var s = 1.0
		match bites_remaining:
			3: s = 6.0
			2: s = 4.0
			1: s = 2.0
		model.scale = Vector3.ONE * s
	else:
		model.scale = Vector3.ONE * GameConstants.FOOD_VISUAL_SCALE

func take_bite() -> bool:
	bites_remaining -= 1

	if food_type == Type.MEGA:
		if audio_chew:
			audio_chew.play()
		_update_visuals()

	if bites_remaining <= 0:
		if food_type == Type.MEGA:
			_handle_mega_finish()
		else:
			fully_eaten.emit.call_deferred()
			queue_free()
		return true # Fully eaten
	return false # Still has bites left

func _handle_mega_finish() -> void:
	model.visible = false
	collision_shape.set_deferred("disabled", true)

	for child in get_children():
		if child is OmniLight3D:
			child.visible = false

	if audio_burp:
		var timer = get_tree().create_timer(0.5)
		timer.timeout.connect(func():
			audio_burp.play()
			audio_burp.finished.connect(func():
				fully_eaten.emit.call_deferred()
				queue_free()
			)
		)
	else:
		fully_eaten.emit.call_deferred()
		queue_free()

func _reset_all_node_positions(node: Node) -> void:
	if node is Node3D:
		node.position = Vector3.ZERO
	for child in node.get_children():
		_reset_all_node_positions(child)
