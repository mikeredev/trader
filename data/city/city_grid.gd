class_name CityGrid extends RefCounted

var size: Vector2i # size in grid tiles, e.g., (40, 23)
var area: Vector2i # size in pixels, e.g., (640, 368)


func _init() -> void:
	var base_size: Vector2i = ProjectSettings.get_setting("services/config/scene_base_size")
	var default_tile_size: int = ProjectSettings.get_setting("services/config/default_tile_size")

	var grid_x: int = ceili(base_size.x / float(default_tile_size) * 1.3) # allow for multiplier
	var grid_y: int = ceili(base_size.y / float(default_tile_size) * 1.9)
	size = Vector2i(grid_x, grid_y)
	area = size * default_tile_size

	Debug.log_debug("Created tile grid: [S: %s, A: %s]" % [size, area])
