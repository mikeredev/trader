class_name NotificationBox extends PanelContainer

var visible_line_count: int
var total_line_count: int

@onready var ui_icon: TextureRect = %Icon
@onready var ui_message: Label = %Message


func configure_message(p_message: String) -> void:
	ui_message.text = p_message
	ui_message.tooltip_text = p_message
	total_line_count = ui_message.get_line_count()
	visible_line_count = ui_message.get_visible_line_count()
	#prints(ui_message.get_line_height(), ui_message.get_line_count(), ui_message.get_visible_line_count(), ui_message.custom_minimum_size.y)


func _on_message_gui_input(event: InputEvent) -> void:
	pass
