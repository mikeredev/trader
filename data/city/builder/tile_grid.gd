class_name CityBuildUtilTileGrid extends RefCounted

var grid_size: Vector2i # size in grid tiles, e.g., (40, 23)
var grid_area: Vector2i # size in pixels, e.g., (640, 368)


func generate() -> void:
	var base_size: Vector2i = ProjectSettings.get_setting("services/config/scene_base_size")
	var default_tile_size: int = ProjectSettings.get_setting("services/config/default_tile_size")

	var grid_x: int = ceili(base_size.x / float(default_tile_size) * 1.0) # allow for multiplier
	var grid_y: int = ceili(base_size.y / float(default_tile_size) * 1.0)
	grid_size = Vector2i(grid_x, grid_y)
	grid_area = grid_size * default_tile_size

	Debug.log_debug("Created tile grid: size: %s, area: %s" % [grid_size, grid_area])

	# signal back grid_size for binding camera limits
	#tile_grid_created.emit(grid_area)
