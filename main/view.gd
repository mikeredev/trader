class_name View extends SubViewportContainer

enum ViewType { OVERWORLD, PORT, INTERIOR }
enum ContainerType { MAP, VILLAGE, CITY, SUPPLY_PORT, SHIP, SCENE }

var subviewport: SubViewport
var _containers: Dictionary[ContainerType, NodeContainer] # everything in a container is freed on soft reset
var _camera: Camera
var _active: bool: # debug mode
	set(p):
		_active = p
		set_active(_active)
		return _active


func add_camera(p_camera: Camera) -> void:
	_camera = p_camera


func add_container(p_type: ContainerType, p_container: NodeContainer) -> void:
	_containers[p_type] = p_container


func get_camera() -> Camera:
	return _camera


func get_container(p_type: ContainerType) -> NodeContainer:
	return _containers.get(p_type, null)


func set_active(p_active: bool) -> void:
	var camera: Camera = get_camera()
	camera.enabled = p_active
	visible = p_active
	Debug.log_debug("Set view %s active: %s" % [name.to_upper(), p_active])
