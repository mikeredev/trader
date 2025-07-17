class_name CityBlueprint extends RefCounted

var datastore: Dictionary[StringName, Dictionary]


static func from_dict(p_data: Dictionary[String, Dictionary]) -> CityBlueprint:
	var data: Dictionary[StringName, Dictionary] = {}

	for city_id: StringName in p_data.keys():
		var city_data: Dictionary = p_data[city_id]

		if city_data.get("remove", false):
			Debug.log_verbose("  Ignoring city marked for removal: %s" % [city_id])
			continue

		data[city_id] = {}
		for property: String in p_data[city_id].keys():
			match property:
				"position":
					var x: int = p_data[city_id]["position"][0]
					var y: int = p_data[city_id]["position"][1]
					var position: Vector2i = Vector2i(x, y)
					data[city_id]["position"] = position

				"buildings":
					var buildings: Array = p_data[city_id]["buildings"]
					data[city_id]["buildings"] = buildings

				"production":
					var economy: int = p_data[city_id]["production"]["economy"]
					var industry: int = p_data[city_id]["production"]["industry"]
					var production: Dictionary[String, int] = {
						"economy": economy,
						"industry": industry }
					data[city_id]["production"] = production

				"support":
					var support: Dictionary[StringName, float] = {}
					var _data: Dictionary = p_data[city_id]["support"]
					for country_id: StringName in _data.keys():
						var _value: float = _data[country_id]
						support[country_id] = snappedf(_value, 0.1)
					data[city_id]["support"] = support

				"trade":
					var market_id: StringName = p_data[city_id]["trade"]["market"]
					var specialty_id: StringName = p_data[city_id]["trade"]["specialty"]["resource"]
					var specialty_price: int = p_data[city_id]["trade"]["specialty"]["price"]
					var specialty_required: int = p_data[city_id]["trade"]["specialty"]["required"]
					var trade: Dictionary[String, Variant] = {
						"market": market_id,
						"specialty": {
							"resource": specialty_id,
							"price": specialty_price,
							"required": specialty_required,
						},
					}
					data[city_id]["trade"] = trade

				"owner":
					var owner: StringName = p_data[city_id]["owner"]
					data[city_id][property] = owner

				_: Debug.log_warning("Ignoring unrecognized key: %s" % property)

	var out: CityBlueprint = CityBlueprint.new()
	out.datastore = data
	return out


static func validate(p_data: Dictionary, p_cache: Dictionary) -> bool:
	for city_id: String in p_data.keys():
		var city_data: Dictionary = p_data[city_id]

		if city_data.has("remove"):
			Debug.log_verbose("  Skipping validation due to pending removal: %s" % [city_id])
			continue

		var cache: Dictionary = {}
		var support: Dictionary = city_data.get("support", {}) # optional, city can start neutral

		# validate all referenced countries in support dict
		for country_id: String in support.keys():
			cache = p_cache["country"]["country_id"]
			if not cache.has(country_id):
				Debug.log_warning("Unable to find supporting country: %s (%s)" % [country_id, city_id])
				return false

		# validate city assigned market_id
		var market_id: String = city_data["trade"]["market"]
		cache = p_cache["trade"]["market_id"]
		if not cache.has(market_id):
			Debug.log_warning("Unable to find assigned market: %s (%s)" % [market_id, city_id])
			return false

		# validate assigned trade specialty
		var specialty_id: String = city_data["trade"]["specialty"]["resource"]
		cache = p_cache["trade"]["resource_id"]
		if not cache.has(specialty_id):
			Debug.log_warning("Unable to find specialty resource: %s (%s)" % [specialty_id, city_id])
			return false
	return true


func build() -> void:
	for city_id: StringName in datastore.keys():
		var metadata: Dictionary = datastore[city_id]
		_create_city(city_id, metadata)
	Debug.log_debug("Created %d cities" % datastore.size())


func _create_city(p_city_id: StringName, p_metadata: Dictionary) -> void:
	var city: City = City.new()
	city.city_id = p_city_id
	city.uid = city.city_id.hash()

	var position: Vector2i = p_metadata["position"]
	_set_position(city, position)

	# buildings
	var default: PackedStringArray = ProjectSettings.get_setting("services/city/default_buildings")
	for building_id: StringName in default:
		_create_building(city, building_id)

	# production
	var economy: int = p_metadata["production"]["economy"]
	var industry: int = p_metadata["production"]["industry"]
	_set_production(city, economy, industry)

	# support
	var support: Dictionary = p_metadata.get("support", {}) # optional
	_set_support(city, support)

	# trade
	var market: Market = city.buildings["B_MARKET"] # created with default buildings
	var trade: Dictionary = p_metadata["trade"]
	_set_trade(city, market, trade)

	# body
	var body: CityBody = _create_body(city.city_id, city.position)
	_set_body(city, body)

	# astar
	if System.manage.config.developer_settings.enable_astar:
		_set_astar(city)

	# register for lookup
	App.context.city.register_city(city)

	# done
	Debug.log_verbose("  Created city: %s |  %s |   %s |   %s |   %s" % [
		city.city_id, city.position, Vector2i(city.economy, city.industry),
		App.context.city.get_support_normalized(city), market.specialty.get("resource_id")])


