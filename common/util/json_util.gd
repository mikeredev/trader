class_name JSONUtil extends RefCounted


func convert_to(p_type: Variant.Type, p_string: Variant) -> Variant:
	match p_type:
		TYPE_VECTOR2I: # expected format "(640, 360)"
			var converted: Vector2i = Vector2i.ZERO
			var split: PackedStringArray = str(p_string).split(",")
			if not split.size() == 2:
				Debug.log_warning("Unable to convert to Vector2: %s" % str(p_string))
				return converted
			converted.x = int(split[0])
			converted.y = int(split[1])
			return converted
		_:
			Debug.log_warning("Unable to convert to %s: %s" % [p_type, str(p_string)])
			return null


#static func get_dict(p_dict: Dictionary) -> Dictionary[String, Dictionary]:
	#var result: Dictionary[String, Dictionary] = {}
	#for key: String in p_dict.keys():
		#result[key] = p_dict[key]
	#return result


func get_dict(p_path: String) -> Dictionary[Variant, Variant]:
	Debug.log_verbose("󰘦  Loading JSON: %s" % p_path)
	if not FileAccess.file_exists(p_path):
		Debug.log_warning("File does not exist: %s" % p_path)
		return {}

	var string: String = FileAccess.get_file_as_string(p_path)
	if not string:
		Debug.log_warning("Error reading: %s" % p_path)
		return {}

	# cast as variant to handle errors
	var json: Variant = JSON.parse_string(string)
	if not json:
		Debug.log_warning("Error parsing: %s" % p_path)
		return {}

	if not typeof(json) == TYPE_DICTIONARY:
		Debug.log_warning("Not a valid dictionary: %s" % p_path)
		return {}

	var dict: Dictionary[Variant, Variant] = json
	return dict # only return if object is a valid Dictionary


func save_dict(p_path: String, p_data: Dictionary) -> void:
	var json_string: String = JSON.stringify(p_data, "\t")
	var file: FileAccess = FileAccess.open(p_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		Debug.log_debug("Saved JSON: %s" % p_path)
	else:
		Debug.log_error("Could not open for writing: %s" % p_path) # TBD create alert event on failure
