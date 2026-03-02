extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var achievement_label = $AchievementLabel

var original_score_scale: Vector2
var score_tween: Tween
var achievement_tween: Tween
var achievement_queue: Array[String] = []
var is_showing_achievement: bool = false

func _ready() -> void:
	original_score_scale = score_label.scale
	achievement_label.modulate.a = 0
	achievement_label.scale = Vector2.ZERO

func update_score(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score
	play_score_pop()

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
