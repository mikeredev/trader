class_name SceneManager extends Service

var _views: Dictionary[View.ViewType, View] = {}
var _ui: UI


func register_view(p_type: View.ViewType, p_view: View) -> void:
	_views[p_type] = p_view
	Debug.log_debug("Registered view: %s" % p_view)


func register_ui(p_ui: UI) -> void:
	_ui = p_ui
	Debug.log_debug("Registered UI: %s" % p_ui)


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


func _create_from_packed(p_preload: PackedScene) -> Node:
	var scene: Node = p_preload.instantiate()
	return scene


func _create_from_path(p_path: String) -> Node:
	var packed_scene: PackedScene = load(p_path)
	var scene: Node = packed_scene.instantiate()
	return scene # nothing logged
