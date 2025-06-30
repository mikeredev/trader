extends Node

var _services: Dictionary[StringName, Service]


func get_service(p_type: Service.Type) -> Service:
	var _name: StringName = _get_name(p_type)
	return _services.get(_name, null)


func start_service(p_service: Service, p_type: Service.Type) -> void:
	var _name: StringName = _get_name(p_type)
	_services[_name] = p_service
	Debug.log_debug("Started service: %s" % _name)


func _get_name(p_type: Service.Type) -> StringName:
	return str(Service.Type.keys()[p_type]).to_pascal_case()
