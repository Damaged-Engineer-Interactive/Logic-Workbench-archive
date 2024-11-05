# The name of the Class

# The class this class extends
extends VBoxContainer
# Docstring

# Signals
signal view_loading_done

# Enums

# Constants

# @export variables
@export var first_view: String = "Home" # Home View
@export var set_global_vars: bool = true

# public variables
## ID of the current view
var current_view: View

# private variables
var _loaded_views: Dictionary = {}

# @onready variables

# optional built-in _init() function

# optional built-in _enter_tree() function

# optional built-in _ready() function
func _ready() -> void:
	# check if packages can be imported or dir doesnt exist
	if not DirAccess.dir_exists_absolute("user://packs"): # Dir does not exist
		DirAccess.make_dir_recursive_absolute("user://packs") # Make directory, continue _ready
	else: # Directory Exists
		var dir = DirAccess.open("user://packs")
		if dir:
			dir.list_dir_begin()
			var file_name: String = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir():
					if file_name.get_extension() == "pck": # Load Pack
						ProjectSettings.load_resource_pack("user://packs/" + file_name, true, 0)
				file_name = dir.get_next()
	if set_global_vars:
		Global.auth = $KeyAuth
		Global.root = self
		# Continue _ready
		_load_views()
		await view_loading_done
		_print("All views loaded!\n"+str(_loaded_views.keys()))
		_print("Loading view : " + str(first_view))
		Global.change_view(first_view)
	else:
		Global.change_view(first_view, true)
		return

# remaining built-in functions

# virtual functions to override

# public functions
func change_view(id: String) -> void:
	if current_view:
		if current_view.id == id:
			return
		if current_view.id != "":
			# Clear view
			@warning_ignore("confusable_local_declaration")
			#$Background.remove_child(current_view)
			#$Background.show()
			remove_child(current_view)
			current_view.delete_instance()
			current_view = null
	if not ( id in _loaded_views.keys() ):
		printerr("view with id <",id,"> does not exist!")
		return
	print("view chosen!")
	$Background/Loading.show()
	var view: View = _loaded_views[id]
	_print(str(view.get_parent()))
	#$Background.add_child(view)
	add_child(view)
	view.create_instance()
	current_view = view
	$Background.hide()
	$Background/Loading.hide()
	print("view instanced")
	_print(str(view.position))
	_print(str(view.size))
	_print(str(view.visible))

# private functions
func _load_views(path: String = "res://scenes/views") -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				_load_views(path + "/" + file_name)
			else:
				if file_name.get_extension() == "tscn":
					await _load_view(path + "/" + file_name)
			file_name = dir.get_next()
	else:
		printerr("An error occurred when trying to load the views.")
	view_loading_done.emit()

func _load_view(path: String) -> void:
	var slice_count: int = path.get_slice_count("/") - 1
	var id: String = path.get_basename().get_slice("/",slice_count)
	var view := View.new(path,id)
	$Temp.add_child(view)
	view.start_loading()
	await view.loaded
	$Temp.remove_child(view)
	_loaded_views[id] = view
	print("Loaded view : '" + path + "' <" + id + ">")

func _print(msg: String) -> void:
	Global._print(msg)

func _printerr(msg: String) -> void:
	Global._printerr(msg)


# subclasses
