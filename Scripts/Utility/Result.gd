class_name Result
extends Node
## Base class for every ValueWrapper

enum Types {MESSAGE,LOG,WARNING,ERROR,DEBUG}

const UNKNOWN: int = -1

var type : Types
var data : Variant:
	set(value):
		data = value
		if data == null:
			while not is_queued_for_deletion():
				queue_free()
	get:
		while not is_queued_for_deletion():
			queue_free()
		return data
var print_data: String
var error : int
var msg : String
var time : String

func _init(e: int,d : Variant,m: String,t: Types = Types.LOG):
	error = e
	data = d
	print_data = str(data)
	if data is String or data is StringName:
		print_data.xml_escape(true)
	msg = m
	type = t
	_setup()


func _to_string() -> String:
	return "{time} [{type}] || {err} : {msg} || {data}".format({"time":time,"type":_match_type(type),"err":_match_err(error),"msg":msg,"data":str(print_data)})

func to_output() -> void:
	print_rich("[color=magenta]{time}[/color] {type}[color=cyan]| {err} : {msg} |[/color][color=orange]| {data}".format({"time":time,"type":_match_type(type),"err":_match_err(error),"msg":msg,"data":str(print_data)}))

func _setup():
	time = Time.get_datetime_string_from_system(false,true)
	Wrapper.push(self)

func _enter_tree():
	add_to_group(&"Result")

func is_ok():
	return error == OK

func is_message():
	if type == Types.MESSAGE:
		return true
	return false

func is_log():
	if type == Types.LOG:
		return true
	return false

func is_warning():
	if type == Types.WARNING:
		return true
	return false

func is_error():
	if type == Types.ERROR:
		return true
	return false

func is_debug():
	if type == Types.DEBUG:
		return true
	return false

func _match_type(t):
	var res = ""
	match t:
		Types.MESSAGE:
			res = "[color=white][b][ MESSAGE ] |[/b][/color]"
		Types.LOG:
			res = "[color=pink][b][ LOG     ] |[/b][/color]"
		Types.WARNING:
			res = "[color=yellow][b][ WARNING ] |[/b][/color]"
		Types.ERROR:
			res = "[color=red][b][ ERROR   ] |[/b][/color]"
		_:
			res = str(t)
	return res

func _match_err(e):
	var res = ""
	match e:
		-1:
			res = "ERR_UNKNOWN"
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
		ERR_CANT_RESOLVE:
			res = "ERR_CANT_RESOLVE"
		ERR_PARSE_ERROR:
			res = "ERR_PARSE_ERROR"
		_:
			res = str(e)
	return res
