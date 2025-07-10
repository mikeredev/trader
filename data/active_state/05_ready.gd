class_name ReadyState extends ActiveState

var is_new_game: bool


func _init(p_is_new_game: bool = false) -> void:
	state_id = "Ready"
	is_new_game = p_is_new_game


func _start_services() -> void:
	pass#System.manage.start_service(DialogManager.new(), Service.Type.DIALOG_MANAGER)


func _main() -> void:
	# start game
	if is_new_game: start()
	else: resume()

	# broadcast game start
	EventBus.game_started.emit()


func start() -> void:
	Debug.log_info("New game: %s" % is_new_game)
	var player: Character = App.context.character.get_player()
	var capital: City = App.context.country.get_capital(player.profile.country_id)
	Debug.log_debug("Starting in: %s, %s" % [capital.city_id, player.profile.profile_name])
	System.state.change(InCityState.new(capital.city_id))


func resume() -> void:
	pass
