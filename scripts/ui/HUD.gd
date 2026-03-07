extends CanvasLayer

var original_score_scale: Vector2
var score_tween: Tween
var achievement_tween: Tween
var achievement_queue: Array[String] = []
var is_showing_achievement: bool = false
var has_celebrated = false

@onready var score_label = $ScoreLabel
@onready var achievement_label = $AchievementLabel
@onready var player_name_label = $PlayerNameLabel
@onready var scores_list = $Leaderboard/ScoresList
@onready var celebrate_label = $CelebrateLabel
@onready var celebrate_sound = $CelebrateSound
@onready var confetti = $Confetti
@onready var pause_label = $PauseLabel

func _ready() -> void:
	original_score_scale = score_label.scale
	achievement_label.modulate.a = 0
	achievement_label.scale = Vector2.ZERO
	celebrate_label.visible = false
	update_leaderboard()
	ScoreManager.high_score_beaten.connect(_on_high_score_beaten)

func update_player_name(player_name: String) -> void:
	player_name_label.text = "Player: " + player_name

func update_score(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score
	play_score_pop()
	if not has_celebrated and ScoreManager.is_new_high_score(new_score):
		_on_high_score_beaten()

func play_score_pop() -> void:
	if score_tween:
		score_tween.kill()

	score_tween = create_tween()
	score_tween.set_parallel(true)

	# Neon Green color
	var neon_green = Color(0.2, 1.0, 0.2)

	score_label.pivot_offset = score_label.size / 2.0

	score_tween.tween_property(score_label, "scale", Vector2(1.3, 1.3), 0.1)
	score_tween.tween_property(score_label, "modulate", neon_green, 0.1)

	score_tween.chain().set_parallel(true)
	score_tween.tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.1)
	score_tween.tween_property(score_label, "modulate", Color.WHITE, 0.1)

func show_achievement(text: String) -> void:
	achievement_queue.append(text)
	if not is_showing_achievement:
		_show_next_achievement()

func _show_next_achievement() -> void:
	if achievement_queue.is_empty():
		is_showing_achievement = false
		return

	is_showing_achievement = true
	var text = achievement_queue.pop_front()
	achievement_label.text = text

	achievement_label.pivot_offset = achievement_label.size / 2.0
	achievement_label.modulate.a = 0
	achievement_label.scale = Vector2.ZERO

	if achievement_tween:
		achievement_tween.kill()

	achievement_tween = create_tween()

	# Pop in
	achievement_tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	achievement_tween.tween_property(achievement_label, "scale", Vector2(1.2, 1.2), 0.5)
	achievement_tween.parallel().tween_property(achievement_label, "modulate:a", 1.0, 0.2)

	# Stay a bit
	achievement_tween.tween_interval(2.0)

	# Fade out
	achievement_tween.chain().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	achievement_tween.tween_property(achievement_label, "modulate:a", 0.0, 0.5)
	achievement_tween.parallel().tween_property(achievement_label, "scale", Vector2(0.5, 0.5), 0.5)

	# Check for next
	achievement_tween.tween_callback(_show_next_achievement)

func update_leaderboard():
	for child in scores_list.get_children():
		child.queue_free()

	var top_scores = ScoreManager.get_top_scores()
	var medium_settings = LabelSettings.new()
	medium_settings.font_size = 64
	medium_settings.outline_size = 6
	medium_settings.outline_color = Color.BLACK

	for i in range(top_scores.size()):
		var entry = top_scores[i]
		var label = Label.new()
		label.text = "%d. %s: %d" % [i + 1, entry["name"], entry["score"]]
		label.label_settings = medium_settings
		scores_list.add_child(label)

func _on_high_score_beaten():
	if has_celebrated: return
	has_celebrated = true

	celebrate_label.visible = true
	confetti.emitting = true

	# Placeholder sound logic
	if celebrate_sound.stream:
		celebrate_sound.play()

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(celebrate_label, "scale", Vector2(1.2, 1.2), 0.3).from(Vector2(0.1, 0.1))
	tween.tween_interval(2.0)
	tween.tween_property(celebrate_label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(func(): celebrate_label.visible = false)

func show_pause(is_visible: bool) -> void:
	if pause_label:
		pause_label.visible = is_visible
