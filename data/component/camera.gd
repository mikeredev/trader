class_name Camera extends Camera2D

const SYSTEM_MIN_ZOOM: Vector2 = Vector2(0.9, 0.9)
const ZOOM_STEP: float = 0.1
const ZOOM_SNAP: float = 0.001

var _cam_control: bool

var speed: int = 200
#var target: CharacterBody
var min_zoom: Vector2 = Vector2(1, 1)
var max_zoom: Vector2 = Vector2(60, 60)
var limits: Dictionary[String, int] = {
	"limit_left": 0,
	"limit_top": 0,
	"limit_right": 0,
	"limit_bottom": 0,
}


func _process(delta: float) -> void:
	if not enabled: return
	if not _cam_control: return
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
	if Input.is_action_pressed("ui_page_up"):
		zoom_in()
	elif Input.is_action_pressed("ui_page_down"):
		zoom_out()


#func enable(p_toggled_on: bool) -> void: # overrides standard camera enable
	#enabled = p_toggled_on
	#_cam_control = false # ensure hard reset


#func follow(p_body: CharacterBody) -> void:
	#target = p_body
	#var remote_transform: RemoteTransform2D = target.remote_transform
	#remote_transform.remote_path = get_path()
	#Debug.log_debug("-> %s camera following: %s" % [name.to_upper(), target.name])


func set_cam_control(p_toggled_on: bool) -> void:
	if not enabled: return
	_cam_control = p_toggled_on
	if _cam_control:
		adjust_limits(true)
	else: # forces snap-back to computed min zoom
		adjust_limits(false)
		EventBus.viewport_resized.emit(DisplayServer.window_get_size())
	Debug.log_debug("Toggled %s control: %s" % [name, p_toggled_on])


func set_limits(p_limits: Vector2i) -> void:
	limits.limit_left = 0
	limits.limit_top = 0
	limits.limit_right = p_limits.x
	limits.limit_bottom = p_limits.y
	_apply_limits() # set limits
	position = p_limits / 2 # auto-centre
	Debug.log_debug("%s limits: %s" % [name, Vector2i(limit_right, limit_bottom)])
	if _cam_control: adjust_limits() # increase slightly if in dev mode


func adjust_limits(p_increase: bool = true) -> void:
	if p_increase:
		limit_left -= 100
		limit_top -= 100
		limit_right += 100
		limit_bottom += 100
	else:
		_apply_limits()

func _apply_limits() -> void:
		limit_left = limits.get("limit_left")
		limit_top = limits.get("limit_top")
		limit_right = limits.get("limit_right")
		limit_bottom = limits.get("limit_bottom")


func set_min_zoom(p_viewport: Vector2i, p_reference: Vector2i) -> void:
	var x: float = float(p_viewport.x) / p_reference.x
	var y: float = float(p_viewport.y) / p_reference.y
	var minimum: float = max(x, y)
	minimum = snappedf(minimum, Camera.ZOOM_SNAP)
	min_zoom = Vector2(minimum, minimum)
	zoom = min_zoom
	EventBus.camera_zoomed.emit(zoom)
	Debug.log_debug("%s minimum zoom: %s" % [name, min_zoom])


#func unfollow() -> void:
	#target.remote_transform.remote_path = ""
	#target = null
	#Debug.log_debug("%s camera unfollowing" % self.name.to_upper())


func zoom_in() -> void:
	var minimum: Vector2 = SYSTEM_MIN_ZOOM if _cam_control else min_zoom
	zoom += Vector2(ZOOM_STEP, ZOOM_STEP)
	zoom = zoom.clamp(minimum, max_zoom)
	EventBus.camera_zoomed.emit(zoom)


func zoom_out() -> void:
	var minimum: Vector2 = SYSTEM_MIN_ZOOM if _cam_control else min_zoom
	zoom -= Vector2(ZOOM_STEP, ZOOM_STEP)
	zoom = zoom.clamp(minimum, max_zoom)
	EventBus.camera_zoomed.emit(zoom)
