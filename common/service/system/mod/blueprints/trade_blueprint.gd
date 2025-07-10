class_name TradeBlueprint extends RefCounted

var datastore: Dictionary[StringName, Dictionary]


static func from_dict(p_data: Dictionary[String, Dictionary]) -> TradeBlueprint:
	var data: Dictionary[StringName, Dictionary] = {}

	for resource_id: StringName in p_data.keys():
		var trade_data: Dictionary = p_data[resource_id]

		if trade_data.get("remove", false):
			Debug.log_verbose("  Ignoring trade resource marked for removal: %s" % resource_id)
			continue

		data[resource_id] = {}
		for property: String in trade_data.keys():
			match property:
				"category":
					var category_id: StringName = trade_data["category"]
					data[resource_id]["category"] = category_id

				"buy_price":
					var buy_price: Dictionary[StringName, int] = {}
					var price_data: Dictionary = trade_data["buy_price"]
					for market_id: StringName in price_data.keys():
						if not buy_price.has(market_id):
							var price: int = price_data[market_id]
							buy_price[market_id] = price
					data[resource_id]["buy_price"] = buy_price

				"sell_price":
					var sell_price: Dictionary[StringName, Dictionary] = {}
					var price_data: Dictionary = trade_data["sell_price"]
					for market_id: StringName in price_data.keys():
						var price: int = price_data[market_id]["price"]
						var required: int = price_data[market_id]["required"]
						sell_price[market_id] = {
							"price": price,
							"required": required,
						}
					data[resource_id]["sell_price"] = sell_price

				"owner":
					var owner: StringName = trade_data["owner"]
					data[resource_id]["owner"] = owner

				_: Debug.log_warning("Ignoring unrecognized key: %s" % property)

	var out: TradeBlueprint = TradeBlueprint.new()
	out.datastore = data
	return out


func build() -> void:
	for resource_id: StringName in datastore.keys():
		var metadata: Dictionary = datastore[resource_id]
		_create_resource(resource_id, metadata)

	Debug.log_debug("Created: %d categories, %d markets, %d resources" % [
		App.context.trade.category_datastore.size(),
		App.context.trade.market_datastore.size(),
		App.context.trade.resource_datastore.size() ])


static func validate(_p_data: Dictionary, _p_cache: Dictionary) -> bool:
	return true # specialties and market_id checked in CityBlueprint:validate()


func _create_resource(resource_id: StringName, p_metadata: Dictionary) -> void:
	var resource: TradeResource = TradeResource.new()
	resource.resource_id = resource_id

	_configure_category(resource, p_metadata)
	_configure_buy_price(resource, p_metadata)
	_configure_sell_price(resource, p_metadata)

	# register for lookup
	App.context.trade.resource_datastore[resource_id] = resource
	Debug.log_verbose("󰈺  Created resource: %s (%s)" % [resource.resource_id, resource.category_id])


func _configure_category(p_resource: TradeResource, p_metadata: Dictionary) -> void:
	var category_id: StringName = p_metadata.get("category")

	# lazy initialise category
	var category: TradeCategory = _get_or_create_category(category_id)

	# update resource with category
	p_resource.category_id = category_id

	# update category with resource
	category.resources[p_resource.resource_id] = p_resource



func _configure_buy_price(p_resource: TradeResource, p_metadata: Dictionary) -> void:
	var buy_price: Dictionary = p_metadata.get("buy_price")
	for market_id: StringName in buy_price.keys():

		# lazy initialise market
		var market: TradeMarket = _get_or_create_market(market_id)

		# update market with resource buy price
		var price: int = buy_price.get(market_id)
		var price_ceiling: int = ProjectSettings.get_setting("services/trade/max_price")
		market.buy_price[p_resource.resource_id] = clampi(price, 0, price_ceiling)


func _configure_sell_price(p_resource: TradeResource, p_metadata: Dictionary) -> void:
	var sell_price: Dictionary = p_metadata.get("sell_price")
	for market_id: StringName in sell_price.keys():
		var market: TradeMarket = _get_or_create_market(market_id)

		# create sell_price[resource_id] if not existing
		if not market.sell_price.has(p_resource.resource_id):
			market.sell_price[p_resource.resource_id] = {}

		# update market sell price with resource price and required economy level
		var price: int = sell_price[market_id]["price"]
		var price_ceiling: int = ProjectSettings.get_setting("services/trade/max_price")
		var required: int = sell_price[market_id]["required"]
		var production_ceiling: int = ProjectSettings.get_setting("services/city/max_production")
		market.sell_price[p_resource.resource_id]["price"] = clampi(price, 0, price_ceiling)
		market.sell_price[p_resource.resource_id]["required"] = clampi(required, 0, production_ceiling)

		# update resource with markets it is sold in
		p_resource.markets[market_id] = market



func _get_or_create_market(p_market_id: StringName) -> TradeMarket:
	var market: TradeMarket
	if App.context.trade.get_market(p_market_id):
		market = App.context.trade.get_market(p_market_id)
	else:
		# create object
		market = TradeMarket.new()
		market.market_id = p_market_id

		# register for lookup
		App.context.trade.market_datastore[p_market_id] = market
		Debug.log_verbose("󰓜  Created market: %s" % [market.market_id])
	return market


func _get_or_create_category(p_category_id: StringName) -> TradeCategory: # lazy initialize category if needed
	var category: TradeCategory
	if App.context.trade.get_category(p_category_id):
		category = App.context.trade.get_category(p_category_id)
	else:
		# create object
		category = TradeCategory.new()
		category.category_id = p_category_id

		# register for lookup
		App.context.trade.category_datastore[p_category_id] = category
		Debug.log_verbose("  Created category: %s" % [category.category_id])
	return category
