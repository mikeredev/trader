class_name CountryManager extends Service

var datastore: Dictionary[StringName, Country]


func create_country(p_country_id: StringName, p_metadata: Dictionary) -> void:
	var profile: Dictionary = p_metadata["leader"]
	var leader: Character = Service.character_manager.create_character_no_register(Character.Role.LEADER, profile.name, p_country_id, Rank.Level.KING, profile.title)
	Service.character_manager.register_character(leader)

	var country: Country = Country.new()
	var capital_id: StringName = p_metadata.get("capital")
	var color: Color = p_metadata.get("color", Color.CYAN) # default to

	country.country_id = p_country_id
	country.capital_id = capital_id
	country.color = color
	country.leader = leader

	datastore[country.country_id] = country

	Debug.log_verbose("  Created country: %s (%s, %s, %s)" % [country.country_id, country.capital_id, country.leader.profile.profile_name, country.leader.profile.rank.title.to_pascal_case()])


func get_capital(p_country_id: StringName) -> City:
	var country: Country = get_country(p_country_id)
	var city_id: StringName = country.capital_id
	return city_manager.get_city(city_id)


func get_country(p_country_id: StringName) -> Country:
	return datastore.get(p_country_id, null)


func get_leader(p_country_id: StringName) -> Character:
	var country: Country = get_country(p_country_id)
	var profile_id: StringName = country.leader.profile.profile_id
	return Service.character_manager.get_character(profile_id)
