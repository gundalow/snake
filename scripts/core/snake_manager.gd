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
    # Hide new segment until history is populated
    segment.global_position = snake_head.global_position
