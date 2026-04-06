extends CanvasLayer

@onready var fuel_label = $Control/FuelLabel
@onready var game_over_box = $Control/GameOverBox
@onready var reboot_button = $Control/GameOverBox/VBoxContainer/RebootButton

func _ready() -> void:
    game_over_box.visible = false
    reboot_button.pressed.connect(_on_reboot_pressed)

func update_score(score: int) -> void:
    fuel_label.text = "FUEL: " + str(score)

func show_game_over() -> void:
    game_over_box.visible = true

func _on_reboot_pressed() -> void:
    get_tree().reload_current_scene()
