# The name of the Class
class_name LogicGate
# The class this class extends
extends GraphNode
# Docstring
## short description goes here 
## 
## Long desciption goes here

# Signals
signal tick

# Enums
enum OptionTypes {STRING,INT,BOOL,SIZES,THEME} # BOOL and THEME arent implemented yet

# Constants
## If a color is undefined, this color is used instead
const CLR_UN := Color.BLACK
## The color for the "component" wire
const CLR_CMP := Color("5363b9")
## The image of a Port
var IMG_PORT: Texture2D = get_theme_icon("GuiGraphNodePort", "EditorIcons")

# @export variables
#region Data
@export_category("Data")
## The priority when loading the Gates.[br]
## The lower the priority, the sooner it will load
@export var priority: int = 0
## The version of the save file
@export var version: int = 1
## The path of the script
@export var path: String = get("script").resource_path
## The classes this script inherits
@export var inherited: Dictionary = {
	"Object":0,
	"Node":1,
	"CanvasItem":2,
	"Control":3,
	"Container":4,
	"GraphElement":5,
	"GraphNode":6,
	"LogicGate":7,
}
#endregion

#region Information
@export_category("Information")
## The name of the Gate
@export var gate_name: String = ""
## The short name of the Gate
@export var short: String = ""
## The description of the Gate
@export_multiline var description: String = "":
	set = _set_description
## The stats of the Gate
@export var stats: Dictionary = {}
#endregion

#region Workspace
@export_category("Workspace")
## The Color of the Chip
@export_color_no_alpha var col := Color("471f1f")
## The Snapping Ratio when resizing.[br]
## Should be the same as the [code]snapping_distance[/code] of the GraphEdit
@export var snap: int = 10
## If the gate should always be able to simulate
@export var is_master: bool = false
## If the gate should never be able to simulate
@export var is_preview: bool = false
## The setup options this gate has when initialising
@export var setup_options: Dictionary
#endregion

#region IO
@export_category("IO")
## Maximum amount of inputs the Gate is allowed to have.
## Enter [code]-1[/code] to disable the Limit.
@export var max_inputs: int = -1
## The inputs of the Gate.[br]
## Format : [code]int Slot : InternalInput Node[/code]
@export var inputs: Dictionary = {}
## Maximum amount of outputs the Gate is allowed to have.[br]
## Enter [code]-1[/code] to disable the Limit.
@export var max_outputs: int = -1
## The outputs of the Gate.[br]
## Format : [code]int Slot : InternalOutput Node[/code]
@export var outputs: Dictionary = {}
#endregion

# public variables
var id: StringName = &""

var script_name: String = "<undefined.file>"
var class_str: String = "<undefined.name>"

# private variables
var _processed: bool = false
var _is_simulating: bool = false

var _redrawing: bool = false

var _original_options: Dictionary = {}
# @onready variables

# optional built-in _init() function
func _init(options: Dictionary = {}) -> void:
	_setup(options)

func _setup(options: Dictionary) -> void:
	# connect signals
	self.tick.connect(_tick)
	self.delete_request.connect(_delete_request)
	self.raise_request.connect(_raise_request)
	self.resize_request.connect(_resize_request)
	self.resized.connect(_resized)
	# prepare
	self.id = Global.make_id().data
	self.name = id
	self.setup_options = options
	self._original_options = options
	# check if gate should load from file
	if setup_options.has("load"):
		load_cfg(setup_options.get("load"))
	else: # gate should not load from file
		self.is_master = setup_options.get("master",false)
		setup_options.erase("master")
		self.is_preview = setup_options.get("preview",false)
		setup_options.erase("preview")
		self.script_name = path.get_file()
		self.class_str = script_name.replace("."+script_name.get_extension(), "")
		self.resizable = true
		self.custom_minimum_size = Vector2(300,150)
		# check for inheritance
		if not ( class_str == "LogicGate" ):
			add_inherited(class_str)
		# add 'CMP' input
		add_input("Component",Wire.Sizes.CMP,Wire.Colors.CMP)
		add_output("Component",Wire.Sizes.CMP,Wire.Colors.CMP)
		# configure options
		_options_available()
		# configure io
		_setup_io()
	# simulate to set values
	_simulate()
	# update io
	request_redraw()

