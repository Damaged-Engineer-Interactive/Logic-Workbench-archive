extends LogicGate
class_name OutputComponent

var inputs: Array = [false]

func _init(id: int) -> void:
	self.id = id
	inputs = [false]

func get_outputs() -> Result:
	return Result.new(OK,inputs)

func set_inputs(values: Array) -> Result:
	if values.size() == inputs.size():
		inputs = values
		return Result.new(OK,null)
	else:
		return Result.new(ERR_INVALID_PARAMETER,null)
