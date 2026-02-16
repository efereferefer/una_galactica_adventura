# globals/EventActions.gd
extends Node

# Функция, имя которой будет в EventDef -> options
func destroy_player_ships(args: Array):
	for system_id in args:
		var system = StrategyGlobals.get_systems_data(system_id)
	
		if system:
		# Создаем копию массива, так как будем удалять элементы в процессе
			var ships = system.ships_in_system.duplicate()
			for ship in ships:
				if ship.get_owner_id() == StrategyGlobals.PLAYER_FACTION_ID:
				# Вызываем сигнал смерти у данных корабля
					ship.died.emit()

func depopulate_system(args):
	var system = StrategyGlobals.get_systems_data(args[0])
	system.population = []
	system.set_owner(StrategyGlobals.get_faction(StrategyGlobals.NEUTRAL_FACTION_ID))

func reveal_nonor_give_jump_drive(args: Array):
	# 1. Устанавливаем глобальный флаг "jump_drive"
	# Теперь ты сможешь проверять его в экшенах или других эвентах через GameEvents.get_flag("jump_drive")
	GameEvents.set_flag("jump_drive")
	print("Событие: Технология прыжкового двигателя получена.")

	# 2. Находим стейт системы Nonor (sys_005)
	var target_sys_id = "sys_005"
	var system_state = StrategyGlobals.get_systems_data(target_sys_id)

	if system_state:

		var map = get_tree().get_first_node_in_group("map")
		if map:
			map.reveal_system(system_state)
			print("Событие: Система ", target_sys_id, " обнаружена.")
	
