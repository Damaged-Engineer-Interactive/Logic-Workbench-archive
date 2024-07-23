extends Node

func make_id() -> Result:
	var id = PackedByteArray()
	for _a in range(16):
		id.append(randi()%256)
	
	var id_str: String = "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x" % [
			id[0], id[1], id[2], id[3],
			id[4], id[5], id[6], id[7],
			id[8], id[9], id[10], id[11],
			id[12], id[13], id[14], id[15] ]
	
	var id_strn := StringName(id_str)
	
	return Result.new(OK,id_strn,"Global::make_id()")
