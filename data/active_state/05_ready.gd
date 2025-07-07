class_name ReadyState extends ActiveState

var is_new_game: bool


func _init(p_is_new_game: bool = false) -> void:
	state_id = "Ready"
	is_new_game = p_is_new_game


func _start_services() -> void:
	pass#System.start_service(DialogManager.new(), Service.ServiceType.DIALOG_MANAGER)


func _main() -> void:
	Debug.log_info("Creating UI...")
	Service.scene_manager.add_to_ui(FileLocation.UI_DEV_UI, UI.ContainerType.DEV_UI)

	# start game
	if is_new_game: start()
	else: resume()


func start() -> void:
	Debug.log_info("New game: %s" % is_new_game)
	var player: Character = Service.character_manager.get_player()
	var capital: City = Service.country_manager.get_capital(player.profile.country_id)
	Debug.log_debug("Starting in: %s, %s" % [capital.city_id, player.profile.profile_name])
	System.change_state(InCityState.new(capital.city_id))


func resume() -> void:
	pass
