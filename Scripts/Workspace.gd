# The name of the Class

# The class this class extends
extends VBoxContainer
# Docstring
## The class used to control the Workspace and simulation
## 
## I dont even care why are you reading this ??

# Signals

# Enums

# Constants
const SEPARATOR: StyleBoxFlat = preload("res://Assets/Separator.stylebox")

# @export variables

# public variables
var circuit: Circuit

# gate.id : gate
var selected: Dictionary

# private variables
var _available_gates: Dictionary

var _last_added_gate: LogicGate

var _loaded_gates: bool = false
# @onready variables
@onready var workspace: GraphEdit = $Center/Workspace
@onready var wire_layer: Control = workspace.get_child(0,true)

# optional built-in _init() function

# optional built-in _enter_tree() function
func _enter_tree():
	circuit = Circuit.new({"master":true})
	circuit.name = "Master"
	# Initialise Gates
	_init_gates()
	print("\n\n")

# optional built-in _ready() function
func _ready():
	_on_simulate_wait_time_drag_ended(true)
	# connect popup signals
	$TopBar/MenuHolder/Menu.get_popup().index_pressed.connect(_on_menu_popup)
	$TopBar/MenuHolder/Chip.get_popup().index_pressed.connect(_on_chip_popup)
	$TopBar/MenuHolder/View.get_popup().index_pressed.connect(_on_view_popup)
	$TopBar/MenuHolder/Music.get_popup().index_pressed.connect(_on_music_popup)
	# play music
	var target_db := AudioServer.get_bus_volume_db(1)
	AudioServer.set_bus_volume_db(1,-80)
	# start playing music
	MusicManager.play_playlist.emit(Global.playlist,true,false,false,0.0)
	# fade in
	var current_db := AudioServer.get_bus_volume_db(1)
	while current_db < target_db:
		current_db += 1
		AudioServer.set_bus_volume_db(1,current_db)
	_on_update_io_pressed()
	print("_ready() - Done \n\n")

# remaining built-in functions
func _process(_d):
	$Center/SideBar/TabContainer/Debug/Container/FPS.text = "FPS : %s" % str(Engine.get_frames_per_second())
	$TopBar/MenuHolder/Zoom.text = str(int(workspace.zoom * 100)) + "%"

func _on_simulate_timer_timeout():
	_on_simulate_pressed()

#region workspace
func _on_workspace_gui_input(event):
	if event is InputEventMouseButton:
		pass

func _on_workspace_popup_request(pos):
	if selected.size() == 0:
		return
	if selected.size() == 1:
		$ChipMenu.set_item_text(0,selected.values()[0].class_str)
		$ChipMenu.set_item_disabled(1,false) # enable "view"
	else:
		$ChipMenu.set_item_text(0,"Multiple Gates")
		$ChipMenu.set_item_disabled(1,true) # disable "view"
	$ChipMenu.position = pos
	$ChipMenu.show()

func _draw_connection_line(from: Vector2, to: Vector2) -> PackedVector2Array:
	var x_diff: float = to.x - from.x
	var cp_offset: float = x_diff * workspace.connection_lines_curvature
	if x_diff < 0:
		cp_offset *= -1
	
	var curve := Curve2D.new()
	curve.add_point(from)
	curve.set_point_out(0,Vector2(cp_offset,0))
	curve.add_point(to)
	curve.set_point_in(1,Vector2(-cp_offset,0))
	
	if workspace.connection_lines_curvature > 0:
		return curve.tessellate(5,2.0)
	else:
		return curve.tessellate(1)

func _on_workspace_node_selected(node: LogicGate):
	selected[node.id] = node

func _on_workspace_node_deselected(node: LogicGate):
	selected.erase(node.id)

