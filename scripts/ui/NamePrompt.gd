extends Control

signal name_selected(player_name)

var previous_names: Array = []
var selected_index: int = -1

@onready var name_list = $Panel/VBoxContainer/NameList
@onready var new_name_input = $Panel/VBoxContainer/NewNameInput

func _ready():
	previous_names = ScoreManager.get_previous_names()
	refresh_list()
	new_name_input.grab_focus()

func refresh_list():
	for child in name_list.get_children():
		child.queue_free()

	var medium_settings = LabelSettings.new()
	medium_settings.font_size = 64
	medium_settings.outline_size = 4
	medium_settings.outline_color = Color.BLACK

	for i in range(previous_names.size()):
		var label = Label.new()
		label.text = previous_names[i]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.label_settings = medium_settings
		name_list.add_child(label)

	update_selection()

func update_selection():
	for i in range(name_list.get_child_count()):
		var label = name_list.get_child(i)
		if i == selected_index:
			label.add_theme_color_override("font_color", Color.YELLOW)
			label.text = "> " + previous_names[i] + " <"
		else:
			label.remove_theme_color_override("font_color")
			label.text = previous_names[i]

	if selected_index == -1:
		new_name_input.modulate = Color.WHITE
		new_name_input.grab_focus()
	else:
		new_name_input.modulate = Color(0.5, 0.5, 0.5)
		new_name_input.release_focus()

func _input(event):
	if not visible: return

	if event.is_action_pressed("move_up"):
		selected_index -= 1
		if selected_index < -1:
			selected_index = previous_names.size() - 1
		update_selection()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("move_down"):
		selected_index += 1
		if selected_index >= previous_names.size():
			selected_index = -1
		update_selection()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_accept"):
		var chosen_name = ""
		if selected_index == -1:
			chosen_name = new_name_input.text.strip_edges()
		else:
			chosen_name = previous_names[selected_index]

		if chosen_name != "":
			ScoreManager.set_player_name(chosen_name)
			name_selected.emit(chosen_name)
			hide()
			get_viewport().set_input_as_handled()
