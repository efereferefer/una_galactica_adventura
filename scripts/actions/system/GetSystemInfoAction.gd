class_name GetSystemInfoAction extends GameAction

func is_possible(target: Node, selected: Node) -> bool:
	return target is StarSystemNode

func execute(target: Node, selected: Node = null) -> void:
	target.system_info_requested.emit(target.state)
