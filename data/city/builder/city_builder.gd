class_name CityBuilder extends RefCounted

var city: City
var scene: CityScene
var tile_grid: CityBuildUtilTileGrid
var terrain_builder: CityBuildUtilTerrainBuilder


func _init(p_city: City, p_scene: CityScene) -> void:
	city = p_city
	scene = p_scene
	tile_grid = CityBuildUtilTileGrid.new()
	terrain_builder = CityBuildUtilTerrainBuilder.new(city, scene)


func build() -> void:
	Debug.log_info("Building city scene: %s (%d)" % [city.city_id, city.uid])

	Debug.log_info("Creating tile grid...")
	tile_grid.generate()

	Debug.log_info("Creating borders...")
	var area: Vector2i = tile_grid.grid_area
	var container: Node2D = scene.border_group
	Service.scene_manager.create_borders(area, container)

	Debug.log_info("Drawing terrain...")
	terrain_builder.draw_terrain(tile_grid.grid_size)
