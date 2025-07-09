class_name CityBuildingBuilder extends RefCounted

const BUILDING_BUFFER: int = 2
const MAX_BUILD_ATTEMPTS: int = 50

var city: City
var scene: CityScene
var tile_map: Dictionary[String, Vector2i]
var shore_area: Array[Vector2i]


func _init(p_city: City, p_scene: CityScene, p_tile_map: Dictionary[String, Vector2i]) -> void:
	city = p_city
	scene = p_scene
	tile_map = p_tile_map


func _add_debug_rect(p_position: Vector2i, p_color: Color = Color.BLACK) -> void:
	var box: ColorRect = ColorRect.new()
	box.name = "%s" % p_position
	box.position = p_position * 16
	box.size = Vector2i(16,16)
	box.color = p_color
	box.color.a = 0.5
	scene.debug_overlay.add_child(box)


func create_cell_bias() -> void:
	shore_area = _get_shore_area()


func create_buildings(p_rng: RandomNumberGenerator) -> void:
	for building: Building in city.buildings.values():
		var rect: Rect2i = _get_building_rect(p_rng, building)
		if rect.size > Vector2i.ZERO:
			_create_building(building, rect)
		else:
			Debug.log_error("Failed to build %s after %d attempts" % [building.building_id, MAX_BUILD_ATTEMPTS])


func _get_building_rect(p_rng: RandomNumberGenerator, p_building: Building) -> Rect2i:
	var building_size: Vector2i = p_building.exterior_size
	building_size.x += BUILDING_BUFFER * 2
	building_size.y += BUILDING_BUFFER * 2
	var available_cells: Array[Vector2i] = _get_available_cells(p_building)
	var attempt: int = 0
	var rand: int
	var pos: Vector2i
	var rect: Rect2i
	while attempt < MAX_BUILD_ATTEMPTS:
		attempt += 1
		rand = p_rng.randi_range(0, available_cells.size() - 1)
		pos = available_cells[rand]
		rect = Rect2i(pos, building_size)
		if _can_create_building(rect):
			Debug.log_debug("Built %s (bias: %s) on attempt %d %s" % [p_building.building_id, Building.PlacementBias.keys()[p_building.placement_bias], attempt, rect])
			return rect
	return Rect2i()


func _get_available_cells(p_building: Building) -> Array[Vector2i]:
	match p_building.placement_bias:
		Building.PlacementBias.SHORE: return shore_area
		_: return scene.ground_layer.get_used_cells()


func _can_create_building(p_rect: Rect2i) -> bool:
	for x: int in range(p_rect.position.x, p_rect.position.x + p_rect.size.x):
		for y: int in range(p_rect.position.y, p_rect.position.y + p_rect.size.y):
			var coords: Vector2i = Vector2i(x, y)
			if scene.ground_layer.get_cell_source_id(coords) == -1:
				return false
	return true


func _create_building(p_building: Building, p_rect: Rect2i) -> void:
	var tile: Vector2i
	# create buffer
	for x: int in range(p_rect.position.x, p_rect.position.x + p_rect.size.x):
		for y: int in range(p_rect.position.y, p_rect.position.y + p_rect.size.y):
			var coords: Vector2i = Vector2i(x, y)
			scene.ground_layer.erase_cell(coords)
			tile = tile_map.get("reserved")
			scene.buffer_layer.set_cell(coords, 1, tile)

	# draw building rect inside buffer
	for x: int in range(p_rect.position.x + BUILDING_BUFFER, p_rect.position.x + (p_rect.size.x - BUILDING_BUFFER)):
		for y: int in range(p_rect.position.y + BUILDING_BUFFER, p_rect.position.y + (p_rect.size.y - BUILDING_BUFFER)):
			var coords: Vector2i = Vector2i(x, y)
			scene.buffer_layer.erase_cell(coords)
			tile = tile_map.get("grass")
			scene.building_layer.set_cell(coords, 1, tile)

	# place exterior instance onto the building rect
	var default_tile_size: int = ProjectSettings.get_setting("services/config/default_tile_size")
	var x: int = (p_rect.position.x + BUILDING_BUFFER) * default_tile_size
	var y: int = (p_rect.position.y + BUILDING_BUFFER) * default_tile_size
	var building_exterior: Node2D = p_building.exterior_scene.instantiate()
	scene.building_group.add_child(building_exterior)
	building_exterior.position = Vector2i(x, y)

	# draw access point
	var access_x: int = p_rect.position.x + floori(p_rect.size.x / 2.0)
	var access_y: int = p_rect.position.y + p_rect.size.y - BUILDING_BUFFER - 1
	var access_point: Vector2i = Vector2i(access_x, access_y)
	scene.building_layer.erase_cell(access_point) # building_layer is A* unwalkable
	tile = tile_map.get("reserved")
	scene.ground_layer.set_cell(access_point, 1, tile) # put it back on the ground

	# add door interaction area
	var interaction_area: Area2D = Area2D.new()
	interaction_area.name = p_building.building_id
	interaction_area.set_meta("building", p_building)
	interaction_area.set_meta("interact", p_building)
	interaction_area.position = scene.building_layer.map_to_local(access_point)

	interaction_area.collision_layer = 1#Common.Collision.Bitmask.INTERACTION
	interaction_area.collision_mask = 0
	interaction_area.monitoring = false
	interaction_area.monitorable = true

	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	collision_shape.name = "CollisionShape"

	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2i(default_tile_size, default_tile_size)
	collision_shape.shape = shape

	interaction_area.add_child(collision_shape)
	scene.access_point_group.add_child(interaction_area)

	# register AP
	scene.access_points[p_building] = access_point


func _get_shore_area() -> Array[Vector2i]: # generates an array of cells near the shore
	var distance: int = 0
	for building: Building in city.buildings.values():
		if building.exterior_size.x > distance: distance = building.exterior_size.x
		if building.exterior_size.y > distance: distance = building.exterior_size.y

	# derive minimum size from largest building
	distance += BUILDING_BUFFER * 2

	# mark any cells within [distance] cells of the shore layer
	var used_cells: Array[Vector2i] = scene.ground_layer.get_used_cells()
	var result: Array[Vector2i] = []
	for cell: Vector2i in used_cells:
		if _is_near_layer(cell, distance, scene.shore_layer):
			result.append(cell)
			#_add_debug_rect(cell)
	Debug.log_verbose("Set shore area: %d tiles, %s size" % [distance, result.size()])
	return result


func _is_near_layer(p_origin: Vector2i, p_distance: int, p_layer: TileMapLayer) -> bool:
	for dir: Vector2i in [ Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN ]:
		var pos: Vector2i = p_origin
		for dist: int in range(1, p_distance + 1):
			pos += dir
			if p_layer.get_cell_source_id(pos) != -1:
				return true
	return false
