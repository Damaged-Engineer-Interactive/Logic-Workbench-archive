extends LogicGate
class_name AndGate

func _init(s: int) -> void: # s = num_inputs
	self.title = "AND"
	self.short = "AND"
	self.description = "A AND B"
	self.id = Global.make_uuid().unwrap()
	self.size = Wire.Sizes.S1
	
	for a in range(s):
		self.inputs[str(a)] = Wire.new(Wire.Sizes.S1)
	
	self.outputs["OUT"] = Wire.new(Wire.Sizes.S1)

func simulate() -> void:
	var res: bool = true
	for key in inputs.keys():
		res = res and self.inputs[key].get_bit(0).unwrap()
		outputs["OUT"].set_bit(0,res)
