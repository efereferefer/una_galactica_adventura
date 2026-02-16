extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func load_stuff_by_id_from_single_directory(path: String):
	var ship_components: Dictionary = {}
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() and (file_name.ends_with(".tres") or file_name.ends_with(".remap")):
				var res = load(path + file_name.replace(".remap", ""))
				ship_components[res.id] = res
			file_name = dir.get_next()
	return ship_components

func _load_actions_automatically(path: String):
	var registered_actions: Array[GameAction] = []
	_recursive_load_actions_from(path,registered_actions)
	return registered_actions
	#

func _recursive_load_actions_from(path: String,registered_actions):
	var dir = DirAccess.open(path)
	if not dir: return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
		var full_path = path.path_join(file_name)
		if dir.current_is_dir():
			_recursive_load_actions_from(full_path,registered_actions)
		elif file_name.ends_with(".tres") or file_name.ends_with(".remap"):
			var res = load(full_path.replace(".remap", ""))
			if res is GameAction:
				registered_actions.append(res)
		file_name = dir.get_next()
