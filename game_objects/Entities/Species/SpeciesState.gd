class_name SpeciesState extends Resource

@export var def: SpeciesDef
@export var amount: int = 0
@export var happines: int = 0

func _init(_def: SpeciesDef = null, _amount: int = 0, _happines: int = 50):
	if _def:
		def = _def
	if _amount:
		amount = _amount
	if _happines:
		happines = _happines

func get_species_work()-> float:
	var work: float
	work = (amount/1000)*def.productivity
	return work
	
func increment(habitat: GlobalDefs.HabitabilityType, overpopulated: bool = false)-> void:
	var inc: int = 0
	if habitat == def.habitat or habitat == GlobalDefs.UniversalHabitat:
		inc = int(ceil(amount*def.growth_rate))
	else:
		inc = int(ceil((amount*def.growth_rate)/10))
	if not overpopulated:
		amount+=inc
	else:
		amount -= inc
