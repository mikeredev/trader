class_name NotificationBox extends PanelContainer

signal remove

#var visible_line_count: int
#var total_line_count: int

@onready var ui_icon: TextureRect = %Icon
@onready var ui_message: Label = %Message


func configure(p_message: String) -> void:
	ui_message.text = p_message
	ui_message.tooltip_text = p_message
	#total_line_count = ui_message.get_line_count()
	#visible_line_count = ui_message.get_visible_line_count()


func _unhandled_input(event: InputEvent) -> void:
	if has_focus():
		if event.is_action_pressed("ui_accept"): print("accept")
		elif event.is_action_pressed("ui_cancel"): print("cancel")


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.pressed:
			match mouse_event.button_index:
				MOUSE_BUTTON_LEFT: print("left")
				MOUSE_BUTTON_MIDDLE: print("middle")
				MOUSE_BUTTON_RIGHT: remove.emit()
