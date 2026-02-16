extends Node

const SAVE_PATH = "user://savegame.tres"

func save_game():
	var save_data = SavedGame.new()
	
	# 1. Упаковка простых данных
	save_data.current_round = StrategyGlobals.current_round
	save_data.active_faction_id = StrategyGlobals.active_faction_id
	save_data.ship_counter = StrategyGlobals._ship_counter
	save_data.timestamp = Time.get_datetime_string_from_system()
	
	# 2. Упаковка сложных данных (копируем словари)
	save_data.factions = StrategyGlobals.factions
	save_data.systems_data = StrategyGlobals.systems_data
	
	# 3. Запись на диск
	var error = ResourceSaver.save(save_data, SAVE_PATH)
	if error != OK:
		print("Ошибка сохранения: ", error)
	else:
		print("Игра сохранена в ", SAVE_PATH)

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("Файл сохранения не найден!")
		return

	var save_data = ResourceLoader.load(SAVE_PATH)
	if not save_data is SavedGame: # Проверка на битый файл
		print("Ошибка: Некорректный файл сохранения")
		return
		
	print("Загрузка сохранения от: ", save_data.timestamp)
	
	# 1. Очистка текущего состояния (важно!)
	_clear_current_game_state()
	
	# 2. Распаковка данных обратно в глобалку
	StrategyGlobals.current_round = save_data.current_round
	StrategyGlobals.active_faction_id = save_data.active_faction_id
	StrategyGlobals._ship_counter = save_data.ship_counter
	
	StrategyGlobals.factions = save_data.factions
	StrategyGlobals.systems_data = save_data.systems_data
	
	# 3. МАГИЯ ВОССТАНОВЛЕНИЯ ССЫЛОК (Post-Load Fixup)
	# При сохранении ресурсы сохраняются, но перекрестные ссылки могут потеряться 
	# или дублироваться, если они не экспортированы. Восстановим их вручную.
	_restore_references()
	
	# 4. Перезагрузка карты
	# Мы просим карту перерисовать всё с нуля на основе новых данных
	var map = get_tree().get_first_node_in_group("map")
	if map:
		map.rebuild_world_from_save()
		
	print("Загрузка завершена!")

func _clear_current_game_state():
	# Сброс очередей и состояний, если нужно
	pass

func _restore_references():
	# Проходимся по всем системам
	for sys_id in StrategyGlobals.systems_data:
		var sys = StrategyGlobals.systems_data[sys_id]
		
		# 1. Восстанавливаем владельца системы
		# (Если owner_faction не сохранился, можно восстановить его по ID, если добавить faction_id в StarSystemState)
		# Но пока ResourceSaver должен справиться сам, если FactionState лежит внутри saved_data.factions
		
		# 2. Восстанавливаем связи кораблей
		# Корабли лежат внутри массива sys.ships_in_system.
		# Нам нужно сказать каждому кораблю: "Ты сейчас в этой системе".
		for ship in sys.ships_in_system:
			ship.current_system = sys # Восстанавливаем ссылку на систему
			ship.owner = StrategyGlobals.get_faction(ship.get_owner_id()) # Обновляем ссылку на фракцию (на всякий случай)
			
		# 3. Восстанавливаем связи планет
		for planet in sys.planets:
			if planet.owner_faction:
				# Убеждаемся, что ссылка ведет на актуальный объект фракции из загруженного словаря
				planet.owner_faction = StrategyGlobals.get_faction(planet.owner_faction.id)
