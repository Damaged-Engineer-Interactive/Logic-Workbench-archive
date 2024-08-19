# The name of the Class

# The class this class extends
extends LogicGate
# Docstring
## An OR Gate
## 
## Outputs 1 if any inputs is 1

# Signals

# Enums

# Constants

# @export variables

# public variables
var input_count: int = 2

# private variables

# @onready variables

# optional built-in _init() function
func _init(options: Dictionary) -> void:
	self.short = "OR"
	self.description = "Outputs 1 if any input is 1"
	_setup(options)

# optional built-in _enter_tree() function

# optional built-in _ready() function

# remaining built-in functions

# virtual functions to override
#region Options
func _options() -> Dictionary:
	return {
		"input_count": LogicGate.OptionTypes.INT,
	}

func _options_available() -> void:
	self.input_count = setup_options.get("input_count",input_count)

func _options_display() -> Array[String]:
	return []

func _setup_io() -> void:
	add_output("OUT",Wire.Sizes.BIT1,Wire.Colors.RED)
	for i in range(input_count):
		add_input(str(i),Wire.Sizes.BIT1,Wire.Colors.RED)
#endregion

func _get_cmp() -> Array[Wire]:
	var res: Array[Wire] = []
	res.append(get_output(1).data.val)
	return res

func _simulate() -> Result:
	var res: Wire = Wire.new(Wire.Sizes.BIT1,Wire.Colors.RED)
	for i in range(input_count):
		var input: InternalInput = get_input(i+1).data
		var val_in: bool = input.val.get_bit(0).data
		var val_res: bool = res.get_bit(0).data
		res.set_bit(0,val_res or val_in)
	var output: InternalOutput = get_output(1).data
	output.val.set_value(res.get_value().data)
	set_output(1,output)
	return Result.new(OK,null,_id_fmt(_simulate,false))

# public functions

# private functions

# subclasses
