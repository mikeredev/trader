class_name StateManager extends Service

var active_state: ActiveState


func change_state(p_new: ActiveState) -> void:
	if active_state:
		active_state._exit()
		EventBus.state_exited.emit(active_state)
		Debug.log_verbose("Exited state: %s" % active_state.name)
		active_state = null

	active_state = p_new
	EventBus.state_entered.emit(p_new)
	Debug.log_verbose("Entered state: %s" % p_new.name)
	active_state._connect_signals()
	active_state._start_services()
	active_state._main()
