class_name JumpAction extends GameAction

func is_possible(target: Node, selected: Node) -> bool:
	if not target is StarSystemNode: return false
	if not selected is ShipUnit: return false
	
	var ship = selected as ShipUnit
	var target_state = target.state as StarSystemState
	
	# Синхронные проверки: владелец, не та же система, есть соединение
	if ship.get_owner_id() != StrategyGlobals.PLAYER_FACTION_ID: return false
	if target_state == ship.current_system: return false
	if not selected.has_action_points(): return false
	if not selected.data.has_component("jump_drive"): return false
	
	# НЕ делаем await здесь!
	# Просто возвращаем true, если базовые условия ок
	return true

func execute(target: Node, selected: Node = null) -> void:
	if not target is StarSystemNode: return
	var target_state = target.state
	Transport.move_ship_request.emit(target_state,false,true)
