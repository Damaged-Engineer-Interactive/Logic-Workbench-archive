extends Node2D
class_name LogicGate

@export_group("Informational")
@export var title: String = ""
@export var short: String = ""
@export var description: String = ""

@export var stats: Dictionary = {}

@export_group("Visualisation")
var pos: Vector3i = Vector3i(0,0,0) # x, y, layer

@export_group("Data")
var gate_name: String = ""

var multi_input: bool = true # Allow Multiple Input Pins
var multi_output: bool = true # Allow Multiple Output Pins

var inputs: Dictionary = {} # Name : Wire , if Name starts with "_", dont use as pin
var outputs: Dictionary = {} # Name : wire , if Name starts with "_", dont use as pin

var id: String = "" # uuid of the component / block
var size: Wire.Sizes # bit size of the component

var processed = false # Check if the gate has been processed

func _init() -> void:
	self.id = Global.make_uuid().unwrap()
	add_to_group("Gates",true)

func get_short():
	return self.short

func set_short(val):
	self.short = val

func get_title():
	return self.title

func set_title(val):
	self.title = val

func get_description():
	return self.description

func set_description(val):
	self.description = val

func _setup() -> void:
	self.id = Global.make_uuid().unwrap()
	add_to_group("Gates",true)

func simulate() -> void:
	return

func tick() -> void: # Circuit.next_tick signal connects here
	processed = true

func has_output(i: String) -> Result:
	if outputs.has(i):
		return Result.new(OK,null)
	else:
		return Result.new(ERR_DOES_NOT_EXIST,null)

func has_input(i: String) -> Result:
	if inputs.has(i):
		return Result.new(OK,null)
	else:
		return Result.new(ERR_DOES_NOT_EXIST,null)

func get_output(i: String) -> Result:
	simulate()
	if outputs.has(i):
		return Result.new(OK,outputs[i])
	else:
		return Result.new(ERR_DOES_NOT_EXIST,null)

func set_input(i: String, value: Wire) -> Result:
	if inputs.has(i):
		inputs[i].merge(value)
		return Result.new(OK,null)
	else:
		return Result.new(ERR_DOES_NOT_EXIST,null)

func _to_string() -> String:
	return str(id+" : "+short+" : "+gate_name+" : "+name)
