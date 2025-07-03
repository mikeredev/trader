class_name CountryBlueprint extends RefCounted

var datastore: Dictionary[StringName, Dictionary]


static func from_dict(p_data: Dictionary[String, Dictionary]) -> CountryBlueprint:
	var data: Dictionary[StringName, Dictionary] = {}

	for country_id: StringName in p_data.keys():
		data[country_id] = {}

		for property: String in p_data[country_id].keys():
			match property:
				"capital":
					var capital_id: StringName = p_data[country_id]["capital"]
					data[country_id]["capital"] = capital_id

				"color":
					var color: Color = Color(str(p_data[country_id]["color"]))
					data[country_id]["color"] = color

				"leader":
					var country_data: Dictionary = p_data[country_id]["leader"]
					var name: String = country_data.get("name")
					var title: String = country_data.get("title", "KING")
					var leader: Dictionary[String, String] = {
						"name": name,
						"title": title,
					}
					data[country_id]["leader"] = leader

				"owner":
					var owner: StringName = p_data[country_id]["owner"]
					data[country_id][property] = owner

				_: Debug.log_warning("Ignoring unrecognized key: %s" % property)

	var out: CountryBlueprint = CountryBlueprint.new()
	out.datastore = data
	return out


static func validate(p_data: Dictionary, p_cache: Dictionary) -> bool:
	for country_id: String in p_data.keys():
		var country_data: Dictionary = p_data[country_id]
		var _cache: Dictionary = p_cache["city"]["city_id"]
		var capital_id: String = country_data.get("capital", "")

		if not _cache.has(capital_id):
			Debug.log_warning("Unable to find capital: %s (%s)" % [capital_id, country_id])
			return false

		if _cache[capital_id] == true:
			Debug.log_warning("Unable to claim existing capital: %s" % [capital_id])
			return false

		# mark capital as claimed
		_cache[capital_id] = true
	return true


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
