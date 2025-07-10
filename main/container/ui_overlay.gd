class_name UIOverlay extends Control


func add_scene(p_scene: Control) -> Control:
	add_child(p_scene)
	return p_scene


func clear() -> void:
	for node: Node in get_children():
		remove_child(node)
		node.call_deferred("queue_free")
		Debug.log_verbose("Freed scene: %s" % node)
	Debug.log_debug("Cleared UI overlay: %s" % get_path())
