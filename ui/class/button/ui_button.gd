class_name UIButton extends Button ## A button that plays an animation.

signal pressed_tweened # connect from externally to this, not pressed


func _ready() -> void:
	await get_tree().process_frame
	self.pivot_offset = size / 2
	self.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	_play_press_tween()
	pressed_tweened.emit()


func _play_press_tween() -> void: # overwrite this in any subclasses to modify tween animation
	var return_to: Vector2 = scale
	scale = Vector2(0.95, 0.95)
	var tween: Tween = Service.scene_manager.create_tween(self, "scale", return_to, 0.1)
