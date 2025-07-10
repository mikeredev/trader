class_name SceneManager extends Service

var _active_view: View
var _views: Dictionary[View.ViewType, View] = {}
var ui: UI


func add_view(p_type: View.ViewType, p_view: View) -> void:
	_views[p_type] = p_view
	Debug.log_debug("Registered view: %s" % p_view)


func register_ui(p_ui: UI) -> void:
	ui = p_ui
	Debug.log_debug("Registered UI: %s" % p_ui)


func activate_view(p_type: View.ViewType) -> View:
	var target: View = get_view(p_type)
	for view: View in get_views():
		var active: bool = view == target
		view.set_active(active)
	_active_view = target
	Debug.log_debug("Activated view: %s" % target.get_path())
	return target


func center_window(p_resolution: Vector2i) -> void:
	var center: Vector2i = (DisplayServer.screen_get_size() - DisplayServer.window_get_size()) / 2
	EventBus.get_window().position = center
	EventBus.get_window().content_scale_size = p_resolution
	Debug.log_debug("Centered window: %s" % center)


func create_borders(p_area: Vector2i, p_thickness: int = 50) -> Array[StaticBody2D]:
	var borders: Array[StaticBody2D] = []
	for direction: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		var border: StaticBody2D = StaticBody2D.new()
		var collision: CollisionShape2D = CollisionShape2D.new()
		var shape: RectangleShape2D = RectangleShape2D.new()
		collision.name = "CollisionShape2D"
		collision.shape = shape
		border.collision_layer = 1# Common.Collision.Bitmask.COLLISION
		border.collision_mask = 0
		border.add_child(collision)
		match direction:
			Vector2i.UP:
				border.position.x = p_area.x / 2.0
				border.position.y = - (p_thickness / 2.0)
				shape.size = Vector2i(p_area.x + (p_thickness * 2), p_thickness)
			Vector2i.DOWN:
				border.position.x = p_area.x / 2.0
				border.position.y = p_area.y + (p_thickness / 2.0)
				shape.size = Vector2i(p_area.x + (p_thickness * 2), p_thickness)
			Vector2i.LEFT:
				border.position.x = - (p_thickness / 2.0)
				border.position.y = p_area.y / 2.0
				shape.size = Vector2i(p_thickness, p_area.y)
			Vector2i.RIGHT:
				border.position.x = p_area.x + (p_thickness / 2.0)
				border.position.y = p_area.y / 2.0
				shape.size = Vector2i(p_thickness, p_area.y)
		border.name = str(direction)
		borders.append(border)
	Debug.log_debug("Created border: %s" % p_area)
	return borders


func create_notification(p_message: String) -> void:
	EventBus.create_notification.emit(p_message)


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


func get_active_view() -> View:
	return _active_view


func get_confirmation(p_text: String, p_confirm_text: String = "YES", p_cancel_text: String = "NO") -> bool:
	var modal: DialogConfirm = create_scene(FileLocation.DIALOG_CONFIRM)
	ui.hud.dialog_confirm.add_child(modal)
	ui.hud.fade_background(true)
	modal.configure(p_text, p_confirm_text, p_cancel_text)
	var result: bool = await modal.await_input()
	ui.hud.fade_background(false)
	return result


func get_view(p_type: View.ViewType) -> View:
	return _views.get(p_type, null)


func get_views() -> Array[View]:
	return _views.values()


func _create_from_packed(p_preload: PackedScene) -> Node:
	var scene: Node = p_preload.instantiate()
	return scene


func _create_from_path(p_path: String) -> Node:
	var packed_scene: PackedScene = load(p_path)
	var scene: Node = packed_scene.instantiate()
	return scene
