class_name ConfigManager extends Service

enum Section { GENERAL, DISPLAY, AUDIO, MODS, LOCALE, DEVELOPER }

var path: String
var audio_settings: AudioSettings
var general_settings: GeneralSettings
var display_settings: DisplaySettings
var mod_settings: ModSettings
var locale_settings: LocaleSettings
var developer_settings: DeveloperSettings
var _active_mods: PackedStringArray

func _init() -> void:
	EventBus.config_changed.connect(save_config)
	path = FileLocation.USER_CONFIG_FILE


func apply_config() -> void:
	var utilities: Array[ConfigUtility] = [
		general_settings, audio_settings, display_settings, mod_settings, locale_settings, developer_settings ]
	for utility: ConfigUtility in utilities:
		utility.apply_config()


func get_active_mods() -> PackedStringArray:
	return _active_mods


func set_active_mods(p_active_mods: PackedStringArray) -> void:
	_active_mods = p_active_mods


## Attempts to load user settings from [path], using default settings if not found or unreadable.
func load_config() -> void:
	var create_default: bool

	# create a default settings file if [path] does not exist
	if not FileAccess.file_exists(path):
		Debug.log_warning("User config not found, using default")
		create_default = true

	# parse user settings file
	var raw: Dictionary = Common.Util.json.get_dict(path)

	# hydrate utility with user settings, if present
	for section: Section in Section.values():
		var _name: String = _get_section_name(section)
		var _dict: Dictionary = raw.get(_name, {})
		match section:
			Section.GENERAL:
				general_settings = GeneralSettings.from_dict(_dict)
			Section.AUDIO:
				audio_settings = AudioSettings.from_dict(_dict)
			Section.DISPLAY:
				display_settings = DisplaySettings.from_dict(_dict)
			Section.MODS:
				mod_settings = ModSettings.from_dict(_dict)
			Section.LOCALE:
				locale_settings = LocaleSettings.from_dict(_dict)
			Section.DEVELOPER:
				developer_settings = DeveloperSettings.from_dict(_dict)

	_active_mods = raw.get("mods", [])

	# save default settings, if required
	if create_default: save_config()


func restore_section(p_section: Section, p_save: bool = false) -> void:
	match p_section:
		Section.GENERAL:
			general_settings = GeneralSettings.new()
			general_settings.apply_config()

		Section.AUDIO:
			audio_settings = AudioSettings.new()
			audio_settings.apply_config()

		Section.DISPLAY:
			display_settings = DisplaySettings.new()
			display_settings.apply_config()

		Section.MODS:
			mod_settings = ModSettings.new()
			mod_settings.apply_config()

		Section.LOCALE:
			locale_settings = LocaleSettings.new()
			locale_settings.apply_config()

		Section.DEVELOPER:
			developer_settings = DeveloperSettings.new()
			developer_settings.apply_config()

	Debug.log_info("Restored %s settings" % _get_section_name(p_section))
	if p_save:
		EventBus.config_changed.emit()


## Writes user settings to disk at [path].
func save_config() -> void:
	Debug.log_verbose("Saving user config")
	var data: Dictionary[String, Variant] = {}
	for section: Section in Section.values():
		var _name: String = _get_section_name(section)
		match section:
			Section.GENERAL: data[_name] = general_settings.to_dict()
			Section.AUDIO: data[_name] = audio_settings.to_dict()
			Section.DISPLAY: data[_name] = display_settings.to_dict()
			Section.MODS: data[_name] = mod_settings.to_dict()
			Section.LOCALE: data[_name] = locale_settings.to_dict()
			Section.DEVELOPER: data[_name] = developer_settings.to_dict()

	if _active_mods: data["mods"] = _active_mods
	Common.Util.json.save_dict(path, data)


func _get_section_name(p_section: Section) -> String:
	return Section.keys()[p_section]
