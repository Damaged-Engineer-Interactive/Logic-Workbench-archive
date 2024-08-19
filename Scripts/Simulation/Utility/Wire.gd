# The name of the Class
class_name Wire
# The class this class extends
extends Node
# Docstring
## Stores the value of a Wire / Connection
## 
## Used inside Connection.gd , Circuit.gd , *Gate.gd

# Signals

# Enums
enum States {
	UNDEFINED=0,
	CMP=1,
	FALSE=2,
	TRUE=3,
}

enum Colors {
	UNDEFINED=0,
	CMP=1,
	MAGENTA=2,
	RED=3,
	ORANGE=4,
	GREEN=5,
	CYAN=6,
}
enum Sizes {
	CMP=0, # Component Wire
	BIT1=1, # 1 Bit
	BIT2=2,
	BIT4=4,
	BIT8=8,
	BIT16=16,
	BIT32=32,
	BIT64=64,
	BIT128=128,
	BIT256=256,
	BIT512=512,
	BIT1024=1024, # 1024 Bits
	BYTE1=8, # 1 Byte = 8 Bits
	BYTE2=16,
	BYTE4=32,
	BYTE8=64,
	BYTE16=128,
	BYTE32=256,
	BYTE64=512,
	BYTE128=1024,
	BYTE256=2048,
	BYTE512=4096,
	BYTE1024=8192, # 1024 Bytes = 8192 Bits
}

# Constants
const COLORS: Dictionary = { # f = false | t = true | c = cmp | u = undefined
	"0f": LogicGate.CLR_UN,
	"0t": LogicGate.CLR_UN,
	"1f": LogicGate.CLR_CMP,
	"1t": LogicGate.CLR_CMP,
	"2f": Color.DARK_MAGENTA,
	"2t": Color.MAGENTA,
	"3f": Color.DARK_RED,
	"3t": Color.RED,
	"4f": Color.DARK_ORANGE,
	"4t": Color.ORANGE,
	"5f": Color.DARK_GREEN,
	"5t": Color.GREEN,
	"6f": Color.DARK_CYAN,
	"6t": Color.CYAN,
}

# @export variables

# public variables
## The bitsize of the Wire
var size: Sizes
## The color theme of the Wire
var theme := Colors.RED
## The current color of the Wire.[br]
## DO NOT SET MANUALY
var color: Color:
	get = _get_color

# private variables
var _values: Array[bool] # lsb -> msg
var _cmp: Array[Wire] # first component -> last component

# @onready variables

# optional built-in _init() function
func _init(s: Sizes,c: Colors) -> void:
	size = s
	theme = c
	_values.resize(size)
	if is_normal(): # if normal :
		_values.fill(false) # Set all bits to false

# optional built-in _enter_tree() function

# optional built-in _ready() function

# remaining built-in functions
func _to_string() -> String:
	return "<%s> %s" % [_match_size(size),_values]

# virtual functions to override

# public functions
# || Type Related ||
## Check if the wire is a "normal" Wire[br]
## Returns the oposite of [code]is_cmp()[/code]
func is_normal() -> bool:
	return size != Sizes.CMP

## Check if the wire is a "component" Wire[br]
## Returns the oposite of [code]is_normal()[/code]
func is_cmp() -> bool:
	return size == Sizes.CMP

## Check if any of the Wire's values is true.
func is_true() -> States:
	if is_cmp():
		return States.CMP
	var res: bool = false
	for val: bool in _values:
		res = res or val
	if res == true:
		return States.TRUE
	elif res == false:
		return States.FALSE
	else:
		return States.UNDEFINED

# || bit operations ||
## get a specific bit of the Wire
func get_bit(bit: int) -> Result:
	if is_cmp():
		return Result.new(ERR_INVALID_DATA,null,_id_fmt(get_bit,true,"Unsupported in 'CMP' mode"),Result.Types.ERROR)
	if bit < _values.size():
		return Result.new(OK,_values[bit],_id_fmt(get_bit,false))
	else:
		return Result.new(ERR_DOES_NOT_EXIST,null,_id_fmt(get_bit,true,"Out of Bounds"),Result.Types.ERROR)

