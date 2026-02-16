extends Control

var state: InfrastructureState

@onready var name_label = %NameLabel
@onready var details_box = %DetailsBox
@onready var level_label = %LevelLabel
@onready var status_label = %StatusLabel
@onready var effect_label = %EffectLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	details_box.visible = false

func setup(def: InfrastructureState):
	state = def
	name_label.text = def.name
	level_label.text = "Level: %s" % [def.level]
	effect_label.text = def.effect_text

func _on_button_pressed() -> void:
	details_box.visible = not details_box.visible
