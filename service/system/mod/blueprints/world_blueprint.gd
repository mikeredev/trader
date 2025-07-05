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


func build() -> void:
	var overworld: View = Service.scene_manager.get_view(View.Type.OVERWORLD)
	var container: NodeContainer = overworld.get_container(View.ContainerType.MAP)

	# create world map
	var texture: String = map.texture
	var world_map: WorldMap = WorldMap.new(texture)
	container.add_child(world_map)

	# register world map
	Service.world_manager.map = world_map

	# create and bind camera
	var camera: Camera = overworld.get_camera()
	camera.set_limits(world_map.texture.get_size())
	camera.set_min_zoom(DisplayServer.screen_get_size(), world_map.texture.get_size())

	# TESTING
	camera.enabled = true
	camera.cam_control = true

	if Service.config_manager.developer_settings.enable_astar:

		# create A* grid
		var astar: Dictionary[String, Variant] = {
			"compute": AStarGrid2D.HEURISTIC_EUCLIDEAN,
			"estimate": AStarGrid2D.HEURISTIC_EUCLIDEAN,
			"diagonal": AStarGrid2D.DIAGONAL_MODE_ALWAYS,
			"jumping": true }

		var grid: WorldGrid = WorldGrid.new(world_map.texture, astar)

		# register A* grid
		Service.world_manager.grid = grid

	else:
		Debug.log_warning("Overworld A* is disabled")
