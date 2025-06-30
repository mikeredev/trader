class_name ModSettings extends ConfigUtility



func apply_config() -> void:
	Debug.log_info("Applying mod settings...")




func to_dict() -> Dictionary[String, Variant]:
	return {
	}


func to_grid() -> GridContainer:
	#var settings: Array[Variant] = [ max_autosaves ]
	var grid: GridContainer = GridContainer.new()
	grid.name = "ModSettings"
	grid.columns = 2
#
	#for setting: Variant in settings:
		#var label_name: Label = Label.new()
		#var ui_element: Control # variable
#
		#match setting:
			#max_autosaves:
				#label_name.text = tr("MAX_AUTOSAVES")
				#ui_element = SpinBox.new()
				#ui_element.min_value = 0
				#ui_element.max_value = system_max_autosaves
				#ui_element.value = max_autosaves
				#ui_element.value_changed.connect(_get_max_autosaves.bind(true))
#
		#label_name.name = "%s%s" % ["Label", label_name.text.to_pascal_case()]
		#ui_element.name = "%s%s" % ["Option", label_name.text.to_pascal_case()]
		#grid.add_child(label_name)
		#grid.add_child(ui_element)
#
	return grid


static func from_dict(_p_dict: Dictionary) -> ModSettings:
	var out: ModSettings = ModSettings.new()

	#out.max_autosaves = p_dict.get("max_autosaves", out.max_autosaves)

	return out


#func _get_max_autosaves(p_value: float, p_save: bool) -> void:
	#set_max_autosaves(int(p_value), p_save)
