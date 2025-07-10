class_name SessionManager extends Service


func start_session(p_player: Character, p_is_new_game: bool = false) -> void:
	Debug.log_debug("Entering session: %s" % p_player.profile.profile_name)

	# add player object to blueprint
	var blueprint: Blueprint = System.manage.content.get_blueprint()
	blueprint.player = p_player

	# advance to build state
	System.state.change(BuildState.new(p_is_new_game))
