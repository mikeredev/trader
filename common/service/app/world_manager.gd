class_name WorldManager extends Service

var grid: WorldGrid
var map: WorldMap


func get_map() -> WorldMap:
	return map


func get_map_size() -> Vector2i:
	return map.texture.get_size()


func get_grid() -> WorldGrid:
	return grid
