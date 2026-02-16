extends Node2D

signal fog_of_war_update()

var _ship_state_to_unit_map: Dictionary = {}

# --- CAMERA VARIABLES ---
var _camera_zoom_target: Vector2 = Vector2.ONE
var _is_panning: bool = false
const MIN_ZOOM: float = 0.2
const MAX_ZOOM: float = 4.0
const ZOOM_SPEED: float = 10.0
const CAMERA_PAN_SPEED: float = 500.0 
# ------------------------

@export var orbit_radius: float = 50.0 
@export var initial_layout: MapLayout

var selected_object: Node2D = null
var active_systems: Array[StarSystemState] = []
var active_ships: Array[ShipUnit] = [] 
var last_expanded_system: StarSystemNode = null

@export var registered_actions: Array[GameAction] = []
@export var info_window: ObjectInfoWindow # <-- Используем универсальное окно
@export var info_window_ship: ShipInfoWindow
@export var player_id: int = 0
@export var context_menu: ContextMenu
@export var battle_simulator: BattleSimulator

# Удален info_window_planet, так как теперь используется единый info_window

var system_node_scene = preload("res://game_objects/Entities/StarSystem/StarSystemNode.tscn")
var system_nodes: Dictionary = {}
@onready var camera: Camera2D = %PlayerCamera

func _ready() -> void:
	add_to_group("map") 
	registered_actions = Loader._load_actions_automatically("res://data_files/actions/")
	registered_actions.sort_custom(func(a, b): return a.priority < b.priority)
	
	StrategyGlobals.prepare_turn_order()
	
	_spawn_systems()
	_validate_bidirectional_connections()
	
	_apply_map_layout()
	_update_fog_of_war() 
	await get_tree().process_frame
	
	_focus_camera_on_map()
	_camera_zoom_target = camera.zoom
	
	queue_redraw()
	
	AwaitTransport.request_map_answer.connect(_move_is_correct)
	Transport.move_ship_request.connect(_move_ship_to)
	Transport.move_specific_ships_request.connect(_move_group_of_ships)
		
func _spawn_systems() -> void:
	for system_id in StrategyGlobals.systems_data:
		var state = StrategyGlobals.systems_data[system_id]
		active_systems.append(state)
		
		var node := system_node_scene.instantiate() as StarSystemNode
		add_child(node)
		node.setup(state)
		system_nodes[state.id] = node
		
		node.selected.connect(new_selected)
		# Подключаем сигналы к универсальному обработчику
		node.system_info_requested.connect(_on_object_info_requested)
		node.system_move_requested.connect(_on_system_move_requested)
		node.system_expanded.connect(_on_system_expanded)
		node.planet_info_requested.connect(_on_object_info_requested)
		node.planet_selected_relay.connect(new_selected)

func _apply_map_layout():
	if not initial_layout:
		print("ОШИБКА: Файл initial_map_layout не назначен в инспекторе карты!")
		return
		
	for system_id in initial_layout.mapArray:
		var faction_id = initial_layout.mapArray[system_id]
		var system_state = StrategyGlobals.get_systems_data(system_id)
		var faction_state = StrategyGlobals.get_faction(faction_id)
		
		if system_state and faction_state:
			system_state.set_owner(faction_state, true)
			if system_nodes.has(system_id):
				system_nodes[system_id].update_visuals()
		else:
			print("Ошибка расстановки владельца: ", system_id, " или ", faction_id, " не найден.")

	for system_id in initial_layout.shipArray:
		var ships_to_spawn = initial_layout.shipArray[system_id]
		var system_state = StrategyGlobals.get_systems_data(system_id)
		
		if not system_state:
			print("Ошибка спавна корабля: система ", system_id, " не найдена.")
			continue
			
		for ship_info in ships_to_spawn:
			var template_id_num = int(ship_info.x)
			var faction_id = int(ship_info.y)
			
			var template = StrategyGlobals.get_ship_template(str(template_id_num))
			var faction = StrategyGlobals.get_faction(faction_id)
			
			if template and faction:
				_spawn_ship(template, faction, system_state)
			else:
				print("Ошибка спавна корабля: шаблон ", template_id_num, " или фракция ", faction_id, " не найдены.")
		
