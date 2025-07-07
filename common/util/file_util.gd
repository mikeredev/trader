class_name FileUtil extends RefCounted


static func touch_directory(p_path: String) -> bool:
	if not DirAccess.dir_exists_absolute(p_path):
		var error: Error = DirAccess.make_dir_absolute(p_path)
		if error: return false
	return true
