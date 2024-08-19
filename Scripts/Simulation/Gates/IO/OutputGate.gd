# The name of the Class

# The class this class extends
extends LogicGate
# Docstring
## Gate used as circuit Input 
## 
## Holds the Input value using a Wire.

# Signals

# Enums

# Constants

# @export variables

# public variables
var bit_size: Wire.Sizes

# private variables

# @onready variables

# optional built-in _init() function
func _init(options: Dictionary) -> void:
	self.short = "OUT"
	self.description = "The output of a Component"
	self.max_inputs = 1
	self.max_outputs = 1
	_setup(options)

# optional built-in _enter_tree() function

# optional built-in _ready() function

# remaining built-in functions

# virtual functions to override
#region Options
func _options() -> Dictionary:
	return {
		"bit_size": LogicGate.OptionTypes.SIZES,
		"gate_name": LogicGate.OptionTypes.STRING,
	}

func _options_available() -> void:
	self.bit_size = setup_options.get("bit_size",Wire.Sizes.BIT1)
	self.gate_name = setup_options.get("gate_name","<undefined>")

func _options_display() -> Array[String]:
	return [
		"Bit Size : %s Bits" % str(bit_size),
		]

func _setup_io() -> void:
	add_input("IN", bit_size, Wire.Colors.CYAN)
	add_output("_OUT", bit_size, Wire.Colors.CYAN)
#endregion

func _get_cmp() -> Array[Wire]:
	var res: Array[Wire] = []
	res.append(get_input(1).data.val)
	return res

func _simulate() -> Result:
	var output: InternalOutput = get_output(-1).data
	var val: Wire = output.val
	var input: InternalInput = get_input(1).data
	val.set_value(input.val.get_value().data)
	set_output(-1,output)
	return Result.new(OK,null,_id_fmt(_simulate,false))

# public functions

# private functions

# subclasses
