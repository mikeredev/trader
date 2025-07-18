extends Node ## Global access point to system-level utilities, services, and core loop.

var manage: SystemServiceLocator = SystemServiceLocator.new()
var state: StateMachine = StateMachine.new()


func _ready() -> void:
	var tick: int = Time.get_ticks_msec()
	if tick > 1000:
		Debug.log_warning("Slow startup time: %d" % tick)


func pause_game(p_paused: bool) -> void:
	Debug.log_info("Game paused: %s" % p_paused)
	System.get_tree().paused = p_paused


func soft_reset() -> void:
	Debug.log_info("Returning to Start...")
	System.state.change(StartState.new())


func quit_game() -> void:
	Debug.log_info("Quitting game...")
	if await System.manage.scene.get_confirmation("QUIT TO DESKTOP?"):
		Debug.log_info("Goodbye.")
		System.get_tree().quit()
