class_name WorldBlueprint extends RefCounted

var map: Dictionary[String, Variant]
var clock: Dictionary[String, Variant]


static func from_dict(p_data: Dictionary[String, Dictionary]) -> WorldBlueprint:
	var out: WorldBlueprint = WorldBlueprint.new()
	for property: String in p_data.keys():
		match property:
			"map":
				var texture: String = p_data["map"]["texture"]
				var owner: StringName = p_data["map"]["owner"]
				out.map = { "texture": texture, "owner": owner }

			"clock":
				var timestamp: String = p_data["clock"]["timestamp"]
				var owner: StringName = p_data["clock"]["owner"]
				out.clock = { "timestamp": timestamp, "owner": owner }

			_: Debug.log_warning("Ignoring unrecognized key: %s" % property)
	return out


static func validate(p_data: Dictionary, p_cache: Dictionary) -> bool:
	for property: String in p_data.keys():
		match property:
			"map":
				var path: String = p_cache["manifest"]["directory"]
				var world_category: String = ModManager.Category.keys()[ModManager.Category.WORLD]
				var map_data: Dictionary = p_data["map"]
				var texture: String = map_data.get("texture", "")
				var texture_path: String = "%s/%s/%s" % [path, world_category.to_lower(), texture]

				if not FileAccess.file_exists(texture_path):
					Debug.log_warning("Unable to access map texture: %s" % texture_path)
					return false

				# update data with full path
				p_data["map"]["texture"] = texture_path

		# regex timestamp
	return true
