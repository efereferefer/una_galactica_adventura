class_name ConquerPlanetAction extends GameAction

func is_possible(target: Node, selected: Node) -> bool:
	if (not target is PlanetNode) and (not target is StarSystemNode) : return false
	if not selected is ShipUnit: return false
	
	var ship = selected as ShipUnit
	if target is PlanetNode:
		var target_system = target.get_parent() as StarSystemNode
		var target_system_state = target_system.state as StarSystemState
		var target_state = target.state as PlanetState
	
	# Синхронные проверки: владелец, не та же система, есть соединение
		if ship.get_owner_id() != StrategyGlobals.PLAYER_FACTION_ID: return false
		if target_state.get_owner_id() == StrategyGlobals.PLAYER_FACTION_ID: return false
		if target_system_state != ship.current_system: return false
		if not selected.has_action_points(): return false
	
	if target is StarSystemNode:
		var target_state = target.state as StarSystemState
	
	# Синхронные проверки: владелец, не та же система, есть соединение
		if ship.get_owner_id() != StrategyGlobals.PLAYER_FACTION_ID: return false
		if target_state.get_owner_id() == StrategyGlobals.PLAYER_FACTION_ID: return false
		if target_state != ship.current_system: return false
		if not selected.has_action_points(): return false
	
	# НЕ делаем await здесь!
	# Просто возвращаем true, если базовые условия ок
	return true

func execute(target: Node, selected: Node = null) -> void:
	if target is PlanetNode:
		target.conquer(selected.data.owner.id)
	if target is StarSystemNode:
		target.conquer(selected.data.owner.id)
