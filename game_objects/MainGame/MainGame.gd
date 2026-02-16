# scripts/scene_scripts/main_game.gd
extends Node2D

# Ссылки на UI. 
# Убедись, что TurnButton тоже имеет "Unique Name" (%) в дереве сцен, 
# либо используй полный путь ($CanvasLayer/Panel/...).
@onready var turn_label: Label = %TurnLabel
@onready var turn_button: Button = %TurnButton # Сделай кнопку уникальной или укажи путь
@onready var map: Node2D = $Map

var current_turn: int = 1

func _ready() -> void:
	# Инициализация UI
	update_turn_ui()
	
	# Подключаем сигнал нажатия кнопки
	turn_button.pressed.connect(advance_turn)

func _unhandled_input(event: InputEvent) -> void:
	# Проверка нажатия ПРОБЕЛА
	# "ui_accept" по умолчанию в Godot это Enter и Space.
	# Если хочешь только Space, создай Action "next_turn" в настройках проекта.
	if event.is_action_pressed("next_turn"):
		advance_turn()

# Основная функция смены хода
func advance_turn() -> void:
	current_turn += 1
	print("--- НАЧАЛО ХОДА %d ---" % current_turn)
	
	# 1. Обновляем UI
	update_turn_ui()
	
	# 2. Сообщаем карте и игровому миру, что наступил новый ход
	if map.has_method("process_turn"):
		map.process_turn(current_turn)

func update_turn_ui() -> void:
	turn_label.text = "Ход: %d" % current_turn


func _on_faction_button_pressed():
	%FactionMenu.swap()


func _on_save_button_pressed():
	SaveManager.save_game()


func _on_load_button_pressed():
	SaveManager.load_game()
