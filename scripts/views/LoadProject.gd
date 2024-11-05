extends Control

func _ready() -> void:
	var ver: String = Global.get_version()
	$BottomPart/VersionLabel.text = "Version : %s    " % ver


func _cancel_button_pressed() -> void:
	Global.change_view("Home")


func _load_button_pressed() -> void:
	pass


func _project_list_item_selected(index: int) -> void:
	pass
