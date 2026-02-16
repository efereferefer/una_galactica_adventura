class_name BuildShipyardAction extends GameAction

func is_possible(target: Node,selected: Node) -> bool:
	return false
	# 1. Это должна быть система
	if not target is StarSystemNode:
		return false
		
	# 2. Система должна принадлежать игроку (0)
	if target.state.get_owner_id() != 0:
		return false
		
	# 3. (Пример) В системе не должно быть верфи
	# if target.state.has_shipyard: return false
	
	return true

func execute(target: Node,selected: Node = null) -> void:
	pass
	#print("Начинается строительство верфи в системе ", target.state.name)
	# target.state.has_shipyard = true
