class_name StarSystemState extends ProducingObjectState

@export var def: StarSystemDef

@export var id: String = ""
@export var map_position: Vector2 = Vector2.ZERO


@export var ships_in_system: Array[ShipState] = []
@export var planets: Array[PlanetState] = []

@export var connections: Array[StarSystemState] = []

func _init(_def: StarSystemDef = null):
	stockpile = EconomyGlobals.give_all_resources()
	if _def:
		def = _def
		id = def.id
		name = def.name
		map_position = def.map_position
		habitat = GlobalDefs.HabitabilityType.SPACE
		population_cap = 0
		development_cap = 0
		population = EconomyGlobals.give_species_list()
		is_explored = _def.is_explored
		is_visible = _def.is_visible
		flags = _def.flags.duplicate(true)

func add_ship(ship: ShipState):
	if not ship in ships_in_system:
		ships_in_system.append(ship)
		print("Флот ", ship.ship_name, " (", ship.get_owner_id(), ") вошел в ", name)
		_check_combat_conditions()

func remove_ship(ship: ShipState):
	if ship in ships_in_system:
		ships_in_system.erase(ship)

func _check_combat_conditions():
	if ships_in_system.size() < 2: 
		return

	var first_id = ships_in_system[0].get_owner_id()
	for ship in ships_in_system:
		if ship.get_owner_id() != first_id:
			print("!!! БОЙ В СИСТЕМЕ: ", name)
			return

func get_infr_class():
	return InfrastructureDef.Infrastructure_Class.STELLAR

func turn_began():
	super.turn_began()
	for planet in planets:
		if planet.owner_faction == null and owner_faction != null:
			planet.set_owner(owner_faction)

		if planet.get_owner_id() == StrategyGlobals.active_faction_id:
			planet.turn_began()

func set_owner(new_owner: FactionState, planet_owner = false):
	super.set_owner(new_owner)
	if planet_owner:
		for planet in planets:
			planet.set_owner(new_owner)
