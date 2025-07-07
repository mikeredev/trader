class_name CityTerrainBuilder extends RefCounted

const SHORE_SIZE: int = 2 # tile size of shoreline. southern shore will be automatically set a little larger
const RESERVED_PALACE_HEIGHT: int = 3 # should correspond to height of building exterior from atlas tiles

const BITMASK: Dictionary[Vector2i, int] = {
	Vector2i(-1, -1): 1,
	Vector2i(0, -1): 2,
	Vector2i(1, -1): 4,
	Vector2i(-1, 0): 8,
	Vector2i(1, 0): 16,
	Vector2i(-1, 1): 32,
	Vector2i(0, 1): 64,
	Vector2i(1, 1): 128 }

const CARDINAL_WEIGHT: Dictionary[String, Vector2i] = {
	"N": Vector2(0, -1),
	"S": Vector2(0, 1),
	"W": Vector2(-1, 0),
	"E": Vector2(1, 0) }

const DIRECTION_WEIGHT: Dictionary[Vector2i, Vector2] = {
	Vector2i(0, -1): Vector2(0, -1),
	Vector2i(1, -1): Vector2(0.707, -0.707),
	Vector2i(1, 0): Vector2(1, 0),
	Vector2i(1, 1): Vector2(0.707, 0.707),
	Vector2i(0, 1): Vector2(0, 1),
	Vector2i(-1, 1): Vector2(-0.707, 0.707),
	Vector2i(-1, 0): Vector2(-1, 0),
	Vector2i(-1, -1): Vector2(-0.707, -0.707) }

const SHORELINE_OUTER_MASK: Dictionary = {
	47: Vector2i(0, 0), # left
	40: Vector2i(0, 0), # left
	41: Vector2i(0, 1),
	233: Vector2i(0, 2),
	9: Vector2i(0, 1),
	7: Vector2i(1, 0), # top
	3: Vector2i(1, 0),
	224: Vector2i(1, 2), # bottom
	192: Vector2i(1, 2),
	151: Vector2i(2, 0), # right
	148: Vector2i(2, 1),
	244: Vector2i(2, 2),
	144: Vector2i(2, 1) }

const SHORELINE_INNER_MASK: Dictionary = {
	0: Vector2i(1, 1), # center
	128: Vector2i(3, 0), # top right inner
	32: Vector2i(4, 0), # top left inner
	4: Vector2i(3, 1), # bottom left inner
	1: Vector2i(4, 1), # bottom right inner
	192: Vector2i(3, 2), # bottom on top facing down
	224: Vector2i(3, 2),
	96: Vector2i(3, 2),
	6: Vector2i(1, 0), # top on bottom facing down
	7: Vector2i(1, 0),
	3: Vector2i(1, 0),
	144: Vector2i(2, 1), # right on left facing in
	148: Vector2i(2, 1),
	20: Vector2i(2, 1),
	40: Vector2i(0, 1), # left on right facing in
	41: Vector2i(0, 1),
	9: Vector2i(0, 1) }

var city: City
var scene: CityScene
var tile_map: Dictionary[String, Vector2i]
var ground_rect: Rect2i


func _init(p_city: City, p_scene: CityScene, p_tile_map: Dictionary[String, Vector2i]) -> void:
	city = p_city
	scene = p_scene
	tile_map = p_tile_map


func draw_terrain(p_grid_size: Vector2i) -> void:
	var water_direction: Vector2 = _get_water_direction()
	var city_orientation: Dictionary[String, float] = _get_orientation(water_direction)
	draw_water(p_grid_size, city_orientation)
	ground_rect = draw_ground(p_grid_size)
	draw_shore(city_orientation, ground_rect)
	draw_inner_ring(ground_rect)


func draw_water(p_grid_size: Vector2i, p_city_orientation: Dictionary[String, float]) -> void:
	if not Service.config_manager.developer_settings.enable_astar:
		Debug.log_warning("A* is disabled (city is considered landlocked)")
		return

	if city.body.water_direction.is_empty():
		Debug.log_warning("City is landlocked: %s" % city.city_id)
		return

	var range_x: Vector2i
	var range_y: Vector2i
	for direction: String in p_city_orientation.keys():
		var strength: float = p_city_orientation[direction]
		var thickness: int = ceili(strength * 6.0)
		match direction:
			"N":
				range_x = Vector2i(0, p_grid_size.x)
				range_y = Vector2i(0, thickness if not city.is_capital else 0)
			"S":
				range_x = Vector2i(0, p_grid_size.x)
				range_y = Vector2i(p_grid_size.y - (thickness if not city.is_capital else 0), p_grid_size.y)
			"W":
				range_x = Vector2i(0, thickness)
				range_y = Vector2i(0, p_grid_size.y)
			"E":
				range_x = Vector2i(p_grid_size.x - thickness, p_grid_size.x)
				range_y = Vector2i(0, p_grid_size.y)

		for x: int in range(range_x.x, range_x.y):
			for y: int in range(range_y.x, range_y.y):
				var coords: Vector2i = Vector2i(x, y)
				scene.water_layer.set_cell(coords, 1, tile_map.get("water"))

	# done
	Debug.log_debug("Water direction: %s" % p_city_orientation)


