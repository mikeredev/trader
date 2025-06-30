class_name UIButton extends Button

signal tweened


func _ready() -> void:
	await get_tree().process_frame
	self.pivot_offset = size / 2
	self.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	await _play_press_tween()
	tweened.emit()


func _play_press_tween() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
	#await tween.finished
