class_name DialogConfirm extends Control

signal completed(p_result: bool)

var confirm_text: String
var cancel_text: String
var text: String

@onready var confirm_button: Button = %ConfirmButton
@onready var cancel_button: Button = %CancelButton
@onready var confirmation_label: Label = %ConfirmationLabel


func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS

	confirmation_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	confirmation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	confirmation_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)

	var confirm_shortcut: Shortcut = Shortcut.new()
	var confirm_event: InputEventAction = InputEventAction.new()
	confirm_event.action = "ui_accept"
	confirm_shortcut.events.append(confirm_event)
	confirm_button.shortcut = confirm_shortcut

	var cancel_shortcut: Shortcut = Shortcut.new()
	var cancel_event: InputEventAction = InputEventAction.new()
	cancel_event.action = "ui_cancel"
	cancel_shortcut.events.append(cancel_event)
	cancel_button.shortcut = cancel_shortcut


func configure(p_text: String, p_confirm_text: String, p_cancel_text: String) -> void:
	confirmation_label.text = p_text
	confirm_button.text = p_confirm_text
	cancel_button.text = p_cancel_text
	var height: int = (confirmation_label.get_line_count() * confirmation_label.get_line_height()) + confirmation_label.get_line_height()
	confirmation_label.custom_minimum_size = Vector2(confirmation_label.size.x, height)
	Debug.log_debug("Presented confirmation: %s" % p_text)


func await_input() -> bool:
	System.pause(true)
	var result: bool = await completed
	System.pause(false)
	self.queue_free()
	return result


func _on_confirm_pressed() -> void:
	Debug.log_debug("-> Confirmation received")
	completed.emit(true)


func _on_cancel_pressed() -> void:
	Debug.log_debug("-> Confirmation cancelled")
	completed.emit(false)
