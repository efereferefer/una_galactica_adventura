# scripts/resources/EventDef.gd
class_name EventDef extends Resource

@export var id: String = "event_001"
@export var title: String = "Event Title"
@export_multiline var description: String = "Event description"

@export var conditions: Dictionary = {} #basic trigger : number of triggered
@export var options: Array[Dictionary]

@export var is_one_time: bool = false
