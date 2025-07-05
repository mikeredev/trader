class_name InitState extends ActiveState

var node_tree: Array[Node]


func _init(p_node_tree: Array[Node]) -> void:
	state_id = "init"
	node_tree = p_node_tree


func _main() -> void:
	if not validate_userspace(): return
	if not build_tree():
		Debug.log_error("Error building node tree")
		return
	set_project_settings()
	apply_config()

	var active_mods: PackedStringArray = Service.config_manager.get_active_mods()
	System.change_state(SetupState.new(active_mods))


func _start_services() -> void:
	System.start_service(SceneManager.new(), Service.ServiceType.SCENE_MANAGER)
	System.start_service(ConfigManager.new(), Service.ServiceType.CONFIG_MANAGER)
	System.start_service(DialogManager.new(), Service.ServiceType.DIALOG_MANAGER)


func validate_userspace() -> bool: # confirm write access to user directories
	Debug.log_info("Validating userspace...")
	var success: bool = true
	var user_directories: Array[String] = [
		FileLocation.USER_ROOT_MOD_DIR,
		FileLocation.USER_ROOT_SAVE_DIR,
		FileLocation.USER_ROOT_SETTINGS_DIR ]

	for path: String in user_directories:
		if Common.Util.touch_directory(path): # create if not existing
			Debug.log_verbose("  OK: %s" % path)
		else:
			Debug.log_warning("Unable to access directory: %s" % path)
			success = false

	if success: Debug.log_debug("Success: %s" % success)
	else: Debug.log_error("Error accessing userspace (check write permissions)")
	return success


func build_tree() -> bool:
	Debug.log_info("Building node tree...")
	return Service.scene_manager.build_tree(node_tree)


func apply_config() -> void:
	Debug.log_info("Applying user config...")
	Service.config_manager.load_config()
	Service.config_manager.apply_config()


func set_project_settings() -> void:
	Debug.log_info("Setting project settings...")
	for s: String in Common.PROJECT_SETTINGS:
		ProjectSettings.set_setting(s, Common.PROJECT_SETTINGS[s])
		Debug.log_debug("Set %s: %s" % [s, Common.PROJECT_SETTINGS[s]])
