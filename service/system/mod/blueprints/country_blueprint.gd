class_name CountryBlueprint extends RefCounted

var datastore: Dictionary[StringName, Dictionary]


static func from_dict(p_data: Dictionary[String, Dictionary]) -> CountryBlueprint:
	var data: Dictionary[StringName, Dictionary] = {}

	for country_id: StringName in p_data.keys():
		var country_data: Dictionary = p_data[country_id]

		if country_data.get("remove", false):
			Debug.log_verbose("  Ignoring country marked for removal: %s" % [country_id])
			continue

		data[country_id] = {}
		for property: String in country_data.keys():
			match property:
				"capital":
					var capital_id: StringName = country_data["capital"]
					data[country_id]["capital"] = capital_id

				"color":
					var color: Color = Color(str(country_data["color"]))
					data[country_id]["color"] = color

				"leader":
					var _data: Dictionary = country_data["leader"]
					var name: String = _data.get("name")
					var title: String = _data.get("title", "KING")
					var leader: Dictionary[String, String] = {
						"name": name,
						"title": title,
					}
					data[country_id]["leader"] = leader

				"owner":
					var owner: StringName = country_data["owner"]
					data[country_id][property] = owner

				_: Debug.log_warning("Ignoring unrecognized key: %s" % property)

	var out: CountryBlueprint = CountryBlueprint.new()
	out.datastore = data
	return out


static func validate(p_data: Dictionary, p_cache: Dictionary) -> bool:
	for country_id: String in p_data.keys():
		var country_data: Dictionary = p_data[country_id]

		if country_data.has("remove"):
			Debug.log_verbose("  Skipping validation due to pending removal: %s" % [country_id])
			continue

		var _cache: Dictionary = p_cache["city"]["city_id"]
		var capital_id: String = country_data.get("capital", "")

		if not _cache.has(capital_id):
			Debug.log_warning("Unable to find capital: %s (%s)" % [capital_id, country_id])
			return false

		#if _cache[capital_id] == true:
		if _cache.get(capital_id, false):
			Debug.log_warning("Unable to claim existing capital: %s" % [capital_id])
			return false

		# mark capital as claimed
		_cache[capital_id] = true
		Debug.log_verbose("  Validated capital: %s (%s)" % [capital_id, country_id])
	return true


func build() -> void:
	for country_id: StringName in datastore.keys():
		_create_country(country_id, datastore[country_id])
	Debug.log_debug("Created %d countries" % datastore.size())


func _create_country(p_country_id: StringName, p_metadata: Dictionary) -> void:
	var country: Country = Country.new()
	var capital_id: StringName = p_metadata.get("capital")
	var color: Color = p_metadata.get("color", Color.CYAN) # default to

	# create leader
	var profile: Dictionary = p_metadata["leader"]
	var leader: Character = Service.character_manager.create_character(Character.Role.LEADER,
	str(profile.name), p_country_id, Rank.Level.KING, str(profile.title))

	# assign basic properties
	country.country_id = p_country_id
	country.capital_id = capital_id
	country.color = color
	country.leader = leader

	# mark city as capital
	var city: City = Service.city_manager.get_city(country.capital_id)
	city.is_capital = true

	# register for lookup
	Service.country_manager.register_country(country)

	# done
	Debug.log_verbose("  Created country: %s (%s, %s, %s)" % [ country.country_id,
	country.capital_id, country.leader.profile.profile_name,
	country.leader.profile.rank.title.to_pascal_case() ])


func merge_savedata(p_save_data: Variant) -> void:
	if not typeof(p_save_data) == TYPE_DICTIONARY:
		Debug.log_warning("Invalid save data")
		return

	var save_data: Dictionary[StringName, Dictionary] = {}
	var _raw: Dictionary = p_save_data
	for country_id: StringName in _raw.keys():
		save_data[country_id] = _raw[country_id]

	for country_id: StringName in save_data.keys():
		#Debug.log_debug("Merging %s" % country_id)

		var blueprint_data: Dictionary[String, Variant] = {}
		var savedata: Dictionary = {}

		for property: String in save_data[country_id]:
			#Debug.log_debug("-> Merging %s" % property)
			blueprint_data = datastore[country_id][property]
			savedata = save_data[country_id][property]
			blueprint_data.merge(savedata, true)

	Debug.log_debug("-> Merged %d countries" % save_data.size())
