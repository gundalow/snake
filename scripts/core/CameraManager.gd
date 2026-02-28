extends Node

@export var rider_cam: Camera3D
@export var overhead_cam: Camera3D

func _ready() -> void:
	if overhead_cam:
		overhead_cam.make_current()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_camera"):
		toggle_camera()
	elif event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	elif event.is_action_pressed("quit"):
		get_tree().quit()

func toggle_camera() -> void:
	if rider_cam.current:
		overhead_cam.make_current()
	else:
		rider_cam.make_current()
