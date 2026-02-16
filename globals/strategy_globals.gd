extends Node

signal turn_changed(new_faction_id: int)
signal round_completed(number: int)

var current_round: int = 1
var active_faction_id: int = 0

var turn_order: Array[int] = []

var _ship_counter: int = 0
var ship_components: Dictionary = {}
var factions: Dictionary = {}
var systems_data: Dictionary = {}
var planet_defs: Dictionary = {}
var ship_templates: Dictionary = {}
var infrastructure: Dictionary = {}
var species_data: Array[SpeciesDef]

const NEUTRAL_FACTION_ID = -1
const PLAYER_FACTION_ID = 0

func _ready() -> void:
	_ship_counter = 0
	_load_definitions()
	_init_game_state()

func _load_definitions():
	var infrastructure_load = Loader.load_stuff_by_id_from_single_directory("res://data_files/stellar_infrastructure/")
	for key in infrastructure_load: 
		infrastructure[key] = infrastructure_load[key]
	
	var species_load = Loader.load_stuff_by_id_from_single_directory("res://data_files/species/")
	for key in species_load: 
		species_data.append(species_load[key])

	infrastructure_load = Loader.load_stuff_by_id_from_single_directory("res://data_files/planetary_infrastructure/")
	for key in infrastructure_load: 
		infrastructure[key] = infrastructure_load[key]
		
	var factions_load = Loader.load_stuff_by_id_from_single_directory("res://data_files/factions/")
	for key in factions_load: 
		factions[key] = FactionState.new(factions_load[key])

	var systems_data_load = Loader.load_stuff_by_id_from_single_directory("res://data_files/systems/")
	for key in systems_data_load: 
		systems_data[key] = StarSystemState.new(systems_data_load[key])

	var planets_load = Loader.load_stuff_by_id_from_single_directory("res://data_files/planets/")
	for key in planets_load: 
		planet_defs[key] = planets_load[key]

	var ship_components_load = Loader.load_stuff_by_id_from_single_directory("res://data_files/ship_components/")
	for key in ship_components_load: 
		ship_components[key] = ship_components_load[key]
	
	if not factions.has(NEUTRAL_FACTION_ID):
		var neutral_def = FactionDef.new()
		neutral_def.id = NEUTRAL_FACTION_ID
		neutral_def.faction_name = "Neutral"
		neutral_def.color = Color.GRAY
		neutral_def.is_playable = false
		neutral_def.type = FactionDef.Type.NPC_NEUTRAL
		factions[NEUTRAL_FACTION_ID] = FactionState.new(neutral_def)
	
	var ship_templates_load = Loader.load_stuff_by_id_from_single_directory("res://data_files/ship_templates/")
	for key in ship_templates_load: 
		ship_templates[key] = ship_templates_load[key]

func _init_game_state():
	if FileAccess.file_exists("res://data_files/initial_system_layout.tres"):
		var system_layout = load("res://data_files/initial_system_layout.tres") as InitialSystemLayout
		if system_layout:
			for sys_id in system_layout.system_planets:
				var sys_state = get_systems_data(sys_id)
				if sys_state:
					for planet_def_id in system_layout.system_planets[sys_id]:
						var p_def = get_planet_def(planet_def_id)
						if p_def:
							var p_state = PlanetState.new(p_def)
							sys_state.planets.append(p_state)

	if FileAccess.file_exists("res://data_files/initial_produce_layout.tres"):
		var produce_layout = load("res://data_files/initial_produce_layout.tres") as InitialProduceLayout
		if produce_layout:
			_apply_produce_layout(produce_layout)

func _apply_produce_layout(layout: InitialProduceLayout):
	var all_objects = []
	for sys_id in systems_data:
		var sys = systems_data[sys_id]
		all_objects.append(sys)
		for planet in sys.planets:
			all_objects.append(planet)

	for obj in all_objects:
		var obj_id = obj.id 
		
		if layout.initial_population.has(obj_id):
			var pop_data = layout.initial_population[obj_id]
			var new_species: Dictionary
			for species in pop_data:
				new_species[species] = pop_data[species]
			obj.add_population(new_species)
		
		if layout.initial_infrastructure.has(obj_id):
			var infra_list = layout.initial_infrastructure[obj_id]
			for infra_id in infra_list:
				var def = get_infrastructure(infra_id)
				if def:
					obj.get_new_infrastructure(def)

func get_new_ship_id() -> String:
	_ship_counter += 1
	return str(_ship_counter)

func prepare_turn_order():
	var all_ids = factions.keys()
	if all_ids.has(NEUTRAL_FACTION_ID):
		all_ids.erase(NEUTRAL_FACTION_ID)

	turn_order.assign(all_ids)
	turn_order.sort() 

	if turn_order.size() > 0:
		active_faction_id = turn_order[0]
	else:
		print("Ошибка: Нет активных фракций для очереди ходов!")

func get_faction(id: int) -> FactionState:
	return factions.get(id, null)

func get_systems_data(id: String) -> StarSystemState:
	return systems_data.get(id, null)

func get_ship_template(id: String) -> ShipData:
	return ship_templates.get(id, null)

func get_component(id: String) -> ShipComponentDef:
	return ship_components.get(id, null)

func get_infrastructure(id: String) -> InfrastructureDef:
	return infrastructure.get(id, null)

func get_planet_def(id: String) -> PlanetDef:
	return planet_defs.get(id, null)
