class_name UIControl extends Control # requires MarginOuter/NavMain

@export var outer_margin: int = 256


func _ready() -> void:
	_connect_signals()
	_set_minimum_size() # requires MarginOuter/NavMain structure
	_ui_ready()


func _connect_signals() -> void: pass


func _set_minimum_size() -> void:
	if get_node_or_null("%MarginOuter") and get_node_or_null("%NavMain"):
		var margin_outer: MarginContainer = get_node("%MarginOuter")
		var margin_value: int = outer_margin
		margin_outer.add_theme_constant_override("margin_top", margin_value)
		margin_outer.add_theme_constant_override("margin_left", margin_value)
		margin_outer.add_theme_constant_override("margin_bottom", margin_value)
		margin_outer.add_theme_constant_override("margin_right", margin_value)

		var nav_main: Control = get_node("%NavMain")
		var scene_base_size: Vector2i = ProjectSettings.get_setting("services/config/scene_base_size")
		nav_main.custom_minimum_size.x = scene_base_size.x - 16
		nav_main.custom_minimum_size.y = scene_base_size.y - 16
		Debug.log_verbose("%s outer margin: %d" % [name, outer_margin])
	else:
		Debug.log_warning("Unable to set minimum size: %s" % get_path())


func _ui_ready() -> void: pass
