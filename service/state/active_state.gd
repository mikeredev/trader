class_name ActiveState extends RefCounted

var name: StringName
var start_tick: int = Time.get_ticks_msec()


func _main() -> void: pass

func _connect_signals() -> void: pass

func _start_services() -> void: pass

func _exit() -> void:
	Debug.log_debug("Run time: %dms" % get_duration())

func get_duration() -> int:
	return Time.get_ticks_msec() - start_tick
