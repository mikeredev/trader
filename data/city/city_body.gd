class_name CityBody extends StaticBody2D

var city_id: StringName
var sprite: Sprite2D
var color: Color
var neighbors: Dictionary[Vector2i, Vector2i] # direction to neighbor pixel e.g., (0, -1): (1119, 312)
var water_direction: Array[Vector2i] # all water neighbors
