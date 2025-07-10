class_name AppServiceLocator extends RefCounted

var character: CharacterManager
var city: CityManager
var country: CountryManager
var trade: TradeManager
var world: WorldManager


func start_service(p_service: Service, p_type: Service.Type) -> void:
	match p_type:
		Service.Type.CHARACTER_MANAGER: character = p_service
		Service.Type.CITY_MANAGER: city = p_service
		Service.Type.COUNTRY_MANAGER: country = p_service
		Service.Type.TRADE_MANAGER: trade = p_service
		Service.Type.WORLD_MANAGER: world = p_service
	Debug.log_debug("Started service: %s" % str(Service.Type.keys()[p_type]))
