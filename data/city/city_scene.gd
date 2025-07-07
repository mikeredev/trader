class_name CityScene extends Node2D

@onready var border_group: Node2D = %Borders
@onready var water_layer: TileMapLayer = %Water
@onready var ground_layer: TileMapLayer = %Ground
@onready var shore_layer: TileMapLayer = %Shore
@onready var green_layer: TileMapLayer = %Green # reserved, no buildings/roads here
@onready var buffer_layer: TileMapLayer = %Buffer # reserved area around buildings, road allowed, no other building

@onready var debug_overlay: Control = %Debug

func _init() -> void:
	pass


func _ready() -> void:
	pass
