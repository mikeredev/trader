class_name SplashUI extends Control

var _fade: ColorRect
var tween: Tween

func _init() -> void:
	name = "Splash"


func add_modal(p_scene: Variant, p_fade: Color, p_alpha: float, p_block_mouse: bool = true) -> DialogConfirm:
	var modal: DialogConfirm = Service.scene_manager.create_scene(p_scene) # extend to ModalUI?
	add_child(modal)
	set_fade(p_fade, p_alpha, p_block_mouse)
	Debug.log_debug("Added modal: %s" % modal.get_path())
	return modal


func reset_fade() -> void:
	tween = Service.scene_manager.create_tween(_fade, "modulate:a", 0.0, 0.2)
	tween.parallel().tween_property(_fade, "color", Color.BLACK, 0.8)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_fade(p_fade: Color, p_alpha: float, p_block_mouse: bool) -> void:
	tween = Service.scene_manager.create_tween(_fade, "modulate:a", p_alpha, 0.2)
	tween.parallel().tween_property(_fade, "color", p_fade, 0.8)
	if p_block_mouse:
		_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	Debug.log_verbose("Fade color: %s, alpha: %.1f, blocked: %s" % [p_fade.to_html(), p_alpha, p_block_mouse])


func setup() -> void:
	_add_fade()


func _add_fade() -> void:
	_fade = ColorRect.new()
	_fade.name = "Fade"
	_fade.color = Color.BLACK
	_fade.color.a = 0.0 # always start clear
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade)
