class_name ServiceManager extends RefCounted

var datastore: Dictionary[StringName, Service]

var character_manager: CharacterManager:
	get(): return get_service(Service.ServiceType.CHARACTER_MANAGER)

var city_manager: CityManager:
	get(): return get_service(Service.ServiceType.CITY_MANAGER)

var config_manager: ConfigManager:
	get(): return get_service(Service.ServiceType.CONFIG_MANAGER)

var country_manager: CountryManager:
	get(): return get_service(Service.ServiceType.COUNTRY_MANAGER)

var dialog_manager: DialogManager:
	get(): return get_service(Service.ServiceType.DIALOG_MANAGER)

var mod_manager: ModManager:
	get(): return get_service(Service.ServiceType.MOD_MANAGER)

var scene_manager: SceneManager:
	get(): return get_service(Service.ServiceType.SCENE_MANAGER)

var session_manager: SessionManager:
	get(): return get_service(Service.ServiceType.SESSION_MANAGER)

var trade_manager: TradeManager:
	get(): return get_service(Service.ServiceType.TRADE_MANAGER)

var world_manager: WorldManager:
	get(): return get_service(Service.ServiceType.WORLD_MANAGER)


func _init() -> void: # pre-populate datastore alphabetically for debugging convenience
	for type: Service.ServiceType in Service.ServiceType.values():
		var service_id: StringName = _get_service_id(type)
		datastore[service_id] = null
	datastore.sort()


func get_service(p_type: Service.ServiceType) -> Service:
	var display_name: StringName = _get_service_id(p_type)
	return datastore.get(display_name, null)


func start_service(p_service: Service, p_type: Service.ServiceType) -> void:
	var display_name: StringName = _get_service_id(p_type)

	# log if service is already running / TBD quickload considerations
	if datastore.get(display_name):
		Debug.log_warning("Restarting service: %s" % display_name)

	# add to existing slot (created in _ready())
	datastore[display_name] = p_service
	Debug.log_debug("Started service: %s" % display_name)


func _get_service_id(p_type: Service.ServiceType) -> StringName:
	return str(Service.ServiceType.keys()[p_type]).to_pascal_case()
