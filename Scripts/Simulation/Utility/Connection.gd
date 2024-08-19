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
var src_output: int

var dest_gate: LogicGate
var dest_input: int

# private variables

# @onready variables

# optional built-in _init() function
func _init(sg: LogicGate, so: int, dg: LogicGate, di: int):
	id = "%s.%s:%s.%s" % [sg.id,so,dg.id,di]
	src_gate = sg
	src_output = so
	dest_gate = dg
	dest_input = di
	is_valid()

# optional built-in _enter_tree() function

# optional built-in _ready() function

# remaining built-in functions

# virtual functions to override

# public functions
func is_valid() -> Result:
	var reasons: Array[String] = []
	if not ( src_gate ):
		reasons.append(["sg","Source Gate does not exist"])
	elif not ( src_gate.has_output( src_output ) ):
		reasons.append(["so","Source Output does not exist"])
	if not ( dest_gate ):
		reasons.append(["dg","Destination Gate does not exist"])
	elif not ( dest_gate.has_input( dest_input ) ):
		reasons.append(["di","Destination Input does not exist"])
	var src_output_type: bool = src_gate.get_output(src_output).data.val.is_cmp()
	var dest_input_type: bool = dest_gate.get_input(dest_input).data.val.is_cmp()
	if not ( src_output_type == dest_input_type ):
		reasons.append(["type","Types are incopatible"])
	if reasons.is_empty():
		return Result.new(OK,[],_id_fmt(is_valid,false))
	else:
		return Result.new(ERR_INVALID_DATA,reasons,_id_fmt(is_valid,true,"Check data"),Result.Types.ERROR)

func is_cmp() -> bool:
	var src_output_type: bool = src_gate.get_output(src_output).data.val.is_cmp()
	var dest_input_type: bool = dest_gate.get_input(dest_input).data.val.is_cmp()
	return ( src_output_type and dest_input_type )

func has_gate(gate: LogicGate) -> bool:
	if src_gate.id == gate.id:
		return true
	if dest_gate.id == gate.id:
		return true
	return false

# private functions
func _id_fmt(function: Callable,fail: bool,reason: String = "") -> String:
	var raw_str := "<{id}> Connection::{function}() - {state}"
	var f := ""
	if fail:
		f = "Fail : %s" % reason
	else:
		f = "Success"
	return raw_str.format({"id":id,"function":function.get_method(),"state":f})

# subclasses
