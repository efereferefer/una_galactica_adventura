extends Control

@onready var res_box = %ResBox
var stock_scene = preload("res://game_objects/Entities/StockPile/Stockpile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	clear_all()
	
func show_info():
	# Получаем фракцию игрока
	var player_faction = StrategyGlobals.get_faction(StrategyGlobals.PLAYER_FACTION_ID)
	
	if player_faction:
		_update_resources(player_faction)
		show()
	else:
		print("Error: Player faction not found!")

func _update_resources(faction: FactionState):
	for child in res_box.get_children():
		child.queue_free()
		

	for key in faction.faction_resourses.keys():
		var amount = faction.faction_resourses[key]
		# Показываем только те ресурсы, которых больше 0 (или можно убрать условие, если надо видеть нули)
		# if amount >= 0: 
		var node = stock_scene.instantiate()
		res_box.add_child(node)
		
		var res_name = EconomyGlobals.get_resource_name(key)
		if res_name == null: res_name = key # Фолбэк, если имя не задано
			
		node.setup(res_name, amount)

func clear_all():
	hide()

func swap():
	if visible: clear_all()
	else: show_info()
	
func _on_background_button_pressed():
	clear_all()
