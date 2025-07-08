class_name UIControl extends Control


func _ready() -> void:
	_connect_signals()
	_set_minimum_size() # requires MarginOuter/NavMain structure
	_set_color_scheme() # sets a %Background color rect to the project primary color
	_ui_ready()


func _connect_signals() -> void: pass


func _set_minimum_size() -> void:
	if get_node_or_null("%MarginOuter") and get_node_or_null("%NavMain"):
		var margin_outer: MarginContainer = get_node("%MarginOuter")
		var margin_value: int = 256 # magic, move to ProjSettings
		margin_outer.add_theme_constant_override("margin_top", margin_value)
		margin_outer.add_theme_constant_override("margin_left", margin_value)
		margin_outer.add_theme_constant_override("margin_bottom", margin_value)
		margin_outer.add_theme_constant_override("margin_right", margin_value)

		var nav_main: Control = get_node("%NavMain")
		var scene_base_size: Vector2i = ProjectSettings.get_setting("services/config/scene_base_size")
		nav_main.custom_minimum_size.x = scene_base_size.x - 16
		nav_main.custom_minimum_size.y = scene_base_size.y - 16

	else:
		Debug.log_warning("Cannot size all UI elements: %s" % self)


func _set_color_scheme() -> void: # unused rn
	if get_node_or_null("%Background"):
		var background: ColorRect = get_node("%Background")
		var primary_bg: Color = ProjectSettings.get_setting("gui/theme/scheme/primary_bg")
		background.color = primary_bg


func _ui_ready() -> void: pass
