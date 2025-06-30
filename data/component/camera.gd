class_name Camera extends Camera2D

const ZOOM_STEP: float = 0.1
const ZOOM_SNAP: float = 0.001

var speed: int = 200
var cam_control: bool
#var target: CharacterBody
var min_zoom: Vector2 = Vector2(1, 1)
var max_zoom: Vector2 = Vector2(60, 60)



func _process(delta: float) -> void:
	if not enabled: return
	if cam_control:
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


#func follow(p_body: CharacterBody) -> void:
	#target = p_body
	#var remote_transform: RemoteTransform2D = target.remote_transform
	#remote_transform.remote_path = get_path()
	#Debug.log_debug("-> %s camera following: %s" % [name.to_upper(), target.name])


func set_limits(p_limits: Vector2i) -> void:
	position = p_limits / 2 # auto-centre
	limit_left = 0
	limit_top = 0
	limit_right = p_limits.x
	limit_bottom = p_limits.y
	Debug.log_debug("-> Camera limits: %s" % Vector2i(limit_right, limit_bottom))


func set_min_zoom(p_viewport: Vector2i, p_reference: Vector2i) -> void:
	var x: float = float(p_viewport.x) / p_reference.x
	var y: float = float(p_viewport.y) / p_reference.y
	var minimum: float = max(x, y)
	minimum = snappedf(minimum, Camera.ZOOM_SNAP)
	min_zoom = Vector2(minimum, minimum)
	zoom = min_zoom
	EventBus.camera_zoomed.emit(zoom)
	Debug.log_debug("Minimum zoom (%s): %s" % [name.to_upper(), min_zoom])


#func unfollow() -> void:
	#target.remote_transform.remote_path = ""
	#target = null
	#Debug.log_debug("%s camera unfollowing" % self.name.to_upper())


func zoom_in() -> void:
	zoom += Vector2(ZOOM_STEP, ZOOM_STEP)
	zoom = zoom.clamp(min_zoom, max_zoom)
	EventBus.camera_zoomed.emit(zoom)


func zoom_out() -> void:
	zoom -= Vector2(ZOOM_STEP, ZOOM_STEP)
	zoom = zoom.clamp(min_zoom, max_zoom)
	EventBus.camera_zoomed.emit(zoom)
