class_name SavedGame extends Resource

@export var game_version: String = "0.1"
@export var timestamp: String = ""

# Глобальные переменные
@export var current_round: int = 1
@export var active_faction_id: int = 0
@export var ship_counter: int = 0

# Основные данные (Словари ресурсов сохраняются отлично)
@export var factions: Dictionary = {}
@export var systems_data: Dictionary = {}

# Примечание: Мы не сохраняем ship_templates, planet_defs и infrastructure,
# так как это статические данные из файлов игры, они не меняются.
