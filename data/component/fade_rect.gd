class_name FadeRect extends ColorRect # ensure this is anchored to full screen, behind all other nodes

const BG_FADE_DURATION: float = 1.0

var tween: Tween


func _ready() -> void:
	var primary_bg: Color = ProjectSettings.get_setting("gui/theme/scheme/primary_bg")
	color = primary_bg
	modulate.a = 0.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	Debug.log_verbose("%s/%s color: #%s" % [get_parent().name, name, primary_bg.to_html()])


func fade(p_toggled_on: bool) -> void:
	if tween: tween.kill()
	if p_toggled_on:
		tween = System.manage.scene.create_tween(self, "modulate:a", 0.5, BG_FADE_DURATION)
		self.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		tween = System.manage.scene.create_tween(self, "modulate:a", 0.0, BG_FADE_DURATION)
		self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	Debug.log_verbose("Fade %s: %s" % [p_toggled_on, get_path()])
