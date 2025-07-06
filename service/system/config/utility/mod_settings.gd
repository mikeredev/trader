class_name ModSettings extends ConfigUtility

var saved_mods: PackedStringArray = []


func apply_config() -> void:
	Debug.log_info("Applying mod settings...")
	set_saved_mods(saved_mods)


func to_dict() -> Dictionary[String, Variant]:
	return {
		"saved_mods": saved_mods,
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


static func from_dict(p_dict: Dictionary) -> ModSettings:
	var out: ModSettings = ModSettings.new()
	out.saved_mods = p_dict.get("saved_mods", out.saved_mods)
	return out


func get_saved_mods() -> PackedStringArray:
	return saved_mods


func set_saved_mods(p_active_mods: PackedStringArray, p_save: bool = false) -> void:
	saved_mods = p_active_mods
	Debug.log_debug("Set saved_mods mods: %s" % p_active_mods)
	if p_save: EventBus.config_changed.emit()


#func _get_max_autosaves(p_value: float, p_save: bool) -> void:
	#set_max_autosaves(int(p_value), p_save)
