class_name GeneralSettings extends ConfigUtility

var system_max_autosaves: int = ProjectSettings.get_setting("services/config/max_autosaves")
var max_autosaves: int = 5
var show_intro: bool = true


func apply_config() -> void:
	Debug.log_info("Applying general settings...")
	set_max_autosaves(max_autosaves)


func set_show_intro(p_toggled_on: bool, p_save: bool = false) -> void:
	show_intro = p_toggled_on
	Debug.log_debug("Set show intro: %s" % p_toggled_on)
	if p_save: EventBus.config_changed.emit()


func set_max_autosaves(p_value: int, p_save: bool = false) -> void:
	max_autosaves = clampi(p_value, 0, system_max_autosaves)
	Debug.log_debug("Set max autosaves: %d/%d" % [max_autosaves, system_max_autosaves])
	if p_save: EventBus.config_changed.emit()


func to_dict() -> Dictionary[String, Variant]:
	return {
		"show_intro": show_intro,
		"max_autosaves": max_autosaves
	}


func to_grid() -> GridContainer:
	var settings: Array[Variant] = [ show_intro, max_autosaves ]
	var grid: GridContainer = GridContainer.new()
	grid.name = "GeneralSettings"
	grid.columns = 2

	for setting: Variant in settings:
		var label_name: Label = Label.new()
		var ui_element: Control # variable

		match setting:
			show_intro:
				label_name.text = tr("SHOW_INTRO")
				var check_button: CheckButton = CheckButton.new()
				check_button.button_pressed = show_intro
				check_button.toggled.connect(set_show_intro.bind(true))
				ui_element = check_button

			max_autosaves:
				label_name.text = tr("MAX_AUTOSAVES")
				var spinbox: SpinBox = SpinBox.new()
				spinbox.min_value = 0
				spinbox.max_value = system_max_autosaves
				spinbox.value = max_autosaves
				spinbox.value_changed.connect(_get_max_autosaves.bind(true))
				ui_element = spinbox

		label_name.name = "%s%s" % ["Label", label_name.text.to_pascal_case()]
		ui_element.name = "%s%s" % ["Option", label_name.text.to_pascal_case()]
		grid.add_child(label_name)
		grid.add_child(ui_element)

	return grid


static func from_dict(p_dict: Dictionary) -> GeneralSettings:
	var out: GeneralSettings = GeneralSettings.new()

	out.show_intro = p_dict.get("show_intro", out.show_intro)
	out.max_autosaves = p_dict.get("max_autosaves", out.max_autosaves)

	return out


func _get_max_autosaves(p_value: float, p_save: bool) -> void:
	set_max_autosaves(int(p_value), p_save)
