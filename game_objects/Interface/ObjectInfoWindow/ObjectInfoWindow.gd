extends Control
class_name ObjectInfoWindow

@onready var title_label: Label = %TitleLabel
@onready var desc_label: Label = %DescriptionLabel
@onready var habitat_label: Label = %HabitatLabel
@onready var total_population_label: Label = %PopulationLabel
@onready var development_label: Label = %DevelopmentLabel

@onready var infrastructure_box = %InfrastructureBox
@onready var infra_box = %InfraBox
@onready var infra_scroll = %InfraScroll
@onready var res_box = %ResBox
@onready var res_scroll = %ResScroll
@onready var stock_box = %StockpileBox
@onready var population_box = %PopulationBox
@onready var pop_box = %PopBox
@onready var pop_scroll = %PopScroll

var infrastructure_scene = preload("res://game_objects/Entities/Infrastructure/Infrastructure.tscn")
var stock_scene = preload("res://game_objects/Entities/StockPile/Stockpile.tscn")
var species_scene = preload("res://game_objects/Entities/Species/SpeciesNode.tscn")

func _ready() -> void:
	clear_all()
	%TabContainer.set_tab_hidden(0, true)
	%TabContainer.set_tab_title(0, "Population")
	%TabContainer.set_tab_hidden(1, true)
	%TabContainer.set_tab_title(1, "Buildings")
	%TabContainer.set_tab_hidden(2, true)
	%TabContainer.set_tab_title(2, "Stockpile")

func show_info(state: ProducingObjectState) -> void:
	var owned = state.get_owner_id() == StrategyGlobals.PLAYER_FACTION_ID
	title_label.text = state.name
	
	var owner_name = "Unknown"

	
	if state.is_explored or owned:
		if state.owner_faction:
			owner_name = state.owner_faction.faction_name
	
		if state is StarSystemState:
			pass
	
		if state is PlanetState:
			pass
	
		var habitat_name = GlobalDefs.HabitabilityType.keys()[state.habitat]
		habitat_label.text = "Habitat: %s" % habitat_name
	
		total_population_label.text = "Total population: %d/%d" % [state.get_total_population(), state.population_cap]
	

		development_label.text = "Development: %d/%d" % [state.development, state.development_cap]
		_clear_list(infra_box)
		var infra_tab_hidden = state.infrastructures.is_empty()
		%TabContainer.set_tab_hidden(1, infra_tab_hidden)
		if !infra_tab_hidden: 
			%TabContainer.current_tab = 1
		for infra in state.infrastructures:
			var node = infrastructure_scene.instantiate()
			infra_box.add_child(node)
			node.setup(infra)
		
		_clear_list(res_box)
		var res_tab_hidden = !state.has_resources()  or !owned
		%TabContainer.set_tab_hidden(2, res_tab_hidden)
		if !res_tab_hidden: 
			%TabContainer.current_tab = 2
		for key in state.stockpile.keys():
			if state.stockpile[key] > 0: 
				var node = stock_scene.instantiate()
				res_box.add_child(node)
				node.setup(EconomyGlobals.get_resource_name(key), state.stockpile[key])
	
		_clear_list(pop_box)
		var pop_tab_hidden = !state.has_pops()
		%TabContainer.set_tab_hidden(0, pop_tab_hidden )
		if !pop_tab_hidden : 
			%TabContainer.current_tab = 0
		for species in state.population:
			if species.amount > 0: # Показываем только тех, кто реально живет
				var node = species_scene.instantiate()
				pop_box.add_child(node) 
				node.setup(species)
				
		%TabContainer.visible = !(res_tab_hidden and pop_tab_hidden and infra_tab_hidden)
		
	else:
		habitat_label.text = ""
		total_population_label.text = ""
		development_label.text = ""
		%TabContainer.visible = false
		res_scroll.visible = false
		infra_scroll.visible = false
		pop_scroll.visible = false
	show()

func _clear_list(container: Node):
	for child in container.get_children():
		child.queue_free()

func clear_all():
	_clear_list(infra_box)
	_clear_list(res_box)
	_clear_list(pop_box)
	hide()

func _on_background_blocker_pressed() -> void: clear_all()
func _on_stockpile_button_pressed() -> void: res_box.visible = !res_box.visible
func _on_infrastructure_button_pressed() -> void: infra_box.visible = !infra_box.visible
func _on_pop_button_pressed() -> void: pop_box.visible = !pop_box.visible
