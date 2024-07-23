# The name of the Class
class_name Connection
# The class this class extends
extends Node

# Docstring
## Holds a Connection between 2 Gates
## 
## Contains refference for a Circuit, 2 LogicGates with one Input / Output of it and a Wire

# Signals

# Enums

# Constants

# @export variables

# public variables
var id: StringName

var src_gate: LogicGate
var src_output: StringName = ""

var dest_gate: LogicGate
var dest_input: StringName = ""

# private variables
var _wire: Wire
var _valid: bool

# @onready variables

# optional built-in _init() function
func _init(sg: LogicGate,so: StringName,dg: LogicGate,di: StringName) -> void:
	src_gate = sg
	src_output = so
	dest_gate = dg
	dest_input = di
	id = Global.make_id().data
	_is_valid()
	var size: Wire.Sizes = src_gate.get_output(src_output).data.size
	_wire = Wire.new(id, size)

# optional built-in _enter_tree() function

# optional built-in _ready() function

# remaining built-in functions

# virtual functions to override

# public functions

# private functions
func _is_valid() -> Result:
	_valid = true
	if src_gate:
		if src_gate.has_output(src_output).is_error():
			_valid = false
	else:
		_valid = false
	
	if dest_gate:
		if dest_gate.has_output(dest_input).is_error():
			_valid = false
	else:
		_valid = false
	if _valid:
		return Result.new(OK,self,"<%s> Connection::_is_valid() - Success")
	return Result.new(ERR_DOES_NOT_EXIST,self,"<%s> Connection::_is_valid() - Fail : Invalid Parameters" % id)

# subclasses
