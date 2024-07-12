extends Node
class_name TruthTable

var table: Dictionary = {}
var inputs: Dictionary = {} # Name : Wire ( Wire is for the size )
var outputs: Dictionary = {} # Name : Wire ( Wire is for the size )

func _init() -> void:
	table = {}

func add_input(n: String,w: Wire) -> Result:
	if inputs.has(n):
		return Result.new(ERR_ALREADY_EXISTS,null)
	else:
		inputs[n] = w
		return Result.new(OK,null)

func has_input(n: String) -> Result:
	if inputs.has(n):
		return Result.new(OK,null)
	else:
		return Result.new(ERR_DOES_NOT_EXIST,null)

func add_output(n: String,w: Wire) -> Result:
	if outputs.has(n):
		return Result.new(ERR_ALREADY_EXISTS,null)
	else:
		outputs[n] = w
		return Result.new(OK,null)

func has_output(n: String) -> Result:
	if outputs.has(n):
		return Result.new(OK,null)
	else:
		return Result.new(ERR_DOES_NOT_EXIST,null)

func merge(val: TruthTable) -> Result:
	table = val.table
	return Result.new(OK,null)

func add_entry(inp: Dictionary,out: Dictionary) -> Result:
	var val_in: Dictionary = convert_wire_dict(inp)
	var val_out: Dictionary = convert_wire_dict(out)
	if table.has(val_in):
		return Result.new(ERR_ALREADY_EXISTS,null)
	if validate_entry(val_in,val_out).is_error():
		return Result.new(ERR_INVALID_DATA,null)
	else:
		table[inp] = out
		return Result.new(OK,null)

func validate_entry(inp: Dictionary, out: Dictionary) -> Result:
	for input in inp.keys():
		if has_input(input).is_error():
			return Result.new(ERR_INVALID_DATA,false)
	for output in out.keys():
		if has_output(output).is_error():
			return Result.new(ERR_INVALID_DATA,false)
	return Result.new(OK,true)

func remove_entry(inp: Dictionary) -> Result:
	var val: Dictionary = convert_wire_dict(inp)
	if table.has(val):
		table.erase(val)
		return Result.new(OK,null)
	else:
		return Result.new(ERR_DOES_NOT_EXIST,null)

func get_outputs(inp: Dictionary) -> Result:
	var val: Dictionary = convert_wire_dict(inp)
	if table.has(val):
		var res: Dictionary = convert_dict_wire(table[val])
		return Result.new(OK,res)
	else:
		return Result.new(ERR_DOES_NOT_EXIST,null)

func convert_wire_dict(val: Dictionary) -> Dictionary: # Name : Wire -> Name : Array[bool]
	var res: Dictionary = {}
	for key in val.keys():
		res[key] = val[key].copy().unwrap()
	return res

func convert_dict_wire(val: Dictionary) -> Dictionary: # Name : Array[bool] -> Name : Wire
	var res: Dictionary = {}
	for key in val.keys():
		var w = Wire.new(val[key].size())
		w.set_value(val[key])
	return res

func _to_string():
	return str(table)
