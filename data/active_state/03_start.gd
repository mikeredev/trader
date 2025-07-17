class_name StartState extends ActiveState


func _init() -> void:
	state_id = "Start"


func _start_services() -> void:
	# pass the is_dirty flag when restoring from save
	System.manage.start_service(SessionManager.new(), Service.Type.SESSION_MANAGER)
	App.context.start_service(CharacterManager.new(), Service.Type.CHARACTER_MANAGER)


func _main() -> void:
	#if save_data: # automatically proceed to restore session from save data
		#System.manage.session.restore_session(save_data)
	#else:
	#System.manage.scene.hide_views()
	#System.manage.scene.add_menu(Filepath.START_MENU)

	#System.manage.scene.add_to_ui(FileLocation.UI_NEW_GAME_MENU, UI.ContainerType.MENU)

	#if save_path: # reloading save
		#Debug.log_info("Loading saved session...")
		#return

	Debug.log_info("Showing Start Menu...")
	var start_menu: StartMenu = System.manage.scene.create_scene(FileLocation.UI_START_MENU)
	System.manage.scene.ui.menu.add_scene(start_menu)


func _exit() -> void:
	System.manage.scene.ui.menu.clear()
