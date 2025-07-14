extends UISubMenu

var profile_root: String = FileLocation.USER_ROOT_SAVE_DIR
var autosave_slots: Array[PanelContainer]

@onready var ui_profile_list: OptionButton = %ProfileList
@onready var ui_show_autosaves: CheckButton = %ShowAutosaves
@onready var ui_delete_profile: Button = %DeleteProfile
@onready var ui_save_list: VBoxContainer = %SaveList


func _connect_signals() -> void:
	ui_profile_list.item_selected.connect(_on_profile_selected)
	ui_show_autosaves.toggled.connect(_on_show_autosaves_toggled)
	ui_delete_profile.pressed.connect(_on_delete_profile_pressed)


func _set_button_shortcuts() -> void:
	pass


func _ui_ready() -> void:
	get_profiles()


func get_profiles() -> void:
	Debug.log_info("Searching for saved profiles...")

	# check for saved profiles in USER_ROOT_SAVE_DIR
	var profile_list: PackedStringArray = DirAccess.get_directories_at(profile_root)
	if profile_list.is_empty():
		Debug.log_debug("No profiles found")
		ui_profile_list.add_item("{NO_PROFILES_FOUND}")
		ui_profile_list.set_item_disabled(0, true)
		return

	# append each saved profile to list
	ui_profile_list.add_separator("{SELECT_A_PROFILE}")
	for i: int in range(profile_list.size()):
		var profile_directory: String = "%s/%s" % [profile_root, profile_list[i]]

		# construct path to its session.json
		var path: String = "%s/%s.%s" % [
			profile_directory,
			SessionManager.STORAGE.get("SESSION_FILENAME"),
			SessionManager.STORAGE.get("SAVE_FORMAT") ]

		# add it to list
		Debug.log_debug("Found profile: %s" % profile_list[i])
		var session_data: Dictionary = Common.Util.json.get_dict(path)
		var profile_name: String = session_data.get("profile_name", profile_list[i]) # failback to profile_id
		var country_id: String = session_data.get("country_id", "?")
		var rank: int = session_data.get("rank", -1)
		var format: String = "%s %s %d" % [profile_name, country_id, rank]
		ui_profile_list.add_item(format)
		ui_profile_list.set_item_metadata(i, profile_directory)

	ui_profile_list.select(0) # done


func get_save_list(p_profile_directory: String) -> void:
	Debug.log_debug("Selected profile: %s" % p_profile_directory)

	var save_directory: String = "%s/%s" % [p_profile_directory, SessionManager.STORAGE.get("SAVE_DIRECTORY")]
	var autosave_directory: String = "%s/%s" % [p_profile_directory, SessionManager.STORAGE.get("AUTOSAVE_DIRECTORY")]

	var saves: PackedStringArray = System.manage.session.get_save_list(save_directory)
	var autosaves: PackedStringArray = System.manage.session.get_save_list(autosave_directory)

	saves.append_array(autosaves)
	var sorted: PackedStringArray = Common.Util.file.sort_by_modified(saves)

	if sorted.is_empty():
		Debug.log_debug("No saves found: %s" % save_directory)
		return

	sorted.reverse() # display newest first
	for save_file: String in sorted:
		var strip_ext: String = save_file.get_basename()
		var split: PackedStringArray = strip_ext.split("/")
		var timestamp: int = split[split.size() - 1].to_int()
		var metadata_file: String = "%s/%s/%d.%s" % [
			p_profile_directory,
			SessionManager.STORAGE.get("METADATA_DIRECTORY"),
			timestamp,
			SessionManager.STORAGE.get("SAVE_FORMAT"),
		]
		var metadata: Dictionary = Common.Util.json.get_dict(metadata_file)
		create_slot(save_file, metadata)


func create_slot(p_path: String, p_metadata: Dictionary) -> void:
	var slot: SaveSlot = FileLocation.UI_SAVE_SLOT.instantiate()
	ui_save_list.add_child(slot)
	slot.gui_input.connect(_on_slot_selected.bind(p_path, p_metadata))
	var player_name: String = p_metadata.get("profile_name", "?")
	var rank: int = p_metadata.get("rank", -1)
	var country_id: String = p_metadata.get("country_id", "?")
	var balance: int = 999
	var timestamp: int = p_metadata.get("timestamp", -1)

	if p_metadata.get("autosave") == true:
		autosave_slots.append(slot)
		slot.visible = ui_show_autosaves.button_pressed

		#var is_autosave: Label = Label.new()
		#is_autosave.text = "Autosave"
		#hbox.add_child(is_autosave)

	slot.configure(player_name, rank, country_id, balance, timestamp)


func _on_profile_selected(p_index: int) -> void:
	var profile_directory: String = ui_profile_list.get_item_metadata(p_index - 1) # separator in slot 0
	get_save_list(profile_directory)


func _on_slot_selected(p_event: InputEvent, p_path: String, p_metadata: Dictionary) -> void:
	if p_event is InputEventMouseButton:
		var event: InputEventMouseButton = p_event
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			Debug.log_debug("Selected slot: %s" % p_path)
			System.manage.session.load_save(p_path, p_metadata["mods"])


func _on_show_autosaves_toggled(p_toggled_on: bool) -> void:
	for slot: PanelContainer in autosave_slots:
		slot.visible = p_toggled_on


func _on_delete_profile_pressed() -> void:
	var selected: int = ui_profile_list.selected - 1 # separator in slot 0
	var profile_name: String = ui_profile_list.get_item_text(selected + 1)
	var profile_directory: String = ui_profile_list.get_item_metadata(selected)

	var confirm: bool = await System.manage.scene.get_confirmation("Delete profile '%s'?" % profile_name)
	#if confirm:
		#if Common.Util.delete_directory(profile_directory):
			#clear_save_list()
			#ui_profile_list.clear()
			#ui_delete_profile.disabled = true
			#populate_profiles()
