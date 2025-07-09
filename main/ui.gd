class_name UI extends CanvasLayer

@onready var menu: UIOverlay = %Menu
@onready var dialog: UIOverlay = %Dialog
@onready var hud: UIOverlay = %HUD


func setup() -> void:
	Debug.log_info("Creating UI...")
	# set common properties on all containers (themes set in editor)
	for overlay: UIOverlay in get_children():
		overlay.size = overlay.get_parent_area_size()
		overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		Debug.log_verbose("󱣴  Configured UI overlay: %s" % overlay.get_path())

	# create HUD overlay
	var overlay: HUDOverlay = Service.scene_manager.create_scene(FileLocation.UI_HUD_COMPONENT_DISPLAY)
	hud.add_scene(overlay)
	overlay.setup()


	Service.scene_manager.register_ui(self) # register UI for lookup


#func add_to_dialog(p_scene: Control) -> Control: return _dialog.add_scene(p_scene)
#
#
#func add_to_hud(p_scene: Control) -> Control: return _hud.add_scene(p_scene)
#
#
#func add_to_menu(p_scene: Variant) -> Control:
	#var scene: Node = Service.scene_manager.create_scene(p_scene)
	#return _menu.add_scene(scene)
#
#
#func clear_dialog() -> void: _dialog.clear()
#
#
#func clear_hud() -> void: _hud.clear()
#
#
#func clear_menu() -> void: _menu.clear()


#func clear_all_containers() -> void:
	#for type: ContainerType in _containers.keys():
		#clear_container(type)
#
#
#func clear_container(p_type: ContainerType) -> void:
	#var container: UIOverlay = get_container(p_type)
	#_free_children(container)
#
#
#func _free_children(p_container: UIOverlay) -> void:
	#Debug.log_info("Clearing container: %s" % p_container.get_path())
	#for node: Node in p_container.get_children():
		#p_container.remove_child(node)
		#node.call_deferred("queue_free")
		#Debug.log_verbose("Freed scene: %s" % node)
	#Debug.log_debug("Cleared container: %s" % p_container.get_path())
