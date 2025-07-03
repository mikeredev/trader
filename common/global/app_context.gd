extends Node

var _services: Dictionary[StringName, Service]

func _ready() -> void:
	var list: PackedStringArray = Service.Type.keys()
	list.sort() # pre-populate alphabetically
	for _name: StringName in list:
		_services[_name.to_pascal_case()] = null


func get_service(p_type: Service.Type) -> Service:
	var _name: StringName = _get_name(p_type)
	return _services.get(_name, null)


func start_service(p_service: Service, p_type: Service.Type) -> void:
	var _name: StringName = _get_name(p_type)
	if _services.get(_name): # and not quickload
		Debug.log_warning("Restarting service: %s" % _name)
	_services[_name] = p_service
	Debug.log_debug("Started service: %s" % _name)


func _get_name(p_type: Service.Type) -> StringName:
	return str(Service.Type.keys()[p_type]).to_pascal_case()
