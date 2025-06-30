class_name UIButtonStartMenu extends Button

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
	var tween: Tween
	var return_to: int = position.x
	position.x += 5
	tween = Common.Util.new_tween(self, "position:x", return_to, 0.1, Tween.TRANS_SPRING, Tween.EASE_OUT)
	await tween.finished
