class_name GetShipInfoAction extends GameAction

func is_possible(target: Node,selected: Node) -> bool:

	if not target is ShipUnit:
		return false
	return true

func execute(target: Node,selected: Node = null) -> void:
	target.ship_info_requested.emit(target.data)
	
