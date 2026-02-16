# globals/GameEvents.gd
extends Node

signal trigger_event(event_id: String, source)

var flags: Dictionary
var events: Dictionary

func _init():
	load_events()
	
func get_flag(flag_id: String) -> bool:
	if flag_id in flags.keys():
		return flags[flag_id]
	flags[flag_id] = false
	return false

func set_flag(flag_id: String) -> void:
	flags[flag_id] = true

func load_events():
	var event_load = Loader.load_stuff_by_id_from_single_directory("res://data_files/events/")
	for key in event_load: 
		events[key] = EventState.new(event_load[key])
		trigger_event.connect(events[key].trigger)
		events[key].event_fire.connect(_on_event_fired)

func _on_event_fired(event_state: EventState):
	# Ищем окно эвента в сцене и передаем ему данные
	var window = get_tree().get_first_node_in_group("event_window")
	if window:
		window.setup(event_state)
