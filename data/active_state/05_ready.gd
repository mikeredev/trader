class_name ReadyState extends ActiveState

var is_new_game: bool


func _init(p_is_new_game: bool = false) -> void:
	state_id = "ready"
	is_new_game = p_is_new_game


func _main() -> void:
	Debug.log_info("New game: %s" % is_new_game)
	if is_new_game: start()
	else: resume()


func _start_services() -> void:
	pass#System.start_service(DialogManager.new(), Service.ServiceType.DIALOG_MANAGER)


func start() -> void:
	var player: Character = Service.character_manager.get_player()
	var capital: City = Service.country_manager.get_capital(player.profile.country_id)
	Debug.log_debug("Starting in: %s, %s" % [capital.city_id, player.profile.profile_name])


func resume() -> void:
	pass
