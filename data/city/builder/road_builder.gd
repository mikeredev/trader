class_name CityRoadBuilder extends RefCounted

var scene: CityScene
var tile_map: Dictionary[String, Vector2i]


func _init(p_scene: CityScene, p_tile_map: Dictionary[String, Vector2i]) -> void:
	scene = p_scene
	tile_map = p_tile_map


func create_astar(p_ground_rect: Rect2i) -> void:
	scene.astar_grid = AStarGrid2D.new()
	scene.astar_grid.region = p_ground_rect
	scene.astar_grid.cell_size = Vector2i(1, 1)
	scene.astar_grid.diagonal_mode = AStarGrid2D.DiagonalMode.DIAGONAL_MODE_NEVER
	scene.astar_grid.default_compute_heuristic = AStarGrid2D.Heuristic.HEURISTIC_MANHATTAN
	scene.astar_grid.default_estimate_heuristic = AStarGrid2D.Heuristic.HEURISTIC_MANHATTAN
	scene.astar_grid.jumping_enabled = false
	scene.astar_grid.update()

	# mark unwalkable layers as A* solid
	var unwalkable: Array[TileMapLayer] = [
		scene.shore_layer, scene.green_layer, scene.building_layer ]
	for layer: TileMapLayer in unwalkable:
		var used_cells: Array[Vector2i] = layer.get_used_cells()
		for cell: Vector2i in used_cells:
			scene.astar_grid.set_point_solid(cell, true)

	# bias towards open ground areas
	for cell: Vector2i in scene.ground_layer.get_used_cells():
		scene.astar_grid.set_point_weight_scale(cell, 1.0)
	for cell: Vector2i in scene.buffer_layer.get_used_cells():
		scene.astar_grid.set_point_weight_scale(cell, 5.0)
	Debug.log_debug("Created A*: %s" % scene.astar_grid)


func draw_road(p_start: Building, p_end: Building) -> void:
	var start: Vector2i = scene.access_points.get(p_start)
	var end: Vector2i = scene.access_points.get(p_end)
	var path: PackedVector2Array = scene.astar_grid.get_point_path(start, end)
	var road_tile: Vector2i = tile_map.get("road")

	if path.is_empty():
		Debug.log_error("No path found between %s and %s" % [p_start.building_id, p_end.building_id])
		return

	for cell: Vector2i in path:
		scene.road_layer.set_cell(cell, 3, road_tile)
		scene.astar_grid.set_point_weight_scale(cell, 0.01) # lower weight of existing roads
