extends Node
class_name Result

var data = null
var error : int = OK
var msg : String = ""

func _init(e : int, d, m : String = "") -> void:
	self.data = d # Data
	self.error = e # Error Code
	self.msg = m # Error Message
	if is_error():
		push_error(self)
		printerr(self)
	elif is_empty():
		self.queue_free()
	else:
		print(self)

func is_error() -> bool:
	if error == OK:
		return false # No error
	else:
		return true # Error

func unwrap() -> Variant:
	if is_error():
		return null
	else:
		return data

func _to_string() -> String:
	return match_err(error) + " : " + msg + " - " + str(data)

func is_empty() -> bool:
	if error == OK and data == null:
		return true
	else:
		return false

func match_err(err: int) -> String:
	match err:
		OK:
			return "OK"
		ERR_UNCONFIGURED:
			return "ERR_UNCONFIGURED"
		ERR_ALREADY_EXISTS:
			return "ERR_ALREADY_EXISTS"
		ERR_DOES_NOT_EXIST:
			return "ERR_DOES_NOT_EXIST"
		ERR_INVALID_DATA:
			return "ERR_INVALID_DATA"
		ERR_INVALID_PARAMETER:
			return "ERR_INVALID_PARAMETER"
		_:
			return str(err)
