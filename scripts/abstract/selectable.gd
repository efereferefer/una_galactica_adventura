class_name SelectableEntity extends Node2D

signal selected(object: SelectableEntity)

var selection_visual: Node2D

func _ready() -> void:
	# Ищем узел выделения (рамку)
	if has_node("%Select"):
		selection_visual = get_node("%Select")
	elif has_node("Select"):
		selection_visual = get_node("Select")
	deselect()

func make_selected() -> void:
	if selection_visual: 
		selection_visual.visible = true

func deselect() -> void:
	if selection_visual: 
		selection_visual.visible = false

func request_selection() -> void:
	selected.emit(self)

func handle_input_event(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			request_selection()
