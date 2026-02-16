extends Control
class_name PlanetInfoWindow

@onready var title_label: Label = %TitleLabel
@onready var desc_label: Label = %DescriptionLabel
@onready var infrastructure_label: Label = %InfrastructureLabel
@onready var infrastructure_box = %InfrastructureBox
@onready var infra_box = %InfraBox
@onready var res_box = %ResBox
@onready var stock_box = %StockpileBox
@onready var population_box = %populationBox
@onready var pop_box = %PopBox

var infrastructure_scene = preload("res://game_objects/Entities/Infrastructure/Infrastructure.tscn")
# Исправлен регистр: StockPile
var stock_scene = preload("res://game_objects/Entities/StockPile/Stockpile.tscn")

func _ready() -> void:
	clear_all()
	res_box.visible = false
	infra_box.visible = false

func show_info(state: PlanetState) -> void:
	var owned = state.get_owner_id() == StrategyGlobals.PLAYER_FACTION_ID
	title_label.text = state.name
	
	var owner_name = "Unknown"
	if state.owner_faction: owner_name = state.owner_faction.faction_name
	
	desc_label.text = "ID: %s\nOwner: %s" % [state.id, owner_name]

	_clear_list(infra_box)
	infrastructure_box.visible =!state.infrastructures.is_empty()
	for infra in state.infrastructures:
		var node = infrastructure_scene.instantiate()
		infra_box.add_child(node)
		node.setup(infra)
		
	_clear_list(res_box)
	stock_box.visible = !state.stockpile.is_empty() and owned
	for key in state.stockpile.keys():
		var node = stock_scene.instantiate()
		res_box.add_child(node)
		node.setup(key, state.stockpile[key])
	
	_clear_list(pop_box)
	population_box.visible = !state.has_pops()
	for species in state.population:
		var node = Label.new()
		res_box.add_child(node)
		node.text = "%s: %d" % [species.def.name,species.amount]
	show()

func _clear_list(container: Node):
	for child in container.get_children(): child.queue_free()

func clear_all():
	_clear_list(infra_box)
	_clear_list(res_box)
	_clear_list(pop_box)
	hide()

func _on_background_blocker_pressed() -> void: clear_all()
func _on_stockpile_button_pressed() -> void: res_box.visible = !res_box.visible
func _on_infrastructure_button_pressed() -> void: infra_box.visible = !infra_box.visible
func _on_pop_button_pressed() -> void: pop_box.visible = !infra_box.visible
