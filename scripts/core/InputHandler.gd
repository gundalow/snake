extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().paused = false
		get_tree().reload_current_scene()
	elif event.is_action_pressed("quit"):
		get_tree().quit()
	elif event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
		var hud = get_parent().get_node_or_null("HUD")
		if hud:
			hud.show_pause(get_tree().paused)
