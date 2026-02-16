extends Resource
class_name FactionState

@export var def: FactionDef

@export var id: int
@export var faction_name: String
@export var faction_resourses: Dictionary
@export var population_cap: int
@export var development_cap: int
@export var tech_bonus: Dictionary

func _init(_def: FactionDef = null):
	if _def:
		def = _def
		id = _def.id
		faction_name = _def.faction_name
	faction_resourses = EconomyGlobals.give_all_resources()
	tech_bonus = EconomyGlobals.give_all_resources()
	for key in tech_bonus:
		tech_bonus[key] = float(1)
	
func apply_infrastructure_effects(effects: Dictionary):
	for key in effects.keys():
		if key == "population_cap":
			population_cap += effects[key]  
		if key == "development_cap":
			development_cap += effects[key]
		else:
			if key not in faction_resourses.keys(): 
				faction_resourses[key] = 0
			faction_resourses[key] += effects[key]
	
func get_tech_bonus(resource_id)-> float:
	return tech_bonus[resource_id]
