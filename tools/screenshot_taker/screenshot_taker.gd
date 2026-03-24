extends SceneTree

func _init():
	print("Screenshot taker started")
	var root = get_root()
	var main_scene_packed = load("res://scenes/main/main.tscn")
	if not main_scene_packed:
		print("Error: Could not load main scene")
		quit(1)
		return

	var main_scene = main_scene_packed.instantiate()
	root.add_child(main_scene)
	print("Main scene added to root")

	# Instead of awaiting, we can use a timer or just do it in the next idle frame
	process_frame.connect(_take_screenshot, CONNECT_ONE_SHOT)

func _take_screenshot():
	print("Taking screenshot...")
	var root = get_root()
	var viewport = root.get_viewport()
	var screenshot = viewport.get_texture().get_image()
	var err = screenshot.save_png("verification_screenshot.png")
	if err == OK:
		print("Screenshot saved to verification_screenshot.png")
	else:
		print("Error saving screenshot: ", err)

	quit()
