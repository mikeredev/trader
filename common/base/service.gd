class_name Service extends RefCounted

enum Type {
	CONFIG_MANAGER,
	DIALOG_MANAGER,
	MOD_MANAGER,
	SCENE_MANAGER,
	SESSION_MANAGER,
	STATE_MANAGER,
}

var name: StringName


static func setup() -> void:
	EventBus.game_reset.connect(_on_game_reset) # tbd, for soft reset refs

static var config_manager: ConfigManager:
	get(): return AppContext.get_service(Service.Type.CONFIG_MANAGER)

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


static func _on_game_reset() -> void:
	Debug.log_warning("TBD: not implemented / reset all refs here")
