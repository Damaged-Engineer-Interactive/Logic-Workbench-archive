# The name of the Class
class_name Circuit
# The class this class extends
extends LogicGate
# Docstring
## Class for every circuit
## 
## ... if you have questions : ask me !

# Signals

# Enums

# Constants

# @export variables

# public variables

# private variables
var _gates: Dictionary = {}
var _input_gates: Dictionary = {}
var _output_gates: Dictionary = {}
var _connections: Dictionary = {}
var _tt: TruthTable
var _use_tt: bool = false

# @onready variables

# optional built-in _init() function
func _init(options: Dictionary):
	class_str = "Circuit"
	short = options.get("short","CIR")
	gate_name = options.get("gate_name","Circuit")
	description = options.get("description","A Circuit")
	_setup(options)

# optional built-in _enter_tree() function

# optional built-in _ready() function

# remaining built-in functions

# virtual functions to override
func _simulate() -> Result:
	if not ( _use_tt ):
		# set input gates
		for input: InternalInput in inputs.values():
			if input.slot == 0:
				continue
			var gate: LogicGate = _input_gates[input.name]
			gate.set_input(-1,input)
		# set other gates
		for connection: Connection in _connections.values():
			if connection.is_valid().is_error():
				continue # Skip invalid connection
			var src_gate: LogicGate = connection.src_gate
			var src_output: InternalOutput = src_gate.get_output(connection.src_output).data
			var dest_gate: LogicGate = connection.dest_gate
			var dest_input: InternalInput = dest_gate.get_input(connection.dest_input).data
			var val: Wire = src_output.val
			if val.is_cmp():
				val.add_cmp(src_gate.get_cmp())
				dest_input.val.set_cmp(val.get_cmp().data)
			else:
				dest_input.val.set_value(val.get_value().data)
			dest_gate.set_input(connection.dest_input,dest_input)
		# set output gates
		for output: InternalOutput in outputs.values():
			if output.slot == 0:
				continue
			var gate: LogicGate = _output_gates[output.name]
			var out: InternalOutput = gate.get_output(-1).data
			var val: Wire = out.val
			output.val = val
		# simulate gates that havent been simulated
		for gate: LogicGate in _gates.values():
			gate.simulate()
	if self.is_master:
		self.tick.emit()
	return Result.new(OK,null,_id_fmt(_simulate,false))

#region Save / Load
func save_cfg() -> Result:
	# Create path variable
	var chip = Global.chip_format.format({"priority":priority,"class_name":class_str})
	var save = Global.chip_save_path.format({"project":Global.current_project_name,"chip":chip})
	# make new file
	DirAccess.make_dir_recursive_absolute(save.get_base_dir())
	var f = FileAccess.open(save,FileAccess.WRITE)
	f.close()
	# Create
	var cfg := ConfigFile.new()
	cfg.clear()
	# Secton : Data
	cfg.set_value("Data","version",version )
	cfg.set_value("Data","priority",priority)
	cfg.set_value("Data","script",get("script"))
	cfg.set_value("Data","path",save)
	# Section : Information
	cfg.set_value("Information","class_str",class_str)
	cfg.set_value("Information","gate_name",gate_name)
	cfg.set_value("Information","short",short)
	cfg.set_value("Information","description",description)
	cfg.set_value("Information","stats",stats)
	# Section : Workspace
	cfg.set_value("Workspace","col",col)
	cfg.set_value("Workspace","snap",snap)
	cfg.set_value("Workspace","offset",position_offset)
	# Section : IO
	cfg.set_value("IO","max_inputs",max_inputs)
	cfg.set_value("IO","max_outputs",max_outputs)
	cfg.set_value("IO","inputs",inputs)
	cfg.set_value("IO","outputs",outputs)
	# Section : Circuit
	cfg.set_value("Circuit","gates",_gates)
	cfg.set_value("Circuit","connections",_connections)
	cfg.set_value("Circuit","tt",_tt)
	cfg.set_value("Circuit","tt_usage",_use_tt)
	# Save
	var err = cfg.save(save)
	if err != OK:
		return Result.new(err,cfg,_id_fmt(save_cfg,true,"An unknown error has occured!"))
	# Done
	return Result.new(OK,cfg,_id_fmt(save_cfg,false))

