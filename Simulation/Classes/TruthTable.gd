extends Node
class_name TruthTableArchive

var table: Dictionary = {}

func _init() -> void:
	table = {}

func add_entry(inputs: Array, outputs: Array) -> int:
	if table.has(inputs):
		return ERR_ALREADY_EXISTS
	else:
		table[inputs] = outputs
		return OK

func remove_entry(inputs: Array) -> int:
	if table.has(inputs):
		table.erase(inputs)
		return OK
	else:
		return ERR_DOES_NOT_EXIST

func has_entry(inputs: Array) -> bool:
	return table.has(inputs)

func get_output(inputs: Array) -> Array:
	return table.get(inputs,[])
