class_name View extends SubViewportContainer

enum Type { OVERWORLD, PORT, INTERIOR }
enum ContainerType { MAP, VILLAGE, CITY, SUPPLY_PORT, SHIP, SCENE, CAMERA }

var type: Type
var subviewport: SubViewport
var _containers: Dictionary[ContainerType, NodeContainer] # everything in a container is freed on soft reset

var _active: bool: # debug mode
	set(p):
		set_active(p)
		_active = p
		return _active

#func clear_all() -> void:
	#for container: ContainerType in containers:
		#clear_container(container)
	#Debug.log_debug("Cleared all containers: %s" % self.name)
#
#
#func clear_container(p_type: ContainerType) -> void:
	#var container: NodeContainer = get_container(p_type)
	#for child: Node in container.get_children():
		#container.remove_child(child)
		#child.call_deferred("queue_free")
	#Debug.log_verbose("Cleared container: %s" % ContainerType.keys()[p_type])


func get_camera() -> Camera:
	var container: NodeContainer = get_container(ContainerType.CAMERA)
	assert(container.get_child_count() > 0 and container.get_child(0) is Camera)
	return container.get_child(0) as Camera


func get_container(p_type: ContainerType) -> NodeContainer:
	return _containers.get(p_type, null)


func set_active(p_toggled_on: bool) -> void:
	var camera: Camera = get_camera()
	camera.enabled = p_toggled_on
	self.visible = p_toggled_on
	Debug.log_debug("Set %s active: %s" % [self.name, p_toggled_on])
