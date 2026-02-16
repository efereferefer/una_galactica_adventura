# game_objects/Interface/EventWindow/EventWindow.gd
extends Control

@onready var title_label = %Title
@onready var desc_label = %Description
@onready var button_container = %ButtonContainer

func _init():
	hide()
	
func setup(event_state: EventState):
	add_to_group("event_window")
	title_label.text = event_state.title
	desc_label.text = event_state.description
	
	# Очищаем старые кнопки
	for child in button_container.get_children():
		child.queue_free()
	
	# Создаем новые кнопки из словаря options
	# options = { "option_1": {"text": "Понял, ухожу", "function": "destroy_player_ships", "args": ["sys_007"]} }
	for opt_id in event_state.options:

		var btn = Button.new()
		btn.text = opt_id["text"]
		
		# При нажатии вызываем функцию из EventActions
		btn.pressed.connect(func():
			EventActions.call(opt_id["function"], opt_id["args"])
			hide()
		)
		button_container.add_child(btn)
	
	show()
