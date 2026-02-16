extends Resource
class_name PlanetDef


@export var id: String
@export var name: String
@export var habitat: GlobalDefs.HabitabilityType
@export var population_cap: int
@export var development_cap: float
@export var is_visible: bool = false
@export var is_explored: bool = false
@export var flags: Dictionary
