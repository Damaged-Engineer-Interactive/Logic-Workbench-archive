extends Node

# RPC related
var is_working: bool = false
var current_scene: String = "In the Workspace"
var quote: String = "":
	set = _set_quote

const QUOTES: Array[String] = [
	"What the hell is going on?",
	"What am I doing here?",
	"Why wont my Circuit work?",
	"There are too many wires",
	"01001000100101000",
	"If you make a bad circuit, dont blame the game, blame yourself",
	"Always blame @justmindfulyt",
	"2 bits might not be much but when they work together they can carry one"
]

# Save / Load
@export var current_project: Project
@export var current_project_name: String
const chip_format: String = "{priority}_{class_name}"
const chip_save_path: String = "user://projects/{project}/chip/{chip}.lw"
const data_save_path: String = "user://projects/{project}/data.lw"
const chip_save_dir: String = "user://projects/{project}/chip"
const project_dir: String = "user://projects"
const project_path: String = "user://projects/{project}"

# LogicGate
var panel: StyleBoxFlat = preload("res://Assets/Simulation/LogicGate/Panel.stylebox")
var panel_selected: StyleBoxFlat = preload("res://Assets/Simulation/LogicGate/Panel_Selected.stylebox")
var titelbar: StyleBoxFlat = preload("res://Assets/Simulation/LogicGate/Titlebar.stylebox")
var titelbar_selected: StyleBoxFlat = preload("res://Assets/Simulation/LogicGate/Titlebar_Selected.stylebox")

# Workspace
var allow_simulate: bool = true
var show_debug: bool = false

# Songs
var logic_everflowing: MusicTrack

var playlist: MusicPlaylist

func _init():
	Result.new(OK,null,"Global::_ready() : Start")
	_discord_rpc()
	_change_quote()
	var tmr := Timer.new()
	tmr.wait_time = 60
	tmr.timeout.connect(_change_quote)
	tmr.autostart = true
	add_child(tmr)
	logic_everflowing = MusicTrack.new()
	logic_everflowing.name = "Logic Everflowing"
	logic_everflowing.artist = "Riplostrat"
	logic_everflowing.track = preload("res://Music/LogicEverflowing.wav")
	playlist = MusicPlaylist.new()
	playlist.name = "Logic Workbench"
	playlist.tracks.append(logic_everflowing)
	Result.new(OK,null,"Global::_ready() : Success")

func _enter_tree():
	current_project = Project.new("Main")
	current_project_name = "Main"

func _change_quote():
	if not is_working:
		return
	var new: String = QUOTES.pick_random()
	while new == quote:
		new = QUOTES.pick_random()
	quote = '"%s"' % new

func _set_current(v: String):
	current_scene = v
	if not is_working:
		return
	DiscordRPC.details = v
	DiscordRPC.refresh()

func _set_quote(v: String):
	quote = v
	if not is_working:
		return
	DiscordRPC.state = v
	DiscordRPC.refresh()

func change_scene(scene: PackedScene,n: String):
	_set_current(n)
	get_tree().change_scene_to_packed(scene)


# discord rpc setup
func _discord_rpc() -> void:
	# Application ID
	DiscordRPC.app_id = 1237469970208784394
	# this is boolean if everything worked
	#print("Discord working: " + str(DiscordRPC.get_is_discord_working()))
	if DiscordRPC.get_is_discord_working():
		is_working = true
		Result.new(OK,null,"DiscordRPC::get_is_discord_working() - Success",Result.Types.LOG)
	else:
		Result.new(ERR_DOES_NOT_EXIST,null,"DiscordRPC::get_is_discord_working() - Fail",Result.Types.LOG)
		return
	# Set the first custom text row of the activity here
	DiscordRPC.details = current_scene
	# Set the second custom text row of the activity here
	DiscordRPC.state = quote
	# "02:41 elapsed" timestamp for the activity
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	# Always refresh after changing the values!
	DiscordRPC.refresh() 

func exit():
	Wrapper.close()

func parse_text(t: String) -> Result:
	if t.find("[") == -1:
		return Result.new(OK,t,"Global::parse_text() - Success")
	var regex = RegEx.new()
	regex.compile("\\[.*?]\\")
	for result: RegExMatch in regex.search_all(t):
		var start = result.get_start()
		var count = result.get_end() - start
		var code = result.get_string()
		t.erase(start,count) # Remove code
		if code.replace("[","").replace("]","").is_valid_hex_number(true):
			code = "[color=#%s]" % code.replace("0x","")
		else: # is no hex color
			match code:
				"[code]":
					pass
				"[b]":
					pass
				"[i]":
					pass
				"[u]":
					pass
				_: # No match -> just continue
					continue
		t.insert(start,code)
	t.insert(0,"[center]")
	return Result.new(OK,t,"Global::parse_text() - Success")


func make_id() -> Result:
	var id = PackedByteArray()
	for _a in range(16):
		id.append(randi()%256)
	
	var id_str: String = "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x" % [
			id[0], id[1], id[2], id[3],
			id[4], id[5], id[6], id[7],
			id[8], id[9], id[10], id[11],
			id[12], id[13], id[14], id[15] ]
	
	var id_strn := StringName(id_str)
	
	return Result.new(OK,id_strn,"Global::make_id() - Success")
