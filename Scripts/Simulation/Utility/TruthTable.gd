# The name of the Class
class_name TruthTable
# The class this class extends
extends Node
# Docstring
## A Truth Table .
## 
## ... why are you even reading this ??

# Signals

# Enums

# Constants
const COL := Color.BLACK

# @export variables
@export var table: Dictionary = {}
## The inputs of the Gate.[br]
## Format : [code]StringName Name : InternalInput Node[/code][br]
## Use [code]"_"[/code] if the input should not be visible.
@export var inputs: Dictionary = {}
## The outputs of the Gate.[br]
## Format : [code]StringName Name : InternalOutput Node[/code][br]
## Use [code]"_"[/code] if the output should not be visible.
@export var outputs: Dictionary = {}
# public variables
var id: StringName = &""

# private variables

# @onready variables

# optional built-in _init() function
func _init():
	id = Global.make_id().data

# optional built-in _enter_tree() function

# optional built-in _ready() function

# remaining built-in functions

# virtual functions to override

# public functions

func add_input(i: StringName,s: Wire.Sizes,c: Wire.Colors) -> Result:
	if inputs.has(i):
		return Result.new(ERR_ALREADY_EXISTS,self,"<%s> TruthTable::add_input() - Fail : Already exists" % id,Result.Types.ERROR)
	var next_slt = inputs.size() + 2 # current inputs + 2 ( because of CMP and DESCRIPTION )
	var input := InternalInput.new(next_slt,i,s,c)
	inputs[i] = input
	return Result.new(OK,input,"<%s> TruthTable::add_input() - Success" % id)

func remove_input(i: StringName) -> Result:
	if not inputs.has(i):
		return Result.new(ERR_DOES_NOT_EXIST,self,"<%s> TruthTable::remove_input() - Fail : Does not exist" % id,Result.Types.ERROR)
	inputs.erase(i)
	return Result.new(OK,self,"<%s> TruthTable::remove_input() - Success" % id)

func has_input(i: StringName) -> Result:
	if inputs.has(i):
		return Result.new(OK,self,"<%s> TruthTable::has_input() - Success" % id)
	else:
		return Result.new(ERR_DOES_NOT_EXIST,self,"<%s> TruthTable::has_input() - Fail : Does not exist" % id,Result.Types.ERROR)

func set_input(i: StringName, val: Wire) -> Result:
	if not inputs.has(i):
		return Result.new(ERR_DOES_NOT_EXIST,self,"<%s> TruthTable::set_input - Fail : Does not exist" % id,Result.Types.ERROR)
	inputs[i].val = val
	return Result.new(OK,self,"<%s> TruthTable::set_input() - Success" % id)


func add_output(i: StringName,s: Wire.Sizes,c: Wire.Colors) -> Result:
	if outputs.has(i):
		return Result.new(ERR_ALREADY_EXISTS,self,"<%s> TruthTable::add_output() - Fail : Already exists" % id,Result.Types.ERROR)
	var next_slt = outputs.size() + 2 # current outputs + 2 ( because of CMP and DESCRIPTION )
	var output := InternalOutput.new(next_slt,i,s,c)
	outputs[i] = output
	return Result.new(OK,self,"<%s> TruthTable::add_output() - Success" % id)

func remove_output(i: StringName) -> Result:
	if not outputs.has(i):
		return Result.new(ERR_DOES_NOT_EXIST,self,"<%s> TruthTable::remove_output() - Fail : Does not exist" % id,Result.Types.ERROR)
	outputs.erase(i)
	return Result.new(OK,self,"<%s> TruthTable::remove_output() - Success" % id)

func has_output(i: StringName) -> Result:
	if outputs.has(i):
		return Result.new(OK,self,"<%s> TruthTable::has_output() - Success" % id)
	else:
		return Result.new(ERR_DOES_NOT_EXIST,self,"<%s> TruthTable::has_output() - Fail : Does not exist" % id,Result.Types.ERROR)


func add_entry(inp: Dictionary,out: Dictionary) -> Result:
	if table.has(inp):
		return Result.new(ERR_ALREADY_EXISTS,self,"<%s> TruthTable::add_entry() - Fail : Already exists" % id,Result.Types.ERROR)
	table[inp] = out
	return Result.new(OK,self,"<%s> TruthTable::add_entry() - Success" % id)

func remove_entry(inp: Dictionary) -> Result:
	if not table.has(inp):
		return Result.new(ERR_DOES_NOT_EXIST,self,"<%s> TruthTable::remove_entry() - Fail : Does not exist" % id,Result.Types.ERROR)
	table.erase(inp)
	return Result.new(OK,self,"<%s> TruthTable::remove_entry() - Success" % id)

func has_entry(inp: Dictionary) -> Result:
	if table.has(inp):
		return Result.new(OK,self,"<%s> TruthTable::has_entry() - Success" % id)
	return Result.new(ERR_DOES_NOT_EXIST,self,"<%s> TruthTable::has_entry() - Fail : Does not exist" % id,Result.Types.ERROR)

func merge(val: TruthTable) -> Result:
	table = val.table
	return Result.new(OK,self,"<%s> TruthTable::merge() - Success" % id)

func copy() -> Result:
	var res = TruthTable.new()
	res.table = self.table
	res.inputs = self.inputs
	res.outputs = self.outputs
	return Result.new(OK,res,"<%s> TruthTable::copy() - Success" % id)

func get_outputs(inp: Dictionary) -> Result:
	if table.has(inp):
		var res = table[inp]
		return Result.new(OK,res,"<%s> TruthTable::get_outputs() - Success" % id)
	return Result.new(OK,self,"<%s> TruthTable::get_outputs() - Fail : Does not exist" % id,Result.Types.ERROR)

func is_emtpy() -> bool:
	if not table == {}:
		return false
	if not inputs == {}:
		return false
	if not outputs == {}:
		return false
	return true

# private functions

# subclasses
