@tool
extends Node3D

# This script allows for "Visual Vibe Coding" by automatically snapping
# a segment to its parent's "Socket_Back" marker with a 0.05m tuck margin.

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		# This logic is mainly for the editor visual vibe,
		# but can be used for dynamic spawning too.
		return

	snap_to_parent_socket()

func snap_to_parent_socket() -> void:
	var parent = get_parent()
	if not parent: return

	# Look for "Socket_Back" marker in parent
	var socket_back = parent.get_node_or_null("Socket_Back")
	if not socket_back or not (socket_back is Marker3D):
		return

	# Set global_transform to parent's socket transform
	global_transform = socket_back.global_transform

	# Apply 0.05m "tuck" margin (move forward along local Z by 0.05)
	# This ensures the mesh tucks into the previous segment.
	translate_object_local(Vector3(0, 0, -0.05))
