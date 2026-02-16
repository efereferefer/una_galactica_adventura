class_name DisbandShipAction extends GameAction

func is_possible(target: Node,selected: Node) -> bool:
	if not target is ShipUnit:
		return false
	if target.get_owner_id() != StrategyGlobals.PLAYER_FACTION_ID:
		return false
	return true

func execute(target: Node, selected: Node = null) -> void:
	print("Флот ", target.data.ship_name, " расформирован!")
	# Используем тот же сигнал, что и при смерти в бою
	target.die()