# optional built-in _enter_tree() function
func _enter_tree():
	if not ( is_preview ):
		add_to_group(&"Gates")
	var panel: StyleBoxFlat = Global.panel.duplicate(true)
	panel.bg_color = col
	var panel_selected: StyleBoxFlat = Global.panel_selected.duplicate(true)
	panel_selected.bg_color = col
	set("theme_override_styles/panel",panel)
	set("theme_override_styles/panel_selected",panel_selected)
	set("theme_override_styles/titlebar",Global.titelbar.duplicate(true))
	set("theme_override_styles/titlebar_selected",Global.titelbar_selected.duplicate(true))
	request_redraw()

# optional built-in _ready() function

# remaining built-in functions
func _to_string():
	return "{id} : {short} : {gate} : {name}".format({"id":id,"short":short,"gate":gate_name,"name":name})

# virtual functions to override
#region Setup
## If you want any setup options to be configured, you must provide it here[br]
## [code]Name : String - Type : OptionTypes[/code]
func _options() -> Dictionary:
	return {}

## Gets called when the setup_options are available
func _options_available() -> void:
	return

## Gets called to display a setup option in the title
func _options_display() -> Array[String]:
	return []

## Gets called when the io is ready to be set up
func _setup_io() -> void:
	return
#endregion

## The values that should be transmitted by the "CMP" wire
func _get_cmp() -> Array[Wire]:
	return []

func _simulate() -> Result:
	return Result.new(ERR_UNCONFIGURED,null,_id_fmt(_simulate,true,"Not implemented"),Result.Types.ERROR)

# public functions
func copy(full: bool = false,override: Dictionary = {}) -> LogicGate:
	var options: Dictionary = setup_options
	if full:
		options = _original_options
	options.merge(override)
	var src: GDScript = get("script")
	var res: LogicGate = src.new(options)
	return res

func simulate() -> Result:
	if is_preview:
		return Result.new(OK,null,_id_fmt(simulate,false)+" || Preview Mode")
	if _processed:
		return Result.new(OK,null,_id_fmt(simulate,false)+" || Already simulated",Result.Types.WARNING)
	_is_simulating = true
	# set component Wire
	var cmp_in: InternalInput = get_input(0).data
	var cmp_out: InternalOutput = get_output(0).data
	var val: Wire = cmp_in.val
	cmp_out.val.set_cmp(val.get_cmp().data)
	set_output(0,cmp_out)
	# call custom _simulate()
	var res: Result = _simulate()
	# done
	_is_simulating = false
	request_redraw()
	return res

#region Save / Load
func save_cfg() -> Result:
	# Create path variable
	var chip = Global.chip_format.format({"priority":priority,"class_name":class_str})
	var save = Global.chip_save_path.format({"project":Global.current_project.project_name,"chip":chip})
	# make new file
	DirAccess.make_dir_recursive_absolute(save.get_base_dir())
	var f = FileAccess.open(save,FileAccess.WRITE)
	f.close()
	# Create
	var cfg := ConfigFile.new()
	cfg.clear()
	# Secton : Data
	cfg.set_value("Data","version",version )
	cfg.set_value("Data","priority",priority)
	cfg.set_value("Data","script",get("script"))
	cfg.set_value("Data","path",path)
	cfg.set_value("Data","inherited",inherited)
	# Section : Information
	cfg.set_value("Information","class_str",class_str)
	cfg.set_value("Information","gate_name",gate_name)
	cfg.set_value("Information","short",short)
	cfg.set_value("Information","description",description)
	cfg.set_value("Information","stats",stats)
	# Section : Workspace
	cfg.set_value("Workspace","col",col)
	cfg.set_value("Workspace","snap",snap)
	cfg.set_value("Workspace","offset",position_offset)
	# Section : IO
	cfg.set_value("IO","max_inputs",max_inputs)
	cfg.set_value("IO","max_outputs",max_outputs)
	cfg.set_value("IO","inputs",inputs)
	cfg.set_value("IO","outputs",outputs)
	# Save
	var err = cfg.save(save)
	if err != OK:
		return Result.new(err,cfg,_id_fmt(save_cfg,true,"An unknown error has occured!"),Result.Types.ERROR)
	# Done
	return Result.new(OK,save,_id_fmt(save_cfg,false))

