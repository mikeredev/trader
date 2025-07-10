class_name Debug extends RefCounted

enum Severity {	VERBOSE, DEBUG, INFO, WARNING, ERROR }

const COLOR: Dictionary[Severity, Color] = {
	Severity.VERBOSE: Color.DARK_CYAN,
	Severity.DEBUG: Color.WEB_GRAY,
	Severity.INFO: Color.CORNSILK,
	Severity.WARNING: Color.ORANGE,
	Severity.ERROR: Color.RED }

static var threshold: Severity = Severity.DEBUG
static var active_state: StringName = "NONE"


static func log_verbose(p_text: Variant) -> void:
	_notify(p_text, Severity.VERBOSE)


static func log_debug(p_text: Variant) -> void:
	_notify(p_text, Severity.DEBUG)


static func log_info(p_text: Variant) -> void:
	_notify(p_text, Severity.INFO)


static func log_warning(p_text: Variant) -> void:
	_notify(p_text, Severity.WARNING)


static func log_error(p_text: Variant) -> void:
	_notify(p_text, Severity.ERROR)


static func connect_signals() -> void:
	EventBus.state_entered.connect(_on_state_entered)


static func set_threshold(p_threshold: Severity) -> void:
	threshold = p_threshold


static func _notify(p_text: Variant, p_severity: Severity) -> void:
	if p_severity < threshold: return
	var color: Color = _get_color(p_severity)
	var timestamp: String = _get_timestamp()
	var formatted_active_state: String = _get_active_state()
	var text: String = _get_text(p_text)
	var result: String = "%s | %s | [color=%s]%s[/color]" % [
		timestamp, formatted_active_state, color.to_html(), text ]
	print_rich(result)

	if p_severity == Severity.WARNING:
		_send_ui_alert(text)
		push_warning(text)
	if p_severity == Severity.ERROR:
		_send_ui_alert(text)
		push_error(text)


static func _get_active_state() -> String:
	var color: Color = Color.WHITE
	match active_state:
		"NONE": color = Color.DIM_GRAY
		"BOOT": color = Color.PALE_GREEN
		"INIT": color = Color.PALE_TURQUOISE
		"SETUP": color = Color.LIME_GREEN
		"START": color = Color.PERU
		"BUILD": color = Color.GREEN_YELLOW
		"READY": color = Color.SKY_BLUE
		"INCITY": color = Color.BISQUE
		"ATSEA": color = Color.MEDIUM_SLATE_BLUE
	return "[color=%s]%s[/color]" % [color.to_html(), active_state]


static func _get_color(p_severity: Severity) -> Color:
	return COLOR.get(p_severity)


static func _get_timestamp() -> String:
	return str(Time.get_ticks_msec())


static func _get_text(p_text: Variant) -> String:
	return str(p_text)


static func _send_ui_alert(p_text: String) -> void:
	EventBus.create_notification.emit(p_text) # bypass scene manager for early alerts


static func _on_state_entered(p_state: ActiveState) -> void:
	active_state = p_state.state_id.to_upper()
