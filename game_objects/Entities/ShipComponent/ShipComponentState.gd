class_name ShipComponentState extends Resource

@export var def: ShipComponentDef

@export var id: String
@export var name: String

func _init(_def: ShipComponentDef = null):
	if _def:
		def = _def
		id = _def.id
		name = _def.name
