@tool
extends SceneTree

func _init():
	# 1. The Goal: Snout at (0,0,0), Body South (+Z), Facing North (-Z)
	# 2. Start with Titanoboa Identity
	# From previous deep_inspect: Snout is at Local X = -0.46
	# Total visual length is ~7.36.
	
	# We want a transform T such that T * Snout_Local = (0, 0, 0)
	# and T * Tail_Local = (0, 0, 7.36)
	
	var snout_local = Vector3(-0.46, 0, 0)
	var tail_local = Vector3(6.9, 0, 0)
	
	# Rotation: Map Local -X to World -Z
	# Basis X maps (1,0,0) to (0,0,1)  -> scale 3
	# Basis Y maps (0,1,0) to (0,1,0)  -> scale 3
	# Basis Z maps (0,0,1) to (-1,0,0) -> scale 1
	var b = Basis()
	b.x = Vector3(0, 0, 3)
	b.y = Vector3(0, 3, 0)
	b.z = Vector3(-1, 0, 0)
	
	# Translation:
	# Rotated Snout = b * snout_local = (0, 0, 3) * -0.46 = (0, 0, -1.38)
	# To get this to (0,0,0), we need offset = (0, 0, 1.38)
	var offset = Vector3(0, -0.05, 1.38)
	
	var t = Transform3D(b, offset)
	
	print("\n=== TITANOBOA FINAL TSCN FLOATS ===\n")
	print("Copy these 12 numbers into Transform3D(...) in SnakeHead.tscn:\n")
	print("%f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f" % [
		t.basis.x.x, t.basis.x.y, t.basis.x.z,
		t.basis.y.x, t.basis.y.y, t.basis.y.z,
		t.basis.z.x, t.basis.z.y, t.basis.z.z,
		t.origin.x, t.origin.y, t.origin.z
	])
	print("\n==================================\n")
	quit()
