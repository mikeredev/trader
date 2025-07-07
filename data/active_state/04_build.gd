class_name BuildState extends ActiveState

var blueprint: Blueprint = Service.mod_manager.get_blueprint()
var is_new_game: bool


func _init(p_is_new_game: bool = false) -> void:
	state_id = "Build"
	is_new_game = p_is_new_game


func _start_services() -> void:
	System.start_service(WorldManager.new(), Service.ServiceType.WORLD_MANAGER)
	System.start_service(CountryManager.new(), Service.ServiceType.COUNTRY_MANAGER)
	System.start_service(CityManager.new(), Service.ServiceType.CITY_MANAGER)
	System.start_service(TradeManager.new(), Service.ServiceType.TRADE_MANAGER)


func _main() -> void:
	Debug.log_info("Creating utilities...")
	create_utils()

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

	System.change_state(ReadyState.new(is_new_game))


func create_player() -> void:
	var profile_id: StringName = blueprint.player.profile.profile_id
	var player: Character = Service.character_manager.get_character(profile_id)
	var body: PlayerBody = Service.character_manager.create_body(player)
	player.body = body
	Service.character_manager.cache_body(player.body) # cache until ready for use


func create_utils() -> void:
	System.create_cache() # body cache


func create_ships() -> void:
	Debug.log_info("Creating ships (TBD)...")


func create_inventory_items() -> void:
	Debug.log_info("Creating items (TBD)...")
