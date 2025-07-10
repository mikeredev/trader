class_name DialogConfirm extends PanelContainer

signal completed(p_result: bool)

@onready var ui_confirm: Button = %ConfirmButton # use custom UIButton
@onready var ui_cancel: Button = %CancelButton
@onready var ui_text: Label = %ConfirmationLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# set label properties
	ui_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ui_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# connect button signals
	ui_confirm.pressed.connect(_on_confirm_pressed)
	ui_cancel.pressed.connect(_on_cancel_pressed)

	# create button shortcuts
	var confirm_shortcut: Shortcut = Shortcut.new()
	var confirm_event: InputEventAction = InputEventAction.new()
	confirm_event.action = "ui_accept"
	confirm_shortcut.events.append(confirm_event)
	ui_confirm.shortcut = confirm_shortcut

	var cancel_shortcut: Shortcut = Shortcut.new()
	var cancel_event: InputEventAction = InputEventAction.new()
	cancel_event.action = "ui_cancel"
	cancel_shortcut.events.append(cancel_event)
	ui_cancel.shortcut = cancel_shortcut


func configure(p_text: String, p_confirm_text: String, p_cancel_text: String) -> void:
	completed.connect(_on_completed)
	ui_text.text = p_text
	ui_confirm.text = p_confirm_text
	ui_cancel.text = p_cancel_text
	var height: int = (ui_text.get_line_count() * ui_text.get_line_height()) + ui_text.get_line_height()
	ui_text.custom_minimum_size = Vector2(ui_text.size.x, height)
	Debug.log_debug("Presented for user confirmation: %s" % p_text)


func await_input(p_pause: bool = false) -> bool:
	if p_pause: System.pause_game(true)
	var result: bool = await completed
	if p_pause: System.pause_game(false)
	call_deferred("queue_free")
	return result


func _on_confirm_pressed() -> void:
	Debug.log_debug("Confirmation received")
	completed.emit(true)


func _on_cancel_pressed() -> void:
	Debug.log_debug("Confirmation cancelled")
	completed.emit(false)


func _on_completed(_p_ignore: bool) -> void:
	EventBus.modal_closed.emit() # notify UI of modal closure
