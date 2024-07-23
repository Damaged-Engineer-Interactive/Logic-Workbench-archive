extends LogicGate
class_name BitwiseNotGate

func _init(s: Wire.Sizes) -> void: # s = size
	self.title = "Bitwise NOT"
	self.short = "B. NOT"
	self.description = "NOT Input"
	self.id = Global.make_uuid().unwrap()
	self.size = s
	
	self.inputs["IN"] = Wire.new(size)
	
	self.outputs["OUT"] = Wire.new(size)

func simulate() -> void:
	for i in range(size):
		outputs["OUT"].set_bit(i,not inputs["IN"].get_bit(i))
