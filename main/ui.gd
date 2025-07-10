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

	for child: Control in get_children():
		child.anchor_left = 0
		child.anchor_right = 1
		child.anchor_top = 0
		child.anchor_bottom = 1
		child.offset_left = 0
		child.offset_top = 0
		child.offset_right = 0
		child.offset_bottom = 0
		Debug.log_verbose("Configured UI component: %s" % child.get_path())

	# register for lookup
	System.manage.scene.register_ui(self)


func _setup_menu() -> void:
	menu = UIOverlay.new()
	menu.name = "Menu"
	menu.theme = load(FileLocation.THEME_MENU)
	add_child(menu)


func _setup_hud() -> void:
	hud = System.manage.scene.create_scene(FileLocation.UI_HUD)
	hud.theme = load(FileLocation.THEME_HUD)
	add_child(hud)
	hud.setup()
