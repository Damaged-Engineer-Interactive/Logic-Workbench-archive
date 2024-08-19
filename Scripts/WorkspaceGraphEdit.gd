extends GraphEdit

func _get_connection_line(from: Vector2, to: Vector2) -> PackedVector2Array:
	var root: VBoxContainer = find_parent("Root")
	var ret: PackedVector2Array = root._draw_connection_line(from,to)
	return ret
