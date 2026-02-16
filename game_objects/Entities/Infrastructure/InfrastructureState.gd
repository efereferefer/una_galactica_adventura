class_name InfrastructureState extends Resource

@export var id: String
@export var name: String
@export var infr_class: InfrastructureDef.Infrastructure_Class
@export var type: InfrastructureDef.Infrastructure_Type

@export var build_local_effects: Dictionary = {}
@export var build_global_effects: Dictionary = {}
@export var destroy_local_effects: Dictionary = {}
@export var destroy_global_effects: Dictionary = {}
@export var on_turn_local_effects: Dictionary = {}
@export var on_turn_global_effects: Dictionary = {}
@export var abilities: Array[String]

@export var desc: String =""
@export var effect_text: String = ""

@export var level: int = 1

signal global_effect(effects: Dictionary)
signal local_effect(effects: Dictionary)

func _init(def: InfrastructureDef = null):
	if def:
		id = def.id
		name = def.name
		infr_class = def.infr_class
		type = def.type
		build_local_effects = def.build_local_effects
		build_global_effects = def.build_global_effects
		destroy_local_effects = def.destroy_local_effects
		destroy_global_effects = def.destroy_global_effects
		on_turn_local_effects = def.on_turn_local_effects
		on_turn_global_effects = def.on_turn_global_effects
		abilities = def.abilities
		desc = def.desc
		effect_text = def.effect_text
	
