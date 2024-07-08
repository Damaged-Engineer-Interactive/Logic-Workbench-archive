extends LogicGate
class_name InputGate

func _init(s: Wire.Sizes,n: String) -> void: #s = size, n = name
	self.title = "INPUT"
	self.short = "INPUT"
	self.description = "INPUT of a Component"
	self.id = Global.make_uuid().unwrap()
	self.size = s
	self.multi_input = false
	self.multi_output = false
	
	self.gate_name = n
	
	self.inputs["_IN"] = Wire.new(size)
	
	self.outputs["OUT"] = Wire.new(size)

func simulate() -> void:
	outputs["OUT"].merge(inputs["_IN"])
