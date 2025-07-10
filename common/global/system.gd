extends Node ## Global access point to system-level utilities, services, and core loop.

var _active_state: ActiveState
#var datastore: Dictionary[StringName, Service]
var _cache: Node2D # ensure wiped on reset NOTE

var service: ServiceManager = ServiceManager.new()


func change_state(p_new: ActiveState) -> void:
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


func create_cache() -> void:
	_cache = Node2D.new()
	_cache.name = "Cache"
	_cache.visible = false
	_cache.process_mode = Node.PROCESS_MODE_DISABLED
	self.add_child(_cache)
	Debug.log_debug("Created node cache: %s" % _cache.get_path())


func get_cache() -> Node2D:
	return _cache


func pause_game(p_paused: bool) -> void:
	Debug.log_debug("Paused: %s" % p_paused)
	System.get_tree().paused = p_paused


func quit_game() -> void:
	if await Service.scene_manager.get_confirmation("QUIT TO DESKTOP?"):
		Debug.log_info("Goodbye.")
		System.get_tree().quit()
