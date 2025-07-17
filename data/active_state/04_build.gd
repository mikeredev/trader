class_name BuildState extends ActiveState

var blueprint: Blueprint = System.manage.content.get_blueprint()
var is_new_game: bool


func _init(p_is_new_game: bool = false) -> void:
	state_id = "Build"
	is_new_game = p_is_new_game


func _start_services() -> void:
	App.context.start_service(WorldManager.new(), Service.Type.WORLD_MANAGER)
	App.context.start_service(CountryManager.new(), Service.Type.COUNTRY_MANAGER)
	App.context.start_service(CityManager.new(), Service.Type.CITY_MANAGER)
	App.context.start_service(TradeManager.new(), Service.Type.TRADE_MANAGER)


func _main() -> void:
	Debug.log_info("Creating utilities...")
	create_engine_tools()

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

	System.state.change(ReadyState.new(is_new_game))


func create_player() -> void:
	var profile_id: StringName = blueprint.player.profile.profile_id
	var player: Character = App.context.character.get_character(profile_id)
	var body: PlayerBody = App.context.character.create_body(player)
	player.body = body
	App.context.character.cache_body(player.body) # cache until ready for use


func create_engine_tools() -> void:
	App.create_cache() # body cache


func create_ships() -> void:
	Debug.log_info("Creating ships (TBD)...")


func create_inventory_items() -> void:
	Debug.log_info("Creating items (TBD)...")
