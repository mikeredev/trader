class_name CityScene extends Node2D

var area: Vector2i # size in pixels, e.g., (640, 368)
var astar_grid: AStarGrid2D
var access_points: Dictionary[StringName, Vector2i]

@onready var border_group: Node2D = %Borders
@onready var building_group: Node2D = %Buildings
@onready var access_point_group: Node2D = %AccessPoints

@onready var water_layer: TileMapLayer = %Water
@onready var ground_layer: TileMapLayer = %Ground
@onready var shore_layer: TileMapLayer = %Shore
@onready var green_layer: TileMapLayer = %Green # reserved, no buildings/roads here
@onready var buffer_layer: TileMapLayer = %Buffer # reserved area around buildings, road allowed, no other building
@onready var building_layer: TileMapLayer = %Building
@onready var road_layer: TileMapLayer = %Road

@onready var debug_overlay: Control = %Debug


func add_access_point(p_building: Building, p_access_point: Vector2i) -> void:
	access_points[p_building.building_id] = p_access_point


func get_access_point(p_building: Building) -> Vector2i:
	return access_points.get(p_building.building_id)
