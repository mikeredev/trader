extends Control

@onready var ui_location_label: Label = %LocationLabel
@onready var ui_fps_label: Label = %FPSLabel
@onready var ui_zoom_label: Label = %ZoomLabel


func _init() -> void:
	pass


func _ready() -> void:
	pass


func _connect_signals() -> void:
	pass#EventBus.view_active.connect()

func _process(_delta: float) -> void:
	var fps: float = Engine.get_frames_per_second()
	ui_fps_label.text = "%.00f FPS" % fps


func update_ui_zoom(p_zoom: Vector2) -> void:
	pass
