class_name ConfigManager extends Service

enum Section { GENERAL, AUDIO, DISPLAY, CONTROL, LOCALE, MODS, DEVELOPER } # defines processing order

var path: String
var utilities: Array[ConfigUtility]
var audio_settings: AudioSettings
var control_settings: ControlSettings
var developer_settings: DeveloperSettings
var display_settings: DisplaySettings
var general_settings: GeneralSettings
var locale_settings: LocaleSettings
var mod_settings: ModSettings


func _init() -> void:
	path = FileLocation.USER_CONFIG_FILE
	EventBus.config_changed.connect(save_config)


func apply_config() -> void:
	for utility: ConfigUtility in utilities:
		utility.apply_config()


func apply_project_settings(p_dict: Dictionary[String, Variant]) -> void:
	Debug.log_info("Applying project settings...")
	for setting: String in p_dict.keys():
		ProjectSettings.set_setting(setting, p_dict[setting])
		Debug.log_debug("Set %s: %s" % [setting, p_dict[setting]])


## Attempts to load user settings from [path], using default settings if not found or unreadable.
func load_config() -> void:
	var create_default: bool
	if not FileAccess.file_exists(path):
		Debug.log_warning("User config not found, using default")
		create_default = true
	var raw: Dictionary = Common.Util.json.get_dict(path)
	for section: Section in Section.values():
		var _name: String = _get_section_name(section)
		var _dict: Dictionary = raw.get(_name, {})
		match section:
			Section.AUDIO:
				audio_settings = AudioSettings.from_dict(_dict)
				utilities.append(audio_settings)
			Section.CONTROL:
				control_settings = ControlSettings.from_dict(_dict)
				utilities.append(control_settings)
			Section.DEVELOPER:
				developer_settings = DeveloperSettings.from_dict(_dict)
				utilities.append(developer_settings)
			Section.DISPLAY:
				display_settings = DisplaySettings.from_dict(_dict)
				utilities.append(display_settings)
			Section.GENERAL:
				general_settings = GeneralSettings.from_dict(_dict)
				utilities.append(general_settings)
			Section.LOCALE:
				locale_settings = LocaleSettings.from_dict(_dict)
				utilities.append(locale_settings)
			Section.MODS:
				mod_settings = ModSettings.from_dict(_dict)
				utilities.append(mod_settings)
	if create_default: save_config()


func restore_section(p_section: Section, p_save: bool = false) -> void:
	match p_section:
		Section.AUDIO:
			audio_settings = AudioSettings.new()
			audio_settings.apply_config()
		Section.CONTROL:
			control_settings = ControlSettings.new()
			control_settings.apply_config()
		Section.DEVELOPER:
			developer_settings = DeveloperSettings.new()
			developer_settings.apply_config()
		Section.DISPLAY:
			display_settings = DisplaySettings.new()
			display_settings.apply_config()
		Section.GENERAL:
			general_settings = GeneralSettings.new()
			general_settings.apply_config()
		Section.LOCALE:
			locale_settings = LocaleSettings.new()
			locale_settings.apply_config()
		Section.MODS:
			mod_settings = ModSettings.new()
			mod_settings.apply_config()
	Debug.log_info("Restored %s settings" % _get_section_name(p_section))
	if p_save: EventBus.config_changed.emit()


## Writes user settings to disk at [path].
func save_config() -> void:
	Debug.log_verbose("Saving user config")
	var data: Dictionary[String, Variant] = {}
	for section: Section in Section.values():
		var _name: String = _get_section_name(section)
		match section:
			Section.AUDIO: data[_name] = audio_settings.to_dict()
			Section.CONTROL: data[_name] = control_settings.to_dict()
			Section.DEVELOPER: data[_name] = developer_settings.to_dict()
			Section.GENERAL: data[_name] = general_settings.to_dict()
			Section.DISPLAY: data[_name] = display_settings.to_dict()
			Section.LOCALE: data[_name] = locale_settings.to_dict()
			Section.MODS: data[_name] = mod_settings.to_dict()
	Common.Util.json.save_dict(path, data)


func _get_section_name(p_section: Section) -> String:
	return Section.keys()[p_section]
