extends Control

func _ready() -> void:
	var ver: String = Global.get_version()
	$BottomPart/VersionLabel.text = "Version : %s    " % ver

func _new_project_pressed() -> void:
	Global.change_view("NewProject")


func _load_project_pressed() -> void:
	Global.change_view("LoadProject")


func _settings_pressed() -> void:
	Global.change_view("Settings")


func _user_pressed() -> void:
	Global.change_view("User")


func _credits_pressed() -> void:
	Global.change_view("Credits")


func _quit_pressed() -> void:
	get_tree().quit()
