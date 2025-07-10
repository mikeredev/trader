class_name UIControl extends Control

const BG_FADE_DURATION: float = 1.0

var background_tween: Tween

@export var outer_margin: int = 256


func _ready() -> void:
	_connect_signals()
	_set_minimum_size() # requires MarginOuter/NavMain structure
	_set_color_scheme() # sets a %Background color rect to the project primary color
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
		Debug.log_verbose("Set outer margin %s: %d" % [name, outer_margin])
	else:
		Debug.log_warning("Unable to set minimum size: %s" % get_path())


func _set_color_scheme() -> void:
	if get_node_or_null("%Background"):
		var background: ColorRect = get_node("%Background")
		var primary_bg: Color = ProjectSettings.get_setting("gui/theme/scheme/primary_bg")
		background.color = primary_bg
		background.color.a = 1.0
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		Debug.log_verbose("Set background %s: %s" % [primary_bg.to_html(), name])


func _ui_ready() -> void: pass


func fade_background(p_color: Color = Color.BLACK) -> void:
	if get_node_or_null("%Background"):
		var background: ColorRect = get_node("%Background")
		if background_tween: background_tween.kill()
		background_tween = Service.scene_manager.create_tween(background, "modulate:a", 0.5, BG_FADE_DURATION)
		#background_tween.parallel().tween_property(background, "color", p_color, BG_FADE_DURATION)
		background.mouse_filter = Control.MOUSE_FILTER_STOP


func reset_background() -> void:
	if get_node_or_null("%Background"):
		var background: ColorRect = get_node("%Background")
		if background_tween: background_tween.kill()
		background_tween = Service.scene_manager.create_tween(background, "modulate:a", 0.0, BG_FADE_DURATION)
		#background_tween.parallel().tween_property(background, "color", Color.BLACK, BG_FADE_DURATION)
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
