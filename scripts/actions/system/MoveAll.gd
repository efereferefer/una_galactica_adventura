class_name MoveAllAction extends GameAction

func is_possible(target: Node, selected: Node) -> bool:
	# 1. Мы должны кликнуть по СИСТЕМЕ (target)
	if not target is StarSystemNode: return false
	# 2. У нас должна быть выбрана СИСТЕМА (selected)
	if not selected is StarSystemNode: return false
	
	var selected_sys_node = selected as StarSystemNode
	var target_sys_node = target as StarSystemNode
	
	var selected_state = selected_sys_node.state
	var target_state = target_sys_node.state
	
	# Нельзя двигаться в ту же самую систему
	if selected_state == target_state: return false
	
	if not target_state in selected_state.connections: return false
	
	var has_ready_ships = false
	for ship in selected_state.ships_in_system:
		if ship.get_owner_id() == StrategyGlobals.PLAYER_FACTION_ID and ship.has_action_points():
			has_ready_ships = true
			break
			
	if not has_ready_ships: return false
	
	return true

func execute(target: Node, selected: Node = null) -> void:
	if not target is StarSystemNode or not selected is StarSystemNode: return
	
	var selected_state = (selected as StarSystemNode).state
	var target_state = (target as StarSystemNode).state
	
	var ships_to_move: Array[ShipState] = []
	
	for ship in selected_state.ships_in_system:
		if ship.get_owner_id() == StrategyGlobals.PLAYER_FACTION_ID and ship.has_action_points():
			ships_to_move.append(ship)

	
	Transport.move_specific_ships_request.emit(ships_to_move, target_state)
