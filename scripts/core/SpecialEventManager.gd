extends Node

@export var min_interval: float = 20.0
@export var max_interval: float = 30.0
@export var event_nodes: Array[SpecialEvent] = []

@onready var timer: Timer = Timer.new()

func _ready() -> void:
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)

	for event in event_nodes:
		if event:
			event.event_finished.connect(_on_event_finished)

	_start_random_timer()

func _start_random_timer() -> void:
	var wait_time = randf_range(min_interval, max_interval)
	timer.start(wait_time)

func _on_timer_timeout() -> void:
	if event_nodes.is_empty():
		_start_random_timer()
		return

	var event = event_nodes.pick_random()
	if event:
		event.start_event()
	else:
		_start_random_timer()

func _on_event_finished() -> void:
	_start_random_timer()
