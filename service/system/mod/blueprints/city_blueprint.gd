class_name CityBlueprint extends RefCounted

var datastore: Dictionary[StringName, Dictionary]


static func from_dict(p_data: Dictionary[String, Dictionary]) -> CityBlueprint:
	var data: Dictionary[StringName, Dictionary] = {}

	for city_id: StringName in p_data.keys():
		var city_data: Dictionary = p_data[city_id]

		if city_data.get("remove", false):
			Debug.log_verbose("  Ignoring city marked for removal: %s" % [city_id])
			continue

		data[city_id] = {}
		for property: String in p_data[city_id].keys():
			match property:
				"position":
					var x: int = p_data[city_id]["position"][0]
					var y: int = p_data[city_id]["position"][1]
					var position: Vector2i = Vector2i(x, y)
					data[city_id]["position"] = position

				"buildings":
					var buildings: Array = p_data[city_id]["buildings"]
					data[city_id]["buildings"] = buildings

				"production":
					var economy: int = p_data[city_id]["production"]["economy"]
					var industry: int = p_data[city_id]["production"]["industry"]
					var production: Dictionary[String, int] = {
						"economy": economy,
						"industry": industry }
					data[city_id]["production"] = production

				"support":
					var support: Dictionary[StringName, float] = {}
					var _data: Dictionary = p_data[city_id]["support"]
					for country_id: StringName in _data.keys():
						var _value: float = _data[country_id]
						support[country_id] = snappedf(_value, 0.1)
					data[city_id]["support"] = support

				"trade":
					var market_id: StringName = p_data[city_id]["trade"]["market"]
					var specialty_id: StringName = p_data[city_id]["trade"]["specialty"]["resource"]
					var specialty_price: int = p_data[city_id]["trade"]["specialty"]["price"]
					var specialty_required: int = p_data[city_id]["trade"]["specialty"]["required"]
					var trade: Dictionary[String, Variant] = {
						"market": market_id,
						"specialty": {
							"resource": specialty_id,
							"price": specialty_price,
							"required": specialty_required,
						},
					}
					data[city_id]["trade"] = trade

				"owner":
					var owner: StringName = p_data[city_id]["owner"]
					data[city_id][property] = owner

				_: Debug.log_warning("Ignoring unrecognized key: %s" % property)

	var out: CityBlueprint = CityBlueprint.new()
	out.datastore = data
	return out


static func validate(p_data: Dictionary, p_cache: Dictionary) -> bool:
	for city_id: String in p_data.keys():
		var city_data: Dictionary = p_data[city_id]

		if city_data.has("remove"):
			Debug.log_verbose("  Ignoring: %s" % [city_id])
			continue

		var cache: Dictionary = {}
		var support: Dictionary = city_data.get("support", {}) # optional, city can start neutral

		# validate all referenced countries in support dict
		for country_id: String in support.keys():
			cache = p_cache["country"]["country_id"]
			if not cache.has(country_id):
				Debug.log_warning("Unable to find supporting country: %s (%s)" % [country_id, city_id])
				return false

		# validate city assigned market
		var market_id: String = city_data["trade"]["market"]
		cache = p_cache["trade"]["market_id"]
		if not cache.has(market_id):
			Debug.log_warning("Unable to find assigned market: %s (%s)" % [market_id, city_id])
			return false

		# validate assigned trade specialty
		var specialty_id: String = city_data["trade"]["specialty"]["resource"]
		cache = p_cache["trade"]["resource_id"]
		if not cache.has(specialty_id):
			Debug.log_warning("Unable to find specialty resource: %s (%s)" % [specialty_id, city_id])
			return false

	return true