func _on_workspace_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int,use_circuit: bool = true) -> void:
	if workspace.is_node_connected(from_node,from_port,to_node,to_port):
		Result.new(ERR_ALREADY_EXISTS,null,"Workspace::_on_workspace_connection_request() - Fail : Already exists",Result.Types.ERROR)
		return
	if use_circuit:
		var from_res: Result = circuit.get_gate(from_node)
		if from_res.is_error():
			Result.new(-1,null,"Workspace::_on_workspace_connection_request() - Fail : Unknown Error",Result.Types.ERROR)
		var from: LogicGate = from_res.data
		
		var to_res: Result = circuit.get_gate(to_node)
		if to_res.is_error():
			Result.new(-1,null,"Workspace::_on_workspace_connection_request() - Fail : Unknown Error",Result.Types.ERROR)
		var to: LogicGate = to_res.data
		
		var connection := Connection.new(from,from_port,to,to_port)
		var res: Result = circuit.add_connection(connection)
		if res.is_error():
			return Result.new(-1,null,"Workspace::_on_workspace_connection_request() - Fail : Unknown Error",Result.Types.ERROR)
	workspace.connect_node(from_node,from_port,to_node,to_port)
	Result.new(OK,null,"Workspace::_on_workspace_connection_request() - Success")

func _on_workspace_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var from_res: Result = circuit.get_gate(from_node)
	if from_res.is_error():
		Result.new(-1,null,"Workspace::_on_workspace_disconnection_request() - Fail : Unknown Error",Result.Types.ERROR)
	var from: LogicGate = from_res.data
	
	var to_res: Result = circuit.get_gate(to_node)
	if to_res.is_error():
		Result.new(-1,null,"Workspace::_on_workspace_disconnection_request() - Fail : Unknown Error",Result.Types.ERROR)
	var to: LogicGate = to_res.data
	
	var connection := Connection.new(from,from_port,to,to_port)
	var res: Result = circuit.remove_connection(connection)
	if res.is_error():
		return Result.new(-1,null,"Workspace::_on_workspace_disconnection_request() - Fail : Unknown Error",Result.Types.ERROR)
	workspace.disconnect_node(from_node,from_port,to_node,to_port)
	Result.new(OK,null,"Workspace::_on_workspace_disconnection_request() - Success")

#endregion

func _add_gate(n: String) -> void:
	var gate: LogicGate = _available_gates[n]
	var needed = gate._options()
	var options: Dictionary = {"override":true,"gate_name":"<workspace::undefined>"}
	options.merge(needed,false)
	if needed.size() > 0: # config needed
		var opt: VBoxContainer = $SetupOptions/VBoxContainer/Options
		# remove old options
		for child in opt.get_children():
			opt.remove_child(child)
		# add new options
		var values: Dictionary = {}
		for need: String in needed.keys():
			var hbox := HBoxContainer.new()
			hbox.name = need
			hbox.alignment = BoxContainer.ALIGNMENT_CENTER
			var label := Label.new()
			label.text = need
			hbox.add_child(label)
			var SEP := VSeparator.new()
			hbox.add_child(SEP)
			var VAL
			match needed[need]:
				LogicGate.OptionTypes.STRING:
					VAL = $VAL_STRING.duplicate()
					VAL.name = "Value"
					VAL.visible = true
					hbox.add_child(VAL)
				LogicGate.OptionTypes.INT:
					VAL = $VAL_INT.duplicate()
					VAL.name = "Value"
					VAL.visible = true
					hbox.add_child(VAL)
				LogicGate.OptionTypes.SIZES:
					VAL = $VAL_SIZES.duplicate()
					VAL.name = "Value"
					VAL.visible = true
					hbox.add_child(VAL)
				_:
					Result.new(ERR_UNCONFIGURED,self,"Workspace::_add_gate() - Fail : SetupOptionType does not exist")
			values[need] = VAL
			opt.add_child(hbox)
		$SetupOptions.show()
		await $SetupOptions/VBoxContainer/BottomRow/Create.pressed
		for need: String in values.keys():
			var val = values[need]
			match needed[need]:
				LogicGate.OptionTypes.STRING:
					val = val.text
				LogicGate.OptionTypes.INT:
					val = val.value
				LogicGate.OptionTypes.SIZES:
					val = val.get_selected_id()
			options[need] = val
		$SetupOptions.hide() # hide popup
	var src = gate.get_script()
	gate = src.new(options)
	$Center/Workspace.add_child(gate)
	circuit.add_gate(gate)
	_last_added_gate = gate
	_on_update_io_pressed()