## Set a specific bit of the Wire
func set_bit(bit: int,val: bool) -> Result:
	if is_cmp():
		return Result.new(ERR_INVALID_DATA,null,_id_fmt(set_bit,true,"Unsupported in 'CMP' mode"),Result.Types.ERROR)
	if bit < _values.size():
		_values[bit] = val
		return Result.new(OK,null,_id_fmt(set_bit,false))
	else:
		return Result.new(ERR_DOES_NOT_EXIST,null,_id_fmt(set_bit,true,"Out of Bounds"),Result.Types.ERROR)

# || value operations ||
## get the value of the Wire
func get_value() -> Result:
	if is_cmp():
		return Result.new(ERR_INVALID_DATA,null,_id_fmt(get_value,true,"Unsupported in 'CMP' mode"),Result.Types.ERROR)
	return Result.new(OK,_values,_id_fmt(get_value,false))

## set the value of the Wire
func set_value(val: Array[bool]) -> Result:
	if is_cmp():
		return Result.new(ERR_INVALID_DATA,null,_id_fmt(set_value,true,"Unsupported in 'CMP' mode"),Result.Types.ERROR)
	_values = val
	return Result.new(OK,null,_id_fmt(set_value,false))

# || cmp operations ||
## Add a component to the Wire
func add_cmp(val: Array[Wire]) -> Result:
	if is_normal():
		return Result.new(ERR_INVALID_DATA,null,_id_fmt(add_cmp,true,"Unsupported in 'normal' mode"),Result.Types.ERROR)
	_cmp.append(val)
	return Result.new(OK,null,_id_fmt(add_cmp,false))

## Get all added components
func get_cmp() -> Result:
	if is_normal():
		return Result.new(ERR_INVALID_DATA,null,_id_fmt(get_cmp,true,"Unsupported in 'normal' mode"),Result.Types.ERROR)
	return Result.new(OK,_cmp,_id_fmt(get_cmp,false))

## Set all added components
func set_cmp(val: Array[Wire]) -> Result:
	if is_normal():
		return Result.new(ERR_INVALID_DATA,null,_id_fmt(set_cmp,true,"Unsupported in 'normal' mode"),Result.Types.ERROR)
	_cmp = val
	return Result.new(OK,null,_id_fmt(set_cmp,false))

# || wire operations ||
## Compare this wire with another wire
func compare(val: Wire) -> bool:
	if not self.size == val.size:
		return false
	if not self._values == val._values:
		return false
	if not self._cmp == val._cmp:
		return false
	return true

# private functions
func _id_fmt(function: Callable,fail: bool,reason: String = "") -> String:
	var raw_str := "Wire::{function}() - {state}"
	var f := ""
	if fail:
		f = "Fail : %s" % reason
	else:
		f = "Success"
	return raw_str.format({"function":function.get_method(),"state":f})

func _get_color() -> Color:
	if is_true() == States.CMP:
		return LogicGate.CLR_CMP
	elif is_true() == States.UNDEFINED:
		return LogicGate.CLR_UN
	var clr_str = str(theme)
	if is_true() == States.TRUE:
		clr_str += "t"
	elif is_true() == States.FALSE:
		clr_str += "f"
	self.color = COLORS[clr_str]
	return color

func _match_size(s: Sizes) -> String:
	match s:
		Sizes.CMP:
			return "CMP"
		Sizes.BIT1:
			return "BIT1"
		Sizes.BIT2:
			return "BIT2"
		Sizes.BIT4:
			return "BIT4"
		Sizes.BIT8:
			return "BIT8"
		Sizes.BIT16:
			return "BIT16"
		Sizes.BIT32:
			return "BIT32"
		Sizes.BIT64:
			return "BIT64"
		Sizes.BIT128:
			return "BIT128"
		Sizes.BIT256:
			return "BIT256"
		Sizes.BIT512:
			return "BIT512"
		Sizes.BIT1024:
			return "BIT1024"
		Sizes.BYTE1:
			return "BYTE1"
		Sizes.BYTE2:
			return "BYTE2"
		Sizes.BYTE4:
			return "BYTE4"
		Sizes.BYTE8:
			return "BYTE8"
		Sizes.BYTE16:
			return "BYTE16"
		Sizes.BYTE32:
			return "BYTE32"
		Sizes.BYTE64:
			return "BYTE64"
		Sizes.BYTE128:
			return "BYTE128"
		Sizes.BYTE256:
			return "BYTE256"
		Sizes.BYTE512:
			return "BYTE512"
		Sizes.BYTE1024:
			return "BYTE1024"
		_:
			return str(s)

# subclasses
