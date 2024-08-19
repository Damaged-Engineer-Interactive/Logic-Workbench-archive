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

# private variables

# @onready variables

# optional built-in _init() function
func _init(options: Dictionary) -> void:
	self.short = "NOT"
	self.description = "Outputs the opposite of the Input"
	_setup(options)

# optional built-in _enter_tree() function

# optional built-in _ready() function

# remaining built-in functions

# virtual functions to override
#region Options
func _options() -> Dictionary:
	return {}

func _options_available() -> void:
	return

func _options_display() -> Array[String]:
	return []

func _setup_io() -> void:
	add_input("IN",Wire.Sizes.BIT1,Wire.Colors.RED)
	add_output("OUT",Wire.Sizes.BIT1,Wire.Colors.RED)
#endregion

func _get_cmp() -> Array[Wire]:
	var res: Array[Wire] = []
	res.append(get_output(1).data.val)
	return res

func _simulate() -> Result:
	var output: InternalOutput = get_output(1).data
	var val: Wire = output.val
	var input: InternalInput = get_input(1).data
	val.set_bit(0,not input.val.get_bit(0).data)
	output.val = val
	set_output(1,output)
	return Result.new(OK,null,_id_fmt(_simulate,false))

# public functions

# private functions

# subclasses
