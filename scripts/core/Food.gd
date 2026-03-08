extends Area3D

signal fully_eaten

enum Type { NORMAL, MEGA }

const MEGA_AUDIO = {
	"mega_melon": {
		"chew": preload("res://assets/sounds/foods/mega_melon/chew.ogg")
	}
}

const BURP_SOUNDS = [
	preload("res://assets/sounds/foods/mega_burps/burp1_alex_jauk-funny-burp-sound-effect-440267.ogg"),
	preload("res://assets/sounds/foods/mega_burps/burp2.ogg"),
	preload("res://assets/sounds/foods/mega_burps/burp3_freesound_community-big-burp-36175.ogg")
]

const WHOOSH_SOUND = preload("res://assets/audio/whoosh.wav")

var food_type: Type = Type.NORMAL
var food_name: String = ""
var bites_remaining: int = 1
var model: Node3D
var audio_chew: AudioStreamPlayer3D
var audio_burp: AudioStreamPlayer3D
var bob_tween: Tween

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

	# Start at scale zero for growth animation
	model.scale = Vector3.ZERO

	if collision_shape.shape is BoxShape3D:
		collision_shape.shape.size = Vector3.ONE

	var light = OmniLight3D.new()
	light.light_color = Color(1.0, 1.0, 0.5)
	if food_type == Type.MEGA:
		light.light_color = Color(1.0, 0.5, 0.0)

	light.omni_range = 0.0 # Start at 0
	light.light_energy = 0.0 # Start at 0
	add_child(light)
	light.position = Vector3(0, 0.5, 0)

	model.rotation_degrees = Vector3(0, randf_range(0, 360), 0)

	# Spawn Sound
	var audio_player = AudioStreamPlayer3D.new()
	audio_player.stream = WHOOSH_SOUND
	audio_player.bus = &"SFX"
	add_child(audio_player)
	audio_player.play()

	# Growth Animation
	var tween = create_tween().set_parallel(true)
	var multiplier = GameConstants.FOOD_MODEL_SCALES.get(food_name, 1.0)
	var target_scale = Vector3.ONE * GameConstants.FOOD_VISUAL_SCALE * multiplier
	if food_type == Type.MEGA:
		target_scale = Vector3.ONE * GameConstants.MEGA_FOOD_INITIAL_SCALE

	var duration = 0.75

	tween.tween_property(model, "scale", target_scale, duration)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_property(light, "omni_range", 10.0, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_property(light, "light_energy", 3.0, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.finished.connect(start_bobbing)

func _setup_audio() -> void:
	if food_type == Type.MEGA:
		# Shared random burp for all mega foods
		audio_burp = AudioStreamPlayer3D.new()
		audio_burp.stream = BURP_SOUNDS[randi() % BURP_SOUNDS.size()]
		audio_burp.bus = &"SFX"
		add_child(audio_burp)

		# Specific chew if available
		if MEGA_AUDIO.has(food_name) and MEGA_AUDIO[food_name].has("chew"):
			audio_chew = AudioStreamPlayer3D.new()
			audio_chew.stream = MEGA_AUDIO[food_name]["chew"]
			audio_chew.bus = &"SFX"
			add_child(audio_chew)

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

	tween.tween_property(self, "global_position", mid_pos, 0.25)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", new_pos, 0.25)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)

	# Add a little scale pop
	var original_scale = scale
	tween.parallel().tween_property(self, "scale", original_scale * 1.5, 0.25)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", original_scale, 0.25)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)

	tween.finished.connect(start_bobbing)

func _update_visuals() -> void:
	if food_type == Type.MEGA:
		var s = 1.0
		match bites_remaining:
			3: s = GameConstants.MEGA_FOOD_INITIAL_SCALE
			2: s = GameConstants.MEGA_FOOD_MID_SCALE
			1: s = GameConstants.MEGA_FOOD_MIN_SCALE
		model.scale = Vector3.ONE * s
	else:
		var multiplier = GameConstants.FOOD_MODEL_SCALES.get(food_name, 1.0)
		model.scale = Vector3.ONE * GameConstants.FOOD_VISUAL_SCALE * multiplier

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
