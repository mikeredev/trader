class_name CityManager extends Service

var datastore: Dictionary[StringName, City] = {}


func get_city(p_city_id: StringName) -> City:
	return datastore.get(p_city_id, null)


func get_cities() -> Array[City]:
	return datastore.values()


#func get_general_price_index(p_city: City) -> int:
	#var market: Market = p_city.get_market()
	#var price_index: Dictionary[StringName, int] = market.price_index
	#var total: int = 0
	#var size: int = price_index.size()
	#for value: int in price_index.values():
		#total += value
	#return int(total / float(size))


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
		var share: float = (support[country_id] / total) * 100.0
		normalized[country_id] = snappedf(share, 0.1)
	return normalized


func register_city(p_city: City) -> void:
	if datastore.has(p_city.city_id):
		Debug.log_warning("Overwriting existing city: %s" % p_city.city_id)
	datastore[p_city.city_id] = p_city


func to_dict() -> Dictionary[String, Variant]:
	var dict: Dictionary[String, Variant] = {}
	for city_id: StringName in datastore.keys():
		dict[city_id] = {
			"production": {
				"economy": datastore[city_id]["economy"],
				"industry": datastore[city_id]["industry"]
			},
			"support": {},
		}
	return dict
