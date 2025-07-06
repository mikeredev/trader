class_name SceneManager extends Service

var _views: Dictionary[View.ViewType, View] = {}
var _ui: UI


func activate_view(p_type: View.ViewType) -> void:
	var target: View = get_view(p_type)
	for view: View in get_views():
		var active: bool = view == target
		view.set_active(active)
	Debug.log_debug("Set active view: %s" % [View.ViewType.keys()[p_type]])


func add_to_ui(p_scene: Variant, p_container: UI.ContainerType) -> Node:
	var ui: UI = get_ui()
	var node: Node = create_scene(p_scene)
	return ui.add_to_container(node, p_container)


func add_to_view(p_scene: Variant, p_view: View.ViewType, p_container: View.ContainerType) -> Node:
	var view: View = get_view(p_view)
	var node: Node = create_scene(p_scene)
	return view.add_to_container(node, p_container)


func center_window(p_resolution: Vector2i) -> void:
	var center: Vector2i = (DisplayServer.screen_get_size() - DisplayServer.window_get_size()) / 2
	EventBus.get_window().position = center
	EventBus.get_window().content_scale_size = p_resolution
	Debug.log_debug("Centered window: %s" % center)


func create_scene(p_scene: Variant) -> Node:
	var node: Node
	match typeof(p_scene):
		TYPE_STRING:
			var path: String = p_scene
			node = _create_from_path(path)
		TYPE_OBJECT:
			var scene: PackedScene = p_scene
			node = _create_from_packed(scene)
		_:
			Debug.log_warning("Unknown scene type: %d (%s)" % [typeof(p_scene), p_scene])
			return null
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


func get_views() -> Array[View]:
	return _views.values()


func register_view(p_type: View.ViewType, p_view: View) -> void:
	_views[p_type] = p_view
	Debug.log_debug("Registered view: %s" % p_view)


func register_ui(p_ui: UI) -> void:
	_ui = p_ui
	Debug.log_debug("Registered UI: %s" % p_ui)


func _create_from_packed(p_preload: PackedScene) -> Node:
	var scene: Node = p_preload.instantiate()
	return scene


func _create_from_path(p_path: String) -> Node:
	var packed_scene: PackedScene = load(p_path)
	var scene: Node = packed_scene.instantiate()
	return scene
