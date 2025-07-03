class_name CityManager extends Service

var datastore: Dictionary[StringName, City]


func create_city(p_city_id: StringName, p_metadata: Dictionary) -> void:
	var city: City = City.new()
	city.city_id = p_city_id
	city.uid = city.city_id.hash()

	# position
	var map: WorldMap = Service.world_manager.get_map()
	var map_size: Vector2i = map.texture.get_size()
	var pos: Vector2i = p_metadata.get("position")
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

	# trade

	# body

	datastore[city.city_id] = city
	#printt(p_city_id, p_metadata)
	Debug.log_verbose("  Created city: %s" % [city.city_id])



func get_city(p_city_id: StringName) -> City:
	return datastore.get(p_city_id, null)
