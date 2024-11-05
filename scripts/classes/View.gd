# The name of the Class
class_name View
# The class this class extends
extends Control
# Docstring
## A loaded view that the user can switch to

# Signals
## Gets emited, when the View is loaded and ready to instantiate
signal loaded
## Gets emited, when the View is instanced
signal instanced

# Enums

# Constants

# @export variables
## Path to the Scene File
@export_file("*.tscn") var path: String = ""
## Identifier
@export var id: String = "n/a"

# public variables
var is_loaded: bool = false
var is_instanced: bool = false

var is_loading: bool = false
var progress: int = 0

var scene: PackedScene
var node: Node

# private variables

# @onready variables

# optional built-in _init() function
func _init(p_path: String = "",p_id: String = "") -> void:
	path = p_path
	id = p_id
	name = id

# optional built-in _enter_tree() function

# optional built-in _ready() function

# remaining built-in functions
func _process(_delta: float) -> void:
	if is_loading:
		var _progress: Array = []
		var _status: ResourceLoader.ThreadLoadStatus
		_status = ResourceLoader.load_threaded_get_status(path,_progress)
		match _status:
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
				print(name," - '",path,"' - Loading in Progress - ",str(_progress))
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
				print(name," - '",path,"' - Loading done")
				scene = ResourceLoader.load_threaded_get(path)
				is_loading = false
				is_loaded = true
				loaded.emit()
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
				printerr(name," - '",path,"' - Loading failed")
				is_loading = false
			_:
				pass

# virtual functions to override

# public functions
func fix() -> void:
	if node:
		node.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE
		node.owner = self
		node.set_deferred(&"size",DisplayServer.window_get_size())
		custom_minimum_size = DisplayServer.window_get_size()
		size = DisplayServer.window_get_size()
		node.visible = true
		node.move_to_front()

func start_loading() -> void:
	if not FileAccess.file_exists(path):
		return
	ResourceLoader.load_threaded_request(path,"",true)
	is_loading = true
	print(name," - '",path,"' - Loading started")
	return

func create_instance() -> void:
	if not is_loaded:
		return
	print(name," - '",path,"' - Create Instance")
	print("Can instantiate : ",scene.can_instantiate())
	_print("Instantiating")
	node = scene.instantiate()
	print(scene)
	print(node)
	_print("Adding Child")
	add_child(node)
	_print("Inside tree : "+str(node.is_inside_tree()))
	_print("Waiting for node to be ready")
	#await node.ready
	#while true:
		#if node.is_node_ready():
			#break
		#continue
	_print("Node ready")
	_print("Fixing")
	fix()
	_print("Now Instantiated")
	is_instanced = true
	instanced.emit()
	_print("Data : ")
	_print(str(node.position))
	_print(str(node.size))
	_print(str(node.visible))
	print(name," - '",path,"' - Instanced")

func delete_instance() -> void:
	if not is_loaded:
		return
	if not is_instanced:
		return
	is_instanced = false
	node.queue_free()
	
# private functions
func _print(msg: String) -> void:
	Global._print(msg)

func _printerr(msg: String) -> void:
	Global._printerr(msg)

# subclasses
