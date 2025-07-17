class_name FileUtil extends RefCounted

func sort_by_modified(p_files: PackedStringArray) -> PackedStringArray:
	var sorted_list: Array = []
	for path: String in p_files:
		var time: int = FileAccess.get_modified_time(path)
		sorted_list.append({ "path": path, "time": time })

	sorted_list.sort_custom(func (a: Dictionary, b: Dictionary) -> bool: return a.time < b.time)

	var final_list: PackedStringArray = []
	for file: Dictionary in sorted_list:
		final_list.append(str(file["path"]))
	return final_list # returned ascending by oldest first


func touch_directory(p_path: String) -> bool:
	if not p_path:
		Debug.log_warning("Provided path was empty.")
		return false

	if not p_path.begins_with("user://"):
		Debug.log_warning("Invalid namespace: %s" % p_path)
		return false

	if not DirAccess.dir_exists_absolute(p_path):
		var error: Error = DirAccess.make_dir_absolute(p_path)
		if error: return false
	return true


func remove_file(p_absolute_path: String, p_extension: String) -> bool:
	if p_absolute_path.ends_with(p_extension):
		var error: Error = DirAccess.remove_absolute(p_absolute_path)
		if error != OK: return false
	return true


func validate_directories(p_paths: Array[String]) -> bool:
	var success: bool = true
	for path: String in p_paths:
		if Common.Util.file.touch_directory(path):
			Debug.log_verbose("  OK: %s" % path)
		else:
			Debug.log_warning("Unable to access directory: %s" % path)
			success = false

	if success: Debug.log_debug("Validated %d directories: %s" % [p_paths.size(), p_paths])
	else: Debug.log_error("Error validating directories (check write permissions)")
	return success
