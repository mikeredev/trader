class_name TypewriterRichTextLabel extends RichTextLabel # NOTE set fit_content in editor for visibility

signal is_finished

@export_custom(PROPERTY_HINT_NONE, "suffix:ms") var speed: int = 100
@export_custom(PROPERTY_HINT_NONE, "suffix:ms") var comma_delay: int = 300
@export_custom(PROPERTY_HINT_NONE, "suffix:ms") var period_delay: int = 600
@export var autoplay: bool = false

var _index: int = 0
var _next_tick: int = 0
var _active: bool = false
var _finished: bool = false


func _ready() -> void:
	fit_content = true
	bbcode_enabled = true
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(true)
	if autoplay: play()


func _process(_delta: float) -> void:
	if _finished: return
	if not _active: return

	if _index >= get_total_character_count():
		_active = false
		_finished = true
		is_finished.emit()
		return

	if Time.get_ticks_msec() >= _next_tick:
		_index += 1
		_index = clamp(_index, 0, get_total_character_count())
		visible_characters = _index

		var full_text = get_text()
		var char = full_text[_index - 1]

		var delay = speed
		match char:
			',':
				delay = comma_delay
			'.', ';', '!', '?':
				delay = period_delay

		_next_tick = Time.get_ticks_msec() + delay

	custom_minimum_size.y = get_content_height()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _active: skip()


func play() -> void:
	_active = true
	_index = 0
	visible_characters = 0
	_next_tick = Time.get_ticks_msec() + speed
	_finished = false


func skip() -> void:
	if _finished: return
	_active = false
	_finished = true
	_index = get_total_character_count()
	visible_characters = _index
	is_finished.emit()