func _validate_bidirectional_connections():
	for state in active_systems:
		var new_connections: Array[StarSystemState] = []
		for conn_def in state.def.connections:
			var other_state = StrategyGlobals.get_systems_data(conn_def.id)
			if other_state:
				new_connections.append(other_state)
		state.connections = new_connections
	
	for state_a in active_systems:
		for neighbor in state_a.connections:
			if state_a not in neighbor.connections:
				neighbor.connections.append(state_a)

func _update_fog_of_war():
	var player_id = StrategyGlobals.PLAYER_FACTION_ID
	
	# 1. Находим все системы, где есть ПРИСУТСТВИЕ игрока
	# (либо владеет системой, либо там есть его корабль)
	var systems_with_presence: Array[StarSystemState] = []
	
	for sys in active_systems:
		var has_presence = false
		
		# Проверка владения
		if sys.get_owner_id() == player_id:
			has_presence = true
		
		# Проверка кораблей
		if not has_presence:
			for ship in sys.ships_in_system :
				if ship.get_owner_id() == player_id:
					has_presence = true
					break
					
		
		if has_presence:
			systems_with_presence.append(sys)
			
		if sys.is_visible:
			_reveal_system(sys, true)
	# 2. Применяем правила видимости
	for sys in systems_with_presence:
		_reveal_system(sys, true)
		# Правило 2: Соседи видимы (но планеты в них - нет)
		for neighbor in sys.connections:
			_reveal_system(neighbor, false)
	
	# Перерисовываем линии связей
	queue_redraw()
	fog_of_war_update.emit()
	
func reveal_system(sys_state):
	_reveal_system(sys_state, false)
# Вспомогательная функция открытия
func _reveal_system(sys_state: StarSystemState, reveal_planets: bool):
	# Если система уже была открыта и нам не надо открывать планеты - выходим
	if sys_state.is_visible and (not reveal_planets or _are_all_planets_visible(sys_state)):
		return

	sys_state.is_visible = true
	
	# Обновляем визуальную ноду, если она существует
	if system_nodes.has(sys_state.id):
		system_nodes[sys_state.id].visible = true
		# Можно добавить обновление цвета или иконки "глаза", если нужно
	
	if reveal_planets:
		for planet in sys_state.planets:
			planet.is_visible = true
			# Сами ноды планет обновятся, когда мы раскроем систему, 
			# но если система УЖЕ раскрыта в UI, надо пнуть её
			if system_nodes.has(sys_state.id):
				var sys_node = system_nodes[sys_state.id]
				if sys_node.is_expanded:
					# Форсируем обновление видимости планет
					sys_node.toggle_planets(true) 

func _are_all_planets_visible(sys: StarSystemState) -> bool:
	if sys.planets.is_empty(): return true
	return sys.planets[0].is_visible
	

func _spawn_ship(ship_template: ShipData, faction: FactionState, system: StarSystemState) -> void:
	var ship_scene = preload("res://game_objects/Entities/Ship/ShipUnit.tscn")
	var new_ship = ship_scene.instantiate() as ShipUnit 
	add_child(new_ship)
	
	new_ship.setup(ship_template, faction)
	new_ship.initialize(system)
	
	system.add_ship(new_ship.data) 
	
	new_ship.selected.connect(new_selected)
	new_ship.ship_info_requested.connect(_on_ship_info_requested)
	new_ship.ship_died.connect(_on_ship_died)
	
	fog_of_war_update.connect(new_ship.fog_update)
	
	active_ships.append(new_ship)
	_ship_state_to_unit_map[new_ship.data] = new_ship
	
	TurnManager.turn_started.connect(new_ship.data.turn_began)
	_update_ship_positions_in_system(system)

