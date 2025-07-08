class_name WorldGrid extends AStarGrid2D

const CELL_DATA: Dictionary[String, Dictionary] = {
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
	} }

const SETTINGS: Dictionary[String, Variant] = {
	"compute": AStarGrid2D.HEURISTIC_EUCLIDEAN,
	"estimate": AStarGrid2D.HEURISTIC_EUCLIDEAN,
	"diagonal": AStarGrid2D.DIAGONAL_MODE_ALWAYS,
	"jumping": true }

var pixel_data: PixelData = PixelData.new()


func _init(p_map_texture: Texture2D) -> void:
	var texture_size: Vector2i = p_map_texture.get_size()
	var texture_image: Image = p_map_texture.get_image()

	# set basic properties
	region = Rect2i(Vector2i.ZERO, texture_size)
	cell_shape = AStarGrid2D.CELL_SHAPE_SQUARE
	cell_size = Vector2i(1, 1)

	# apply settings (also calls update)
	_from_dict(SETTINGS)

	# derive point weight from pixel color
	_set_weights(texture_image, region.size)

	Debug.log_debug("A* size: %s, COMPUTE: %d, ESTIMATE: %d, DIAGONAL: %d, JUMPING: %s" %
		[region.size, default_compute_heuristic, default_estimate_heuristic,
		diagonal_mode, jumping_enabled])


func update_grid(p_compute: int, p_estimate: int, p_diagonal: int, p_jumping: bool) -> void:
	default_compute_heuristic = p_compute as AStarGrid2D.Heuristic
	default_estimate_heuristic = p_estimate as AStarGrid2D.Heuristic
	diagonal_mode = p_diagonal as AStarGrid2D.DiagonalMode
	jumping_enabled = p_jumping as bool
	update()


func _from_dict(p_settings: Dictionary[String, Variant]) -> void:
	var compute: int = p_settings.get("compute")#, SETTINGS.compute)
	var estimate: int = p_settings.get("estimate")#, SETTINGS.estimate)
	var diagonal: int = p_settings.get("diagonal")#, SETTINGS.diagonal)
	var jumping: bool = p_settings.get("jumping")#, SETTINGS.jumping)
	update_grid(compute, estimate, diagonal, jumping)


func _set_weights(p_image: Image, p_size: Vector2i) -> void:
	var start: int = Time.get_ticks_msec()
	var color_to_weight: Dictionary[Color, float] = {}

	# map each expected color to its weight. entries without a weight property (i.e., land)
	# will default to -1, representing solid
	for tile_type: String in CELL_DATA.keys():
		var color: Color = CELL_DATA[tile_type].color
		var weight: float = CELL_DATA[tile_type].get("weight", -1)
		color_to_weight[color] = weight

	# walk every pixel in the map texture
	for x: int in range(p_size.x):
		for y: int in range(p_size.y):

			# get the color of the current pixel
			var cell: Vector2i = Vector2i(x, y)
			var color: Color = p_image.get_pixelv(cell)

			pixel_data["datastore"][cell] = color # used by ChunkGrid

			var weight: float = color_to_weight[color]
			if weight < 0: set_point_solid(cell, true)
			else: set_point_weight_scale(cell, weight)

	# minimal logging for performance / will have crashed by now if any problems
	var duration: int = Time.get_ticks_msec() - start
	Debug.log_debug("A* weights: %dms" % duration)