func load_cfg(save: String) -> Result:
	# Create
	var cfg := ConfigFile.new()
	cfg.clear()
	# Load
	var err = cfg.load(save)
	if err != OK:
		return Result.new(err,cfg,_id_fmt(load_cfg,true,"An unknown error has occured!"))
	# Secton : Data
	version = cfg.get_value("Data","version",version)
	priority = cfg.get_value("Data","priority",priority)
	set("script",cfg.get_value("Data","script",get("script")))
	path = cfg.get_value("Data","path",path)
	# Section : Information
	class_str = cfg.get_value("Information","class_str",class_str)
	gate_name = cfg.get_value("Information","gate_name",gate_name)
	short = cfg.get_value("Information","short",short)
	description = cfg.get_value("Information","description",description)
	stats = cfg.get_value("Information","stats",stats)
	# Section : Workspace
	col = cfg.get_value("Workspace","col",col)
	snap = cfg.get_value("Workspace","snap",snap)
	position_offset = cfg.get_value("Workspace","offset",position_offset)
	# Section : IO
	max_inputs = cfg.get_value("IO","max_inputs",max_inputs)
	max_outputs = cfg.get_value("IO","max_outputs",max_outputs)
	inputs = cfg.get_value("IO","inputs",inputs)
	outputs = cfg.get_value("IO","outputs",outputs)
	# Section : Workspace
	_gates = cfg.get_value("Circuit","gates",_gates)
	_connections = cfg.get_value("Circuit","connections",_connections)
	_use_tt = cfg.get_value("Circuit","tt_usage",_use_tt)
	if _use_tt:
		_tt = cfg.get_value("Circuit","tt",_tt)
	# Done
	return Result.new(OK,cfg,_id_fmt(load_cfg,false))
#endregion

# public functions
func clear() -> void:
	for connection: Connection in _connections:
		remove_connection(connection)
	for gate: LogicGate in _gates:
		remove_gate(gate)

#region Gate
## Add a gate to the Circuit
func add_gate(gate: LogicGate) -> Result:
	if has_gate(gate).data:
		return Result.new(ERR_ALREADY_EXISTS,null,_id_fmt(add_gate,true,"Gate with that ID already exists"),Result.Types.ERROR)
	
	_gates[gate.id] = gate
	match gate.class_str:
		"InputGate": # InputGate.gd
			add_input(gate.gate_name,gate.bit_size,Wire.Colors.CYAN)
			_input_gates[gate.gate_name] = gate
		"OutputGate": # OutputGate.gd
			add_output(gate.gate_name,gate.bit_size,Wire.Colors.CYAN)#
			_output_gates[gate.gate_name] = gate
	return Result.new(OK,null,_id_fmt(add_gate,false))

func remove_gate(gate: LogicGate) -> Result:
	if not ( has_gate( gate ).data ) :
		return Result.new(ERR_DOES_NOT_EXIST,null,_id_fmt(remove_gate,true,"Gate with that ID does not exist"),Result.Types.ERROR)
	# remove connections that contain the gate
	for key: String in _connections.keys():
		var connection: Connection = _connections.get(key)
		if connection.has_gate(gate):
			remove_connection(connection)
	# remove io that is made by the gate
	match gate.class_str:
		"InputGate": # InputGate.gd
			var input: InternalInput = find_input(gate.gate_name).data
			remove_input(input.slot)
		"OutputGate": # OutputGate.gd
			var output: InternalOutput = find_output(gate.gate_name).data
			remove_output(output.slot) 
	# remove gate
	_gates.erase(gate.id)
	return Result.new(OK,null,_id_fmt(remove_gate,false))

func has_gate(gate: LogicGate) -> Result:
	return Result.new(OK,_gates.has(gate.id),_id_fmt(has_gate,false))

func get_gate(gate: StringName) -> Result:
	if _gates.has(gate):
		return Result.new(OK,_gates[gate],_id_fmt(has_gate,false))
	return Result.new(ERR_DOES_NOT_EXIST,null,_id_fmt(get_gate,true,"Gate with that ID does not exist"),Result.Types.ERROR)
#endregion

#region Connection
## Add a connection to the circuit
func add_connection(connection: Connection) -> Result:
	if has_connection(connection).data:
		return Result.new(ERR_ALREADY_EXISTS,null,_id_fmt(add_connection,true,"Connection with that ID already exists"),Result.Types.ERROR)
	if connection.is_valid():
		_connections[connection.id] = connection
		return Result.new(OK,null,_id_fmt(add_connection,false))
	return Result.new(ERR_INVALID_DATA,null,_id_fmt(add_connection,true,"Connection is invalid"),Result.Types.ERROR)

## Remove a connection from the circuit
func remove_connection(connection: Connection) -> Result:
	if not ( has_connection(connection).data ) :
		return Result.new(ERR_DOES_NOT_EXIST,null,_id_fmt(remove_connection,true,"Connection with that ID does not exist"),Result.Types.ERROR)
	_connections.erase(connection.id)
	return Result.new(OK,null,_id_fmt(remove_connection,false))

## Check if the connection exist in the circuit
func has_connection(connection: Connection) -> Result:
	return Result.new(OK,_connections.has(connection.id),_id_fmt(has_connection,false))
#endregion

# private functions
func _tick() -> void:
	_processed = false
	for gate: LogicGate in _gates.values():
		gate.tick.emit()

# subclasses
