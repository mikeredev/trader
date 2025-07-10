class_name SplashUI extends Control

var _fade: ColorRect


func _init() -> void:
	name = "Splash"


func setup() -> void:
	_add_fade()


func set_fade(p_color: Color, p_alpha: float, p_block_mouse: bool) -> void:
	_fade.color = p_color
	_fade.color.a = p_alpha
	if p_block_mouse: _fade.mouse_filter = Control.MOUSE_FILTER_STOP
	else: _fade.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _add_fade() -> void:
	_fade = ColorRect.new()
	_fade.name = "Fade"
	_fade.color = Color.BLACK
	_fade.color.a = 0.0 # start clear
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade)
