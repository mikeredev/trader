class_name SessionManager extends Service

const STORAGE: Dictionary[String, String] = {
	"SAVE_DIRECTORY": "save",
	"METADATA_DIRECTORY": "metadata",
	"AUTOSAVE_DIRECTORY": "autosave",
	"SESSION_FILENAME": "session",
	"SAVE_FORMAT": "json",
}

var user_save_root: String = FileLocation.USER_ROOT_SAVE_DIR
var profile_directory: String
var save_directory: String
var autosave_directory: String
var metadata_directory: String
var max_autosaves: int = System.manage.config.general_settings.max_autosaves


func get_save_list(p_folder: String) -> PackedStringArray:
	Debug.log_verbose("Retrieving files from: %s" % p_folder)
	var all_files: PackedStringArray = DirAccess.get_files_at(p_folder)
	var snapshot_files: PackedStringArray
	for file: String in all_files:
		if file.ends_with(str(STORAGE["SAVE_FORMAT"])):
			snapshot_files.append("%s/%s" % [p_folder, file])
	return Common.Util.file.sort_by_modified(snapshot_files) # returned ascending by oldest first


func start_session(p_player: Character, p_is_new_game: bool = false) -> void:
	Debug.log_debug("Entering session: %s" % p_player.profile.profile_name)

	# establish environmental paths
	profile_directory = "%s/%s" % [user_save_root, p_player.profile.profile_id]
	save_directory = "%s/%s" % [profile_directory, STORAGE["SAVE_DIRECTORY"]]
	autosave_directory = "%s/%s" % [profile_directory, STORAGE["AUTOSAVE_DIRECTORY"]]
	metadata_directory = "%s/%s" % [profile_directory, STORAGE["METADATA_DIRECTORY"]]

	# add player object to blueprint
	var blueprint: Blueprint = System.manage.content.get_blueprint()
	blueprint.player = p_player

	# advance to build state
	System.state.change(BuildState.new(p_is_new_game))


func save_session(p_autosave: bool = false) -> void:
	Debug.log_info("Saving session (autosave: %s)" % p_autosave)

	# validate profile directories inside USER_ROOT_SAVE_DIR
	if not _validate_user_dirs():
		Debug.log_error("Unable to access user profile directories (profile loaded?)")
		return

	var timestamp: int = ceili(Time.get_unix_time_from_system())
	var snapshot: Snapshot = Snapshot.new(timestamp)

	var directory: String = autosave_directory if p_autosave else save_directory
	var save_path: String = "%s/%d.%s" % [directory, timestamp, STORAGE["SAVE_FORMAT"]]

	# save snapshot
	Common.Util.json.save_dict(save_path, snapshot.to_dict())

	# save metadata
	var metadata_path: String = "%s/%d.%s" % [metadata_directory, timestamp, STORAGE["SAVE_FORMAT"]]
	var metadata: Dictionary[String, Variant] = _get_metadata(p_autosave, timestamp)
	Common.Util.json.save_dict(metadata_path, metadata)

	# save session data
	var session_path: String = "%s/%s.%s" % [profile_directory, STORAGE["SESSION_FILENAME"], STORAGE["SAVE_FORMAT"]]
	var session_data: Dictionary[String, Variant] = _get_session_data()
	Common.Util.json.save_dict(session_path, session_data)

	# prune autosaves
	if p_autosave: _prune_autosaves()

	# update user settings for quick continue
	System.manage.config.general_settings.set_last_save(save_path, metadata, true)
	Debug.log_debug("Snapshot complete")


func restore_session(p_path: String, p_metadata: Dictionary) -> void:
	Debug.log_info("Restoring session: %s" % p_path)
	var active_mods: Dictionary[StringName, ModManifest] = System.manage.content.get_active_mods(false)
	var saved_mods: PackedStringArray = p_metadata["mods"]["order"]
	var save_data: Dictionary = Common.Util.json.get_dict(p_path)
	if _validate(saved_mods, active_mods.keys()):
		Debug.log_info("Loading save '%s'..." % p_path)
		System.state.change(SetupState.new(saved_mods, save_data))
	else:
		if await System.manage.scene.get_confirmation("RELOAD_MODS?"):
			System.state.change(SetupState.new(saved_mods, save_data))


func _validate(p_saved_mods: PackedStringArray, p_active_mods: PackedStringArray) -> bool:
	# verify mod order
	Debug.log_debug("Saved mods: %s" % p_saved_mods)
	Debug.log_debug("Active mods: %s" % p_active_mods)
	if p_saved_mods == p_active_mods:
		return true
	return false


func _get_metadata(p_autosave: bool, p_timestamp: int) -> Dictionary[String, Variant]:
	return { # metadata is used to display game info in a load menu SaveSlot
		"autosave": p_autosave,
		#"balance": App.context.character.get_player().inventory.balance,
		"country_id": App.context.character.get_player().profile.country_id,
		"mods": System.manage.content.to_dict(false), # exclude core
		"profile_name": App.context.character.get_player().profile.profile_name,
		"rank": App.context.character.get_player().profile.rank.level,
		"timestamp": p_timestamp,
	}


func _get_session_data() -> Dictionary[String, Variant]:
	return { # session data (aka profile?) is used to display profile info in load menu profile list
		"country_id": App.context.character.get_player().profile.country_id,
		"profile_name": App.context.character.get_player().profile.profile_name,
		"rank": App.context.character.get_player().profile.rank.level,
	}


func _prune_autosaves() -> void:
	Debug.log_verbose("Pruning autosaves")
	var files: PackedStringArray = get_save_list(autosave_directory)

	files.reverse() # order by newest first
	var total: int = files.size()

	if total <= max_autosaves:
		Debug.log_verbose("Nothing to do (%d/%d autosaves found)" % [total, max_autosaves])
		return

	while total > max_autosaves:
		var path: String = files[total - 1] # take oldest from end
		if Common.Util.file.remove_file(path, STORAGE["SAVE_FORMAT"]):
			Debug.log_debug("Deleted snapshot: %s" % path)

			# check for metadata
			var split: PackedStringArray = path.split("/")
			var filename: String = split[split.size() - 1]
			var metadata: String = "%s/%s" % [metadata_directory, filename]
			if FileAccess.file_exists(metadata):
				if Common.Util.file.remove_file(metadata, STORAGE["SAVE_FORMAT"]):
					Debug.log_debug("Deleted metadata: %s" % metadata)
				else:
					Debug.log_warning("Unable to remove metadata")
		else:
			Debug.log_warning("Unable to remove snapshot")
		total -= 1


func _validate_user_dirs() -> bool:
	var dirs: PackedStringArray = [
		user_save_root, profile_directory,
		save_directory, autosave_directory, metadata_directory ]
	for dir: String in dirs:
		if not Common.Util.file.touch_directory(dir):
			return false
	Debug.log_verbose("Validated access: %s" % dirs)
	return true
