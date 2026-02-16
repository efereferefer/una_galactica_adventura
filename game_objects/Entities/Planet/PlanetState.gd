class_name PlanetState extends ProducingObjectState

@export var def: PlanetDef

@export var id: String


func _init(_def: PlanetDef = null):
	if _def:
		def = _def
		id = _def.id
		name = _def.name
		habitat = _def.habitat
		population_cap = _def.population_cap
		development_cap = _def.development_cap
		population = EconomyGlobals.give_species_list()
		is_explored = _def.is_explored
		is_visible = _def.is_visible
		flags = _def.flags.duplicate(true)
		
