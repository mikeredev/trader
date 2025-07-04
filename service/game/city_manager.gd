class_name CityManager extends Service

var datastore: Dictionary[StringName, City] = {}


func create_city(p_city_id: StringName, p_metadata: Dictionary) -> void:
	var city: City = City.new()
	city.city_id = p_city_id
	city.uid = city.city_id.hash()

	# position
	var map: WorldMap = Service.world_manager.get_map()
	var map_size: Vector2i = map.texture.get_size()
	var pos: Vector2i = p_metadata["position"]
	var pos_x: int = clampi(pos.x, 0, map_size.x)
	var pos_y: int = clampi(pos.y, 0, map_size.y)
	city.position = Vector2i(pos_x, pos_y)

	# buildings

	# production
	var economy: int = p_metadata.get("production")["economy"]
	var industry: int = p_metadata.get("production")["industry"]
	var ceiling: int = ProjectSettings.get_setting("services/city/max_production")
	city.economy = clampi(economy, 0, ceiling)
	city.industry = clampi(industry, 0, ceiling)

	# support
	var raw: Dictionary = p_metadata.get("support", {})
	var support: Dictionary[StringName, float] = {}
	for country_id: StringName in raw.keys():
		var value: float = raw[country_id]
		support[country_id] = snappedf(value, 0.1)
	city.support = support

	# trade
	var market_id: StringName = p_metadata["trade"]["market"]
	city.market_id = market_id # already validated

	# verify specialty has not been removed by mods
	var specialty_id: StringName = p_metadata["trade"]["specialty"]["resource"]
	if Service.trade_manager.get_resource(specialty_id):
		var price: int = p_metadata["trade"]["specialty"]["price"]
		var required: int = p_metadata["trade"]["specialty"]["required"]
		var specialty: Dictionary[String, Variant] = {
			"resource_id": specialty_id,
			"price": price,
			"required": required }
		city.trade_specialty = specialty
	else:
		Debug.log_warning("Unable to add specialty: %s (%s)" % [specialty_id, city.city_id])

	# body

	datastore[city.city_id] = city
	Debug.log_verbose("  Created city: %s |  %s | 󱌢 %s |   %s" % [city.city_id, city.position, Vector2i(city.economy, city.industry), Service.city_manager.get_support_normalized(city)])



func get_city(p_city_id: StringName) -> City:
	return datastore.get(p_city_id, null)


func get_support_normalized(p_city: City) -> Dictionary[StringName, float]:
	var support: Dictionary[StringName, float] = p_city.support.duplicate()
	var total: float = 0.0
	for value: float in support.values():
		total += value

	# return as-is if total is <= 100
	if total < 100.0 or is_equal_approx(total, 100.0):
		return support

	# otherwise normalize
	var normalized: Dictionary[StringName, float] = {}
	for country_id: StringName in support.keys():
		var share = (support[country_id] / total) * 100.0
		normalized[country_id] = snappedf(share, 0.1)
	return normalized
