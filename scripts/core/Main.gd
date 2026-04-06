extends Node2D

@onready var snake_chain = $YSortContainer/SnakeChain
@onready var hud = $HUD

func _ready() -> void:
    # Logic for 2.5D snake is managed by SnakeChain/SnakeManager
    pass
