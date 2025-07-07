class_name CityBuilder extends RefCounted

const TILE_MAP: Dictionary[String, Vector2i] = {
	"reserved": Vector2i(0, 0),
	"water": Vector2i(1, 1),
	"grass": Vector2i(2, 2) }

var city: City
var scene: CityScene
var tile_grid: CityTileGridBuilder
var terrain_builder: CityTerrainBuilder
var building_builder: CityBuildingBuilder


func _init(p_city: City, p_scene: CityScene) -> void:
	city = p_city
	scene = p_scene
	tile_grid = CityTileGridBuilder.new()
	terrain_builder = CityTerrainBuilder.new(city, scene, TILE_MAP)
	building_builder = CityBuildingBuilder.new(city, scene, TILE_MAP)


func build() -> void:
	Debug.log_info("Building city scene: %s (%d)" % [city.city_id, city.uid])
	tile_grid.generate()

	# create borders
	var area: Vector2i = tile_grid.grid_area
	var container: Node2D = scene.border_group
	Service.scene_manager.create_borders(area, container)

	# draw terrain
	Debug.log_info("Drawing terrain...")
	terrain_builder.draw_terrain(tile_grid.grid_size)

	# create buildings
	Debug.log_info("Creating buildings...")
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = city.uid
	building_builder.create_buildings(rng)
