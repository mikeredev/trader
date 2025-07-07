class_name CityBuilder extends RefCounted

const TILE_MAP: Dictionary[String, Vector2i] = {
	"reserved": Vector2i(0, 0), # terrain tileset
	"water": Vector2i(1, 1),
	"grass": Vector2i(2, 2),
	"road": Vector2i(1, 3), # city tileset
}

var tile_grid: CityTileGridBuilder
var terrain_builder: CityTerrainBuilder
var building_builder: CityBuildingBuilder
var road_builder: CityRoadBuilder

var city: City
var scene: CityScene
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(p_city: City, p_scene: CityScene) -> void:
	city = p_city
	scene = p_scene
	rng.seed = city.uid
	tile_grid = CityTileGridBuilder.new(scene)
	terrain_builder = CityTerrainBuilder.new(city, scene, TILE_MAP)
	building_builder = CityBuildingBuilder.new(city, scene, TILE_MAP)
	road_builder = CityRoadBuilder.new(scene, TILE_MAP)


func build() -> void:
	tile_grid.generate()

	# create borders
	Service.scene_manager.clamp_borders(scene.area, scene.border_group)

	# draw terrain
	Debug.log_info("Drawing terrain...")
	terrain_builder.draw_terrain(tile_grid.grid_size)

	# create buildings
	Debug.log_info("Creating buildings...")
	building_builder.create_buildings(rng)

	# create A* grid
	Debug.log_info("Creating roads...")
	road_builder.create_astar(terrain_builder.ground_rect)

	# connect buildings
	var market: Market = city.buildings.get("B_MARKET")
	var dock: Dock = city.buildings.get("B_DOCK")
	road_builder.draw_road(market, dock)
