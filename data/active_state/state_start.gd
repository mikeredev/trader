class_name StartState extends ActiveState


func _init() -> void:
	name = "Start"


func _main() -> void:
	#if save_data: # automatically proceed to restore session from save data
		#Service.session_manager.restore_session(save_data)
	#else:
	#Service.scene_manager.hide_views()
	#Service.scene_manager.add_menu(Filepath.START_MENU)

	Service.scene_manager.create_scene(FileLocation.UI_START_MENU, UI.ContainerType.MENU)
	#Service.scene_manager.create_scene(FileLocation.UI_NEW_GAME_MENU, UI.ContainerType.MENU)


func _start_services() -> void:
	Debug.log_info("Starting services...")
	# pass the is_dirty flag when restoring from save
	AppContext.start_service(SessionManager.new(), Service.Type.SESSION_MANAGER)
	AppContext.start_service(CharacterManager.new(), Service.Type.CHARACTER_MANAGER)


func _exit() -> void:
	Service.scene_manager.clear_ui(UI.ContainerType.MENU)
