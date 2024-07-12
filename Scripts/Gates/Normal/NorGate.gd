extends LogicGate
class_name NorGate

func _init(s: int) -> void: # s = num_inputs
	self.title = "NOR"
	self.short = "NOR"
	self.description = "A NOR B"
	self.id = Global.make_uuid().unwrap()
	self.size = Wire.Sizes.S1
	
	for a in range(s):
		self.inputs[str(a)] = Wire.new(Wire.Sizes.S1)
	
	self.outputs["OUT"] = Wire.new(Wire.Sizes.S1)

func simulate() -> void:
	var res: bool = false
	for key in inputs.keys():
		res = res or self.inputs[key].get_bit(0).unwrap()
		outputs["OUT"].set_bit(0,not res)