func _remove_gate(gates: Array[StringName]) -> void:
	for n: StringName in gates:
		for child in workspace.get_children():
			if child.name != n:
				continue
			circuit.remove_gate(child)
			workspace.remove_child(child)

func _on_cancel_pressed():
	$SetupOptions.hide()

func _on_zoom_pressed():
	workspace.zoom = 1

func _on_arange_pressed():
	workspace.arrange_nodes()

# virtual functions to override
func _on_menu_popup(idx: int) -> void:
	match idx:
		0: # Credits
			$Credits.popup_centered()

func _on_chip_popup(idx: int) -> void:
	match idx:
		0: # New
			for connection: Connection in circuit._connections.values():
				_on_workspace_disconnection_request(connection.src_gate.name,connection.src_output,connection.dest_gate.name,connection.dest_input)
			for gate: LogicGate in circuit._gates.values():
				_remove_gate([gate.name])
			circuit.clear()
		1: # Save
			$SaveOptions.show()
		2: # Load
			$LoadOptions.show()

func _on_view_popup(idx: int) -> void:
	match idx:
		0: # Minimap
			workspace.minimap_enabled = not workspace.minimap_enabled
		1: # Center
			pass
		2: # Arange
			workspace.arrange_nodes()

func _on_music_popup(idx: int) -> void:
	var menu: PopupMenu = $TopBar/MenuHolder/Music.get_popup()
	match idx:
		0: # enable
			menu.set_item_checked(idx,not menu.is_item_checked(idx))
			match menu.is_item_checked(idx):
				false:
					MusicManager.stop_music.emit()
					menu.set_item_text(2,"N/A")
				true:
					MusicManager.play_playlist.emit(Global.playlist,true,false,false,0.0)
					menu.set_item_text(2,Global.logic_everflowing.name)

# public functions

# private functions
func _init_gates() -> void:
	# Load internal gates first
	if not ( _loaded_gates ):
		var int_dir := DirAccess.open("res://Scripts/Simulation/Gates")
		int_dir.list_dir_begin()
		var int_file = int_dir.get_next()
		while int_file != "":
			if int_dir.current_is_dir():
				var p = "res://Scripts/Simulation/Gates/" + int_file
				_load_dir_gates(p)
			else:
				var p = "res://Scripts/Simulation/Gates/" + int_file
				_load_internal_gate(p)
			int_file = int_dir.get_next()
		_loaded_gates = true
	# load external gates
	var path: String = Global.chip_save_dir.format({"project":Global.current_project_name})
	if DirAccess.dir_exists_absolute(path):
		var dir := DirAccess.open(path)
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				var p = path + "/" + file_name
				_load_dir_gates(p)
			else:
				var p = path + "/" + file_name
				_load_external_gate(p)
	else:
		DirAccess.make_dir_recursive_absolute(path)
		return

