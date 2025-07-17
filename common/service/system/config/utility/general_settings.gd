class_name GeneralSettings extends ConfigUtility

var system_max_autosaves: int = ProjectSettings.get_setting("services/config/max_autosaves")
var last_save: String
var last_save_metadata: Dictionary
var max_autosaves: int = 5
var show_intro: bool = true
var show_ui_alerts: bool = true


static func from_dict(p_dict: Dictionary) -> GeneralSettings:
	var out: GeneralSettings = GeneralSettings.new()
	out.last_save = p_dict.get("last_save", out.last_save)
	out.last_save_metadata = p_dict.get("last_save_metadata", out.last_save_metadata)
	out.max_autosaves = p_dict.get("max_autosaves", out.max_autosaves)
	out.show_intro = p_dict.get("show_intro", out.show_intro)
	out.show_ui_alerts = p_dict.get("show_ui_alerts", out.show_ui_alerts)
	return out


func to_dict() -> Dictionary[String, Variant]:
	return {
		"last_save": last_save,
		"last_save_metadata": last_save_metadata,
		"max_autosaves": max_autosaves,
		"show_intro": show_intro,
		"show_ui_alerts": show_ui_alerts,
	}


func to_grid() -> GridContainer:
	var settings: Array[Variant] = [ show_intro, show_ui_alerts, max_autosaves ]
	var grid: GridContainer = GridContainer.new()
	grid.name = "GeneralSettings"
	grid.columns = 2

	for setting: Variant in settings:
		var label_name: Label = Label.new()
		var ui_element: Control # variable

		match setting:
			max_autosaves:
				label_name.text = tr("MAX_AUTOSAVES")
				var spinbox: SpinBox = SpinBox.new()
				spinbox.min_value = 0
				spinbox.max_value = system_max_autosaves
				spinbox.value = max_autosaves
				spinbox.value_changed.connect(_set_max_autosaves.bind(true))
				ui_element = spinbox

			show_intro:
				label_name.text = tr("SHOW_INTRO")
				var check_button: CheckButton = CheckButton.new()
				check_button.button_pressed = show_intro
				check_button.toggled.connect(set_show_intro.bind(true))
				ui_element = check_button

			show_ui_alerts:
				label_name.text = tr("SHOW_UI_ALERTS")
				var check_button: CheckButton = CheckButton.new()
				check_button.button_pressed = show_ui_alerts
				check_button.toggled.connect(set_show_ui_alerts.bind(true))
				ui_element = check_button

		label_name.name = "%s%s" % ["Label", label_name.text.to_pascal_case()]
		ui_element.name = "%s%s" % ["Option", label_name.text.to_pascal_case()]
		grid.add_child(label_name)
		grid.add_child(ui_element)

	return grid


func apply_config() -> void:
	Debug.log_info("Applying general settings...")
	set_max_autosaves(max_autosaves)
	set_show_intro(show_intro)
	set_show_ui_alerts(show_ui_alerts)
	set_last_save(last_save, last_save_metadata)


func set_last_save(p_path: String, p_metadata: Dictionary, p_save: bool = false) -> void:
	last_save = p_path
	last_save_metadata = p_metadata
	Debug.log_debug("Set last save: %s" % p_path)
	if p_save: EventBus.config_changed.emit()


func set_max_autosaves(p_value: int, p_save: bool = false) -> void:
	max_autosaves = clampi(p_value, 0, system_max_autosaves)
	Debug.log_debug("Set max autosaves: %d/%d" % [max_autosaves, system_max_autosaves])
	if p_save: EventBus.config_changed.emit()


func set_show_intro(p_toggled_on: bool, p_save: bool = false) -> void:
	show_intro = p_toggled_on
	Debug.log_debug("Set show intro: %s" % p_toggled_on)
	if p_save: EventBus.config_changed.emit()


func set_show_ui_alerts(p_toggled_on: bool, p_save: bool = false) -> void:
	show_ui_alerts = p_toggled_on
	Debug.log_debug("Set show UI alerts: %s" % p_toggled_on)
	if p_save: EventBus.config_changed.emit()


func _set_max_autosaves(p_value: float, p_save: bool) -> void:
	set_max_autosaves(int(p_value), p_save)
