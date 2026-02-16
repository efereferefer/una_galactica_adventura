class_name GameAction extends Resource

@export var id: String = "action_generic"
@export var text: String = "Do something"
@export var priority: int = 0

# --- Виртуальные методы (упрощенные) ---

# Видима ли кнопка? 
# target: то, на что кликнули ПКМ (StarSystemNode, ShipUnit)
func is_possible(target: Node,selected: Node) -> bool:
	return false

# Что происходит при нажатии
func execute(target: Node, selected: Node = null) -> void:
	print("Base action executed")

# Динамический текст
func get_display_text(target: Node) -> String:
	return text
