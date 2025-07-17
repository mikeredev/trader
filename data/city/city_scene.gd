class_name CityScene extends Node2D

var tile_grid: CityGrid
var astar_grid: AStarGrid2D
var access_points: Dictionary[Building, Vector2i]

@onready var border_group: Node2D = %Borders
@onready var building_group: Node2D = %Buildings
@onready var access_point_group: Node2D = %AccessPoints
@onready var sprite_group: Node2D = %Sprites

@onready var water_layer: TileMapLayer = %Water
@onready var ground_layer: TileMapLayer = %Ground
@onready var shore_layer: TileMapLayer = %Shore
@onready var green_layer: TileMapLayer = %Green # reserved, no buildings/roads here
@onready var buffer_layer: TileMapLayer = %Buffer # reserved area around buildings, road allowed, no other building
@onready var building_layer: TileMapLayer = %Building
@onready var road_layer: TileMapLayer = %Road

@onready var debug_overlay: Control = %Debug
