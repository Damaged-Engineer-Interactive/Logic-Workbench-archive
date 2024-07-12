extends Node2D

var MM = "MainMenu"
var SM = "SettingsMenu"
var NPM = "NewProjectMenu"
var LPM = "LoadProjectMenu"
var CM = "CreditsMenu"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node(MM).show()
	get_node(SM).hide()
	get_node(NPM).hide()
	get_node(LPM).hide()
	get_node(CM).hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_new_project_button_up():
	get_node(MM).hide()
	get_node(NPM).show()

func _on_load_project_button_up():
	get_node(MM).hide()
	get_node(LPM).show()


func _on_settings_button_up():
	get_node(MM).hide()
	get_node(SM).show()


func _on_credits_button_up():
	get_node(MM).hide()
	get_node(CM).show()


func _on_exit_button_up():
	get_tree().quit()
	return

func _on_back_settings_button_up():
	get_node(MM).show()
	get_node(SM).hide()


func _on_back_np_button_up():
	get_node(MM).show()
	get_node(NPM).hide()


func _on_back_lp_button_up():
	get_node(MM).show()
	get_node(LPM).hide()


func _on_back_credits_button_up():
	get_node(MM).show()
	get_node(CM).hide()
