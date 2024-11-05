# The name of the Class

# The class this class extends
extends Node
# Docstring
## short description goes here 
## 
## Long desciption goes here

# Signals

# Enums

# Constants

# @export variables

# public variables
var auth: KeyAuth
var root: VBoxContainer

# private variables

# @onready variables

# optional built-in _init() function

# optional built-in _enter_tree() function

# optional built-in _ready() function

# remaining built-in functions

# virtual functions to override

# public functions
func _print(msg : String) -> void:
	print("[GLOBAL : LOG] -> " + str(msg))

func _printerr(msg : String) -> void:
	printerr("[GLOBAL : ERR] -> " + str(msg))

func call_if_feature(features: int, function: Callable, arguments: Array):
	pass

func get_version() -> String:
	var f = FileAccess.open("res://assets/version.txt",FileAccess.READ)
	var ver: String = f.get_line()
	f.close()
	return ver

func change_view(id: String, force_implemented: bool = false) -> void:
	if root and not force_implemented:
		_print("root exist - using custom view switching")
		root.change_view(id)
	# root unavailable
	_print("root does not exist - using tree view switching")
	if not FileAccess.file_exists("res://scenes/views/"+id+".tscn"):
		push_error("View does not exist!")
	get_tree().change_scene_to_file("res://scenes/views/"+id+".tscn")

# private functions

# subclasses
