class_name SessionManager extends Service


#func start_session(p_player: Player, p_state: BuildState.State, p_restore_state: Dictionary = {}) -> void:
	#var blueprint: Blueprint = Service.mod_manager.get_blueprint()
	#blueprint.player = p_player
#
	#profile_directory = "%s/%s" % [Common.Location.User.SAVE_FOLDER, p_player.profile.profile_id]
	#save_directory = "%s/%s" % [profile_directory, STORAGE.get("SAVE_DIRECTORY")]
	#autosave_directory = "%s/%s" % [profile_directory, STORAGE.get("AUTOSAVE_DIRECTORY")]
	#metadata_directory = "%s/%s" % [profile_directory, STORAGE.get("METADATA_DIRECTORY")]
#
	#var restore_state: Dictionary[String, Variant] = {}
	#for key: String in p_restore_state.keys():
		#restore_state[key] = p_restore_state[key]
#
	#Debug.log_debug("Entering session: %s" % p_player.profile.profile_id)
	#System.change_state(BuildState.new(p_state, restore_state))
