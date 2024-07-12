extends LogicGate
class_name NotGate

func _init(_s: int) -> void: # s = num_inputs
	self.title = "NOT"
	self.short = "NOT"
	self.description = "A NOT B"
	self.id = Global.make_uuid().unwrap()
	self.size = Wire.Sizes.S1
	self.multi_input = false # Gate can only have one Input pin
	self.multi_output = false # Gate can only have one Output pin
	
	self.inputs["IN"] = Wire.new(Wire.Sizes.S1)
	
	self.outputs["OUT"] = Wire.new(Wire.Sizes.S1)

func simulate() -> void:
	var res: bool = self.inputs["IN"].get_bit(0).unwrap()
	outputs["OUT"].set_bit(0,not res)
