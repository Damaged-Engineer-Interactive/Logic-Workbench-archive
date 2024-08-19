# The name of the Class
class_name Project
# The class this class extends
extends Node
# Docstring
## Holds data of a Logic Workbench Project
## 
## Used to store / load / export / import projects

# Signals

# Enums

# Constants

# @export variables
@export_category("Data")
## The latest version of the save file format
@export var version: int = 1

@export_category("Information")
## The name of the project
@export var project_name: String = "<undefined.name>"


# public variables
var id: StringName

# private variables

# @onready variables

# optional built-in _init() function
func _init(n: String):
	project_name = n
	if not DirAccess.dir_exists_absolute(Global.project_path.format({"project":project_name})):
		DirAccess.make_dir_recursive_absolute(Global.project_path.format({"project":project_name}))
	save_cfg()
# optional built-in _enter_tree() function

# optional built-in _ready() function

# remaining built-in functions
func _to_string() -> String:
	return "<%s>" % project_name

# virtual functions to override
func save_cfg() -> Result:
	# Create path variable
	var save = Global.data_save_path.format({"project":project_name})
	# make new file
	DirAccess.make_dir_recursive_absolute(save.get_base_dir())
	var f = FileAccess.open(save,FileAccess.WRITE)
	f.close()
	# Create
	var cfg := ConfigFile.new()
	cfg.clear()
	# Secton : Data
	cfg.set_value("Data","version",version )
	# Section : Information
	cfg.set_value("Information","project_name",project_name)
	# Save
	var err = cfg.save(save)
	if err != OK:
		return Result.new(err,cfg,_id_fmt(save_cfg,true,"An unknown error has occured!"))
	# Done
	return Result.new(OK,cfg,_id_fmt(save_cfg,false))

func load_cfg() -> Result:
	# Create path variable
	var save = Global.data_save_path.format({"project":project_name})
	# Create
	var cfg := ConfigFile.new()
	cfg.clear()
	# Load
	var err = cfg.load(save)
	if err != OK:
		return Result.new(err,cfg,_id_fmt(load_cfg,true,"An unknown error has occured!"))
	# Secton : Data
	version = cfg.get_value("Data","version",version)
	# Section : Information
	project_name = cfg.get_value("Information","project_name",project_name)
	# Done
	return Result.new(OK,cfg,_id_fmt(load_cfg,false))

# public functions

# private functions
func _id_fmt(function: Callable,fail: bool,reason: String = "") -> String:
	var raw_str := "<{id}> Project::{function}() - {state}"
	var f := ""
	if fail:
		f = "Fail : %s" % reason
	else:
		f = "Success"
	return raw_str.format({"id":name,"function":function.get_method(),"state":f})

# subclasses
