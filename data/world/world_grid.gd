class_name WorldGrid extends AStarGrid2D

const TILE_DATA: Dictionary[String, Dictionary] = {
	"land": {
		"color": "#C0C0C0"
	},
	"border": {
		"color": "#000000",
		"weight": 1.3,
	},
	"ocean": {
		"color": "#FFFFFF",
		"weight": 1.0,
	},
	"coast": {
		"color": "#A9A9A9",
		"weight": 1.3,
	},
	"region": {
		"color": "#9F9F9F",
		"weight": 1.4,
	},
	"beacon": {
		"color": "#0000FF",
		"weight": 0.1,
	},
}

var settings: Dictionary[String, Variant]
var pixel_data: PixelData = PixelData.new()


func _init(p_map_texture: Texture2D, p_settings: Dictionary[String, Variant]) -> void:
	settings = p_settings
	_create_grid(p_map_texture.get_size(), settings)
	_set_weights(self, region.size, p_map_texture.get_image(), TILE_DATA)


func _create_grid(p_size: Vector2i, p_settings: Dictionary) -> void:
	var compute: int = p_settings["compute"]
	var estimate: int = p_settings["estimate"]
	var diagonal: int = p_settings["diagonal"]
	var jumping: bool = p_settings["jumping"]

	region = Rect2i(Vector2i.ZERO, p_size)
	default_compute_heuristic = compute as AStarGrid2D.Heuristic
	default_estimate_heuristic = estimate as AStarGrid2D.Heuristic
	diagonal_mode = diagonal as AStarGrid2D.DiagonalMode
	jumping_enabled = jumping as bool
	update()

	Debug.log_debug("Created grid: COMPUTE: %d, ESTIMATE: %d, DIAGONAL: %d, JUMPING: %s, size: %s" %
		[default_compute_heuristic, default_estimate_heuristic,
		diagonal_mode, jumping_enabled, p_size])


func _set_weights(p_grid: AStarGrid2D, p_size: Vector2i, p_image: Image, p_tile_data: Dictionary[String, Dictionary]) -> void:
	var start: int = Time.get_ticks_msec()
	var color_to_weight: Dictionary[Color, float] = {}
	var color_to_info: Dictionary[Color, Dictionary] = {}
	var unknown: int = 0

	for tile_type: String in p_tile_data.keys():
		var color: Color = p_tile_data[tile_type].color
		var weight: float = p_tile_data[tile_type].get("weight", -1) # set below 0
		color_to_weight[color] = weight
		color_to_info[color] = {
			"tile_type": tile_type as String,
			"count": 0 as int,
		}

	for x: int in range(p_size.x):
		for y: int in range(p_size.y):
			var color: Color = p_image.get_pixel(x, y)
			var cell: Vector2i = Vector2i(x, y)

			if color_to_weight.has(color):
				var weight: float = color_to_weight[color]
				color_to_info[color]["count"] += 1
				pixel_data["datastore"][cell] = color # used by chunk grid
				if weight < 0:
					p_grid.set_point_solid(cell, true)
				else:
					p_grid.set_point_weight_scale(cell, weight)
			else:
				unknown += 1

	var end: int = Time.get_ticks_msec()
	var duration: int = end - start

	var output: Dictionary[String, Dictionary] = {}
	for color: Color in color_to_info.keys():
		output[color_to_info[color]["tile_type"]] = {
			"count": color_to_info[color]["count"],
			"weight": color_to_weight[color],
		}
	Debug.log_debug("Set weights: unknown %d, %s, duration: %dms" % [unknown, output, duration])


func update_grid(p_compute: int, p_estimate: int, p_diagonal: int, p_jumping: bool) -> void:
	default_compute_heuristic = p_compute as AStarGrid2D.Heuristic
	default_estimate_heuristic = p_estimate as AStarGrid2D.Heuristic
	diagonal_mode = p_diagonal as AStarGrid2D.DiagonalMode
	jumping_enabled = p_jumping as bool
	update()
