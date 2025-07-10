extends Node ## Global access point to system-level utilities, services, and core loop.

var service: ServiceLocator = ServiceLocator.new()
var state: StateMachine = StateMachine.new()
var _cache: Node2D # ensure wiped on reset NOTE


func _ready() -> void:
	var tick: int = Time.get_ticks_msec()
	if tick > 1000:
		Debug.log_warning("Slow startup time: %d" % tick)


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
	if await System.service.scene_manager.get_confirmation("QUIT TO DESKTOP?"):
		Debug.log_info("Goodbye.")
		System.get_tree().quit()
