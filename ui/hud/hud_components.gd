class_name HUDComponentDisplay extends VBoxContainer

# reminder to unassigned theme from root when done

@onready var info_bar: InfoBar = %InfoBar
@onready var notification_area: NotificationArea = %NotificationArea



func setup() -> void:
	create_info_bar()
	create_notification_area()


func create_info_bar() -> void:
	info_bar.setup()


func create_notification_area() -> void:
	notification_area.setup()


#func _process(_delta: float) -> void:
	#var fps: float = Engine.get_frames_per_second()
	#ui_fps_label.text = "%.00f FPS" % fps


#func update_ui_zoom(p_zoom: Vector2) -> void:
	#pass
