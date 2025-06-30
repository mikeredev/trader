class_name BootstrapState extends ActiveState

var node_tree: Array[Node]


func _init(p_node_tree: Array[Node]) -> void:
	name = "Boot"
	node_tree = p_node_tree


func _main() -> void:
	# confirm write access to user directory
	if not validate_userspace():
		Debug.log_error("Error accessing userspace (check write permissions)")
		return

	# create node tree
	if not build_tree():
		Debug.log_error("Error building node tree")
		return

	# apply project-level runtime settings
	set_project_settings()

	# apply user configuration
	apply_config()

	# next
	var active_mods: PackedStringArray = Service.config_manager.get_active_mods()
	Service.state_manager.change_state(SetupState.new(active_mods))


func _start_services() -> void:
	Debug.log_info("Starting services...")
	AppContext.start_service(SceneManager.new(), Service.Type.SCENE_MANAGER)
	AppContext.start_service(ConfigManager.new(), Service.Type.CONFIG_MANAGER)
	AppContext.start_service(DialogManager.new(), Service.Type.DIALOG_MANAGER)


func apply_config() -> void:
	Debug.log_info("Applying user config...")
	Service.config_manager.load_config()
	Service.config_manager.apply_config()


func build_tree() -> bool:
	Debug.log_info("Building node tree...")

	var success: bool = true

	for node: Node in node_tree:
		if node is View:
			var view: View = node
			if not Service.scene_manager.setup_view(view):
				success = false

		if node is UI:
			var ui: UI = node
			Service.scene_manager.setup_ui(ui)

	return success


func set_project_settings() -> void:
	Debug.log_info("Setting project settings...")

	for setting: String in Common.PROJECT_SETTINGS:
		ProjectSettings.set_setting(setting, Common.PROJECT_SETTINGS[setting])
		Debug.log_debug("Set %s: %s" % [setting, Common.PROJECT_SETTINGS[setting]])


func validate_userspace() -> bool:
	Debug.log_info("Validating userspace...")

	var success: bool = true

	var user_directories: Array[String] = [
		FileLocation.USER_MOD_DIR,
		FileLocation.USER_SAVE_DIR,
		FileLocation.USER_SETTINGS_DIR,
	]

	for path: String in user_directories:
		if Common.Util.touch_directory(path):
			Debug.log_verbose("Validated access: %s" % path)
		else:
			Debug.log_warning("Unable to access directory: %s" % path)
			success = false

	return success
