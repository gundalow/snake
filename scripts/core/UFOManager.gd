extends Node

@export var ufo_scene: PackedScene = preload("res://scenes/main/UFO.tscn")
@export var spawn_interval: float = GameConstants.UFO_SPAWN_INTERVAL

var spawn_timer: float = 0.0
var can_spawn: bool = true

func _process(delta: float) -> void:
	if not can_spawn:
		spawn_timer += delta
		if spawn_timer >= spawn_interval:
			can_spawn = true
			spawn_timer = 0.0

func on_food_spawned(food: Node3D) -> void:
	if can_spawn:
		# Wait 0.5s after food appears
		await get_tree().create_timer(0.5).timeout
		if is_instance_valid(food):
			spawn_ufo(food)

func spawn_ufo(food: Node3D) -> void:
	can_spawn = false
	var ufo = ufo_scene.instantiate()
	ufo.food_stolen.connect(get_parent()._on_food_stolen)
	# Spawn far away
	var board_size = GameConstants.BOARD_SIZE
	ufo.position = Vector3(board_size * 1.5, 5.0, board_size * 1.5)
	if randf() > 0.5: ufo.position.x *= -1
	if randf() > 0.5: ufo.position.z *= -1

	get_parent().add_child(ufo)
	ufo.start_hunt(food)
