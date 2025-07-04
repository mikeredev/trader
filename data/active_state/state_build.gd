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
	create_world()

	Debug.log_info("Creating markets...")
	create_markets()

	Debug.log_info("Creating cities...")
	create_cities()

	Debug.log_info("Creating countries...")
	create_countries()

	Debug.log_info("Creating ships...")
	create_ships()

	Debug.log_info("Creating items...")
	create_inventory_items()

	Service.state_manager.change_state(ReadyState.new(is_new_game))


func _start_services() -> void:
	Debug.log_info("Starting services...")
	AppContext.start_service(WorldManager.new(), Service.Type.WORLD_MANAGER)
	AppContext.start_service(CountryManager.new(), Service.Type.COUNTRY_MANAGER)
	AppContext.start_service(CityManager.new(), Service.Type.CITY_MANAGER)
	AppContext.start_service(TradeManager.new(), Service.Type.TRADE_MANAGER)


func create_player() -> void: # player object has already been created, so just register it
	# TBD create and cache body
	#Service.character_manager.register_character(blueprint.player)
	Debug.log_debug("TBD - Creat player here: %s" % blueprint.player.profile.profile_name)


func create_world() -> void:
	Service.world_manager.create_world(blueprint.world)


func create_countries() -> void:
	var countries: CountryBlueprint = blueprint.country
	for country_id: StringName in countries.datastore.keys():
		Service.country_manager.create_country(country_id, countries.datastore[country_id])
	Debug.log_debug("Created %d countries" % Service.country_manager.datastore.size())


func create_cities() -> void:
	var cities: CityBlueprint = blueprint.city
	for city_id: StringName in cities.datastore.keys():
		Service.city_manager.create_city(city_id, cities.datastore[city_id])
	Debug.log_debug("Created %d cities" % Service.city_manager.datastore.size())


func create_markets() -> void:
	var trade: TradeBlueprint = blueprint.trade
	for resource_id: StringName in trade.datastore.keys():
		Service.trade_manager.create_resource(resource_id, trade.datastore[resource_id])
	Debug.log_debug("Created: %d categories, %d markets, %d resources" % [
		Service.trade_manager._category_datastore.size(),
		Service.trade_manager._market_datastore.size(),
		Service.trade_manager._resource_datastore.size() ])


func create_ships() -> void:
	pass


func create_inventory_items() -> void:
	pass
