class_name SettingsMenu extends UISubMenu # hbox

var active: ConfigManager.Section
var cache: Dictionary[ConfigManager.Section, GridContainer]

@onready var nav_bar: VBoxContainer = %NavBar
@onready var nav_content: MarginContainer = %NavContent
@onready var restore_button: UIButton = %RestoreButton
@onready var return_button: UIButton = %ReturnButton


func _connect_signals() -> void:
	restore_button.pressed_tweened.connect(_on_restore_button_pressed)
	return_button.pressed_tweened.connect(_on_return_button_pressed)


func _set_button_shortcuts() -> void:
	var shortcut: Shortcut = Shortcut.new()
	var event: InputEventAction = InputEventAction.new()
	event.action = "ui_cancel"
	shortcut.events.append(event)
	return_button.shortcut = shortcut


func _ui_ready() -> void:
	create_nav()


func create_nav() -> void:
	var group: ButtonGroup = ButtonGroup.new()
	for section: ConfigManager.Section in ConfigManager.Section.values():
		var button: Button = Button.new()
		var section_name: String = ConfigManager.Section.keys()[section]
		button.name = "%s%s" % [section_name.to_pascal_case(), "Settings"]
		button.toggle_mode = true
		button.button_group = group
		button.text = tr(section_name)
		button.toggled.connect(_on_nav_button_toggled.bind(section))
		nav_bar.add_child(button)


func change_grid(p_section: ConfigManager.Section, p_toggled_on: bool) -> void:
	for grid: GridContainer in cache.values():
		grid.visible = !p_toggled_on

	if cache.has(p_section):
		cache[p_section].visible = p_toggled_on
	else:
		var grid: GridContainer
		match p_section:
			ConfigManager.Section.GENERAL: grid = System.manage.config.general_settings.to_grid()
			ConfigManager.Section.AUDIO: grid = System.manage.config.audio_settings.to_grid()
			ConfigManager.Section.CONTROL: grid = System.manage.config.control_settings.to_grid()
			ConfigManager.Section.DEVELOPER: grid = System.manage.config.developer_settings.to_grid()
			ConfigManager.Section.DISPLAY: grid = System.manage.config.display_settings.to_grid()
			ConfigManager.Section.LOCALE: grid = System.manage.config.locale_settings.to_grid()
			ConfigManager.Section.MODS: grid = System.manage.config.mod_settings.to_grid()
		cache[p_section] = grid
		nav_content.add_child(grid)
	active = p_section


func restore_grid() -> void:
	var active_grid: GridContainer = cache.get(active)
	active_grid.queue_free()
	cache.erase(active)
	change_grid(active, true)


func _on_nav_button_toggled(p_toggled_on: bool, p_section: ConfigManager.Section) -> void:
	change_grid(p_section, p_toggled_on)


func _on_restore_button_pressed() -> void:
	if await System.manage.scene.get_confirmation("RESTORE DEFAULT SETTINGS?"):
		System.manage.config.restore_section(active, true)
		restore_grid()


func _on_return_button_pressed() -> void:
	submenu_closed.emit()
