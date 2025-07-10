class_name StartState extends ActiveState


func _init() -> void:
	state_id = "Start"


func _start_services() -> void:
	# pass the is_dirty flag when restoring from save
	System.service.start_service(SessionManager.new(), Service.Type.SESSION_MANAGER)
	System.service.start_service(CharacterManager.new(), Service.Type.CHARACTER_MANAGER)


func _main() -> void:
	#if save_data: # automatically proceed to restore session from save data
		#System.service.session_manager.restore_session(save_data)
	#else:
	#System.service.scene_manager.hide_views()
	#System.service.scene_manager.add_menu(Filepath.START_MENU)

	#System.service.scene_manager.add_to_ui(FileLocation.UI_NEW_GAME_MENU, UI.ContainerType.MENU)
	var start_menu: StartMenu = System.service.scene_manager.create_scene(FileLocation.UI_START_MENU)
	System.service.scene_manager.ui.menu.add_scene(start_menu)


func _exit() -> void:
	System.service.scene_manager.ui.menu.clear()
