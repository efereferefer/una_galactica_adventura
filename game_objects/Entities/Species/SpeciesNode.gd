extends Control
var species: SpeciesState

@onready var name_label = %NameAndAmount
@onready var details_box = %DetailsBox
@onready var desc_label = %DescLabel
@onready var habitat_label = %HabitatLabel
@onready var growth_label = %GrowthLabel
@onready var prod_label = %ProductivityLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	details_box.visible = false

func setup(def: SpeciesState):
	species = def
	# %s - вставит строку (имя вида)
	name_label.text = "%s: %d" % [species.def.name, species.amount]
	desc_label.text = species.def.desc
	
	# Получаем имя климата из Enum по индексу
	var habitat_name = GlobalDefs.HabitabilityType.keys()[species.def.habitat]
	habitat_label.text = "Habitat: %s" % habitat_name
	
	# %.2f - выведет float с 2 знаками после запятой
	growth_label.text = "Growth rate: %.2f" % species.def.growth_rate
	
	# %.1f - выведет float с 1 знаком после запятой
	prod_label.text = "Productivity: %.1f" % species.def.productivity
	
	

func _on_button_pressed() -> void:
	details_box.visible = not details_box.visible
