extends PanelContainer

signal MenuPressed

var _mouse_dragging := false
var _mouse_pos := Vector2.ZERO


func _process(_d: float) -> void:
	# Window Movement
	if _mouse_dragging:
		var new_pos: Vector2 
		new_pos  = DisplayServer.window_get_position()
		new_pos += get_global_mouse_position()
		new_pos -= _mouse_pos
		DisplayServer.window_set_position(new_pos)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.button_index == MOUSE_BUTTON_LEFT:
			return
		if event.pressed:
			if not _mouse_dragging:
				# Drag Start
				_mouse_dragging = true
				_mouse_pos = get_local_mouse_position()
		else:
			if _mouse_dragging:
				# Drag End
				_mouse_dragging = false
				_mouse_pos = Vector2.ZERO


func _quit_pressed() -> void:
	get_tree().quit()

func _title_pressed() -> void:
	MenuPressed.emit()
