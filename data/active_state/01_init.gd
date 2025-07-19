class_name InitState extends ActiveState

var ui: UI
var views: Array[View]
var color_scheme: ColorScheme
var user_directories: Array[String] = [
	FileLocation.USER_ROOT_MOD_DIR,
	FileLocation.USER_ROOT_SAVE_DIR,
	FileLocation.USER_ROOT_SETTINGS_DIR ]


func _init(p_color_scheme: ColorScheme, p_node_tree: Array[Node]) -> void:
	state_id = "Init"
	color_scheme = p_color_scheme
	for node: Node in p_node_tree:
		if node is UI: ui = node
		if node is View: views.append(node)


func _start_services() -> void:
	System.manage.start_service(ConfigManager.new(), Service.Type.CONFIG_MANAGER)
	System.manage.start_service(SceneManager.new(), Service.Type.SCENE_MANAGER)


func _main() -> void:
	# apply runtime overrides
	color_scheme.apply()

	# establish environment
	if not validate_directories(user_directories): return
	if not build_viewports(views): return

	# apply project and user settings
	System.manage.config.apply_project_settings(Common.PROJECT_SETTINGS)
	System.manage.config.load_config()
	System.manage.config.apply_config()

	# allow for notifications
	ui.setup()

	# process mods
	var saved_mods: PackedStringArray = System.manage.config.mod_settings.get_saved_mods()
	System.state.change(SetupState.new(saved_mods))


func apply_settings(p_dict: Dictionary[String, Variant]) -> void:
	System.manage.config.apply_project_settings(p_dict) # project
	System.manage.config.load_config() # user
	System.manage.config.apply_config()


func build_viewports(p_views: Array[View]) -> bool:
	Debug.log_info("Building views...")
	for view: View in p_views:
		if not view.setup(): return false
	return true


func validate_directories(p_paths: Array[String]) -> bool:
	Debug.log_info("Checking directories...")
	return Common.Util.file.validate_directories(user_directories)
