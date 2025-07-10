class_name ServiceLocator extends RefCounted

var character_manager: CharacterManager
var city_manager: CityManager
var config_manager: ConfigManager
var country_manager: CountryManager
var dialog_manager: DialogManager
var mod_manager: ModManager
var scene_manager: SceneManager
var session_manager: SessionManager
var trade_manager: TradeManager
var world_manager: WorldManager


func start_service(p_service: Service, p_type: Service.Type) -> void:
	match p_type:
		Service.Type.CHARACTER_MANAGER: character_manager = p_service
		Service.Type.CITY_MANAGER: city_manager = p_service
		Service.Type.CONFIG_MANAGER: config_manager = p_service
		Service.Type.COUNTRY_MANAGER: country_manager = p_service
		Service.Type.DIALOG_MANAGER: dialog_manager = p_service
		Service.Type.MOD_MANAGER: mod_manager = p_service
		Service.Type.SCENE_MANAGER: scene_manager = p_service
		Service.Type.SESSION_MANAGER: session_manager = p_service
		Service.Type.TRADE_MANAGER: trade_manager = p_service
		Service.Type.WORLD_MANAGER: world_manager = p_service
	Debug.log_debug("Started service: %s" % str(Service.Type.keys()[p_type]))
