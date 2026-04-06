extends Node2D

@export var segment_scene: PackedScene = preload("res://scenes/main/segment.tscn")
@onready var snake_head = $SnakeHead

var history: Array[Vector2] = []
var segments: Array[Node2D] = []
var spacing: int = 15

func _ready() -> void:
    # Spawn 3 initial segments
    for i in range(3):
        add_segment()

    # Wait for the main scene to be ready so we can find the FuelCell
    await get_tree().process_frame
    var fuel_cell = get_parent().get_node_or_null("FuelCell")
    if fuel_cell:
        fuel_cell.collected.connect(add_segment)

func _physics_process(_delta: float) -> void:
    # Record head position
    history.push_front(snake_head.global_position)

    # Cap history size
    var max_history = (segments.size() + 1) * spacing
    if history.size() > max_history:
        history.pop_back()

    # Position segments based on history
    for i in range(segments.size()):
        var history_index = (i + 1) * spacing
        if history_index < history.size():
            segments[i].global_position = history[history_index]

func add_segment() -> void:
    var segment = segment_scene.instantiate()
    add_child(segment)
    segments.append(segment)
    # Start segment at head position
    segment.global_position = snake_head.global_position