func load_cfg(save: String) -> Result:
	# Create
	var cfg := ConfigFile.new()
	cfg.clear()
	# Load
	var err = cfg.load(save)
	if err != OK:
		return Result.new(err,cfg,_id_fmt(load_cfg,true,"An unknown error has occured!"),Result.Types.ERROR)
	# Secton : Data
	version = cfg.get_value("Data","version",version)
	priority = cfg.get_value("Data","priority",priority)
	var src: GDScript = cfg.get_value("Data","script",get("script"))
	src.reload()
	set("script",src)
	path = cfg.get_value("Data","path",path)
	inherited = cfg.get_value("Data","inherited",inherited)
	# Section : Information
	class_str = cfg.get_value("Information","class_str",class_str)
	gate_name = cfg.get_value("Information","gate_name",gate_name)
	short = cfg.get_value("Information","short",short)
	description = cfg.get_value("Information","description",description)
	stats = cfg.get_value("Information","stats",stats)
	# Section : Workspace
	col = cfg.get_value("Workspace","col",col)
	snap = cfg.get_value("Workspace","snap",snap)
	position_offset = cfg.get_value("Workspace","offset",position_offset)
	# Section : IO
	max_inputs = cfg.get_value("IO","max_inputs",max_inputs)
	max_outputs = cfg.get_value("IO","max_outputs",max_outputs)
	inputs = cfg.get_value("IO","inputs",inputs)
	outputs = cfg.get_value("IO","outputs",outputs)
	# Done
	return Result.new(OK,cfg,_id_fmt(load_cfg,false))
#endregion

#region Inheritance
func add_inherited(cls: String) -> void:
	if inherited.has(cls):
		return
	inherited[cls] = inherited.values()[-1] + 1

func check_inherited(cls: String) -> bool:
	return inherited.has(cls)
#endregion

#region Input
func add_input(i: String, s: Wire.Sizes, c: Wire.Colors) -> Result:
	if not ( max_inputs == -1): # check if input limiting is enabled
		if inputs.size() - 1 == max_inputs + 1: # check if limit is reached
			return Result.new(ERR_CANT_CREATE,null,_id_fmt(add_input,true,"Limit reached"),Result.Types.ERROR)
	for input: InternalInput in inputs.values():
		if input.name == i:
			return Result.new(ERR_ALREADY_EXISTS,null,_id_fmt(add_input,true,"Already exists"),Result.Types.ERROR)
	var slt: int = 0
	if not i.begins_with("_"):
		slt = inputs.size()
	else:
		slt = inputs.size() * -1
	var input := InternalInput.new(slt, i, s, c)
	inputs[slt] = input
	request_redraw()
	return Result.new(OK,input,_id_fmt(add_input,false))

func remove_input(slt: int) -> Result:
	if not has_input(slt).data:
		return Result.new(ERR_DOES_NOT_EXIST,null,_id_fmt(remove_input,true,"Does not exist"),Result.Types.ERROR)
	var input: InternalInput = inputs[slt]
	inputs.erase(slt)
	input.queue_free()
	request_redraw()
	return Result.new(OK,null,_id_fmt(remove_input,false))

func has_input(slt: int) -> Result:
	return Result.new(OK,inputs.has(slt),_id_fmt(has_input,false))

func find_input(n: String) -> Result:
	for input: InternalInput in inputs.values():
		if input.name == n:
			return Result.new(OK,input,_id_fmt(find_input,false))
	return Result.new(ERR_DOES_NOT_EXIST,null,_id_fmt(find_input,true,"Cant be found"),Result.Types.ERROR)

func get_input(slt: int) -> Result:
	if not has_input(slt).data:
		return Result.new(ERR_DOES_NOT_EXIST,null,_id_fmt(get_input,true,"Does not exist"),Result.Types.ERROR)
	return Result.new(OK,inputs[slt],_id_fmt(get_input,false))

