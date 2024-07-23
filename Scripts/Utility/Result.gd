class_name Result
extends Node
## Base class for every ValueWrapper

var data : Variant
var error : int
var msg : String
var time : String

func _init(e: int,d : Variant,m: String):
	error = e
	data = d
	msg = m
	_setup()


func _to_string() -> String:
	return "{time} - {err} : {msg} || {data}".format({"time":time,"err":_match_err(error),"msg":msg,"data":str(data)})


func _setup():
	time = Time.get_datetime_string_from_system(false,true)
	Wrapper.push(self)

func _is_error():
	if OK:
		return false
	return true

func _match_err(e):
	var res = ""
	match e:
		OK:
			res = "OK"
		ERR_UNCONFIGURED:
			res = "ERR_UNCONFIGURED"
		ERR_ALREADY_EXISTS:
			res = "ERR_ALREADY_EXISTS"
		ERR_DOES_NOT_EXIST:
			res = "ERR_DOES_NOT_EXIST"
		ERR_INVALID_DATA:
			res = "ERR_INVALID_DATA"
		ERR_INVALID_PARAMETER:
			res = "ERR_INVALID_PARAMETER"
	return "%-25d" % res
