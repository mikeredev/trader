class_name UIButtonStartMenu extends UIButton


func _play_press_tween() -> void:
	var return_to: float = position.x
	position.x += 5
	var tween: Tween = System.service.scene_manager.create_tween(self, "position:x", return_to, 0.1, Tween.TRANS_SPRING, Tween.EASE_OUT)
	await tween.finished
