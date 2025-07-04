class_name TradeManager extends Service

var _category_datastore: Dictionary[StringName, TradeCategory] = {}
var _resource_datastore: Dictionary[StringName, TradeResource] = {}
var _market_datastore: Dictionary[StringName, TradeMarket] = {}


func create_resource(resource_id: StringName, p_metadata: Dictionary) -> void:
	var resource: TradeResource = TradeResource.new()
	resource.resource_id = resource_id

	_configure_category(resource, p_metadata)
	_configure_buy_price(resource, p_metadata)
	_configure_sell_price(resource, p_metadata)

	# register for lookup
	_resource_datastore[resource_id] = resource
	Debug.log_verbose("󰈺  Created resource: %s (%s)" % [resource.resource_id, resource.category_id])


func get_category(p_category_id: StringName) -> TradeCategory:
	return _category_datastore.get(p_category_id, null)


func get_market(p_market_id: StringName) -> TradeMarket:
	return _market_datastore.get(p_market_id, null)


func get_resource(p_resource_id: StringName) -> TradeResource:
	return _resource_datastore.get(p_resource_id, null)


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
	if _market_datastore.has(p_market_id):
		market = get_market(p_market_id)
	else:
		# create object
		market = TradeMarket.new()
		market.market_id = p_market_id

		# register for lookup
		_market_datastore[p_market_id] = market
		Debug.log_verbose("󰓜  Created market: %s" % [market.market_id])
	return market


func _get_or_create_category(p_category_id: StringName) -> TradeCategory: # lazy initialize category if needed
	var category: TradeCategory
	if _category_datastore.has(p_category_id):
		category = get_category(p_category_id)
	else:
		# create object
		category = TradeCategory.new()
		category.category_id = p_category_id

		# register for lookup
		_category_datastore[p_category_id] = category
		Debug.log_verbose("  Created category: %s" % [category.category_id])
	return category
