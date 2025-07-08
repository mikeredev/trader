class_name InitState extends ActiveState

var node_tree: Array[Node] # main/get_children()


func _init(p_node_tree: Array[Node]) -> void:
	state_id = "Init"
	node_tree = p_node_tree


func _start_services() -> void:
	System.start_service(SceneManager.new(), Service.ServiceType.SCENE_MANAGER)
	System.start_service(ConfigManager.new(), Service.ServiceType.CONFIG_MANAGER)
	System.start_service(DialogManager.new(), Service.ServiceType.DIALOG_MANAGER)


func _main() -> void:
	# establish environment
	if not check_access(): return
	if not build_tree(node_tree): return

	# apply runtime settings
	Debug.log_info("Applying settings...")
	apply_project_settings(Common.PROJECT_SETTINGS)
	apply_user_settings()

	# load UI
	Debug.log_info("Creating HUD...")
	var hud_component_display: HUDComponentDisplay = Service.scene_manager.add_to_ui(FileLocation.UI_DASHBOARD, UI.ContainerType.HUD)
	print(hud_component_display)

	# move to second core loop state: inject saved mod IDs
	var saved_mods: PackedStringArray = Service.config_manager.mod_settings.get_saved_mods()
	System.change_state(SetupState.new(saved_mods))


func check_access() -> bool:
	Debug.log_info("Checking directories...")
	var success: bool = true

	var user_directories: Array[String] = [
		FileLocation.USER_ROOT_MOD_DIR,
		FileLocation.USER_ROOT_SAVE_DIR,
		FileLocation.USER_ROOT_SETTINGS_DIR ]

	for path: String in user_directories:
		if Common.Util.file.touch_directory(path):
			Debug.log_verbose("  OK: %s" % path)
		else:
			Debug.log_warning("Unable to access directory: %s" % path)
			success = false

	if not success:
		Debug.log_error("Error accessing directory (check write permissions)")
	return success


func build_tree(p_node_tree: Array[Node]) -> bool:
	Debug.log_info("Building node tree...")
	for node: Node in p_node_tree:
		if node is View:
			var view: View = node
			if not _build_view(view):
				Debug.log_error("Error building node tree.")
				return false
		if node is UI:
			var ui: UI = node
			_build_ui(ui)
	return true


func apply_project_settings(p_dict: Dictionary[String, Variant]) -> void:
	for setting: String in p_dict.keys():
		ProjectSettings.set_setting(setting, p_dict[setting])
		Debug.log_debug("Set %s: %s" % [setting, p_dict[setting]])


func apply_user_settings() -> void:
	Service.config_manager.load_config()
	Service.config_manager.apply_config()


func _build_ui(p_ui: UI) -> void:
	# create UI containers
	for container_name: String in UI.ContainerType.keys():
		var container: UIContainer = UIContainer.new()
		container.name = container_name.to_pascal_case()
		p_ui.add_child(container)

		# set common control properties for all containers
		container.size = container.get_parent_area_size()
		container.set_anchors_preset(Control.PRESET_FULL_RECT)
		container.mouse_filter = Control.MOUSE_FILTER_IGNORE

		# register for lookup by container type
		var container_type: UI.ContainerType
		for i: int in range(UI.ContainerType.size()):
			if container_name == UI.ContainerType.keys()[i]:
				container_type = UI.ContainerType.values()[i]
				p_ui.add_container(container_type, container)

		# apply theme
		match container_type:
			UI.ContainerType.DIALOG:
				container.theme = load(FileLocation.THEME_DIALOG)
			UI.ContainerType.MENU:
				container.theme = load(FileLocation.THEME_MENU)
			UI.ContainerType.HUD:
				container.theme = load(FileLocation.THEME_HUD)

		# done
		Debug.log_verbose("󱣴  Created UI container: %s" % container.get_path())

	# register ui for lookup
	Service.scene_manager.register_ui(p_ui)


func _build_view(p_view: View) -> bool:
	# validate View name
	if not View.ViewType.keys().has(p_view.name.to_upper()):
		Debug.log_warning("Invalid view name: %s, expected: %s" % [p_view.name, View.ViewType.keys()])
		return false

	# verify subviewport
	if not (p_view.get_child_count() > 0 and p_view.get_child(0) is SubViewport):
		Debug.log_warning("%s requires subviewport" % p_view)
		return false

	# get View type
	var type: View.ViewType
	for i: int in range(View.ViewType.size()):
		if View.ViewType.keys()[i] == p_view.name.to_upper():
			type = View.ViewType.values()[i]

	# set properties common across all Views
	p_view.subviewport = p_view.get_child(0)
	p_view.stretch = true

	# create parent Node2D for containers
	var container_parent: Node2D = Node2D.new()
	container_parent.name = "View"
	container_parent.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p_view.subviewport.add_child(container_parent)
	Debug.log_verbose("  Created container parent: %s" % container_parent.get_path())

	# assign containers
	var default_containers: Array[View.ContainerType] = []
	match type:
		View.ViewType.OVERWORLD:
			default_containers = [
				View.ContainerType.MAP, View.ContainerType.VILLAGE, View.ContainerType.SUPPLY_PORT,
				View.ContainerType.CITY, View.ContainerType.SHIP ]
		View.ViewType.CITY:
			default_containers = [ View.ContainerType.SCENE ]
		View.ViewType.INTERIOR:
			default_containers = [ View.ContainerType.SCENE ]

	# add containers to container parent
	for container_type: View.ContainerType in default_containers:
		var container: NodeContainer = NodeContainer.new()
		container.name = str(View.ContainerType.keys()[container_type]).to_pascal_case()
		container_parent.add_child(container)

		# register for lookup
		p_view.add_container(container_type, container)
		Debug.log_verbose("  Created container: %s" % container.get_path())

	# create camera under container_parent
	var camera: Camera = Camera.new()
	camera.name = "Camera"
	container_parent.add_child(camera)
	p_view.add_camera(camera)
	Debug.log_verbose("  Created camera: %s" % camera.get_path())

	# start as inactive
	p_view._set_active(false)

	# register View for lookup
	Service.scene_manager.register_view(type, p_view)
	return true
