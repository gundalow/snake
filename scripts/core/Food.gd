extends Area2D

signal fully_eaten

enum Type { NORMAL, MEGA }

const BURP_SOUNDS = [
	preload("res://assets/sounds/foods/mega_burps/burp1_alex_jauk-funny-burp-sound-effect-440267.ogg"),
	preload("res://assets/sounds/foods/mega_burps/burp2.ogg"),
	preload("res://assets/sounds/foods/mega_burps/burp3_freesound_community-big-burp-36175.ogg")
]

const WHOOSH_SOUND = preload("res://assets/audio/whoosh.wav")

var food_type: Type = Type.NORMAL
var food_name: String = ""
var bites_remaining: int = 1
var bob_tween: Tween

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: Polygon2D = $Polygon2D

func setup(type: Type, name: String) -> void:
	food_type = type
	food_name = name
	if food_type == Type.MEGA:
		bites_remaining = GameConstants.MEGA_FOOD_BITES_TO_FINISH
		if visual:
			visual.color = Color(1.0, 0.5, 0.0) # Mega food color
			visual.scale = Vector2.ONE * GameConstants.MEGA_FOOD_INITIAL_SCALE
	else:
		if visual:
			visual.color = Color(1.0, 1.0, 0.5) # Normal food color

func _ready() -> void:
	# Spawn Sound
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = WHOOSH_SOUND
	audio_player.bus = &"SFX"
	add_child(audio_player)
	audio_player.play()

	# Growth Animation
	var tween = create_tween()
	var target_scale = Vector2.ONE * GameConstants.FOOD_VISUAL_SCALE
	if food_type == Type.MEGA:
		target_scale = Vector2.ONE * GameConstants.MEGA_FOOD_INITIAL_SCALE

	scale = Vector2.ZERO
	tween.tween_property(self, "scale", target_scale, 0.75)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)

	tween.finished.connect(start_bobbing)

func start_bobbing() -> void:
	if bob_tween:
		bob_tween.kill()
	bob_tween = create_tween().set_loops()
	# Simulate 3D bobbing by slightly changing scale and position
	bob_tween.tween_property(visual, "position:y", -5.0, 1.0).set_trans(Tween.TRANS_SINE)
	bob_tween.tween_property(visual, "position:y", 0.0, 1.0).set_trans(Tween.TRANS_SINE)

func jump_to(new_pos: Vector2) -> void:
	if bob_tween:
		bob_tween.kill()

	var tween = create_tween().set_parallel(false)

	# Jump and Move
	var mid_pos = (global_position + new_pos) / 2.0
	mid_pos.y -= 50.0 # Jump height in 2D pixels

	tween.tween_property(self, "global_position", mid_pos, 0.25)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", new_pos, 0.25)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)

	tween.finished.connect(start_bobbing)

func take_bite() -> bool:
	bites_remaining -= 1

	if food_type == Type.MEGA:
		_update_visuals()

	if bites_remaining <= 0:
		_handle_finish()
		return true # Fully eaten
	return false # Still has bites left

func _update_visuals() -> void:
	if food_type == Type.MEGA:
		var s = 1.0
		match bites_remaining:
			3: s = GameConstants.MEGA_FOOD_INITIAL_SCALE
			2: s = GameConstants.MEGA_FOOD_MID_SCALE
			1: s = GameConstants.MEGA_FOOD_MIN_SCALE
		visual.scale = Vector2.ONE * s

func _handle_finish() -> void:
	visual.visible = false
	collision_shape.set_deferred("disabled", true)

	# Burp Logic
	var audio_burp = AudioStreamPlayer2D.new()
	audio_burp.stream = BURP_SOUNDS[randi() % BURP_SOUNDS.size()]
	audio_burp.bus = &"SFX"
	add_child(audio_burp)
	
	var timer = get_tree().create_timer(0.5)
	timer.timeout.connect(func():
		audio_burp.play()
		audio_burp.finished.connect(func():
			fully_eaten.emit.call_deferred()
			queue_free()
		)
	)
