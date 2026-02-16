extends Node

var resource_names: Dictionary

func _ready() -> void:
	fill_resource_names()

func fill_resource_names():
	resource_names["basic_materials"] = "Basic materials"
	resource_names["advanced_materials"] = "Advanced materials"
	resource_names["scientific_materials"] = "Scientific materials"
	resource_names["credits"] = "Credits"

func get_resource_name(res_id) -> String:
	return resource_names[res_id]	
	
func give_species_list() -> Array[SpeciesState]:
	var species_array: Array[SpeciesState]
	for species in StrategyGlobals.species_data:
		var new_species = SpeciesState.new(species)
		species_array.append(new_species)
	return species_array

func give_all_resources() -> Dictionary:
	var all_resources: Dictionary = {}
	all_resources["basic_materials"] = 0
	all_resources["advanced_materials"] = 0
	all_resources["scientific_materials"] = 0
	all_resources["credits"] = 0
	return all_resources

func run_economies(faction_id):
	for system_id in StrategyGlobals.systems_data:
		var system_state = StrategyGlobals.get_systems_data(system_id)
		if system_state.get_owner_id() == faction_id:
			system_state.turn_began()
