class_name FileUtil extends RefCounted


func touch_directory(p_path: String) -> bool:
	if not DirAccess.dir_exists_absolute(p_path):
		var error: Error = DirAccess.make_dir_absolute(p_path)
		if error: return false
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
