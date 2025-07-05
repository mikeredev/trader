class_name Service extends RefCounted

enum ServiceType {
	CHARACTER_MANAGER,
	CITY_MANAGER,
	CONFIG_MANAGER,
	COUNTRY_MANAGER,
	DIALOG_MANAGER,
	WORLD_MANAGER,
	MOD_MANAGER,
	SCENE_MANAGER,
	SESSION_MANAGER,
	TRADE_MANAGER,
}


static func connect_signals() -> void:
	EventBus.game_reset.connect(_on_game_reset) # tbd, for soft reset refs

static var character_manager: CharacterManager:
	get(): return System.get_service(ServiceType.CHARACTER_MANAGER)

static var city_manager: CityManager:
	get(): return System.get_service(ServiceType.CITY_MANAGER)

static var config_manager: ConfigManager:
	get(): return System.get_service(ServiceType.CONFIG_MANAGER)

static var country_manager: CountryManager:
	get(): return System.get_service(ServiceType.COUNTRY_MANAGER)

static var dialog_manager: DialogManager:
	get(): return System.get_service(ServiceType.DIALOG_MANAGER)

static var mod_manager: ModManager:
	get(): return System.get_service(ServiceType.MOD_MANAGER)

static var scene_manager: SceneManager:
	get(): return System.get_service(ServiceType.SCENE_MANAGER)

static var session_manager: SessionManager:
	get(): return System.get_service(ServiceType.SESSION_MANAGER)

static var trade_manager: TradeManager:
	get(): return System.get_service(ServiceType.TRADE_MANAGER)

static var world_manager: WorldManager:
	get(): return System.get_service(ServiceType.WORLD_MANAGER)


static func _on_game_reset() -> void:
	Debug.log_warning("TBD: not implemented / reset all service mgr refs here")
