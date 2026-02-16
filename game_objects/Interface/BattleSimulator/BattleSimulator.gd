class_name BattleSimulator extends Control

signal battle_concluded(results: Dictionary)

@onready var battle_container = %BattleContainer
@onready var player_label = %PlayerLabel
@onready var enemy_label = %EnemyLabel
@onready var result_container= %ResultContainer
@onready var result_label = %ResultLabel

var _allies: Array[ShipState]
var _enemies: Array[ShipState]
var _victory: bool

func _ready() -> void:
	Transport.transport_battle_initiate.connect(begin_battle)
	visible = false

func begin_battle(allies: Array[ShipState], enemies: Array[ShipState]):
	_allies = allies
	_enemies = enemies
	
	visible = true
	battle_container.visible = true
	result_container.visible = false
	
	var allies_power = 0
	for ship in _allies:
		allies_power += ship.power
		
	var enemies_power = 0
	for ship in _enemies:
		enemies_power += ship.power
		
	player_label.text = "Our power: %d" % [allies_power]
	enemy_label.text = "Enemy power: %d" % [enemies_power]

func _on_battle_button_pressed() -> void:
	battle_container.visible = false
	result_container.visible = true
	
	var allies_power = 0
	for ship in _allies: allies_power += ship.power
	
	var enemies_power = 0
	for ship in _enemies: enemies_power += ship.power
	
	if allies_power > enemies_power:
		result_label.text = "We won!"
		_victory = true
	else: 
		result_label.text = "We lost"
		_victory = false

func _on_exit_button_pressed() -> void:
	visible = false
	
	var results = {
		"winners": _allies if _victory else _enemies,
		"losers": _enemies if _victory else _allies
	}
	
	var winners = results["winners"] as Array[ShipState]
	var losers = results["losers"] as Array[ShipState]
	
	# Обрабатываем победителей (снимаем ОД)
	for ship_state in winners:
		ship_state.catch_battle_result(true)
		
	# Обрабатываем проигравших (уничтожаем)
	for ship_state in losers:
		ship_state.died.emit() # Вызываем смерть на узле, который вызовет сигнал для карты


func _on_background_button_pressed() -> void:
	visible = false