func _load_dir_gates(path: String) -> void:
	var dir := DirAccess.open(path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			var p = path + "/" + file_name
			_load_dir_gates(p)
		else:
			var p: String = path + "/" + file_name
			if p.begins_with("res://"):
				_load_internal_gate(p)
			else:
				_load_external_gate(p)
		file_name = dir.get_next()

func _load_internal_gate(path: String) -> void:
	if path.get_base_dir().split("/")[-1].begins_with("#"): # skip dir starting with "#"
		return
	var folder: String = path.get_base_dir().split("/")[-1]
	var folder_node: VBoxContainer
	for child in $Center/SideBar/TabContainer/Gates/Scroll/Container.get_children():
		if child.name == folder:
			folder_node = child
			break
	if folder_node == null:
		folder_node = _make_folder_node(folder)
		$Center/SideBar/TabContainer/Gates/Scroll/Container.add_child(folder_node)
	var src: GDScript = load(path)
	src.reload()
	var d : LogicGate = src.new({"preview":true})
	assert(d.get_script() == src,"Script mismatch")
	_available_gates[d.class_str] = d
	var btn = Button.new()
	btn.text = d.short
	btn.name = d.short
	btn.tooltip_text = d.class_str + "\n" + d.description
	btn.pressed.connect(_add_gate.bind(d.class_str))
	folder_node.add_child(btn)

func _load_external_gate(path: String) -> void:
	var folder: String = path.get_base_dir().split("/")[-1]
	print(folder)
	var folder_node: VBoxContainer
	for child in $Center/SideBar/TabContainer/Gates/Scroll/Container.get_children():
		if child.name == folder:
			folder_node = child
			break
	if folder_node == null:
		folder_node = _make_folder_node(folder)
		$Center/SideBar/TabContainer/Gates/Scroll/Container.add_child(folder_node)
	var res := Circuit.new({"load":path,"preview":true})
	_available_gates[res.class_str] = res
	var btn = Button.new()
	btn.text = res.short
	btn.name = res.short
	btn.tooltip_text = res.class_str + "\n" + res.description
	btn.pressed.connect(_add_gate.bind(res.class_str))
	folder_node.add_child(btn)

func _make_folder_node(n: String) -> VBoxContainer:
	var res := VBoxContainer.new()
	res.name = n
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0,20)
	res.add_child(spacer)
	var label := Label.new()
	label.text = n
	label.name = "LABEL"
	res.add_child(label)
	return res

# subclasses


func _on_allow_simulate_toggled(val: bool):
	Global.allow_simulate = val

func _on_show_debug_toggled(val: bool):
	Global.show_debug = val
	get_tree().call_group(&"Gates",&"request_redraw",true)

func _on_redraw_pressed():
	get_tree().call_group(&"Gates",&"request_redraw",true)

func _on_simulate_pressed():
	update_inputs()
	circuit.simulate()
	update_outputs()
	_on_redraw_pressed()

func _on_update_io_pressed():
	update_inputs()
	update_outputs()

#region IO
func update_inputs():
	var container: VBoxContainer = $Center/SideBar/TabContainer/IO/Scroll/Container/Inputs
	# clear
	for child in container.get_children():
		if child.name == "LABEL":
			continue
		elif child.name == "SEP":
			continue
		elif int(str(child.name)) in circuit.inputs.keys():
			continue
		else:
			container.remove_child(child)
			child.queue_free()
	# make new
	for key: int in circuit.inputs.keys():
		if key == 0: # skip cmp
			continue
		var skip: bool = false
		for child in container.get_children():
			if str(child.name) == str(key):
				skip = true
				break
		if skip:
			continue
		var input: InternalInput = circuit.get_input(key).data
		var slt: VBoxContainer = _make_slot(key,input.name,input.val,false)
		container.add_child(slt)
	# set values
	for child in container.get_children():
		if child.name == "LABEL":
			continue
		elif child.name == "SEP":
			continue
		var input_name: String = child.get_child(0).text
		var input: InternalInput = circuit.find_input(input_name).data
		var val: Wire = input.val
		for slt in child.get_children():
			if slt.name == "LABEL":
				continue
			val.set_bit(int(str(slt.name)),slt.button_pressed)
		circuit.set_input(input.slot,input)

