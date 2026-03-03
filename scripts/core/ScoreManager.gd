extends Node

const HIGHSCORES_PATH = "user://highscores.json"
const MAX_SAVED_NAMES = 10
const MAX_LEADERBOARD_ENTRIES = 10

var current_player_name: String = ""
var current_score: int = 0
var high_scores: Array = [] # Array of dictionaries: {"name": String, "score": int}
var unique_names: Array = [] # To keep track of previous names for the prompt

signal high_score_beaten

func _ready():
	load_scores()

func load_scores():
	if not FileAccess.file_exists(HIGHSCORES_PATH):
		high_scores = []
		unique_names = []
		return

	var file = FileAccess.open(HIGHSCORES_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var data = json.get_data()
		if data is Dictionary:
			high_scores = data.get("high_scores", [])
			unique_names = data.get("unique_names", [])
		else:
			high_scores = []
			unique_names = []
	else:
		print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
		high_scores = []
		unique_names = []

func save_scores():
	var file = FileAccess.open(HIGHSCORES_PATH, FileAccess.WRITE)
	var data = {
		"high_scores": high_scores,
		"unique_names": unique_names
	}
	var json_string = JSON.stringify(data)
	file.store_string(json_string)
	file.close()

func set_player_name(player_name: String):
	current_player_name = player_name
	if unique_names.has(player_name):
		unique_names.erase(player_name)
	unique_names.push_front(player_name)
	if unique_names.size() > MAX_SAVED_NAMES:
		unique_names.pop_back()
	save_scores()

func submit_score(score: int):
	current_score = score
	var entry = {"name": current_player_name, "score": score}
	high_scores.append(entry)
	high_scores.sort_custom(func(a, b): return a["score"] > b["score"])

	# We keep all scores in high_scores for the json as per requirement,
	# but we might want to prune it eventually if it gets too large.
	# The requirement said "json file should have all names. The though only top 10 are displayed."

	save_scores()

func is_new_high_score(score: int) -> bool:
	if high_scores.size() < MAX_LEADERBOARD_ENTRIES:
		return score > 0
	return score > high_scores[MAX_LEADERBOARD_ENTRIES - 1]["score"]

func get_top_scores() -> Array:
	var top_10 = high_scores.slice(0, MAX_LEADERBOARD_ENTRIES)
	return top_10

func get_previous_names() -> Array:
	return unique_names
