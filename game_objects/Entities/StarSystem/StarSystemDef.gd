@tool
class_name StarSystemDef extends Resource

@export var id: String = "sys_001"
@export var name: String = "Kepler Prime"
@export var map_position: Vector2 = Vector2(0, 0)
@export var connections: Array[StarSystemDef] = []
@export var is_visible: bool = false
@export var is_explored: bool = false
@export var flags: Dictionary