func set_input(slt: int, val: InternalInput) -> Result:
	if not has_input(slt).data:
		return Result.new(ERR_DOES_NOT_EXIST,null,_id_fmt(set_input,true,"Does not exist"),Result.Types.ERROR)
	inputs[slt] = val
	request_redraw()
	return Result.new(OK,inputs[slt],_id_fmt(set_input,false))
#endregion

#region Output
func add_output(i: String, s: Wire.Sizes, c: Wire.Colors) -> Result:
	if not ( max_outputs == -1): # check if output limiting is enabled
		if outputs.size() - 1== max_outputs + 1: # check if limit is reached
			return Result.new(ERR_CANT_CREATE,null,_id_fmt(add_output,true,"Limit reached"),Result.Types.ERROR)
	for output: InternalOutput in outputs.values():
		if output.name == i:
			return Result.new(ERR_ALREADY_EXISTS,null,_id_fmt(add_output,true,"Already exists"),Result.Types.ERROR)
	var slt: int = 0
	if not i.begins_with("_"):
		slt = outputs.size()
	else:
		slt = outputs.size() * -1
	var output := InternalOutput.new(slt, i, s, c)
	outputs[slt] = output
	request_redraw()
	return Result.new(OK,output,_id_fmt(add_output,false))

func remove_output(slt: int) -> Result:
	if not has_output(slt).data:
		return Result.new(ERR_DOES_NOT_EXIST,null,_id_fmt(remove_output,true,"Does not exist"),Result.Types.ERROR)
	var output: InternalOutput = outputs[slt]
	outputs.erase(slt)
	output.queue_free()
	request_redraw()
	return Result.new(OK,null,_id_fmt(remove_output,false))

func has_output(slt: int) -> Result:
	return Result.new(OK,outputs.has(slt),_id_fmt(has_output,false))

func find_output(n: String) -> Result:
	for output: InternalOutput in outputs.values():
		if output.name == n:
			return Result.new(OK,output,_id_fmt(find_output,false))
	return Result.new(ERR_DOES_NOT_EXIST,null,_id_fmt(find_output,true,"Cant be found"),Result.Types.ERROR)

func get_output(slt: int) -> Result:
	if not ( _is_simulating ):
		if Global.allow_simulate:
			if not ( _processed ):
				var err: Result = simulate()
				if err.is_error():
					return Result.new(Result.UNKNOWN,null,_id_fmt(get_output,true,"Unknown simulation error"))
	if not has_output(slt).data:
		return Result.new(ERR_DOES_NOT_EXIST,null,_id_fmt(get_output,true,"Does not exist"),Result.Types.ERROR)
	return Result.new(OK,outputs[slt],_id_fmt(get_output,false))

func set_output(slt: int, val: InternalOutput) -> Result:
	if not has_output(slt).data:
		return Result.new(ERR_DOES_NOT_EXIST,null,_id_fmt(set_output,true,"Does not exist"),Result.Types.ERROR)
	outputs[slt] = val
	request_redraw()
	return Result.new(OK,outputs[slt],_id_fmt(set_output,false))
#endregion

# private functions
func _id_fmt(function: Callable,fail: bool,reason: String = "") -> String:
	var raw_str := "<{id}> {class}::{function}() - {state}"
	var f := ""
	if fail:
		f = "Fail : %s" % reason
	else:
		f = "Success"
	return raw_str.format({"id":id,"class":class_str,"function":function.get_method(),"state":f})

func _tick() -> void:
	_processed = false

func _delete_request() -> void:
	self.queue_free()

func _raise_request() -> void:
	self.move_to_front()

func _resize_request(new: Vector2) -> void:
	self.size = new

func _resized() -> void:
	self.size = self.size.snapped(Vector2(snap,snap))

func _set_description(val: String) -> void:
	description = Global.parse_text(val).data

#region Visuals
func request_redraw(immediate: bool = false):
	if immediate == true:
		self._redraw()
		self._redrawing = true
	if self._redrawing == false:
		self._redraw.call_deferred()
		self._redrawing = true

