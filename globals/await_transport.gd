extends Node

# В Transport.gd
signal request_map_answer(target_state: StarSystemState, selected: ShipUnit)
signal move_answer(answer: bool)

var current_answer: Variant

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func ask_map_for_move_permission(target_state: StarSystemState, selected: ShipUnit) -> Variant:
	request_map_answer.emit(target_state, selected)
	var result = await move_answer
	return result

# В получателе (где-то в другой ноде или там же)
