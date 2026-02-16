class_name ProducingObjectState extends Resource

@export var habitat: GlobalDefs.HabitabilityType
@export var name: String = "" # Перенесли сюда
@export var owner_faction: FactionState
signal turn_started()
@export var infrastructures: Array[InfrastructureState] = []

@export var stockpile: Dictionary = {}
@export var addition: Dictionary = {}

@export var population: Array[SpeciesState]
@export var population_cap: int = 10000

@export var development: float = 0
@export var development_cap: float = 0

@export var developmental_infrastructure: float = 0
@export var building_slots: int = 1

@export var is_visible: bool = false
@export var is_explored: bool = false
@export var flags: Dictionary

func _init() -> void:
	pass

func get_new_infrastructure(_def: InfrastructureDef):
	if not _def.infr_class == get_infr_class():
		return
	var new_infrastructure = InfrastructureState.new(_def)
	infrastructures.append(new_infrastructure)
	apply_infrastructure_effects(new_infrastructure.build_local_effects)
	owner_faction.apply_infrastructure_effects(new_infrastructure.build_global_effects)
	finilize_effects()

func has_infrastructure(infrastructure_id) -> bool:
	var has_infrastructure_id: bool = false
	for infrastructure in infrastructures:
		if infrastructure.id == infrastructure_id:
			has_infrastructure_id = true
	return has_infrastructure_id

func add_population(species_pop:Dictionary):
	for species in population:
		if species.def.id in species_pop.keys():
			species.amount += species_pop[species.def.id]

func get_total_population() -> int:
	var total = 0
	for species in population:
		total += species.amount
	return total

func has_pops() -> bool:
	if population == null: 
		return false
	for species in population:
		if species.amount > 0: 
			return true
	return false

func has_resources() -> bool:
	if stockpile == null: 
		return false
	for key in stockpile.keys():
		if stockpile[key] > 0: 
			return true
	return false
	
func next_turn():
	turn_started.emit()

func turn_began():
	
	for key in addition.keys():
		addition[key] = 0

	infrastructure_work()
	population_work()
	_process_population_growth()
	development_work()
	finilize_effects()
	adjust_building_slots()

	
func development_work():
	var new_basic_resources: float = ceil(development)
	if "basic_materials" not in addition.keys(): 
		addition["basic_materials"] = 0
	addition["basic_materials"] += new_basic_resources
	owner_faction.faction_resourses["credits"] += new_basic_resources
	
func infrastructure_work():
	for infrastructure in infrastructures:
		apply_infrastructure_effects(infrastructure.on_turn_local_effects)
		owner_faction.apply_infrastructure_effects(infrastructure.on_turn_global_effects)

func population_work():
	for species in population:
		development+= species.get_species_work()

func _process_population_growth():
	var overpop = population_cap < get_total_population() 
	for species in population:
		species.increment(habitat, overpop)
	pass

func apply_infrastructure_effects(effects: Dictionary):
	for key in effects.keys():
		if key == "population_cap":
			population_cap += effects[key]
		if key == "development_cap":
			development_cap += effects[key]
		else:
			if key not in addition.keys(): 
				addition[key] = 0
			addition[key] += effects[key]

func finilize_effects():
	for key in addition.keys():
		addition[key] *= owner_faction.get_tech_bonus(key)
		if key not in stockpile: 
			stockpile[key] = 0
		stockpile[key] += addition[key]
	addition = {}

func adjust_building_slots():
	var new_slots: int = int(get_total_population()/1000)
	building_slots = new_slots
	
func get_owner_id() -> int:
	if owner_faction:
		return owner_faction.id
	return StrategyGlobals.NEUTRAL_FACTION_ID

func get_infr_class():
	pass

func set_owner(new_owner: FactionState):
	owner_faction = new_owner
	
func get_species_setup():
	pass
