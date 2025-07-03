class_name DeveloperSettings extends ConfigUtility

var enable_astar: bool = true

func apply_config() -> void:
	Debug.log_info("Applying developer settings...")
	set_enable_astar(enable_astar)


func set_enable_astar(p_enabled: bool, p_save: bool = false) -> void:
	enable_astar = p_enabled
	Debug.log_debug("Set enable A*: %s" % [enable_astar])
	if p_save: EventBus.config_changed.emit()


func to_dict() -> Dictionary[String, Variant]:
	return {
		"enable_astar": enable_astar
	}


func to_grid() -> GridContainer:
	var settings: Array[Variant] = [ enable_astar ]
	var grid: GridContainer = GridContainer.new()
	grid.name = "DeveloperSettings"
	grid.columns = 2

	for setting: Variant in settings:
		var label_name: Label = Label.new()
		var ui_element: Control # variable

		match setting:
			enable_astar:
				label_name.text = tr("ENABLE_A*")
				var check_button: CheckButton = CheckButton.new()
				check_button.button_pressed = enable_astar
				check_button.toggled.connect(set_enable_astar.bind(true))
				ui_element = check_button

		label_name.name = "%s%s" % ["Label", label_name.text.to_pascal_case()]
		ui_element.name = "%s%s" % ["Option", label_name.text.to_pascal_case()]
		grid.add_child(label_name)
		grid.add_child(ui_element)
#
	return grid


static func from_dict(p_dict: Dictionary) -> DeveloperSettings:
	var out: DeveloperSettings = DeveloperSettings.new()

	out.enable_astar = p_dict.get("enable_astar", out.enable_astar)

	return out


#func _get_max_autosaves(p_value: float, p_save: bool) -> void:
	#set_max_autosaves(int(p_value), p_save)
