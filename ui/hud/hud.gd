class_name HUD extends UIControl

# UIControl elements
@onready var background: ColorRect = %Background
@onready var margin_outer: MarginContainer = %MarginOuter
@onready var nav_main: VBoxContainer = %NavMain

# HUD components
@onready var info_bar: InfoBar = %InfoBar
@onready var notification_area: NotificationArea = %NotificationArea
@onready var city_options: CityOptionsPanel = %CityOptions
@onready var game_options: GameOptionsPanel = %GameOptions
@onready var dialog_confirm: Control = %DialogConfirm


func _ui_ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin_outer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.process_mode = Node.PROCESS_MODE_ALWAYS
	Debug.log_debug("Created HUD Overlay: %s" % get_path())


func clear() -> void:
	pass # clear notifs etc, used on soft reset


func setup() -> void:
	info_bar.setup()
	notification_area.setup()
	city_options.setup()
	game_options.setup()


func _on_test_alert_button_pressed() -> void:
	EventBus.create_notification.emit("test message")


func _on_test_alert_button_2_pressed() -> void:
	System.service.scene_manager.get_confirmation("hello test here")
