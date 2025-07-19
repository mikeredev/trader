class_name Camera extends Camera2D

const DEVMODE_MIN_ZOOM: Vector2 = Vector2(0.9, 0.9)
const ZOOM_STEP: float = 0.1
const ZOOM_SNAP: float = 0.001

var speed: int = 200
var min_zoom: Vector2 = Vector2(1, 1)
var max_zoom: Vector2 = Vector2(60, 60)
var limits: Dictionary[String, int]

var _dev_mode: bool


func _process(delta: float) -> void:
	if not enabled: return
	if not _dev_mode: return
	_process_movement(delta)
	_process_zoom()


func _process_movement(delta: float) -> void:
	var movement: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		movement.x -= 1
	if Input.is_action_pressed("ui_right"):
		movement.x += 1
	if Input.is_action_pressed("ui_up"):
		movement.y -= 1
	if Input.is_action_pressed("ui_down"):
		movement.y += 1
	if movement != Vector2.ZERO:
		position += movement.normalized() * speed * delta
		position.x = clamp(position.x, limit_left, limit_right)
		position.y = clamp(position.y, limit_top, limit_bottom)


func _process_zoom() -> void:
	if Input.is_action_pressed("ui_page_up"): _zoom_in()
	elif Input.is_action_pressed("ui_page_down"): _zoom_out()


func follow(p_body: CharacterBody) -> void:
	var remote_transform: RemoteTransform2D = p_body.remote_transform
	remote_transform.remote_path = get_path()
	Debug.log_debug("%s following: %s" % [name, p_body.name])


func enable_devmode(p_toggled_on: bool) -> void:
	if not enabled: return
	_dev_mode = p_toggled_on
	if _dev_mode:
		_remove_limits()
	else:
		_apply_limits()
		EventBus.viewport_resized.emit(DisplayServer.window_get_size()) # forces snap-back to min zoom


func set_min_zoom(p_viewport: Vector2i, p_reference: Vector2i) -> void:
	if not enabled: return
	var x: float = float(p_viewport.x) / p_reference.x
	var y: float = float(p_viewport.y) / p_reference.y
	var minimum: float = max(x, y)
	minimum = snappedf(minimum, Camera.ZOOM_SNAP)
	min_zoom = Vector2(minimum, minimum)
	zoom = min_zoom
	if enabled: EventBus.camera_zoomed.emit(zoom)
	Debug.log_debug("%s minimum zoom: %s" % [get_path(), min_zoom])


func update_limits(p_limits: Vector2i) -> void:
	_set_limits(p_limits)
	if _dev_mode: _remove_limits()
	else: _apply_limits()
	position = p_limits / 2 # auto-centre


func _apply_limits() -> void:
	limit_left = limits["limit_left"]
	limit_top = limits["limit_top"]
	limit_right = limits["limit_right"]
	limit_bottom = limits["limit_bottom"]
	Debug.log_verbose("Applied camera limits: %s, %s" % [name, Vector2i(limit_right, limit_bottom)])


func _remove_limits() -> void:
	limit_left = -10000
	limit_top = -10000
	limit_right = 10000
	limit_bottom = 10000
	Debug.log_verbose("Removed camera limits: %s" % name)


func _set_limits(p_limits: Vector2i) -> void:
	limits["limit_left"] = 0
	limits["limit_top"] = 0
	limits["limit_right"] = p_limits.x
	limits["limit_bottom"] = p_limits.y


func _zoom_in() -> void:
	var minimum: Vector2 = DEVMODE_MIN_ZOOM if _dev_mode else min_zoom
	zoom += Vector2(ZOOM_STEP, ZOOM_STEP)
	zoom = zoom.clamp(minimum, max_zoom)
	EventBus.camera_zoomed.emit(zoom)


func _zoom_out() -> void:
	var minimum: Vector2 = DEVMODE_MIN_ZOOM if _dev_mode else min_zoom
	zoom -= Vector2(ZOOM_STEP, ZOOM_STEP)
	zoom = zoom.clamp(minimum, max_zoom)
	EventBus.camera_zoomed.emit(zoom)
