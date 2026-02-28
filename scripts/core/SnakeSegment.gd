extends Node3D

@onready var cobra_model: Node3D = $CobraModel

func _ready() -> void:
	_fit_to_size(5.0)
	
	# VISIBILITY VERIFICATION: Add a bright blue marker
	var marker = MeshInstance3D.new()
	marker.mesh = BoxMesh.new()
	marker.mesh.size = Vector3(0.8, 0.8, 0.8)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0, 0, 1, 1) # Full bright blue
	mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	marker.material_override = mat
	add_child(marker)

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
