extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var player_name_label = $PlayerNameLabel
@onready var scores_list = $Leaderboard/ScoresList
@onready var celebrate_label = $CelebrateLabel
@onready var celebrate_sound = $CelebrateSound
@onready var confetti = $Confetti

var has_celebrated = false

func _ready():
	update_leaderboard()
	celebrate_label.visible = false
	ScoreManager.high_score_beaten.connect(_on_high_score_beaten)

func update_player_name(player_name: String):
	player_name_label.text = "Player: " + player_name

func update_score(new_score: int):
	score_label.text = "Score: %d" % new_score
	if not has_celebrated and ScoreManager.is_new_high_score(new_score):
		_on_high_score_beaten()

func update_leaderboard():
	for child in scores_list.get_children():
		child.queue_free()

	var top_scores = ScoreManager.get_top_scores()
	for i in range(top_scores.size()):
		var entry = top_scores[i]
		var label = Label.new()
		label.text = "%d. %s: %d" % [i + 1, entry["name"], entry["score"]]
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
