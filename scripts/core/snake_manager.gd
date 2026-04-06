extends Node2D

@export var segment_scene: PackedScene = preload("res://scenes/main/segment.tscn")
@onready var snake_head = $SnakeHead

var history: Array[Vector2] = []
var segments: Array[Node2D] = []
var spacing: int = 15
var score: int = 0
var is_game_over: bool = false
var hud: Node
var invulnerability_timer: float = 0.5

func _ready() -> void:
    # Spawn 3 initial segments
    for i in range(3):
        add_segment()

    # Wait for the main scene to be ready so we can find other nodes
    await get_tree().process_frame
    var fuel_cell = get_parent().get_node_or_null("FuelCell")
    if fuel_cell:
        fuel_cell.collected.connect(_on_fuel_collected)

    hud = get_node_or_null("../../HUD")
    snake_head.hit_obstacle.connect(_on_snake_hit)

    # Connect BiteArea to detect segments
    var bite_area = snake_head.get_node_or_null("BiteArea")
    if bite_area:
        bite_area.area_entered.connect(_on_bite_area_entered)

func _process(delta: float) -> void:
    if invulnerability_timer > 0:
        invulnerability_timer -= delta

func _physics_process(_delta: float) -> void:
    if is_game_over: return

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

    # Start segment at the tail of history if available, else far away
    if history.size() > 0:
        segment.global_position = history.back()
    else:
        segment.global_position = Vector2(-1000, -1000)

func _on_fuel_collected() -> void:
    score += 1
    if hud:
        hud.update_score(score)
    add_segment()

func _on_snake_hit() -> void:
    end_game()

func _on_bite_area_entered(area: Area2D) -> void:
    if is_game_over: return
    if invulnerability_timer > 0: return

    # Check if we hit a segment. Since they are children of this node, we can check that.
    if area.get_parent() == self and area != snake_head:
        end_game()

func end_game() -> void:
    if is_game_over: return
    is_game_over = true
    snake_head.die()
    if hud:
        hud.show_game_over()
