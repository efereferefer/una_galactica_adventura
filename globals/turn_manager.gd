# scripts/managers/TurnManager.gd
extends Node

signal player_turn_started
signal ai_turn_started(faction_name: String)
signal turn_started(faction_id)

func start_next_turn():
	var order = StrategyGlobals.turn_order
	var current_idx = order.find(StrategyGlobals.active_faction_id)
	var next_idx = current_idx + 1
	
	if next_idx >= order.size():
		_begin_new_round()
	else:
		_start_faction_turn(order[next_idx])

func _begin_new_round():
	StrategyGlobals.current_round += 1
	StrategyGlobals.active_faction_id = StrategyGlobals.turn_order[0]
	StrategyGlobals.round_completed.emit(StrategyGlobals.current_round)
	
	print("--- НАЧАЛО РАУНДА ", StrategyGlobals.current_round, " ---")
	_start_faction_turn(StrategyGlobals.active_faction_id)

func _start_faction_turn(faction_id: int):
	StrategyGlobals.active_faction_id = faction_id
	var faction = StrategyGlobals.get_faction(faction_id)
	EconomyGlobals.run_economies(faction_id)
	turn_started.emit(faction_id)
	# УБРАНА ЛИШНЯЯ ПРОВЕРКА НА НЕЙТРАЛОВ
	if faction.def.is_playable:
		print("Ход игрока")
		player_turn_started.emit()
	else:
		print("Ход ИИ: ", faction.faction_name)
		ai_turn_started.emit(faction.faction_name)
		_process_ai_logic(faction)

func _process_ai_logic(faction: FactionState):
	start_next_turn()
