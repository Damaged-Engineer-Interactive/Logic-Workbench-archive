extends LogicGate
class_name CircuitArchive


var gates: Array = []
var connections: Dictionary = {}
var truth_table: TruthTable
var use_truth_table: bool = false
var inputs: Array = []
var outputs: Array = []
var input_components: Dictionary = {}
var output_components: Dictionary = {}

func _init(id: int, num_inputs: int, num_outputs: int, use_truth_table: bool) -> void:
	self.id = id
	self.use_truth_table = use_truth_table
	truth_table = TruthTable.new()

func add_gate(gate: LogicGate) -> void:
	gates.append(gate)

func set_gate_inputs(gate_index: int, values: Array) -> int:
	if gate_index < gates.size():
		gates[gate_index].set_inputs(values)
		return OK
	else:
		return ERR_INVALID_PARAMETER

func get_gate_outputs(gate_index: int = -1) -> Array:
	if use_truth_table:
		var inputs_combined = []
		for gate in gates:
			inputs_combined.append_array(gate.get_outputs())
		return truth_table.get_outputs(inputs_combined)
	else:
		if gate_index < gates.size():
			return gates[gate_index].get_outputs()
		else:
			return []

func set_truth_table(truth_table: TruthTable) -> int:
	self.truth_table = truth_table
	return OK

func add_connection(src_gate: int, src_out: int, dest_gate: int, dest_in: int) -> int:
	if connections.has([src_gate,src_out]):
		return ERR_ALREADY_EXISTS
	else:
		connections[[src_gate,src_out]] = [dest_gate,dest_in]
		return OK

func add_input_component(id: int) -> void:
	var input_component = InputComponent.new(id)
	input_components[id] = input_component
	add_gate(input_component)

func add_output_component(id: int) -> void:
	var output_component = OutputComponent.new(id)
	output_components[id] = output_component
	add_gate(output_component)

func set_input_value(id: int, value: Array) -> int:
	if input_components.has(id):
		input_components[id].set_inputs(value)
		return OK
	else:
		return ERR_DOES_NOT_EXIST

func get_output_value(id: int) -> Array:
	if output_components.has(id):
		return output_components[id].get_outputs()[0]
	else:
		return [false]
