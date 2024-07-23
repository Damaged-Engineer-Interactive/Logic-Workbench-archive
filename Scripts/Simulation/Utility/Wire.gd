class_name Wire # The name of the Class
extends Node # The class this class is based on
# Documentation
## Stores the value of a Wire
## 
## Used inside Connection.gd , Circuit.gd , *Gate.gd

# Signals

# Enums
enum Sizes {
	B1=1,
	B2=2,
	B4=4,
	B8=8,
	B16=16,
	B32=32,
	B64=64,
	B128=128,
	B256=256,
	B512=512,
	B1024=1024,
}

# Constants

# @export variables

# public variables
var size: Sizes
var group: StringName

# private variables
var _values: Array[bool] # lsb -> msb

# @onready variables

# optional built-in _init() function
func _init(group: StringName,s: Sizes) -> void:
	add_to_group(group,true)
	size = s
	_values.resize(s) # Resize the "_values" Array to the bit size of the wire
	_values.fill(false) # Set all bits to false

# optional built-in _enter_tree() function

# optional built-in _ready() function

# remaining built-in functions
func _to_string() -> String:
	return "<%4s> %s" % [size,_values]

# virtual functions to override

# public functions
func get_bit(bit: int) -> Result:
	if bit < _values.size():
		return Result.new(OK,_values[bit],"<%s> Wire::get_bit() - Success" % group)
	else:
		return Result.new(ERR_DOES_NOT_EXIST,false,"<%s> Wire::get_bit() - Fail : Out of Bounds" % group)

func set_bit(bit: int, val: bool) -> Result:
	if bit < _values.size():
		_values[bit] = val
		return Result.new(OK,self,"<%s> Wire::set_bit() - Success" % group)
	else:
		return Result.new(ERR_DOES_NOT_EXIST,self,"<%s> Wire::set_bit() - Fail : Out of Bounds" % group)

func get_value() -> Result:
	return Result.new(OK,_values,"<%s> Wire::get_value() - Success" % group)

func set_value(val: Array[bool]) -> Result:
	if val.size() == _values.size():
		_values = val
		return Result.new(OK,self,"<%s> Wire::set_value() - Success" % group)
	else:
		return Result.new(ERR_INVALID_PARAMETER,self,"<%s> Wire::set_value() - Fail : Invalid Size")

func get_bin() -> Result:
	return Result.new(OK,_values,"<%s> Wire::get_bin() - Success" % group)

func get_int() -> Result:
	var res : int = 0
	for i in range(_values.size()):
		res = res << 1
		if _values[i]:
			res += 1
	return Result.new(OK,res,"<%s> Wire::get_int() - Success" % group)

func get_hex() -> Result:
	var tmp : Array[Array] = []
	var tmp_cnt : int = 0 # current tmp slot
	var tmp_int : int = 0 # current increment
	@warning_ignore("integer_division")
	tmp.resize(_values.size()/4)
	for i in range(_values.size()):
		if tmp_int == 3:
			tmp_int = 0
			tmp_cnt += 1
		tmp[tmp_cnt].push_back(_values[i])
		tmp_int += 1
	var hex_string: String = ""
	for i in range(tmp.size()):
		while tmp[i].size() != 4:
			tmp[i].push_front(false)
		var res: Result = _make_hex(tmp[i])
		if res.is_error():
			return res
		else:
			hex_string += res.data
	if hex_string.is_valid_hex_number():
		return Result.new(OK,hex_string,"<%s> Wire::get_hex() - Success" % group)
	else:
		return Result.new(ERR_INVALID_DATA,self,"<%s> Wire::get_hex() - Fail : Invalid Data")

# private functions
func _make_hex(data : Array[bool]) -> Result:
	if not data.size() == 4:
		return Result.new(ERR_INVALID_DATA,null,"<%s> Wire::_make_hex() - Fail : Invalid Data")
	var hex_result: String = ""
	match data:
		[false,false,false,false]: 
			hex_result = "0"
		[false,false,false,true]: 
			hex_result = "1"
		[false,false,true,false]:
			hex_result = "2"
		[false,false,true,true]:
			hex_result = "3"
		[false,true,false,false]:
			hex_result = "4"
		[false,true,false,true]:
			hex_result = "5"
		[false,true,true,false]:
			hex_result = "6"
		[false,true,true,true]:
			hex_result = "7"
		[true,false,false,false]: 
			hex_result = "8"
		[true,false,false,true]: 
			hex_result = "9"
		[true,false,true,false]:
			hex_result = "A"
		[true,false,true,true]:
			hex_result = "B"
		[true,true,false,false]:
			hex_result = "C"
		[true,true,false,true]:
			hex_result = "D"
		[true,true,true,false]:
			hex_result = "E"
		[true,true,true,true]:
			hex_result = "F"
		_:
			return Result.new(ERR_INVALID_PARAMETER,self,"<%s> Wire::_make_hex() - Fail : Invalid Parameter")
	if not hex_result.is_valid_hex_number():
		return Result.new(ERR_INVALID_DATA,self,"<%s> Wire::_make_hex() - Fail : Invalid Data")
	else:
		return Result.new(OK,hex_result,"<%s> Wire::_make_hex() - Success")

# subclasses
