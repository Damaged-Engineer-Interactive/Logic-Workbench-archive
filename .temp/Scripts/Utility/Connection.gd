extends Node
class_name Connection

var circuit: Circuit

var src_gate: LogicGate
var src_output: String = "" 

var dest_gate: LogicGate
var dest_input: String = ""

var wire: Wire

var valid: bool = false

func _init(c: Circuit,sg: LogicGate,so: String,dg: LogicGate,di: String) -> void:
	wire = Wire.new(Wire.Sizes.S1)
	circuit = c
	src_gate = sg
	src_output = so
	dest_gate = dg
	dest_input = di
	is_valid()

func update(val: Wire):
	wire.merge(val)
	dest_gate.set_input(dest_input,wire)

func is_valid() -> Result: # modifies is_valid 
	valid = true
	var errs = []
	if src_gate:
		if src_gate.has_output(src_output).is_error():
			valid = false # Invalid OUTPUT
			errs.append("source_output does not exist!")
	else:
		valid = false
		errs.append("source_gate does not exist!")
	if dest_gate:
		if dest_gate.has_input(dest_input).is_error():
			valid = false # Invalid INPUT
			errs.append("destination_input does not exist!")
	else:
		valid = false
		errs.append("destination_gate does not exist!")
	var err = OK if valid else ERR_DOES_NOT_EXIST
	return Result.new(err,valid,str(errs))
