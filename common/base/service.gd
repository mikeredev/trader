class_name Service extends RefCounted

enum Type {
	CHARACTER_MANAGER,
	CITY_MANAGER,
	CONFIG_MANAGER,
	COUNTRY_MANAGER,
	DIALOG_MANAGER,
	MOD_MANAGER,
	SCENE_MANAGER,
	SESSION_MANAGER,
	STATE_MANAGER,
	TRADE_MANAGER,
	WORLD_MANAGER,
}

var name: StringName


static func setup() -> void:
	EventBus.game_reset.connect(_on_game_reset) # tbd, for soft reset refs

static var character_manager: CharacterManager:
	get(): return AppContext.get_service(Service.Type.CHARACTER_MANAGER)

static var city_manager: CityManager:
	get(): return AppContext.get_service(Service.Type.CITY_MANAGER)

static var config_manager: ConfigManager:
	get(): return AppContext.get_service(Service.Type.CONFIG_MANAGER)

static var country_manager: CountryManager:
	get(): return AppContext.get_service(Service.Type.COUNTRY_MANAGER)

static var dialog_manager: DialogManager:
	get(): return AppContext.get_service(Service.Type.DIALOG_MANAGER)

static var mod_manager: ModManager:
	get(): return AppContext.get_service(Service.Type.MOD_MANAGER)

static var scene_manager: SceneManager:
	get(): return AppContext.get_service(Service.Type.SCENE_MANAGER)

static var session_manager: SessionManager:
	get(): return AppContext.get_service(Service.Type.SESSION_MANAGER)

static var state_manager: StateManager:
	get(): return AppContext.get_service(Service.Type.STATE_MANAGER)

static var trade_manager: TradeManager:
	get(): return AppContext.get_service(Service.Type.TRADE_MANAGER)

static var world_manager: WorldManager:
	get(): return AppContext.get_service(Service.Type.WORLD_MANAGER)


static func _on_game_reset() -> void:
	Debug.log_warning("TBD: not implemented / reset all refs here")
