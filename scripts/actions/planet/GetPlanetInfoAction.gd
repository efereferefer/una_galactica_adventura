class_name GetPlanetInfoAction extends GameAction

func is_possible(target: Node, selected: Node) -> bool:
	return target is PlanetNode

func execute(target: Node, selected: Node = null) -> void:
	target.planet_info_requested.emit(target.state)
