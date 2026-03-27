@tool
extends SceneTree

func _init():
	print("\n--- FINAL LOG ANALYSIS ---")
	
	# DATA FROM USER LOG
	var pivot_z = -8.847803
	var head_tip_z = -7.05227
	var tail_end_z = -28.2188
	
	print("Movement: NORTH (-Z)")
	print("Pivot Z: ", pivot_z)
	print("Head Tip Z: ", head_tip_z)
	print("Tail End Z: ", tail_end_z)
	
	if head_tip_z > pivot_z:
		print("VERDICT: Head is SOUTH of pivot. Snake is facing BACKWARDS.")
	
	# CURRENT TRANSFORM
	# Basis(X:(0,0,1), Y:(0,3,0), Z:(-3,0,0))
	# Translation: (0, -0.05, 0.46)
	
	print("\nApplying 180-degree flip to Basis and Offset...")
	
	# To rotate 180 around Y:
	# NewBasisX = -OldBasisX
	# NewBasisZ = -OldBasisZ
	# NewOffsetX = -OldOffsetX
	# NewOffsetZ = -OldOffsetZ
	
	print("\n--- SUGGESTED NEW TRANSFORM ---")
	print("Basis X: (0, 0, -1)")
	print("Basis Y: (0, 3, 0)")
	print("Basis Z: (3, 0, 0)")
	print("Origin:  (0, -0.05, -0.46)")
	
	print("\nTransform3D(0, 0, -1, 0, 3, 0, 3, 0, 0, 0, -0.05, -0.46)")
	
	quit()
