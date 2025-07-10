class_name HUD extends UIControl

# UIControl elements
@onready var margin_outer: MarginContainer = %MarginOuter
@onready var nav_main: VBoxContainer = %NavMain
@onready var background: ColorRect = %Background

# HUD components
@onready var info_bar: InfoBar = %InfoBar
@onready var notification_area: NotificationArea = %NotificationArea
@onready var city_options: CityOptionsPanel = %CityOptions
@onready var game_options: GameOptionsPanel = %GameOptions
@onready var dialog_confirm: Control = %DialogConfirm


func _ui_ready() -> void:
	background.modulate.a = 0.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin_outer.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	Service.scene_manager.get_confirmation("hello test here")
