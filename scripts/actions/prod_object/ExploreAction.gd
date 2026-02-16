class_name ExploreAction extends GameAction

func is_possible(target: Node, selected: Node) -> bool:
	if not (target is StarSystemNode or target is PlanetNode): return false
	if not selected is ShipUnit: return false
	
	var ship = selected as ShipUnit
	var target_state = target.state
	
	# Синхронные проверки: владелец, не та же система, есть соединение
	if ship.get_owner_id() != StrategyGlobals.PLAYER_FACTION_ID: return false
	if target_state.get_owner_id() == StrategyGlobals.PLAYER_FACTION_ID: return false
	if target is StarSystemNode:
		if target_state != ship.current_system: return false
	elif target is PlanetNode:
		if target.get_parent().state != ship.current_system: return false
	if target.state.is_explored: return false
	if not selected.has_action_points(): return false
	
	return true

func execute(target: Node, selected: Node = null) -> void:
	if not (target is StarSystemNode or target is PlanetNode): return
	var target_state = target.state
	target_state.is_explored = true
