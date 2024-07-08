extends Node
class_name Wire

enum Sizes {S1=1,S2=2,S4=4,S8=8,S16=16,S32=32,S64=64,S128=128,S256=256,S512=512,S1024=1024}
enum Types {BIT,INT,HEX}

var size: Sizes = Sizes.S1
var values: Array[bool] = []

func _init(s: Sizes) -> void:
	size = s
	values.resize(s)
	values.fill(false)

func get_bit(bit: int) -> Result:
	if bit < size:
		return Result.new(OK,values[bit])
	else:
		return Result.new(ERR_INVALID_PARAMETER,null)

func set_bit(bit: int,val: bool) -> Result:
	if bit < size:
		values[bit] = val
		return Result.new(OK,null)
	else:
		return Result.new(ERR_INVALID_PARAMETER,null)

func copy() -> Result:
	return Result.new(OK,values)

func merge(val: Wire) -> Result:
	values = val.values
	return Result.new(OK,null)

func set_value(val: Array[bool]) -> Result:
	if val.size() == values.size():
		values = val
		return Result.new(OK,null)
	else:
		return Result.new(ERR_INVALID_PARAMETER,null)

func get_value(type: Types) -> Result:
	return convert_value(values,type)

func convert_value(val: Array[bool], type: Types) -> Result:
	match type:
		Types.BIT:
			return Result.new(OK,val)
		Types.INT:
			var res : int = 0
			for i in range(val.size()):
				res = res << 1
				if values[i]:
					res += 1
			return Result.new(OK,res)
		Types.HEX:
			var tmp : Array[Array] = []
			var tmp_cnt : int = 0 # current tmp slot
			var tmp_int : int = 0 # current increment
			@warning_ignore("integer_division")
			tmp.resize(val.size()/4)
			for i in range(val.size()):
				if tmp_int == 3:
					tmp_int = 0
					tmp_cnt += 1
				tmp[tmp_cnt].push_back(val[i])
				tmp_int += 1
			var hex_string: String = ""
			for i in range(tmp.size()):
				while tmp[i].size() != 4:
					tmp[i].push_front(false)
				var res: Result = make_hex(tmp[i])
				if res.is_error():
					return Result.new(ERR_INVALID_DATA,res)
				else:
					hex_string += res.unwrap()
			if hex_string.is_valid_hex_number():
				return Result.new(OK,hex_string)
			else:
				return Result.new(ERR_INVALID_DATA,null)
		_:
			return Result.new(ERR_INVALID_PARAMETER,null)

func make_hex(data : Array[bool]) -> Result:
	if not data.size() == 4:
		return Result.new(ERR_INVALID_PARAMETER,null)
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
			return Result.new(ERR_INVALID_PARAMETER,null)
	if not hex_result.is_valid_hex_number():
		return Result.new(ERR_INVALID_DATA,hex_result)
	else:
		return Result.new(OK,hex_result)

func _to_string():
	return str(values)