func draw_ground(p_grid_size: Vector2i) -> Rect2i:
	for x: int in range(p_grid_size.x):
		for y: int in range(p_grid_size.y):
			var coords: Vector2i = Vector2i(x, y)
			var id: int = scene.water_layer.get_cell_source_id(coords)
			if id == -1: # get every "not water" cell in the whole grid
				scene.ground_layer.set_cell(coords, 1, tile_map.get("grass"))
	var ground_rect: Rect2i = scene.ground_layer.get_used_rect()
	Debug.log_debug("Ground rect: %s" % ground_rect)
	return ground_rect


func draw_shore(p_city_orientation: Dictionary[String, float], p_ground_rect: Rect2i) -> void:
	if not city.is_capital: # capitals have no northern or southern shore
		if p_city_orientation.has("N"):
			var range_x: Vector2i = Vector2i(p_ground_rect.position.x, p_ground_rect.position.x + p_ground_rect.size.x)
			var range_y: Vector2i = Vector2i(p_ground_rect.position.y, p_ground_rect.position.y + SHORE_SIZE)
			_reserve_shore(range_x, range_y)

		if p_city_orientation.has("S"): # southern shore should be a little larger in viewport
			var southern_shore_size: int = SHORE_SIZE + 1
			var range_x: Vector2i = Vector2i(p_ground_rect.position.x, p_ground_rect.position.x + p_ground_rect.size.x)
			var range_y: Vector2i = Vector2i((p_ground_rect.position.y + p_ground_rect.size.y) - southern_shore_size, p_ground_rect.position.y + p_ground_rect.size.y)
			_reserve_shore(range_x, range_y)

	if p_city_orientation.has("W"):
		var range_x: Vector2i = Vector2i(p_ground_rect.position.x, p_ground_rect.position.x + SHORE_SIZE)
		var range_y: Vector2i = Vector2i(p_ground_rect.position.y, p_ground_rect.position.y + p_ground_rect.size.y)
		_reserve_shore(range_x, range_y)

	if p_city_orientation.has("E"):
		var range_x: Vector2i = Vector2i((p_ground_rect.position.x + p_ground_rect.size.x) - SHORE_SIZE, p_ground_rect.position.x + p_ground_rect.size.x)
		var range_y: Vector2i = Vector2i(p_ground_rect.position.y, p_ground_rect.position.y + p_ground_rect.size.y)
		_reserve_shore(range_x, range_y)

	# 1 / bitmask the shoreline outer layer
	var shore_inner: Array[Vector2i] = []
	for coords: Vector2i in scene.shore_layer.get_used_cells():
		# bitmask each cell against the water layer
		var bitmask: int = _get_bitmask(coords, scene.water_layer)
		var tile: Vector2i = SHORELINE_OUTER_MASK.get(bitmask, Vector2i(-1, -1))

		# if it doesn't have a mapped tile, consider it part of the inner shoreline
		if tile == Vector2i(-1, -1): shore_inner.append(coords)

		# otherwise set the selected tile on the cell
		else: scene.shore_layer.set_cell(coords, 3, tile)

	# 2 / bitmask shoreline inner layer
	for coords: Vector2i in shore_inner:
		var bitmask: int = _get_bitmask(coords, scene.ground_layer)
		var tile: Vector2i = SHORELINE_INNER_MASK.get(bitmask, Vector2i(-1, -1))
		if tile == Vector2i(-1, -1): Debug.log_warning("Tile %s is not bitmasked (%d)" % [coords, bitmask])
		else: scene.shore_layer.set_cell(coords, 3, tile)

	# done
	Debug.log_verbose("  Bitmasked shoreline (is capital: %s)" % city.is_capital)


