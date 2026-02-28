extends Node3D

@onready var cobra_model: Node3D = $CobraModel

func _ready() -> void:
	_fit_to_size(1.0)
	
	# DEBUG CUBE: Visualize actual segment position
	var debug_mesh = MeshInstance3D.new()
	debug_mesh.mesh = BoxMesh.new()
	debug_mesh.mesh.size = Vector3(0.4, 0.4, 0.4)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0, 0, 1, 0.5) # Semi-transparent blue
	debug_mesh.material_override = mat
	add_child(debug_mesh)
	
	# Find and play animation if it exists
	var anim_player = _find_node_by_class(cobra_model, "AnimationPlayer")
	if anim_player:
		anim_player.play("SANKE animations")

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
	
	# Match head's offset: local Y=0 is bottom of mesh
	cobra_model.position.y = -aabb.position.y * s
	# Center on Z
	cobra_model.position.z = -aabb.get_center().z * s

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
