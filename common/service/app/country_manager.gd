class_name CountryManager extends Service

var datastore: Dictionary[StringName, Country] = {}


func get_capital(p_country_id: StringName) -> City:
	var country: Country = get_country(p_country_id)
	var city_id: StringName = country.capital_id
	return App.context.city.get_city(city_id)


func get_country(p_country_id: StringName) -> Country:
	return datastore.get(p_country_id, null)


func get_leader(p_country_id: StringName) -> Leader:
	var country: Country = get_country(p_country_id)
	var profile_id: StringName = country.leader.profile.profile_id
	return App.context.character.get_character(profile_id)


func register_country(p_country: Country) -> void:
	if datastore.has(p_country.country_id):
		Debug.log_warning("Overwriting existing country: %s" % p_country.country_id)
	datastore[p_country.country_id] = p_country


func to_dict() -> Dictionary[String, Variant]:
	var dict: Dictionary[String, Variant] = {}
	for country_id: StringName in datastore.keys():
		var leader: Character = get_leader(country_id)
		dict[country_id] = {
			"leader": {
				"profile_id": leader.profile.profile_id,
				#"position": leader.body.position if leader.body else Vector2i.ZERO,
			}
		}
	return dict
