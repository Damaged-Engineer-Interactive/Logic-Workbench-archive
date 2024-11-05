extends Control


func audio_master_value_changed(val: float) -> void:
	var idx: int = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(0, val)

func audio_music_value_changed(val: float) -> void:
	var idx: int = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(1, val)


func _home_button_pressed() -> void:
	Global.change_view("Home")
