extends Control

func _ready() -> void:
	var ver: String = ProjectSettings.get_setting("application/config/version","N/A")
	$BottomPart/VersionLabel.text = "Version : %s    " % ver


func _home_button_pressed() -> void:
	Global.change_view("Home")
