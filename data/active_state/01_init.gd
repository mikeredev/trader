class_name InitState extends ActiveState

var ui: UI
var views: Array[View]
var saved_mods: PackedStringArray
var user_directories: Array[String] = [
	FileLocation.USER_ROOT_MOD_DIR,
	FileLocation.USER_ROOT_SAVE_DIR,
	FileLocation.USER_ROOT_SETTINGS_DIR ]


func _init(p_node_tree: Array[Node]) -> void:
	state_id = "Init"
	for node: Node in p_node_tree:
		if node is UI: ui = node
		if node is View: views.append(node)


func _start_services() -> void:
	System.manage.start_service(ConfigManager.new(), Service.Type.CONFIG_MANAGER)
	System.manage.start_service(SceneManager.new(), Service.Type.SCENE_MANAGER)


func _main() -> void:
	# establish environment
	if not validate_directories(user_directories): return
	if not build_viewports(views): return

	# apply project and user settings
	System.manage.config.apply_project_settings(Common.PROJECT_SETTINGS)
	System.manage.config.load_config()
	System.manage.config.apply_config()
	#System.manage.mod.apply_config()
	#System.data.trade.get_character()

	# allow for notifications
	ui.setup()

	# process mods
	saved_mods = System.manage.config.mod_settings.get_saved_mods()
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
	return Common.Util.file.validate_directories(p_paths)