func _on_ship_died(ship_to_remove: ShipUnit):
	print("Карта получила сигнал о смерти корабля: ", ship_to_remove.data.ship_name)
	if not is_instance_valid(ship_to_remove): return

	var system_state = ship_to_remove.current_system
	system_state.remove_ship(ship_to_remove.data)

	if ship_to_remove in active_ships:
		active_ships.erase(ship_to_remove)
	
	if _ship_state_to_unit_map.has(ship_to_remove.data):
		_ship_state_to_unit_map.erase(ship_to_remove.data)
		
	if selected_object == ship_to_remove:
		selected_object = null

	ship_to_remove.queue_free()
	_update_ship_positions_in_system(system_state)

func new_selected(new_object):
	if selected_object == new_object: return
	
	if selected_object and is_instance_valid(selected_object):
		selected_object.deselect()
	
	selected_object = new_object
	
	if selected_object and selected_object.has_method("make_selected"):
		selected_object.make_selected()
	
	# Логика сворачивания аккордеона систем
	if new_object is StarSystemNode:
		pass
	elif new_object is PlanetNode:
		pass
	else:
		pass

func _on_system_expanded(node: StarSystemNode):
	if last_expanded_system and last_expanded_system != node:
		#last_expanded_system.toggle_planets(false)
		pass
	last_expanded_system = node

# Единый обработчик инфо (система или планета)
func _on_object_info_requested(state: ProducingObjectState) -> void:
	if info_window: info_window.show_info(state)

func _on_system_move_requested(target_state: StarSystemState) -> void:
	var current_f = StrategyGlobals.get_faction(StrategyGlobals.active_faction_id)
	if not current_f.def.is_playable: return
	if not selected_object is ShipUnit: return
	var move_correct = _move_is_correct(target_state, selected_object, false)
	
	if move_correct:
		if info_window.visible: info_window.hide()
		_move_ship_to(target_state, move_correct)
		
func _move_is_correct(target_state: StarSystemState, selected: ShipUnit, await_request: bool = true) -> bool:
	var answer: bool = true
	if selected_object.get_owner_id() != player_id: answer = false
	if not selected_object.has_action_points(): answer = false
	if target_state == selected_object.current_system: answer = false
	if not target_state in selected_object.current_system.connections:
		answer = false
	if await_request:
		AwaitTransport.move_answer.emit(answer)
	return answer
	
func _on_ship_info_requested(ship_data: ShipState) -> void:
	if info_window_ship: info_window_ship.show_info(ship_data)

func _move_ship_to(target_state: StarSystemState, move_correct: bool = false, check_override: bool = false) -> void:
	if not check_override:
		if not move_correct:
			move_correct = _move_is_correct(target_state, selected_object, false)
		if not move_correct: return
	
	var ship_unit = selected_object
	var old_system_state = ship_unit.current_system
	
	old_system_state.remove_ship(ship_unit.data)
	target_state.add_ship(ship_unit.data)
	
	ship_unit.current_system = target_state
	ship_unit.move()
	
	_update_ship_positions_in_system(old_system_state)
	_update_ship_positions_in_system(target_state)
	_update_fog_of_war() 
	GameEvents.trigger_event.emit("ship_entered", ship_unit)
	
func _move_group_of_ships(ships: Array[ShipState], target_state: StarSystemState) -> void:
	var last_ship
	for ship_data in ships:
		# Находим юнит на карте по данным
		if _ship_state_to_unit_map.has(ship_data):
			var ship_unit = _ship_state_to_unit_map[ship_data]
			
			var old_system_state = ship_unit.current_system
			
			old_system_state.remove_ship(ship_unit.data)
			target_state.add_ship(ship_unit.data)
			
			ship_unit.current_system = target_state
			ship_unit.move()
			last_ship = ship_unit
			_update_ship_positions_in_system(old_system_state)
	GameEvents.trigger_event.emit("ship_entered", last_ship)
			
	
	# Обновляем позиции в целевой системе один раз в конце
	_update_ship_positions_in_system(target_state)
	_update_fog_of_war()
		
