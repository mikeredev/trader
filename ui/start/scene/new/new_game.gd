extends Control

@onready var return_button: UIButton = %ReturnButton


func _ready() -> void:
	_connect_signals()
	_set_button_shortcuts()


func _connect_signals() -> void:
	return_button.pressed_tweened.connect(_on_return_button_pressed)


func _set_button_shortcuts() -> void:
	var shortcut: Shortcut = Shortcut.new()
	var event: InputEventAction = InputEventAction.new()
	event.action = "ui_cancel"
	shortcut.events.append(event)
	return_button.shortcut = shortcut


func _on_return_button_pressed() -> void:
	EventBus.menu_closed.emit(self)
