# The name of the Class
class_name InternalOutput
# The class this class extends
extends Node
# Docstring
## The Internal Output of a Gate
## 
## Holds data of the slot

# Signals

# Enums

# Constants

# @export variables

# public variables
var slot: int # Slot number
var val: Wire # Value

# private variables

# @onready variables

# optional built-in _init() function
func _init(slt: int,n: StringName,s: Wire.Sizes,c: Wire.Colors):
	if n == &"":
		n = &"<undefined.name>"#
		Result.new(ERR_INVALID_DATA,n,_id_fmt(_init,true,"Name is empty"),Result.Types.ERROR)
	slot = slt
	val = Wire.new(s,c)
	name = n

# optional built-in _enter_tree() function

# optional built-in _ready() function

# remaining built-in functions
func _to_string() -> String:
	return "<%s:%s> %s" % [name,slot,val.size]

# virtual functions to override

# public functions
func get_type() -> int:
	return int(val.size)

func is_internal() -> bool:
	return name.begins_with("_")

# private functions
func _id_fmt(function: Callable,fail: bool,reason: String = "") -> String:
	var raw_str := "<{name}:{slot}> InternalInput::{function}() - {state}"
	var f := ""
	if fail:
		f = "Fail : %s" % reason
	else:
		f = "Success"
	return raw_str.format({"name":name,"slot":slot,"function":function.get_method(),"state":f})

# subclasses
