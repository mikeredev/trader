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
		if node is View: views.append(node)
		if node is UI: ui = node


func _start_services() -> void:
	System.start_service(ConfigManager.new(), Service.ServiceType.CONFIG_MANAGER)
	System.start_service(SceneManager.new(), Service.ServiceType.SCENE_MANAGER)


func _main() -> void:
	if not validate_directories(user_directories): return
	if not build_viewports(views): return
	apply_project_settings(Common.PROJECT_SETTINGS)
	apply_user_settings()
	ui.setup()

	return
	saved_mods = Service.config_manager.mod_settings.get_saved_mods()
	System.change_state(SetupState.new(saved_mods))


func apply_project_settings(p_dict: Dictionary[String, Variant]) -> void:
	Service.config_manager.apply_project_settings(p_dict)


func apply_user_settings() -> void:
	Service.config_manager.load_config()
	Service.config_manager.apply_config()


func build_viewports(p_views: Array[View]) -> bool:
	Debug.log_info("Building primary viewports...")
	for view: View in p_views:
		if not view.setup(): return false
	return true


func validate_directories(p_paths: Array[String]) -> bool:
	Debug.log_info("Checking directories...")
	return Common.Util.file.validate_directories(p_paths)