func update_outputs():
	var container: VBoxContainer = $Center/SideBar/TabContainer/IO/Scroll/Container/Outputs
	# clear
	for child in container.get_children():
		if child.name == "LABEL":
			continue
		elif child.name == "SEP":
			continue
		container.remove_child(child)
		child.queue_free()
	# set
	for key: int in circuit.outputs.keys():
		if key == 0: # skip cmp
			continue
		var output: InternalOutput = circuit.get_output(key).data
		var slt: VBoxContainer = _make_slot(key,output.name,output.val,true)
		container.add_child(slt)

func _make_slot(slt: int, n: String,v: Wire,disable: bool) -> VBoxContainer:
	var RES := VBoxContainer.new()
	RES.name = str(slt)
	var LABEL := Label.new()
	LABEL.name = "LABEL"
	LABEL.text = n
	RES.add_child(LABEL)
	var values: Array[bool] = v.get_value().data
	for i: int in range(values.size()):
		var VAL := CheckBox.new()
		VAL.name = str(i)
		VAL.text = "BIT" + str(i)
		VAL.button_pressed = values[i]
		VAL.disabled = disable
		# connect signal
		VAL.pressed.connect(on_slot_updated)
		# set overrides
		var font_clr := Color.WHITE
		VAL.set("theme_override_constants/h_separation",10)
		VAL.set("theme_override_colors/font_color",font_clr)
		VAL.set("theme_override_colors/font_pressed_color",font_clr)
		VAL.set("theme_override_colors/font_hover_color",font_clr)
		VAL.set("theme_override_colors/font_hover_pressed_color",font_clr)
		VAL.set("theme_override_colors/font_focus_color",font_clr)
		VAL.set("theme_override_colors/font_disabled_color",font_clr)
		VAL.set("theme_override_colors/font_outline_color",font_clr)
		VAL.set("theme_override_styles/focus",StyleBoxEmpty.new())
		# add 
		RES.add_child(VAL)
	return RES
#endregion

func on_slot_updated():
	_on_redraw_pressed()

func _on_simulate_wait_time_drag_ended(changed: bool):
	if changed:
		var slider: HSlider = $Center/SideBar/TabContainer/Debug/Container/SimulateWaitTime
		if slider.value > 0:
			$SimulateTimer.wait_time = slider.value / 1000
			$SimulateTimer.start()
		else:
			$SimulateTimer.wait_time = 1
			$SimulateTimer.stop()


func _on_credits_close_pressed():
	$Credits.hide()



func _on_save_cancel_pressed():
	$SaveOptions.hide()

func _on_load_cancel_pressed():
	$LoadOptions.hide()

func _on_save_pressed():
	var priority: int = $SaveOptions/VBoxContainer/Options/priority/Value.value
	var short: String = $SaveOptions/VBoxContainer/Options/short/Value.text
	var nme: String = $SaveOptions/VBoxContainer/Options/name/Value.text
	var description: String = $SaveOptions/VBoxContainer/Options/description/Value.text
	circuit.priority = priority
	circuit.short = short
	circuit.gate_name = nme
	circuit.class_str = nme
	circuit.description = description
	circuit.is_master = false
	var res: Result = circuit.save_cfg()
	var path: String = res.data
	_on_chip_popup(0) # clear
	# load gate into the game
	_load_external_gate(path)
	_on_save_cancel_pressed() # close popup

func _on_load_pressed():
	var short: String = $LoadOptions/VBoxContainer/Options/short/Value.text
	var gte: LogicGate
	for gate: LogicGate in _available_gates.values():
		if gate.short == short:
			gte = gate
			break
	if not gte.check_inherited("Circuit"):
		return
	_on_chip_popup(0) # clear
	circuit = gte
	gte.is_master = true
	for gate: LogicGate in circuit._gates.values():
		workspace.add_child(gate)
	for connection: Connection in circuit._connections.values():
		_on_workspace_connection_request(connection.src_gate.name,connection.src_output,connection.dest_gate.name,connection.dest_input,false)
	_on_load_cancel_pressed()
