class_name NotificationArea extends ScrollContainer

var _box: PackedScene = FileLocation.NOTIFICATION_BOX

@onready var alert_stack: VBoxContainer = %AlertStack


func _ready() -> void:
	EventBus.notification_sent.connect(_on_notification_sent)


func _on_notification_sent(p_message: String) -> void:
	var box: NotificationBox = _box.instantiate()

	# add to stack
	alert_stack.add_child(box)

	# configure message
	box.configure_message(p_message)
