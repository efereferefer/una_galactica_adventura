class_name InitiateBattleAction extends GameAction

func is_possible(target: Node,selected: Node) -> bool:
	if not target is StarSystemNode:
		return false
	
	var system = target.state
	if system.ships_in_system.size() < 2:
		return false
	
	var has_player = false
	var has_enemy = false
	
	for ship in system.ships_in_system:
		if ship.get_owner_id() == StrategyGlobals.PLAYER_FACTION_ID:
			has_player = true
		else:
			has_enemy = true
	
	return has_player and has_enemy

func execute(target: Node,selected: Node = null) -> void:
	if not target is StarSystemNode:
		return
	
	var system = target.state
	var allies: Array[ShipState] = []
	var enemies: Array[ShipState] = []
	
	for ship in system.ships_in_system:
		if ship.get_owner_id() == StrategyGlobals.PLAYER_FACTION_ID:
			allies.append(ship)
		else:
			enemies.append(ship)
	
	# Ищем карту (Map) в сцене — предполагаем, что у неё группа "map" или она корневая
	Transport.transport_battle_initiate.emit(allies, enemies)
