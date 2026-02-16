extends Resource
class_name InfrastructureDef


enum Infrastructure_Class {STELLAR, PLANETARY}
enum Infrastructure_Type {DEFENCE, INDUSTRY, SPECIAL}

@export var id: String
@export var name: String
@export var infr_class: Infrastructure_Class
@export var type: Infrastructure_Type
@export var build_local_effects: Dictionary = {}
@export var build_global_effects: Dictionary = {}
@export var destroy_local_effects: Dictionary = {}
@export var destroy_global_effects: Dictionary = {}
@export var on_turn_local_effects: Dictionary = {}
@export var on_turn_global_effects: Dictionary = {}
@export var abilities: Array[String]

@export var desc: String =""
@export var effect_text: String = ""
