class_name UI extends CanvasLayer

#var setup_config: Dictionary[]

@onready var menu: UIOverlay = %Menu
@onready var dialog: UIOverlay = %Dialog
@onready var hud: HUDOverlay


func clear_all() -> void:
	menu.clear()
	dialog.clear()
	hud.clear()
	Debug.log_verbose("Cleared all UI overlays")


func setup() -> void:
	Debug.log_info("Creating UI...")
	_setup_hud()
	for child: Control in get_children(): # themes etc applied in editor to tscn
		child.set_anchors_preset(Control.PRESET_FULL_RECT)
		child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		#overlay.size = overlay.get_parent_area_size()
		Debug.log_verbose("󱣴  Configured UI overlay: %s" % child.get_path())
	Service.scene_manager.add_ui(self) # register for lookup


func _setup_hud() -> void:
	hud = Service.scene_manager.create_scene(FileLocation.UI_HUD_COMPONENT_DISPLAY)
	add_child(hud)
	hud.setup()
