class_name SceneManager extends Service

var _management: ManagementNode
var _views: Dictionary[View.Type, View] = {}
var _ui: UI


func build_tree(p_node_tree: Array[Node]) -> bool: # each top-level node under Main
	for node: Node in p_node_tree:
		# holds cache, world clock, etc.
		if node is ManagementNode:
			var mgmt: ManagementNode = node
			_build_management_node(mgmt)

		if node is View: # subviewport containers
			var view: View = node
			if not _build_view(view): return false

		if node is UI: # canvas layer HUD/UI/menu etc
			var ui: UI = node
			_build_ui(ui)
	return true


func _build_management_node(p_node: ManagementNode) -> void:
	# create body cache
	var cache: Node2D = Node2D.new()
	cache.name = "Cache"
	cache.visible = false
	cache.process_mode = Node.PROCESS_MODE_DISABLED
	p_node.add_child(cache)
	p_node._cache = cache

	# register for lookup
	_management = p_node
	Debug.log_debug("Created management node: %s" % _management)


func _build_view(p_view: View) -> bool:
	# validate View name
	if not View.Type.keys().has(p_view.name.to_upper()):
		Debug.log_warning("Invalid view: %s" % p_view)
		return false

	# verify subviewport
	if not (p_view.get_child_count() > 0 and p_view.get_child(0) is SubViewport):
		Debug.log_warning("%s requires subviewport" % p_view)
		return false

	# set View type
	for i: int in range(View.Type.size()):
		if View.Type.keys()[i] == p_view.name.to_upper():
			p_view.type = View.Type.values()[i]

	# set View common properties
	p_view.stretch = true
	p_view.subviewport = p_view.get_child(0)

	# create parent for containers
	var container_parent: Node2D = Node2D.new()
	container_parent.name = "Containers"
	container_parent.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p_view.subviewport.add_child(container_parent)
	Debug.log_verbose("  Created container parent: %s" % container_parent.get_path())

	# assign containers to View
	var node_containers: Array[View.ContainerType] = []
	match p_view.type:
		View.Type.OVERWORLD:
			node_containers = [
				View.ContainerType.MAP, View.ContainerType.VILLAGE, View.ContainerType.SUPPLY_PORT,
				View.ContainerType.CITY, View.ContainerType.SHIP, View.ContainerType.CAMERA ]
		View.Type.PORT:
			node_containers = [ View.ContainerType.SCENE, View.ContainerType.CAMERA ]
		View.Type.INTERIOR:
			node_containers = [ View.ContainerType.SCENE, View.ContainerType.CAMERA ]

	# add containers to container parent
	for container_type: View.ContainerType in node_containers:
		var node_container: NodeContainer = NodeContainer.new()
		node_container.name = str(View.ContainerType.keys()[container_type]).to_pascal_case()
		container_parent.add_child(node_container)

		# register container for lookup by ContainerType
		#p_view.add_container() # set type on cont
		p_view._containers[container_type] = node_container
		Debug.log_verbose("  Created container: %s" % node_container.get_path())

	# create camera
	var camera_container: NodeContainer = p_view.get_container(View.ContainerType.CAMERA) # TBD move to NodeContainer.Type
	var camera: Camera = Camera.new()
	camera.name = "%s%s" % [p_view.name, "Camera"]
	camera_container.add_child(camera)
	Debug.log_verbose("  Created camera: %s" % camera.get_path())

	# start inactive
	p_view.set_active(false)

	# register View for lookup by type
	_views[p_view.type] = p_view

	Debug.log_debug("Created view %s: %s" % [View.Type.keys()[p_view.type], p_view])
	return true


func _build_ui(p_ui: UI) -> void:
	# create UI layers
	for layer_name: String in UILayer.Type.keys():
		var layer: UILayer = UILayer.new()
		layer.name = layer_name.to_pascal_case()
		p_ui.add_child(layer)

		# set common control properties for all layers
		layer.size = layer.get_parent_area_size()
		layer.set_anchors_preset(Control.PRESET_FULL_RECT)
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE

		# get type and register
		for i: int in range(UILayer.Type.size()):
			if layer_name == UILayer.Type.keys()[i]:
				layer.type = UILayer.Type.values()[i]
				p_ui.add_ui_layer(layer)

		# apply theme
		match layer.type:
			UILayer.Type.DIALOG: layer.theme = load(FileLocation.THEME_DIALOG)
			UILayer.Type.MENU: layer.theme = load(FileLocation.THEME_MENU)

		Debug.log_verbose("󱣴  Created UI layer: %s" % layer.get_path())

	_ui = p_ui
	Debug.log_debug("Registered UI: %s" % _ui)


func center_window(p_resolution: Vector2i) -> void:
	var center: Vector2i = (DisplayServer.screen_get_size() - DisplayServer.window_get_size()) / 2
	EventBus.get_window().position = center
	EventBus.get_window().content_scale_size = p_resolution
	Debug.log_debug("Centered window: %s" % center)


func create_scene(p_scene: Variant, p_layer: UILayer.Type = -1) -> Node:
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

	if p_layer >= 0:
		var layer: UILayer = _ui.get_ui_layer(p_layer)
		layer.add_child(node)

	var display_name: String = str(node.get_path()) if p_layer >= 0 else str(node.name)
	Debug.log_debug("Created scene: %s" % display_name)
	return node


func get_management_node() -> ManagementNode:
	return _management


func get_ui() -> UI:
	return _ui


func get_view(p_scope: View.Type) -> View:
	return _views.get(p_scope, null)


func _create_from_packed(p_preload: PackedScene) -> Node:
	var scene: Node = p_preload.instantiate()
	return scene


func _create_from_path(p_path: String) -> Node:
	var packed_scene: PackedScene = load(p_path)
	var scene: Node = packed_scene.instantiate()
	return scene
