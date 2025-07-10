class_name SystemServiceLocator extends RefCounted

var config: ConfigManager
var dialog: DialogManager
var content: ModManager
var scene: SceneManager
var session: SessionManager


func start_service(p_service: Service, p_type: Service.Type) -> void:
	match p_type:
		Service.Type.CONFIG_MANAGER: config = p_service
		Service.Type.DIALOG_MANAGER: dialog = p_service
		Service.Type.MOD_MANAGER: content = p_service
		Service.Type.SCENE_MANAGER: scene = p_service
		Service.Type.SESSION_MANAGER: session = p_service
	Debug.log_debug("Started service: %s" % str(Service.Type.keys()[p_type]))
