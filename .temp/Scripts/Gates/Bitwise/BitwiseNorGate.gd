extends LogicGate
class_name BitwiseNorGate

func _init(s: Wire.Sizes) -> void: # s = size
	self.title = "Bitwise NOR"
	self.short = "B. NOR"
	self.description = "Input A NOR Input B"
	self.id = Global.make_uuid().unwrap()
	self.size = s
	
	self.inputs["A"] = Wire.new(size)
	self.inputs["B"] = Wire.new(size)
	
	self.outputs["OUT"] = Wire.new(size)

func simulate() -> void:
	for i in range(size):
		var val = inputs["A"].get_bit(i) or inputs["B"].get_bit(i)
		outputs["OUT"].set_bit(i,not val)
