extends SelectableEntity # <--- Наследуемся
class_name ShipUnit

var data: ShipState
var current_system: StarSystemState

signal ship_info_requested(ship_data: ShipState)
signal ship_died(ship_unit: ShipUnit) # <-- НОВЫЙ СИГНАЛ

func initialize(start_system: StarSystemState) -> void:
	current_system = start_system
	position = start_system.map_position + Vector2(20, -20)
	update_visuals()
	
	deselect()

func update_visuals() -> void:
	if data.owner != null:
		$Area2D/Sprite2D.modulate = data.owner.def.color

func setup(ship_data: ShipData,fation_data: FactionState = null) -> void:
	data = ShipState.new(ship_data,fation_data)
	data.died.connect(die)
	

func _on_area_2d_input_event(_viewport, event, _shape_idx) -> void:
	handle_input_event(event)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			
			request_selection() # <--- Сообщаем о желании быть выбранным
			
			if event.double_click:
				ship_info_requested.emit(data)
				get_viewport().set_input_as_handled()
			else:
				get_viewport().set_input_as_handled()
				
func has_action_points()->bool:
	return data.has_action_points()
	
func move():
	data.deduct_action_point()
	
func next_turn(round: int):
	pass

	
func get_owner_id() -> int:
	return data.get_owner_id()

func get_power()->int:
	return data.power
	
func die():
	ship_died.emit(self) # <-- ИЗМЕНЕНИЕ: Просто испускаем сигнал

func fog_update():
	visible = current_system.is_visible
