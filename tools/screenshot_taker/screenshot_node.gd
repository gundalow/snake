extends Node3D

func _ready():
	print("Screenshot taker node ready")
	# Wait for a few frames
	await get_tree().create_timer(1.0).timeout

	print("Taking screenshot...")
	var viewport = get_viewport()
	var screenshot = viewport.get_texture().get_image()
	var err = screenshot.save_png("verification_screenshot.png")
	if err == OK:
		print("Screenshot saved to verification_screenshot.png")
	else:
		print("Error saving screenshot: ", err)

	get_tree().quit()
