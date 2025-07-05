class_name UI extends CanvasLayer

var _containers: Dictionary[UIContainer.Type, UIContainer]


func add_container(p_container: UIContainer) -> void:
	_containers[p_container.type] = p_container


func get_container(p_type: UIContainer.Type) -> UIContainer:
	return _containers.get(p_type, null)


func clear_all_containers() -> void:
	for ui_container: UIContainer in _containers.values():
		_free_children(ui_container)


func clear_container(p_layer: UIContainer.Type) -> void:
	var ui_container: UIContainer = get_container(p_layer)
	_free_children(ui_container)


func _free_children(p_container: UIContainer) -> void:
	Debug.log_info("Clearing container: %s" % p_container.get_path())
	for node: Node in p_container.get_children():
		p_container.remove_child(node)
		node.call_deferred("queue_free")
		Debug.log_verbose("Freed scene: %s" % node)
	Debug.log_debug("Cleared container: %s" % p_container.get_path())
