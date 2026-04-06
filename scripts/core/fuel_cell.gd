extends Area2D

signal collected

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    relocate()

func _on_body_entered(body: Node2D) -> void:
    if body.name == "SnakeHead":
        collected.emit()
        relocate()

func relocate() -> void:
    var screen_size = get_viewport_rect().size
    # Margin to avoid spawning on the very edge
    var margin = 50
    global_position = Vector2(
        randf_range(margin, screen_size.x - margin),
        randf_range(margin, screen_size.y - margin)
    )
