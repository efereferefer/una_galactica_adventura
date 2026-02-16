class_name AddComponentAction extends GameAction

@export var component_id: String = ""

func is_possible(target: Node,selected: Node) -> bool:

	if not target is ShipUnit:
		return false
	if target.get_owner_id() != StrategyGlobals.PLAYER_FACTION_ID:
		return false
	if target.data.has_component(component_id): return false
	if component_id == "jump_drive" and !GameEvents.get_flag("jump_drive"): return false

	return true

func execute(target: Node,selected: Node = null) -> void:
	var component_def = StrategyGlobals.get_component(component_id)
	target.data.get_new_component(component_def)
	
