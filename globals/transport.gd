extends Node

signal transport_battle_initiate(allies, enemies)
signal move_ship_request(target_state: StarSystemState)
signal turn_completed(faction_id)
signal move_specific_ships_request(ships: Array[ShipState], target_state: StarSystemState)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
