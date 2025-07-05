class_name View extends SubViewportContainer

enum Type { OVERWORLD, PORT, INTERIOR }

var type: Type
var subviewport: SubViewport
var containers: Dictionary[NodeContainer.Type, NodeContainer] # everything in a container is freed on soft reset

var _active: bool: # debug mode
	set(p):
		set_active(p)
		_active = p
		return _active

func add_container(p_container: NodeContainer) -> void:
	containers[p_container.type] = p_container


func get_camera() -> Camera:
	var container: NodeContainer = get_container(NodeContainer.Type.CAMERA)
	return container.get_child(0) as Camera


func get_container(p_type: NodeContainer.Type) -> NodeContainer:
	return containers.get(p_type, null)


func set_active(p_toggled_on: bool) -> void:
	var camera: Camera = get_camera()
	camera.enabled = p_toggled_on
	self.visible = p_toggled_on
	Debug.log_debug("Set %s active: %s" % [self.name, p_toggled_on])
