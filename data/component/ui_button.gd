class_name UIButton extends Button

signal pressed_tweened


func _ready() -> void:
	await get_tree().process_frame
	self.pivot_offset = size / 2
	self.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	#await _play_press_tween()
	_play_press_tween()
	pressed_tweened.emit()


func _play_press_tween() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
	#await tween.finished
