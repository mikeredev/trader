class_name StartState extends ActiveState


func _init() -> void:
	state_id = "Start"


func _start_services() -> void:
	# pass the is_dirty flag when restoring from save
	System.start_service(SessionManager.new(), Service.ServiceType.SESSION_MANAGER)
	System.start_service(CharacterManager.new(), Service.ServiceType.CHARACTER_MANAGER)


func _main() -> void:
	#if save_data: # automatically proceed to restore session from save data
		#Service.session_manager.restore_session(save_data)
	#else:
	#Service.scene_manager.hide_views()
	#Service.scene_manager.add_menu(Filepath.START_MENU)

	Service.scene_manager.add_to_ui(FileLocation.UI_START_MENU, UI.ContainerType.MENU)
	#Service.scene_manager.add_to_ui(FileLocation.UI_NEW_GAME_MENU, UI.ContainerType.MENU)
	Service.scene_manager.create_notification("hello test here")
	#Service.scene_manager.create_notification("hello test here! this is another addition")
	#Service.scene_manager.create_notification("hello test here! this is another addition again. does it break onto a new line? i hope so. let's find out. anyway so how are you. wow that's amazing. 5 years, huh?")


func _exit() -> void:
	var ui: UI = Service.scene_manager.get_ui()
	ui.clear_container(UI.ContainerType.MENU)
