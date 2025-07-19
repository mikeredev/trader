extends UISubMenu

@onready var ui_profile_name: LineEdit = %PlayerName # mismatch
@onready var ui_country_list: OptionButton = %CountryList
@onready var ui_start_button: UIButton = %StartButton
@onready var ui_return_button: UIButton = %ReturnButton


func _connect_signals() -> void:
	ui_start_button.pressed_tweened.connect(_on_start_pressed)
	ui_return_button.pressed_tweened.connect(_on_return_pressed)


func _set_button_shortcuts() -> void: # TBD create helper in Common util
	var shortcut: Shortcut = Shortcut.new()
	var event: InputEventAction = InputEventAction.new()
	event.action = "ui_cancel"
	shortcut.events.append(event)
	ui_return_button.shortcut = shortcut


func _ui_ready() -> void:
	populate_countries()


func populate_countries() -> void: # pull directly from blueprint as nothing is registered yet
	var blueprint: Blueprint = System.manage.content.get_blueprint()
	var countries: PackedStringArray = blueprint.country.datastore.keys()
	for country_id: StringName in countries:
		ui_country_list.add_item(country_id)
	Debug.log_verbose("Populated %d countries from blueprint" % countries.size())


func start_session(p_profile_name: StringName, p_country_id: StringName) -> void:
	Debug.log_info("Starting new session...")
	var player: Character = App.context.character.create_player(p_profile_name, p_country_id, Rank.Level.COMMONER)
	var new_game: bool = true
	System.manage.session.start_session(player, new_game)


func _on_start_pressed() -> void:
	Debug.log_info("New game selected")
	ui_start_button.disabled = true
	if ui_profile_name.text.is_empty():
		Debug.log_warning("A name is required.")
		ui_start_button.disabled = false
		return
	var profile_name: String = str(ui_profile_name.text)
	var country_id: StringName = ui_country_list.get_item_text(ui_country_list.selected)
	Debug.log_debug("User entered: %s, %s" % [profile_name, country_id])
	start_session(profile_name, country_id)


func _on_return_pressed() -> void:
	submenu_closed.emit()
