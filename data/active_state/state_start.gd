class_name StartState extends ActiveState

var save_data: Dictionary
var save_is_dirty: bool


func _init(p_save_data: Dictionary = {}, p_save_is_dirty: bool = false) -> void:
	name = "START"
	save_data = p_save_data
	save_is_dirty = p_save_is_dirty


func _main() -> void:
	#if save_data: # automatically proceed to restore session from save data
		#Service.session_manager.restore_session(save_data)
	#else:
	#Service.scene_manager.hide_views()
	#Service.scene_manager.add_menu(Filepath.START_MENU)

	Service.scene_manager.create_scene("uid://cc0wsa572eev2", UI.ContainerType.MENU)

	#Service.scene_manager.clear_ui(UI.ContainerType.MENU)




func _start_services() -> void:
	# pass the is_dirty flag when restoring from save
	AppContext.start_service(SessionManager.new(), Service.Type.SESSION_MANAGER)


func _exit() -> void:
	Service.scene_manager.clear_ui(UI.ContainerType.MENU)
