class_name View extends SubViewportContainer

enum ViewType { OVERWORLD, CITY, INTERIOR }
enum ContainerType { MAP, VILLAGE, CITY, SUPPLY_PORT, SHIP, SCENE }

var subviewport: SubViewport
var camera: Camera
var _containers: Dictionary[ContainerType, NodeContainer] # everything in a container is freed on soft reset


func add_container(p_type: ContainerType, p_container: NodeContainer) -> void:
	_containers[p_type] = p_container


func add_scene(p_scene: Node, p_container: ContainerType) -> Node:
	var container: NodeContainer = get_container(p_container)
	container.add_child(p_scene)
	Debug.log_debug("Created scene: %s" % p_scene.get_path())
	return p_scene


#func clear_container(p_type: ContainerType) -> void:
	#var container: NodeContainer = get_container(p_type)
	#_clear_container(container)


func clear_view() -> void:
	Debug.log_debug("Clearing view: %s" % get_path())
	for container: NodeContainer in _containers.values():
		_clear_container(container)


func get_container(p_type: ContainerType) -> NodeContainer:
	return _containers.get(p_type, null)


func set_active(p_toggled_on: bool) -> void:
	camera.enabled = p_toggled_on
	visible = p_toggled_on
	Debug.log_verbose("Set view active: %s, %s" % [self.name, p_toggled_on])


func _clear_container(p_container: NodeContainer) -> void:
	for node: Node in p_container.get_children():
		p_container.remove_child(node)
		node.call_deferred("queue_free")
		Debug.log_verbose("Freed scene: %s" % node)
