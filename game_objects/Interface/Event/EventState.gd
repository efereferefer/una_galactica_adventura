class_name EventState extends Resource

signal event_fire(options: Dictionary)
@export var def: EventDef
@export var id: String = "event_001"
@export var title: String = "Event Title"
@export_multiline var description: String = "Event description"

# conditions в дефе: { "ship_entered": 5 } (нужно для срабатывания)
# conditions в стейте: { "ship_entered": 0 } (счетчик прогресса)
@export var conditions: Dictionary = {} 

@export var options: Array[Dictionary]

@export var is_one_time: bool = false
@export var is_completed: bool = false # Флаг завершения для Менеджера
@export var fired: bool = false

func _init(_def: EventDef = null):
	if _def:
		def = _def
		id = _def.id
		title = _def.title
		description = _def.description
		is_one_time = _def.is_one_time
		
		options = _def.options.duplicate(true)
		
		reset()

func reset():
	conditions = def.conditions.duplicate(true)
	
func trigger(event_id: String, source):
	# Если прилетел корабль
	if event_id == "ship_entered":
		var ship = source as ShipUnit
		# Если это корабль игрока и он в системе Древних (ID 2)
		if ship.data.get_owner_id() == StrategyGlobals.PLAYER_FACTION_ID:
			if ship.current_system.get_owner_id() == 2:
				count_trigger("ancient_system_entered")
	if event_id == "planet_conquered":
		var planet = source as PlanetNode
		if "map_to_secret" in planet.state.flags.keys():
			count_trigger("map_found")
		

func count_trigger(trigger_id):
	if trigger_id in conditions.keys():
		conditions[trigger_id] -=1
		if conditions[trigger_id] <= 0: conditions.erase(trigger_id)
	if is_ready_to_fire() and not (is_one_time and fired): fire()

func fire():
	event_fire.emit(self)
	fired = true
	if not is_one_time:
		reset()

func is_ready_to_fire() -> bool:
	if conditions.is_empty(): return true
	return false
