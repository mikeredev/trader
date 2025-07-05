class_name UI extends CanvasLayer

var _ui_layers: Dictionary[UILayer.Type, UILayer]


func add_ui_layer(p_ui_layer: UILayer) -> void:
	_ui_layers[p_ui_layer.type] = p_ui_layer


func get_ui_layer(p_type: UILayer.Type) -> UILayer:
	return _ui_layers.get(p_type, null)


func clear_ui_layer(p_layer: UILayer.Type) -> void:
	var ui_layer: UILayer = get_ui_layer(p_layer)
	Debug.log_info("Clearing UI layer: %s" % ui_layer.get_path())

	for node: Node in ui_layer.get_children():
		ui_layer.remove_child(node)
		node.call_deferred("queue_free")
		Debug.log_verbose("Freed scene: %s" % node)
	Debug.log_debug("Cleared UI layer: %s" % layer)