func _redraw():
	# update title
	var disp_options: Array[String] = _options_display()
	var fmt_disp = ""
	for i: int in disp_options.size():
		fmt_disp += " | "
		fmt_disp += disp_options[i]
	self.title = "%s - %s%s" % [short,gate_name,fmt_disp]
	# calculate io count
	var io: int = max(inputs.size(),outputs.size())
	# remove old slots
	for child in get_children(false):
		remove_child(child)
		child.queue_free()
	# make input / outputs
	for i in range(io):
		#var idx = i - 1
		var s = "SLOT_" + str(i)
		# input
		var input: InternalInput = inputs.get(i,null) # either InternalInput or null
		if Global.show_debug and not ( input is InternalInput ):
			input = inputs.get(-i,null)
		var render_input: bool = true if input is InternalInput else false
		if render_input:
			if not Global.show_debug and input.is_internal():
				render_input = false
		var in_enable: bool = true if render_input else false
		var in_name: String = str(input.name) if render_input else "<undefined.name>"
		var in_clr: Color = input.val.color if render_input else CLR_UN
		var in_type: int = input.get_type() if render_input else 0
		# output
		var output: InternalOutput = outputs.get(i,null) # either InternalOutput or null
		if Global.show_debug and not ( output is InternalOutput ):
			output = outputs.get(-i,null)
		var render_output: bool = true if output is InternalOutput else false
		if render_output:
			if not Global.show_debug and output.is_internal():
				render_output = false
		var out_enable: bool = true if render_output else false
		var out_name: String = str(output.name) if render_output else "<undefined.name>"
		var out_clr: Color = output.val.color if render_output else CLR_UN
		var out_type: int = output.get_type() if render_output else 0
		# make slot
		var slt := HBoxContainer.new()
		slt.name = s
		if in_enable: # make input
			var IN := Label.new()
			IN.name = "IN_"+in_name
			# make input style
			var res := StyleBoxFlat.new()
			res.draw_center = false
			res.border_color = in_clr
			res.border_width_top = 2
			res.border_width_right = 2
			res.border_width_bottom = 2
			res.corner_radius_top_right = 10
			res.corner_radius_bottom_right = 10
			res.expand_margin_right = 5
			res.content_margin_left = 5
			res.content_margin_right = 5
			IN.set("theme_override_styles/normal",res)
			IN.text = in_name
			if Global.show_debug:
				match input.val.is_true():
					Wire.States.UNDEFINED:
						IN.text = IN.text + " | ?"
					Wire.States.CMP:
						IN.text = IN.text + " | CMP"
					Wire.States.TRUE:
						IN.text = IN.text + " | T"
					Wire.States.FALSE:
						IN.text = IN.text + " | F"
			slt.add_child(IN)
		# make spacer
		var SEP := Label.new()
		SEP.name = "SEP"
		SEP.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slt.add_child(SEP)
		if out_enable: # make output
			var OUT := Label.new()
			OUT.name = "OUT_"+out_name
			var res := StyleBoxFlat.new()
			res.draw_center = false
			res.border_color = out_clr
			res.border_width_top = 2
			res.border_width_left = 2
			res.border_width_bottom = 2
			res.corner_radius_top_left = 10
			res.corner_radius_bottom_left = 10
			res.expand_margin_left = 5
			res.content_margin_left = 5
			res.content_margin_right = 5
			OUT.set("theme_override_styles/normal",res)
			OUT.text = out_name
			if Global.show_debug:
				match output.val.is_true():
					Wire.States.UNDEFINED:
						OUT.text = "? | " + OUT.text
					Wire.States.CMP:
						OUT.text = "CMP | " + OUT.text
					Wire.States.TRUE:
						OUT.text = "T | " + OUT.text
					Wire.States.FALSE:
						OUT.text = "F | " + OUT.text
			slt.add_child(OUT)
		add_child(slt)
		# set slot left
		if render_input and not ( input.is_internal() ):
			self.set_slot_enabled_left(i,in_enable)
			self.set_slot_color_left(i,in_clr)
			self.set_slot_type_left(i,in_type)
		else:
			self.set_slot_enabled_left(i,false)
		# set slot right
		if render_output and not ( output.is_internal() ):
			self.set_slot_enabled_right(i,out_enable)
			self.set_slot_color_right(i,out_clr)
			self.set_slot_type_right(i,out_type)
		else:
			self.set_slot_enabled_right(i,false)
		# done
	# done
	self.queue_redraw()
	self._redrawing = false
	return

#endregion

# subclasses
