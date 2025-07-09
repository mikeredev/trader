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
				# construct the full path to the map texture
				var dir: String = p_cache["manifest"]["directory"]
				var folder: String = str(ModManager.Category.keys()[ModManager.Category.WORLD]).to_lower()
				var texture: String = p_data["map"]["texture"]
				var texture_path: String = "%s/%s/%s" % [dir, folder, texture]

				# validate file exists (not that it is a valid map)
				if not FileAccess.file_exists(texture_path):
					Debug.log_warning("Unable to access map texture: %s" % texture_path)
					return false

				# update data with full path
				p_data["map"]["texture"] = texture_path
				Debug.log_verbose("  Validated map texture: %s" % texture_path)

			# regex timestamp
	return true


func build() -> void:
	var view: View = Service.scene_manager.get_view(View.ViewType.OVERWORLD)

	# create world map
	var path: String = map.get("texture")
	var world_map: WorldMap = WorldMap.new(path)
	view.add_scene(world_map, View.ContainerType.MAP)

	# register world map
	Service.world_manager.map = world_map

	# bind camera / TBD this will bind it to the starting window size, ensure overridden later
	view.camera.update_limits(world_map.texture.get_size())
	view.camera.set_min_zoom(DisplayServer.screen_get_size(), world_map.texture.get_size())

	# create A* grid
	var enable_astar: bool = Service.config_manager.developer_settings.enable_astar
	if not enable_astar:
		Debug.log_warning("Overworld A* is disabled")
		return

	var world_grid: WorldGrid = WorldGrid.new(world_map.texture)

	# register A* grid
	Service.world_manager.grid = world_grid
