extends Node

func make_uuid() -> Result:
	var uuid = PackedByteArray()
	for _a in range(16):
		uuid.append(randi()%256)
	
	# Set version to 4
	uuid[6] = (uuid[6] & 0x0F) | 0x40
	# Set variant to DCE 1.1
	uuid[8] = (uuid[8] & 0x3F) | 0x80
	
	var uuid_str: String = "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x" % [
		uuid[0], uuid[1], uuid[2], uuid[3],
		uuid[4], uuid[5], uuid[6], uuid[7],
		uuid[8], uuid[9], uuid[10], uuid[11],
		uuid[12], uuid[13], uuid[14], uuid[15] ]
	
	return Result.new(OK,uuid_str)