func _update_ship_positions_in_system(system_state: StarSystemState):
	var data_list = system_state.ships_in_system
	if data_list.is_empty(): return

	var count = data_list.size()
	for i in range(count):
		var ship_data = data_list[i]
		if _ship_state_to_unit_map.has(ship_data):
			var target_unit = _ship_state_to_unit_map[ship_data]
			var angle = i * (TAU / max(1, count)) 
			var offset = Vector2(cos(angle), sin(angle)) * orbit_radius
			var target_pos = system_state.map_position + offset
			var tween = create_tween()
			tween.tween_property(target_unit, "position", target_pos, 0.5).set_trans(Tween.TRANS_SINE)

func _focus_camera_on_map() -> void:
	if active_systems.is_empty(): return
	var min_x = INF; var max_x = -INF; var min_y = INF; var max_y = -INF
	for state in active_systems:
		min_x = min(min_x, state.map_position.x); max_x = max(max_x, state.map_position.x)
		min_y = min(min_y, state.map_position.y); max_y = max(max_y, state.map_position.y)
	
	var margin = 100.0
	var rect = Rect2(min_x - margin, min_y - margin, (max_x - min_x) + margin * 2, (max_y - min_y) + margin * 2)
	rect.size = rect.size.max(Vector2(1,1))
	
	var screen = get_viewport_rect().size
	var zoom = min(screen.x / rect.size.x, screen.y / rect.size.y)
	zoom = clamp(zoom, MIN_ZOOM, 2.0)
	
	camera.zoom = Vector2(zoom, zoom)
	camera.position = rect.get_center()
	_camera_zoom_target = camera.zoom

func _draw() -> void:
	for state_a in active_systems:
		if not state_a.is_visible: continue # Если А скрыта, линии от неё не рисуем
		
		for state_b in state_a.connections:
			# Рисуем линию только если ОБЕ системы видимы
			if state_b.is_visible: 
				draw_line(state_a.map_position, state_b.map_position, Color.GRAY, 2.0)

func process_turn(turn_number: int) -> void:
	var current_faction = StrategyGlobals.get_faction(StrategyGlobals.active_faction_id)
	if current_faction and current_faction.def.is_playable:
		TurnManager.start_next_turn()
	queue_redraw()
	 
func _on_context_menu_requested(screen_pos: Vector2, selected_node: Node, target_object: Node):
	var options = context_menu.get_header(target_object)

	for action in registered_actions:
		if await action.is_possible(target_object, selected_node):
			options.append({
				"type": "Button",
				"text": action.get_display_text(target_object),
				"callback": func(): action.execute(target_object, selected_object)
			})

	if options.size() > 2 or target_object is PlanetNode:
		context_menu.open(screen_pos, options)
		
func _adjust_zoom(factor: float, mouse_pos: Vector2) -> void:
	var viewport_size = get_viewport_rect().size
	var old_zoom = _camera_zoom_target
	var new_zoom = old_zoom * factor
	
	if new_zoom.x > MAX_ZOOM: new_zoom = Vector2(MAX_ZOOM, MAX_ZOOM)
	if new_zoom.x < MIN_ZOOM: new_zoom = Vector2(MIN_ZOOM, MIN_ZOOM)
	if new_zoom == old_zoom: return
	
	_camera_zoom_target = new_zoom
	var mouse_offset_from_center = (mouse_pos - viewport_size * 0.5)
	var pos_diff = mouse_offset_from_center / old_zoom - mouse_offset_from_center / new_zoom
	camera.position += pos_diff
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		#
		if not info_window.visible:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_adjust_zoom(1.1, event.position)
				get_viewport().set_input_as_handled()
				return
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_adjust_zoom(1.0 / 1.1, event.position)
				get_viewport().set_input_as_handled()
				return
		
		var node_under_mouse = _get_node_under_mouse()
		
		# Нажатие
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				_is_panning = true
				get_viewport().set_input_as_handled()
			elif event.button_index == MOUSE_BUTTON_RIGHT and !event.shift_pressed:
				if node_under_mouse:
					if node_under_mouse.visible:
						_on_context_menu_requested(event.position, selected_object, node_under_mouse)
						get_viewport().set_input_as_handled()
					else:
						_is_panning = true
						get_viewport().set_input_as_handled()
				else:
					_is_panning = true
					get_viewport().set_input_as_handled()
			if event.button_index == MOUSE_BUTTON_LEFT:
					if not node_under_mouse and selected_object:
						selected_object.deselect()
						selected_object = null
		elif not event.pressed:
			if event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
				_is_panning = false

	# Панорамирование
	elif event is InputEventMouseMotion and _is_panning:
		camera.position -= event.relative / camera.zoom
		get_viewport().set_input_as_handled()

