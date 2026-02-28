extends Node3D

@onready var cobra_model: Node3D = $CobraModel

func _ready() -> void:
	_fit_to_size(1.0)

func _fit_to_size(target_units: float) -> void:
	var aabb = AABB()
	var first = true
	var meshes = _get_all_meshes(cobra_model)
	for m in meshes:
		var m_aabb = m.get_aabb()
		if first:
			aabb = m_aabb
			first = false
		else:
			aabb = aabb.merge(m_aabb)
	
	if aabb.size.z == 0: return
	
	var s = target_units / aabb.size.z
	cobra_model.scale = Vector3(s, s, s)
	
	# Align so the back of the segment is at origin, front is at +Z or -Z
	# To match the head, we align End.z to Node origin
	cobra_model.position.y = -aabb.position.y * s
	cobra_model.position.z = -aabb.end.z * s

func _get_all_meshes(root: Node) -> Array[MeshInstance3D]:
	var results: Array[MeshInstance3D] = []
	if root is MeshInstance3D:
		results.append(root)
	for child in root.get_children():
		results.append_array(_get_all_meshes(child))
	return results

func _find_node_by_class(root: Node, target_class: String) -> Node:
	if root.is_class(target_class):
		return root
	for child in root.get_children():
		var found = _find_node_by_class(child, target_class)
		if found:
			return found
	return null
