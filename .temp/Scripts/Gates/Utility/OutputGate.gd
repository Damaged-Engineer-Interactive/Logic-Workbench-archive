extends LogicGate
class_name OutputGate

func _init(s: Wire.Sizes,n: String) -> void: #, s = size
	self.title = "OUTPUT"
	self.short = "OUTPUT"
	self.description = "OUTPUT of a Component"
	self.id = Global.make_uuid().unwrap()
	self.size = s
	self.multi_input = false
	self.multi_output = false
	
	self.gate_name = n
	
	self.inputs["IN"] = Wire.new(size)
	
	self.outputs["_OUT"] = Wire.new(size)

func simulate() -> void:
	outputs["_OUT"].merge(inputs["IN"])
