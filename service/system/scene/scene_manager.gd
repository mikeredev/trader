class_name SceneManager extends Service

var _views: Dictionary[View.ViewType, View] = {}
var _ui: UI


func add_view(p_type: View.ViewType, p_view: View) -> void:
	_views[p_type] = p_view


func add_ui(p_ui: UI) -> void:
	_ui = p_ui


func build_tree(p_node_tree: Array[Node]) -> bool: # each top-level node under Main
	for node: Node in p_node_tree:
		if node is View: # subviewport containers
			var view: View = node
			if not _build_view(view): return false

		if node is UI: # canvas layer HUD/UI/menu etc
			var ui: UI = node
			_build_ui(ui)
	return true


func center_window(p_resolution: Vector2i) -> void:
	var center: Vector2i = (DisplayServer.screen_get_size() - DisplayServer.window_get_size()) / 2
	EventBus.get_window().position = center
	EventBus.get_window().content_scale_size = p_resolution
	Debug.log_debug("Centered window: %s" % center)


func create_scene(p_scene: Variant, p_container: UI.ContainerType) -> Node:
	var node: Node
	var _type: int = typeof(p_scene)
	match _type:
		4:
			var path: String = p_scene
			node = _create_from_path(path)
		24:
			var scene: PackedScene = p_scene
			node = _create_from_packed(scene)
		_:
			Debug.log_warning("Unknown scene type: %d (%s)" % [type_string(_type), p_scene])
			return null

	var container: UIContainer = _ui.get_container(p_container)
	container.add_child(node)
	Debug.log_debug("Created scene: %s" % node.get_path())
	return node


func create_tween(p_object: Object, p_property: NodePath, p_final: Variant,
	p_duration: float, p_trans: Tween.TransitionType = Tween.TRANS_LINEAR,
	p_ease: Tween.EaseType = Tween.EASE_IN) -> Tween:

		var tween: Tween = System.create_tween() # needs any node reference
		tween.tween_property(p_object, p_property, p_final, p_duration) \
		.set_trans(p_trans) \
		.set_ease(p_ease)
		return tween


func get_ui() -> UI:
	return _ui


func get_view(p_type: View.ViewType) -> View:
	return _views.get(p_type, null)


func _build_view(p_view: View) -> bool:
	# validate View name
	if not View.ViewType.keys().has(p_view.name.to_upper()):
		Debug.log_warning("Invalid view: %s" % p_view)
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

	# set View common properties
	p_view.stretch = true
	p_view.subviewport = p_view.get_child(0)

	# create containers parent
	var container_parent: Node2D = Node2D.new()
	container_parent.name = "View"
	container_parent.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p_view.subviewport.add_child(container_parent)
	Debug.log_verbose("  Created container parent: %s" % container_parent.get_path())

	# assign containers to View
	var default_containers: Array[View.ContainerType] = []
	match type:
		View.ViewType.OVERWORLD:
			default_containers = [
				View.ContainerType.MAP, View.ContainerType.VILLAGE, View.ContainerType.SUPPLY_PORT,
				View.ContainerType.CITY, View.ContainerType.SHIP ]
		View.ViewType.PORT:
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
		Debug.log_verbose("  Created container: %s" % container.get_path())

	# create camera under container_parent
	var camera: Camera = Camera.new()
	camera.name = "Camera"
	container_parent.add_child(camera)
	p_view.add_camera(camera)
	Debug.log_verbose("  Created camera: %s" % camera.get_path())

	# start inactive
	p_view.set_active(false)

	# register View for lookup
	add_view(type, p_view)

	Debug.log_debug("Created view %s: %s" % [View.ViewType.keys()[type], p_view])
	return true


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
			UI.ContainerType.DIALOG: container.theme = load(FileLocation.THEME_DIALOG)
			UI.ContainerType.MENU: container.theme = load(FileLocation.THEME_MENU)

		# done
		Debug.log_verbose("󱣴  Created UI container: %s" % container.get_path())

	# register ui for lookup
	add_ui(p_ui)
	Debug.log_debug("Registered UI: %s" % p_ui)


func _create_from_packed(p_preload: PackedScene) -> Node:
	var scene: Node = p_preload.instantiate()
	return scene


func _create_from_path(p_path: String) -> Node:
	var packed_scene: PackedScene = load(p_path)
	var scene: Node = packed_scene.instantiate()
	Debug.log_debug("Created orphan scene from path: %s" % scene)
	return scene
