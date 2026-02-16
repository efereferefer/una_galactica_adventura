extends SelectableEntity
class_name StarSystemNode

var state: StarSystemState
var is_expanded: bool = false
var planet_nodes: Array[PlanetNode] = []

signal planet_info_requested(state: PlanetState)
signal system_selected(node: StarSystemNode)
signal system_info_requested(state: StarSystemState)
signal system_move_requested(state: StarSystemState)
signal system_expanded(node: StarSystemNode)
signal planet_selected_relay(planet_node: PlanetNode)

@onready var label: Label = $Label
var planet_scene = preload("res://game_objects/Entities/Planet/PlanetNode.tscn")

const PLANET_OFFSET_Y = 40.0

func setup(new_state: StarSystemState) -> void:
	state = new_state
	position = state.map_position
	label.text = state.name
	visible = state.is_visible 
	update_visuals()
	deselect()
	_create_planet_nodes()

func _create_planet_nodes():
	for p_state in state.planets:
		var p_node = planet_scene.instantiate() as PlanetNode
		add_child(p_node)
		p_node.setup(p_state)
		p_node.visible = false
		planet_nodes.append(p_node)
		
		# НОВОЕ: Соединяем сигнал планеты с сигналом системы
		p_node.planet_info_requested.connect(func(ps): planet_info_requested.emit(ps))
		p_node.selected.connect(func(node): planet_selected_relay.emit(node))
		
func toggle_planets(should_expand: bool):
	if is_expanded == should_expand and not should_expand: return 
	# Убрал проверку identity для true, чтобы можно было обновлять видимость "на лету"
	is_expanded = should_expand
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Счетчик для задержки анимации (чтобы не считать скрытые планеты)
	var visible_index = 0
	
	for i in range(planet_nodes.size()):
		var p_node = planet_nodes[i]
		
		# --- ГЛАВНОЕ ИЗМЕНЕНИЕ: Проверка тумана войны ---
		if not p_node.state.is_visible:
			p_node.visible = false
			continue 
		# ------------------------------------------------
		
		# Используем visible_index для расчета позиции, чтобы не было дырок
		# если какая-то промежуточная планета скрыта (хотя по логике они открываются скопом)
		var target_pos = Vector2(0, (visible_index + 1) * PLANET_OFFSET_Y)
		var delay_time = visible_index * 0.05 
		visible_index += 1
		
		if is_expanded:
			# --- РАСКРЫТИЕ ---
			p_node.visible = true
			p_node.update_visuals() 
			
			if p_node.modulate.a < 0.1: 
				p_node.position = Vector2.ZERO
				p_node.scale = Vector2(0.1, 0.1)
				p_node.modulate.a = 0.0
			
			tween.tween_property(p_node, "position", target_pos, 0.4).set_delay(delay_time)
			tween.tween_property(p_node, "modulate:a", 1.0, 0.3).set_delay(delay_time)
			tween.tween_property(p_node, "scale", Vector2.ONE, 0.4)\
				.set_trans(Tween.TRANS_BACK).set_delay(delay_time)
			
		else:
			# --- ЗАКРЫТИЕ ---
			tween.tween_property(p_node, "position", Vector2.ZERO, 0.3)
			tween.tween_property(p_node, "modulate:a", 0.0, 0.2)
			tween.tween_property(p_node, "scale", Vector2(0.1, 0.1), 0.3)

	if not is_expanded:
		tween.chain().tween_callback(func():
			for p_node in planet_nodes:
				p_node.visible = false
		)
	
	if is_expanded:
		system_expanded.emit(self)

func update_visuals() -> void:
	visible = state.is_visible
	if state.owner_faction != null:
		$Area2D/Sprite2D.modulate = state.owner_faction.def.color

# Переопределяем, чтобы метка не пропадала при выделении
func make_selected() -> void:
	super.make_selected()
	label.visible = true

func deselect() -> void:
	super.deselect()
	label.visible = false
	
func conquer(faction_id):
	GameEvents.trigger_event.emit("system_conquered", self)
	state.set_owner(StrategyGlobals.get_faction(faction_id))
	update_visuals()
	
func _on_area_2d_input_event(_viewport, event, _shape_idx) -> void:
# Сначала обрабатываем выделение
	handle_input_event(event)
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click:
				toggle_planets(!is_expanded)
			else:
				system_selected.emit(self)
		
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.shift_pressed:
				system_move_requested.emit(state)
				get_viewport().set_input_as_handled()

func _on_area_2d_mouse_entered() -> void:
	label.visible = true

func _on_area_2d_mouse_exited() -> void:
	if selection_visual and !selection_visual.visible:
		label.visible = false
