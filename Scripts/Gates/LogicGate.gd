extends Node
class_name LogicGate

var title: String = ""
var short: String = ""
var description: String = ""

var position: Vector3i = Vector3i(0,0,0) # x, y, layer

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
