class_name TypewriterRichTextLabel extends RichTextLabel

signal is_finished

@export var tick_normal: int = 10
@export var tick_comma: int = 300
@export var tick_period: int = 800
@export var delay_after: int = 1000

@export var active_toggle: bool:
	set(p):
		active_toggle = p
		_active = p
		return p

var _index: int = 0
var _next_tick: int = 0
var _active: bool = false
var _finished_displaying: bool = false


func _ready() -> void:
	bbcode_enabled = true
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(true)


func _process(_delta: float) -> void:
	if not _active:
		return

	if _index >= get_total_character_count():
		_active = false
		_finished_displaying = true
		await get_tree().create_timer(delay_after / 1000.0).timeout
		is_finished.emit()
		return

	if Time.get_ticks_msec() >= _next_tick:
		_index += 1
		visible_characters = _index
		_next_tick = Time.get_ticks_msec()

	# Update height to match currently visible text
	custom_minimum_size.y = get_content_height()




func play() -> void:
	_active = true
	_index = 0
	visible_characters = -1
	_next_tick = Time.get_ticks_msec() + tick_normal



func skip() -> void:
	_active = false
	_index = get_total_character_count()
	visible_characters = _index
	is_finished.emit()
