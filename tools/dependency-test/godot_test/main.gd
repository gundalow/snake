extends Node2D

func _ready():
	print("Godot Graphical Test Started")
	await get_tree().create_timer(1.0).timeout
	print("Godot Graphical Test Finished Successfully")
	get_tree().quit()
