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
	System.service.start_service(ConfigManager.new(), Service.ServiceType.CONFIG_MANAGER)
	System.service.start_service(SceneManager.new(), Service.ServiceType.SCENE_MANAGER)


func _main() -> void:
	# establish environment
	if not validate_directories(user_directories): return
	if not build_viewports(views): return

	# apply project and user settings
	Service.config_manager.apply_project_settings(Common.PROJECT_SETTINGS)
	Service.config_manager.load_config()
	Service.config_manager.apply_config()

	# allow for notifications
	ui.setup()

	# process mods
	saved_mods = Service.config_manager.mod_settings.get_saved_mods()
	System.change_state(SetupState.new(saved_mods))


func apply_settings(p_dict: Dictionary[String, Variant]) -> void:
	Service.config_manager.apply_project_settings(p_dict) # project
	Service.config_manager.load_config() # user
	Service.config_manager.apply_config()


func build_viewports(p_views: Array[View]) -> bool:
	Debug.log_info("Building primary viewports...")
	for view: View in p_views:
		if not _setup_view(view): return false
	return true


func validate_directories(p_paths: Array[String]) -> bool:
	Debug.log_info("Checking directories...")
	return Common.Util.file.validate_directories(p_paths)


func _setup_view(p_view: View) -> bool:
	# match name to enum
	if not View.ViewType.keys().has(p_view.name.to_upper()):
		Debug.log_error("Invalid view name: %s, expected: %s" % [p_view.name, View.ViewType.keys()])
		return false

	# verify subviewport
	if not (p_view.get_child_count() > 0 and p_view.get_child(0) is SubViewport):
		Debug.log_error("%s requires subviewport" % self)
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

		# register container for lookup
		p_view.add_container(container_type, container)
		Debug.log_verbose("  Created container: %s" % container.get_path())

	# create camera under container_parent
	p_view.camera = Camera.new()
	p_view.camera.name = "%sCamera" % p_view.name
	container_parent.add_child(p_view.camera)
	Debug.log_verbose("  Created camera: %s" % p_view.camera.get_path())

	# start disabled
	p_view.set_active(false)

	# register view for lookup
	Service.scene_manager.add_view(type, p_view)
	return true
