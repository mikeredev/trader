class_name UI extends CanvasLayer

@onready var menu: UIOverlay
@onready var hud: HUD


func clear_all() -> void:
	menu.clear()
	hud.clear()
	Debug.log_verbose("Cleared all UI overlays")


func setup() -> void:
	Debug.log_info("Creating UI...")
	_setup_menu()
	_setup_hud()

	# apply common properties to all children
	for child: Control in get_children(): # themes etc applied in editor to tscn
		child.set_anchors_preset(Control.PRESET_FULL_RECT)
		child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		child.size = child.get_parent_area_size() # needed for splash / remove, click quit on start
		Debug.log_verbose("󱣴  Configured UI overlay: %s" % child.get_path())

	# register for lookup
	System.service.scene_manager.register_ui(self)


func _setup_menu() -> void:
	menu = UIOverlay.new()
	menu.name = "Menu"
	add_child(menu)


func _setup_hud() -> void:
	hud = System.service.scene_manager.create_scene(FileLocation.UI_HUD)
	add_child(hud)
	hud.setup()