func _get_node_under_mouse() -> Node:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	var results = space_state.intersect_point(query)
	if not results.is_empty():
		var collider = results[0].collider
		if collider.owner is SelectableEntity:
			return collider.owner
	return null

func _process(delta: float) -> void:
	if camera.zoom.distance_squared_to(_camera_zoom_target) > 0.0001:
		camera.zoom = camera.zoom.lerp(_camera_zoom_target, ZOOM_SPEED * delta)

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if not direction.is_zero_approx():
		camera.position += direction * CAMERA_PAN_SPEED * delta

func rebuild_world_from_save():
	# 1. Удаляем все визуальные ноды
	# Удаляем системы (вместе с планетами)
	for sys_node in system_nodes.values():
		sys_node.queue_free()
	system_nodes.clear()
	
	# Удаляем корабли
	for ship_unit in active_ships:
		ship_unit.queue_free()
	active_ships.clear()
	_ship_state_to_unit_map.clear()
	
	active_systems.clear() # Очищаем список ссылок
	
	selected_object = null
	if info_window: info_window.clear_all()
	
	# 2. Ждем кадр, чтобы Godot удалил объекты
	await get_tree().process_frame
	
	# 3. Заново создаем мир из загруженных данных
	_spawn_systems() # Эта функция берет данные из StrategyGlobals, которые мы только что загрузили
	
	# 4. Восстанавливаем корабли
	# В _spawn_systems() мы создали системы, но корабли там не спавнятся сами по себе,
	# так как в _apply_map_layout() мы читали initial_layout.tres.
	# А сейчас нам надо читать данные из StrategyGlobals.
	
	_respawn_ships_from_data()
	
	_validate_bidirectional_connections()
	_update_fog_of_war()
	queue_redraw()

func _respawn_ships_from_data():
	var ship_scene = preload("res://game_objects/Entities/Ship/ShipUnit.tscn")
	
	for sys_id in StrategyGlobals.systems_data:
		var sys_state = StrategyGlobals.systems_data[sys_id]
		
		# Проходим по всем кораблям, которые числятся в системе (данные)
		for ship_data in sys_state.ships_in_system:
			var faction = StrategyGlobals.get_faction(ship_data.get_owner_id())
			
			# Создаем визуал
			var new_ship = ship_scene.instantiate() as ShipUnit
			add_child(new_ship)
			
			# Важно: мы не делаем new(), мы скармливаем существующий загруженный ship_data
			new_ship.data = ship_data 
			if not new_ship.data.died.is_connected(new_ship.die):
				new_ship.data.died.connect(new_ship.die)
			new_ship.initialize(sys_state)
			
			# Подключаем сигналы
			new_ship.selected.connect(new_selected)
			new_ship.ship_info_requested.connect(_on_ship_info_requested)
			new_ship.ship_died.connect(_on_ship_died)
			fog_of_war_update.connect(new_ship.fog_update)
			
			# Регистрируем
			active_ships.append(new_ship)
			_ship_state_to_unit_map[new_ship.data] = new_ship
			
			new_ship.update_visuals()
			
	# Обновляем позиции (орбиты)
	for sys in active_systems:
		_update_ship_positions_in_system(sys)
