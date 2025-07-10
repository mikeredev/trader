class_name DisplaySettings extends ConfigUtility

## Pre-configured window modes.
enum WindowMode {
	WINDOWED,
	FULLSCREEN,
	WINDOWED_BORDERLESS }

## Pre-configured window sizes.
const WINDOW_SIZE: Dictionary[String, Vector2i] = {
	"640x360": Vector2i(640, 360),
	"1280x720": Vector2i(1280, 720),
	"1920x1080": Vector2i(1920, 1080),
}

var window_mode: WindowMode = WindowMode.WINDOWED_BORDERLESS ## Running [enum WindowMode]
var window_size: Vector2i = WINDOW_SIZE.get("640x360") ## Running [const WINDOW_SIZE]
var vsync: bool = true ## Running V-Sync status.


func apply_config() -> void:
	Debug.log_info("Applying display settings...")
	set_window_mode(window_mode)
	set_window_size(window_size)
	set_vsync(vsync)


#func restore_config() -> void:
	#var x = DisplaySettings.new()
	#window_mode = x.window_mode
	#window_size = x.window_size
	#vsync = x.vsync
	#Debug.log_info("Restored display config")


func to_dict() -> Dictionary[String, Variant]:
	return {
		"window_size": window_size,
		"window_mode": window_mode,
		"vsync": vsync,
	}


func to_grid() -> GridContainer:
	var settings: Array[Variant] = [ window_mode, window_size, vsync ]
	var grid: GridContainer = GridContainer.new()
	grid.name = "DisplaySettings"
	grid.columns = 2

	for setting: Variant in settings:
		var label_name: Label = Label.new()
		var ui_element: Control # variable

		match setting:
			window_mode:
				label_name.text = tr("WINDOW_MODE")
				var option: OptionButton = OptionButton.new()
				option.item_selected.connect(set_window_mode.bind(true))
				populate_dropdown(window_mode, TYPE_INT, option, WindowMode)
				ui_element = option

			window_size:
				label_name.text = tr("WINDOW_SIZE")
				var option: OptionButton = OptionButton.new()
				option.item_selected.connect(_get_window_size.bind(ui_element, true))
				var result: Error = populate_dropdown(window_size, TYPE_VECTOR2I, option, WINDOW_SIZE)
				if result == ERR_DOES_NOT_EXIST:
					option.add_separator("Custom")
					var option_name: String = "%sx%s" % [window_size.x, window_size.y]
					var option_id: int = option.item_count # -1 not required due to separator
					option.add_item(option_name, option_id)
					option.set_item_metadata(option_id, window_size)
					option.select(option_id)
				ui_element = option

			vsync:
				label_name.text = "VSync" # not localized
				var radio: CheckButton = CheckButton.new()
				radio.toggled.connect(set_vsync.bind(true))
				ui_element = radio

		label_name.name = "%s%s" % ["Label", label_name.text.to_pascal_case()]
		ui_element.name = "%s%s" % ["Option", label_name.text.to_pascal_case()]
		grid.add_child(label_name)
		grid.add_child(ui_element)

	return grid


static func from_dict(p_dict: Dictionary) -> DisplaySettings:
	var out: DisplaySettings = DisplaySettings.new()

	var _window_mode: int = p_dict.get("window_mode", out.window_mode)
	out.window_mode = clampi(_window_mode, 0, WindowMode.size() - 1) as WindowMode

	out.window_size = Common.Util.json.convert_to(
		TYPE_VECTOR2I, p_dict.get("window_size", out.window_size))

	out.vsync = p_dict.get("vsync", out.vsync)

	return out


func set_window_mode(p_window_mode: WindowMode, p_save: bool = false) -> void:
	window_mode = clampi(p_window_mode, 0, WindowMode.size() - 1) as WindowMode
	match window_mode:
		WindowMode.WINDOWED_BORDERLESS:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

		WindowMode.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

		WindowMode.WINDOWED:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	Debug.log_debug("Set window mode: %s" % WindowMode.keys()[window_mode])
	if p_save: EventBus.config_changed.emit()


## Applies the given window size and centers the window.
func set_window_size(p_window_size: Vector2i, p_save: bool = false) -> void:
	var min_size: Vector2i = ProjectSettings.get_setting("services/config/scene_base_size")
	var max_size: Vector2i = DisplayServer.screen_get_size()
	window_size = clamp(p_window_size, min_size, max_size) # clamped to scene base size minimum

	DisplayServer.window_set_size(window_size)
	Debug.log_debug("Set window size: %s" % window_size)

	await EventBus.get_tree().process_frame
	System.manage.scene.center_window(window_size)
	if p_save: EventBus.config_changed.emit()


## Toggles V-Sync.
func set_vsync(p_vsync: bool, p_save: bool = false) -> void:
	vsync = p_vsync
	Debug.log_debug("Set V-Sync: %s" % vsync)
	if p_save: EventBus.config_changed.emit()


func _get_window_size(p_index: int, p_ui_element: OptionButton, p_save: bool) -> void:
	if p_index <= WINDOW_SIZE.size():
		var _window_size: Vector2i = WINDOW_SIZE.values()[p_index]
		set_window_size(_window_size, p_save)
	else:
		var _window_size: Vector2i = p_ui_element.get_item_metadata(p_index)
		set_window_size(_window_size, p_save)
