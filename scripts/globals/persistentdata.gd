extends Node

# Completely referenced from Mostly Mad Productions on YouTube
# No reason to reinvent wheels

# A dictionary is basically an array but instead of numbers its words. For an application like this, its pretty damn handy.
var data : Dictionary

func _generated_entry_name(node_path_identifier: String) -> String:
	return str(get_tree().current_scene.get_path(), "/", node_path_identifier)

func has_data_entry(node_path_identifier: String) -> bool:
	if data.has(_generated_entry_name(node_path_identifier)):
		return true
	return false

func has_data_value(node_path_identifier: String, value_name: String) -> bool:
	if has_data_entry(node_path_identifier):
		if get_data_entry(node_path_identifier).has(value_name):
			return true
	return false

func get_data_entry(node_path_identifier: String) -> Dictionary:
	if has_data_entry(node_path_identifier):
		return data[_generated_entry_name(node_path_identifier)]
	return {}

func get_data_value(node_path_identifier: String, value_name: String):
	if has_data_value(node_path_identifier, value_name):
		return get_data_entry(node_path_identifier)[value_name]
	return {}

func store_data_entry(node_path_identifier: String, value: Dictionary) -> void:
	data[_generated_entry_name(node_path_identifier)] = value

func store_data_value(node_path_identifier: String, value_name: String, value) -> void:
	if has_data_entry(node_path_identifier):
		get_data_entry(node_path_identifier)[value_name] = value
	else:
		store_data_entry(node_path_identifier, {value_name: value})

func remove_data_entry(node_path_identifier: String) -> void:
	if has_data_entry(node_path_identifier):
		data.erase(_generated_entry_name(node_path_identifier))

func remove_data_value(node_path_identifier: String, value_name: String) -> void:
	if has_data_value(node_path_identifier, value_name):
		get_data_entry(node_path_identifier).erase(value_name)
		if get_data_entry(node_path_identifier).size() == 0:
			remove_data_entry(node_path_identifier)
