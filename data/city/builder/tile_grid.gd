class_name CityTileGridBuilder extends RefCounted

var scene: CityScene
var grid_size: Vector2i # size in grid tiles, e.g., (40, 23) / set by CityTileGridBuilder


func _init(p_scene: CityScene) -> void:
	scene = p_scene


func generate() -> void:
	var base_size: Vector2i = ProjectSettings.get_setting("services/config/scene_base_size")
	var default_tile_size: int = ProjectSettings.get_setting("services/config/default_tile_size")

	var grid_x: int = ceili(base_size.x / float(default_tile_size) * 1.0) # allow for multiplier
	var grid_y: int = ceili(base_size.y / float(default_tile_size) * 1.0)
	grid_size = Vector2i(grid_x, grid_y)
	scene.area = grid_size * default_tile_size

	Debug.log_debug("Created tile grid: size: %s, total area: %s" % [grid_size, scene.area])
