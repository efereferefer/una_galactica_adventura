extends Resource
class_name FactionDef

enum Type {PLAYER, NPC_NEUTRAL, NPC_AGGRESSIVE, PIRATES}

@export var id: int
@export var faction_name: String
@export var color: Color = Color.WHITE
@export var type: Type = Type.NPC_NEUTRAL
@export var is_playable: bool = false
@export var is_active: bool = false
