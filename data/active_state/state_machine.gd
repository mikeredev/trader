class_name StateMachine extends RefCounted

var _active_state: ActiveState


func change(p_new: ActiveState) -> void:
	if _active_state:
		_active_state._exit()
		EventBus.state_exited.emit(_active_state)
		Debug.log_verbose("Exited state: %s" % _active_state.state_id)
		_active_state = null

	_active_state = p_new
	EventBus.state_entered.emit(_active_state) # updates Debug logger (do before printing)
	Debug.log_verbose("Entered state: %s" % _active_state.state_id)
	_active_state._connect_signals()
	_active_state._start_services()
	_active_state._main()