func draw_inner_ring(p_ground_rect: Rect2i) -> void: # creates a reserved "green area"
	#var reserved_green_tile: Vector2i = Vector2i(1, 2)
	#var reserved_cells: Array[Vector2i] = []
	var edge_cells: Array[Vector2i] = []

	var north_row: int = p_ground_rect.position.y
	var west_col: int = p_ground_rect.position.x
	var east_col: int = (p_ground_rect.position.x + p_ground_rect.size.x) - 1
	var south_row: int = (p_ground_rect.position.y + p_ground_rect.size.y) - 1

	# mark a reserved ring around the exterior perimeter
	for coords: Vector2i in scene.ground_layer.get_used_cells():
		# reserve n northern rows for palace building
		#if city.is_capital:
		#	if coords.y <= north_row + RESERVED_PALACE_HEIGHT:
		#		reserved_cells.append(coords)

		# gets any ground tiles next to shoreline
		if _is_adjacent_to_layer(coords, scene.shore_layer): edge_cells.append(coords)
		else: # gets any ground tiles at rect external border
			if city.is_capital: # allow space for palace in due north
				if coords.y == north_row + RESERVED_PALACE_HEIGHT + 1: edge_cells.append(coords)
			else:
				if coords.y == north_row: edge_cells.append(coords)
			if coords.x == west_col: edge_cells.append(coords)
			if coords.x == east_col: edge_cells.append(coords)
			if coords.y == south_row: edge_cells.append(coords)

	# reserve any palace tiles in building buffer
	#if not reserved_cells.is_empty():
		#for coords: Vector2i in reserved_cells:
			#scene.ground_layer.erase_cell(coords)
			#scene.buffer_layer.set_cell(coords, 1, Vector2(0,0))

	# reserve any (unreserved) edge tiles in green layer
	for coords: Vector2i in edge_cells:
		#if not reserved_cells.has(coords):
		scene.ground_layer.erase_cell(coords)
		scene.green_layer.set_cell(coords, 1, tile_map.get("reserved"))

	# done
	Debug.log_verbose("  Reserved inner ring (is capital: %s)" % city.is_capital)


func _get_bitmask(p_position: Vector2i, p_layer: TileMapLayer) -> int:
	var neighbor: Vector2i
	var bitmask: int = 0
	for direction: Vector2i in BITMASK.keys():
		neighbor = p_position + direction
		if p_layer.get_cell_source_id(neighbor) != -1:
			bitmask += BITMASK[direction]
	return bitmask


func _get_orientation(p_water_direction: Vector2) -> Dictionary[String, float]:
	var result: Dictionary[String, float] = {}

	if p_water_direction.length_squared() < 0.0001:
		result["E"] = 0.1
		result["W"] = 0.1
		result["N"] = 0.1
		result["S"] = 0.1
		return result

	# get dot product
	var vector: Vector2i
	var dot: float
	var total_weight: float = 0.0
	for direction: String in CARDINAL_WEIGHT.keys():
		vector = CARDINAL_WEIGHT[direction]
		dot = p_water_direction.dot(vector)
		if dot > 0.0:
			result[direction] = dot
			total_weight += dot

	# normalise to 1.0
	if total_weight > 0.0:
		for key: String in result.keys():
			result[key] /= total_weight
	return result


func _get_water_direction() -> Vector2:
	var result: Vector2 = Vector2.ZERO
	for direction: Vector2i in city.body.water_direction:
		result += DIRECTION_WEIGHT.get(direction, Vector2.ZERO)
	return result


func _is_adjacent_to_layer(p_cell: Vector2i, p_layer: TileMapLayer) -> bool:
	var neighbors: Array[Vector2i] = p_layer.get_surrounding_cells(p_cell)
	neighbors.append(p_layer.get_neighbor_cell(p_cell, TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER))
	neighbors.append(p_layer.get_neighbor_cell(p_cell, TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER))
	neighbors.append(p_layer.get_neighbor_cell(p_cell, TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER))
	neighbors.append(p_layer.get_neighbor_cell(p_cell, TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER))

	for neighbor: Vector2i in neighbors:
		if p_layer.get_cell_source_id(neighbor) != -1: # is cell valid in neighbor layer
			return true
	return false


func _reserve_shore(p_range_x: Vector2i, p_range_y: Vector2i) -> void:
	for x: int in range(p_range_x.x, p_range_x.y):
		for y: int in range(p_range_y.x, p_range_y.y):
			var coords: Vector2i = Vector2i(x, y)
			scene.ground_layer.erase_cell(coords) # set reserved tile
			scene.shore_layer.set_cell(coords, 1, tile_map.get("reserved"))
