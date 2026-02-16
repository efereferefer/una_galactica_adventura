class_name ShipState extends Resource

@export var id: String = ""
@export var ship_name: String = ""
@export var power: int = 100 
@export var max_action_points: int = 2

@export var components: Array[ShipComponentState] = []
@export var current_aсtion_points: int
@export var owner: FactionState
var current_system: StarSystemState 
signal died()

func _init(_def: ShipData = null,_faction: FactionState = null):
	if _def:
		id = StrategyGlobals.get_new_ship_id()
		ship_name = _def.ship_name + " " + str(id)
		power = _def.power
		max_action_points = _def.max_action_points
		current_aсtion_points = max_action_points # Даем полные ОД при создании
	if _faction:
		owner = _faction

func has_action_points()->bool:
	return current_aсtion_points>0

func deduct_action_point():
	current_aсtion_points-=1
	
func next_turn():
	current_aсtion_points = max_action_points
	
func turn_began(faction_id):
	if faction_id == get_owner_id():
		current_aсtion_points = max_action_points
		
func  set_owner():
	pass

func get_owner_id() -> int:
	return owner.id

func catch_battle_result(victory: bool):
	if victory:
		# Победитель тратит все очки действий
		current_aсtion_points = 0
	else:
		died.emit()
		
func get_new_component(_def: ShipComponentDef):
	var new_component = ShipComponentState.new(_def)
	components.append(new_component)

func has_component(component_id) -> bool:
	var has_component_id: bool = false
	for component in components:
		if component.id == component_id:
			has_component_id = true
	return has_component_id
