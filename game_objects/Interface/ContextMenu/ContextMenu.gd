extends PanelContainer
class_name ContextMenu

@onready var container = $VBoxContainer

func _ready() -> void:
	hide()

func open(screen_position: Vector2, options: Array[Dictionary]):
	_clear_buttons()
	
	# 1. Создаем кнопки
	for opt in options:
		var type = opt["type"]
		
		if type == "Label":
			var lbl = Label.new()
			lbl.text = opt["text"]
		
		# ВАЖНО: В Godot 4 свойство называется horizontal_alignment
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER # Или LEFT
			lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		# Визуальный стиль: сделаем текст серым, чтобы понятно было, что жать нельзя
			lbl.modulate = Color(0.7, 0.7, 0.7) 
		
		# Если нужно добавить отступ сверху/снизу (опционально)
		# В Godot 4 через код это делается так: (но обычно VBox сам справляется)
		# lbl.custom_minimum_size.y = 30 
		
			container.add_child(lbl)
		if type == "Button":
			var btn = Button.new()
			btn.text = opt["text"]
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		# Немного визуального стиля кнопкам, чтобы не слипались
		# Можно пропустить, если настраиваешь тему
			btn.add_theme_constant_override("h_separation", 10) 
		
			btn.pressed.connect(func(): 
				opt["callback"].call()
				close()
			)
			container.add_child(btn)
		if type == "Separator":
			var sep = HSeparator.new()
			container.add_child(sep)
	
	# 2. Сброс размера и позиционирование
	# Сначала показываем (но прозрачно? нет, просто show), чтобы Godot мог посчитать размеры
	show()
	
	# ВАЖНО: Сбрасываем размер до минимального (по размеру кнопок)
	# В Godot 4 size = Vector2.ZERO заставляет контейнер пересчитаться под контент
	size = Vector2.ZERO 
	
	# Форсируем обновление лэйаута немедленно, чтобы получить правильный size прямо сейчас
	# (Иначе size обновится только в следующем кадре)
	_update_layout_and_position(screen_position)

func _update_layout_and_position(target_pos: Vector2):
	# Принудительно обновляем контейнеры (костыль, но надежный для мгновенного UI)
	# Обычно достаточно reset_size(), но иногда нужно пнуть layout
	queue_sort() 
	
	# Берем размер экрана
	var viewport_rect = get_viewport_rect()
	var visible_rect = viewport_rect.size
	
	var final_pos = target_pos
	
	# --- ПРОВЕРКА ГРАНИЦ ---
	
	# Проверяем правую границу
	# Если (позиция X + ширина меню) вылезает за экран -> сдвигаем влево на ширину меню
	if final_pos.x + size.x > visible_rect.x:
		final_pos.x -= size.x
		
	# Проверяем нижнюю границу
	# Если (позиция Y + высота меню) вылезает за низ -> сдвигаем вверх на высоту меню
	if final_pos.y + size.y > visible_rect.y:
		final_pos.y -= size.y
	
	# Защита от "улета" в минус (верхний левый угол), если меню больше экрана (мало ли)
	final_pos.x = max(0, final_pos.x)
	final_pos.y = max(0, final_pos.y)
	
	global_position = final_pos

func close():
	hide()
	_clear_buttons()

func _clear_buttons():
	for child in container.get_children():
		child.queue_free()

func _input(event):
	if event is InputEventMouseButton and event.pressed and visible:
		# get_global_rect() - это прямоугольник нашего меню на экране
		if not get_global_rect().has_point(event.global_position):
			close()
			# ВАЖНО: Мы НЕ делаем accept_event(), чтобы клик прошел сквозь 
			# и мог вызвать, например, выделение другого юнита или новое меню.
func get_header(target_object):
	var options: Array[Dictionary] = []
	
	if target_object is StarSystemNode:
		options.append({ "type": "Label", "text": target_object.state.name })
	elif target_object is ShipUnit:
		options.append({ "type": "Label", "text": target_object.data.ship_name })
		options.append({ "type": "Label", "text": "Action points: %d/%d" % [target_object.data.current_aсtion_points, target_object.data.max_action_points] })
	elif target_object is PlanetNode:
		options.append({ "type": "Label", "text": target_object.state.name})
	options.append({ "type": "Separator" })
	return options
