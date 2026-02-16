extends SelectableEntity
class_name PlanetNode

var state: PlanetState
@onready var label: Label = $Label

signal planet_info_requested(state: PlanetState)

func setup(new_state: PlanetState) -> void:
	state = new_state
	label.text = state.name
	update_visuals() 
	deselect()
	
func update_visuals() -> void:
	if state.owner_faction != null:
		$Area2D/Sprite2D.modulate = state.owner_faction.def.color
		
func _on_area_2d_input_event(_viewport, event, _shape_idx) -> void:
	handle_input_event(event)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click:
				# Тут можно вызывать окно инфо о планете
				pass

func make_selected() -> void:
	super.make_selected()
	label.visible = true

func deselect() -> void:
	super.deselect()
	label.visible = false
	
func conquer(faction_id):
	GameEvents.trigger_event.emit("planet_conquered", self)
	state.set_owner(StrategyGlobals.get_faction(faction_id))
	update_visuals()

func _on_area_2d_mouse_entered() -> void: label.visible = true
func _on_area_2d_mouse_exited() -> void:
	if selection_visual and !selection_visual.visible:
		label.visible = false
