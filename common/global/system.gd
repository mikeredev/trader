extends Node

var _services: Dictionary[StringName, Service]


func _ready() -> void:
	 # pre-populate keys alphabetically for convenience
	var services: PackedStringArray = Service.Type.keys()
	services.sort()
	for service_id: StringName in services:
		_services[service_id.to_pascal_case()] = null


func get_service(p_type: Service.Type) -> Service:
	var display_name: StringName = _get_name(p_type)
	return _services.get(display_name, null)


func start_service(p_service: Service, p_type: Service.Type) -> void:
	var display_name: StringName = _get_name(p_type)

	# log if service is already running / TBD quickload considerations
	if _services.get(display_name):
		Debug.log_warning("Restarting service: %s" % display_name)

	# add to existing slot (created in _ready())
	_services[display_name] = p_service
	Debug.log_debug("Started service: %s" % display_name)


func pause(p_paused: bool) -> void:
	Debug.log_debug("Paused: %s" % p_paused)
	System.get_tree().paused = p_paused


func quit() -> void:
	Debug.log_info("Goodbye.")
	System.get_tree().quit()


func _get_name(p_type: Service.Type) -> StringName:
	return str(Service.Type.keys()[p_type]).to_pascal_case()
