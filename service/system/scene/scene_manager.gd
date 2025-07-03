class_name SceneManager extends Service

var _views: Dictionary[View.Type, View]
var _ui: UI


func center_window(p_resolution: Vector2i) -> void:
	var center: Vector2i = (DisplayServer.screen_get_size() - DisplayServer.window_get_size()) / 2
	EventBus.get_window().position = center
	EventBus.get_window().content_scale_size = p_resolution
	Debug.log_debug("Centered window: %s" % center)


func clear_ui(p_container: UI.ContainerType) -> void:
	var container: Node = _ui.get_container(p_container)
	for child: Node in container.get_children():
		container.remove_child(child)
		child.call_deferred("queue_free")
		Debug.log_verbose("Freed scene: %s" % child)
	Debug.log_debug("Cleared UI container: %s" % container)


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


func get_view(p_scope: View.Type) -> View:
	return _views.get(p_scope, null)


func get_ui() -> UI:
	return _ui


func setup_view(p_view: View) -> bool:
	if not p_view.setup():
		return false

	_views[p_view.type] = p_view
	Debug.log_debug("Registered %s: %s" % [View.Type.keys()[p_view.type], p_view])
	return true


func setup_ui(p_ui: UI) -> void:
	p_ui.setup()
	_ui = p_ui
	Debug.log_debug("Registered UI: %s" % p_ui)


func _create_from_packed(p_preload: PackedScene) -> Node:
	var scene: Node = p_preload.instantiate()
	return scene


func _create_from_path(p_path: String) -> Node:
	var packed_scene: PackedScene = load(p_path)
	var scene: Node = packed_scene.instantiate()
	return scene
