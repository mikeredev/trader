class_name HUDComponentDisplay extends VBoxContainer

@export var dev_mode_enabled: bool = true

# reminder to unassigned theme from root when done
@onready var ui_location_label: Label = %LocationLabel
@onready var ui_fps_label: Label = %FPSLabel
@onready var ui_zoom_label: Label = %ZoomLabel
@onready var notification_area: NotificationArea = %NotificationArea


func _ready() -> void:
	_create_info_bar()
	_create_notification_area()


func _create_info_bar() -> void:
	pass


func _create_notification_area() -> void:
	pass


func _process(_delta: float) -> void:
	var fps: float = Engine.get_frames_per_second()
	ui_fps_label.text = "%.00f FPS" % fps


func update_ui_zoom(p_zoom: Vector2) -> void:
	pass
