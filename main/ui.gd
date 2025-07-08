class_name UI extends CanvasLayer

enum ContainerType { MENU, DIALOG, HUD }

var _containers: Dictionary[ContainerType, UIContainer]


func add_container(p_type: ContainerType, p_container: UIContainer) -> void:
	_containers[p_type] = p_container


func add_to_container(p_scene: Node, p_container: ContainerType) -> Node:
	var container: UIContainer = get_container(p_container)
	container.add_child(p_scene)
	Debug.log_debug("Created scene: %s" % p_scene.get_path())
	return p_scene


func get_container(p_type: ContainerType) -> UIContainer:
	return _containers.get(p_type, null)


func clear_all_containers() -> void:
	for type: ContainerType in _containers.keys():
		clear_container(type)


func clear_container(p_type: ContainerType) -> void:
	var container: UIContainer = get_container(p_type)
	_free_children(container)


func _free_children(p_container: UIContainer) -> void:
	Debug.log_info("Clearing container: %s" % p_container.get_path())
	for node: Node in p_container.get_children():
		p_container.remove_child(node)
		node.call_deferred("queue_free")
		Debug.log_verbose("Freed scene: %s" % node)
	Debug.log_debug("Cleared container: %s" % p_container.get_path())
