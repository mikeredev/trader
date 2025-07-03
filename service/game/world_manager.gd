class_name WorldManager extends Service

var _grid: WorldGrid
var _map: WorldMap


func create_world(p_blueprint: WorldBlueprint) -> void:
	var overworld: View = Service.scene_manager.get_view(View.Type.OVERWORLD)
	var container: NodeContainer = overworld.get_container(View.ContainerType.MAP)

	# create world map
	var texture: String = p_blueprint.map.texture
	_map = WorldMap.new(texture)
	container.add_child(_map)

	# create and bind camera
	var camera: Camera = overworld.get_camera()
	camera.set_limits(_map.texture.get_size())
	camera.set_min_zoom(DisplayServer.screen_get_size(), _map.texture.get_size())

	# TESTING
	camera.enabled = true
	camera.cam_control = true

	# create A* grid
	if Service.config_manager.developer_settings.enable_astar:
		var astar: Dictionary[String, Variant] = {
			"compute": AStarGrid2D.HEURISTIC_EUCLIDEAN,
			"estimate": AStarGrid2D.HEURISTIC_EUCLIDEAN,
			"diagonal": AStarGrid2D.DIAGONAL_MODE_ALWAYS,
			"jumping": true }
		WorldGrid.new(_map.texture, astar)

	else:
		Debug.log_warning("Overworld A* is disabled")


func get_map() -> WorldMap:
	return _map


func get_grid() -> WorldGrid:
	return _grid
