class_name BuildState extends ActiveState

var blueprint: Blueprint = Service.mod_manager.get_blueprint()
var is_new_game: bool


func _init(p_is_new_game: bool = false) -> void:
	name = "Build"
	is_new_game = p_is_new_game


func _main() -> void:
	Debug.log_info("Creating player...")
	create_player()

	Debug.log_info("Creating world...")
	blueprint.world.build()

	Debug.log_info("Creating markets...")
	blueprint.trade.build()

	Debug.log_info("Creating cities...")
	blueprint.city.build()

	Debug.log_info("Creating countries...")
	blueprint.country.build()

	create_ships()
	create_inventory_items()

	Service.state_manager.change_state(ReadyState.new(is_new_game))


func _start_services() -> void:
	Debug.log_info("Starting services...")
	AppContext.start_service(WorldManager.new(), Service.Type.WORLD_MANAGER)
	AppContext.start_service(CountryManager.new(), Service.Type.COUNTRY_MANAGER)
	AppContext.start_service(CityManager.new(), Service.Type.CITY_MANAGER)
	AppContext.start_service(TradeManager.new(), Service.Type.TRADE_MANAGER)


func create_player() -> void:
	var profile_id: StringName = blueprint.player.profile.profile_id
	var player: Character = Service.character_manager.get_character(profile_id)
	var body: PlayerBody = Service.character_manager.create_body(player)
	player.body = body
	Service.character_manager.cache(player.body) # cache until ready for use


func create_ships() -> void:
	Debug.log_info("Creating ships (TBD)...")


func create_inventory_items() -> void:
	Debug.log_info("Creating items (TBD)...")
