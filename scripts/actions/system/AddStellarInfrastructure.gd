class_name AddStellarInfrastructureAction extends GameAction

@export var infrastructure_id: String = ""

func is_possible(target: Node,selected: Node) -> bool:

	if not target is StarSystemNode:
		return false
	if target.state.get_owner_id() != StrategyGlobals.PLAYER_FACTION_ID:
		return false
	#if target.state.has_infrastructure(infrastructure_id):
	#	return false
	return true

func execute(target: Node,selected: Node = null) -> void:
	var infrastructure_def = StrategyGlobals.get_infrastructure(infrastructure_id)
	target.state.get_new_infrastructure(infrastructure_def)
	
