extends LogicGate
class_name Circuit

var gates: Dictionary = {} # ID : Gate
var connections: Array[Connection] = []
var truth_table: TruthTable
var use_truth_table: bool = false

func _init() -> void:
	self.id = Global.make_uuid().unwrap()

func copy() -> Circuit: # needs to be updated, as Circuit / LogicGate changes
	push_warning("Circuit.copy() : remember to check if needs update!")
	var res := Circuit.new()
	res.title = title
	res.short = short
	res.description = description
	res.gate_name = gate_name
	res.size = size
	res.multi_input = multi_input
	res.multi_output = multi_output
	res.gates = gates
	res.connections = connections
	res.inputs = inputs
	res.outputs = outputs
	res.use_truth_table = use_truth_table
	res.truth_table = truth_table
	res.position = position
	return res

func set_truth_table(tt: TruthTable):
	use_truth_table = true
	truth_table = tt
	inputs = truth_table.inputs
	outputs = truth_table.outputs

func remove_truth_table():
	use_truth_table = false
	truth_table = TruthTable.new()

func add_gate(gate: LogicGate) -> Result:
	if gates.has(gate.id):
		return Result.new(ERR_ALREADY_EXISTS,null)
	gates[gate.id] = gate
	match gate.short:
		"INPUT":
			inputs[gate.gate_name] = gate.inputs["_IN"]
		"OUTPUT":
			outputs[gate.gate_name] = gate.outputs["_OUT"]
		_:
			pass
	return Result.new(OK,null)

func get_gate(i: String) -> Result:
	if gates.has(i):
		return Result.new(OK,gates[i])
	else:
		return Result.new(ERR_DOES_NOT_EXIST,null)

func remove_gate(gate: LogicGate) -> Result:
	if gates.has(gate.id):
		gates.erase(gate.id)
		return Result.new(OK,null)
	else:
		return Result.new(ERR_DOES_NOT_EXIST,null)

func set_gate_input(gate: String,i: String,val: Wire) -> Result:
	if not gates.has(gate):
		return Result.new(ERR_DOES_NOT_EXIST,null)
	return gates[gate].set_inputs(i,val)

func get_gate_output(gate: String,o: String) -> Result:
	if not gates.has(gate):
		return Result.new(ERR_DOES_NOT_EXIST,null)
	return gates[gate].get_outputs(o)

# source_gate,source_out,dest_gate,dest_in
func add_connection(sg: LogicGate,so: String,dg: LogicGate,di: String) -> Result:
	var connection: Connection = Connection.new(self,sg,so,dg,di)
	if connections.has(connection):
		return Result.new(ERR_ALREADY_EXISTS,null)
	connections.append(connection)
	return Result.new(OK,null)

func remove_connection(connection: Connection) -> Result:
	if connections.has(connection):
		connections.erase(connections)
		return Result.new(OK,null)
	return Result.new(ERR_DOES_NOT_EXIST,null)

func simulate() -> void:
	if not use_truth_table:
		for connection in connections:
			if connection.is_valid().is_error():
				continue
			# Connection is valid
			var gate = connection.src_gate
			var val = gate.get_output(connection.src_output)
			if val.is_error():
				continue
			val = val.unwrap()
			connection.update(val)
	else:
		var res = truth_table.get_outputs(inputs)
		if res.is_error():
			return
		outputs = res.unwrap()