func _create_body(p_city_id: StringName, p_position: Vector2i, p_color: Color = Color.AQUA) -> CityBody:
	var body: CityBody = CityBody.new()

	body.city_id = p_city_id
	body.name = tr(p_city_id)
	body.position = p_position
	body.color = p_color

	# create sprite
	body.sprite = Sprite2D.new()
	body.sprite.texture = load(FileLocation.DEFAULT_MOD_ICON) # citybody ico
	body.sprite.scale = Vector2(0.0625, 0.0625) # resolves to 1px size from a 16px tile
	body.sprite.name = "Sprite2D"
	body.add_child(body.sprite)

	#var interaction: CollisionArea = CollisionArea.new(25, color, 0.1)
	#interaction.collision_layer = Common.CollisionLayer.INTERACTION
	#interaction.collision_mask = 0
	#interaction.monitoring = false
	#interaction.monitorable = true
	#interaction.name = "Interaction"
	#sprite.add_child(interaction)
#
	#var detection: CollisionArea = CollisionArea.new(100, color, 0.1)
	#detection.collision_layer = Common.CollisionLayer.DETECTION
	#detection.collision_mask = 0
	#detection.monitoring = false
	#detection.monitorable = true
	#detection.name = "Detection"
	#sprite.add_child(detection)
	return body


func _create_building(p_city: City, p_building_id: StringName) -> void:
	var building: Building
	match p_building_id:
		"B_DOCK":
			var dock: Dock = load("uid://yk14qod6i0yw") as Dock
			building = dock
		"B_MARKET":
			var market: Market = load("uid://3rr25xenmydt") as Market
			building = market

	building.building_id = p_building_id
	building.city_id = p_city.city_id
	p_city.buildings[p_building_id] = building


func _set_astar(p_city: City) -> void:
	var grid: WorldGrid = App.context.world.get_grid()

	# get neighbour cells
	var scale: int = 1
	for x: int in range(-scale, scale + 1):
		for y: int in range(-scale, scale + 1):
			if x == 0 and y == 0: continue  # skip centre
			var direction: Vector2i = Vector2i(x, y)
			p_city.body.neighbors[direction] = p_city.position + direction

	# get neighbour water cells
	for direction: Vector2i in p_city.body.neighbors.keys():
		var cell: Vector2i = p_city.body.neighbors[direction]
		if not grid.is_point_solid(cell):
			p_city.body.water_direction.append(direction)

	# set city as A* walkable
	grid.set_point_solid(p_city.position, false)

	if p_city.body.water_direction.is_empty():
		Debug.log_warning("City is landlocked: %s" % p_city.city_id)


func _set_body(p_city: City, p_body: CityBody) -> void:
	var view: View = System.manage.scene.get_view(View.ViewType.OVERWORLD)
	view.add_scene(p_body, View.ContainerType.CITY)
	p_city.body = p_body


func _set_position(p_city: City, p_pos: Vector2i) -> void:
	var map_size: Vector2i = App.context.world.get_map_size()
	var pos_x: int = clampi(p_pos.x, 0, map_size.x)
	var pos_y: int = clampi(p_pos.y, 0, map_size.y)
	p_city.position = Vector2i(pos_x, pos_y)


func _set_production(p_city: City, p_economy: int, p_industry: int) -> void:
	var ceiling: int = ProjectSettings.get_setting("services/city/max_production")
	p_city.economy = clampi(p_economy, 0, ceiling)
	p_city.industry = clampi(p_industry, 0, ceiling)


func _set_support(p_city: City, p_support: Dictionary) -> void:
	var support: Dictionary[StringName, float] = {}
	for country_id: StringName in p_support.keys():
		var value: float = p_support[country_id]
		support[country_id] = snappedf(value, 0.1)
	p_city.support = support


func _set_trade(p_city: City, p_market: Market, p_specialty: Dictionary) -> void:
	var market_id: StringName = p_specialty["market"]
	p_market.market_id = market_id

	# update specialty if not removed by mods
	var resource_id: StringName = p_specialty["specialty"]["resource"]

	if App.context.trade.get_resource(resource_id): # creates dependency on TradeManager
		var price: int = p_specialty["specialty"]["price"]
		var required: int = p_specialty["specialty"]["required"]
		p_market.specialty["resource_id"] = resource_id
		p_market.specialty["price"] = price
		p_market.specialty["required"] = required

	else: Debug.log_warning("Unable to add specialty: %s (%s)" % [resource_id, p_city.city_id])

	# add market to city
	p_city.buildings[p_market.building_id] = p_market
