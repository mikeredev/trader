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
						var economy: int = price_data[market_id]["economy"]
						sell_price[market_id] = {
							"price": price,
							"economy": economy,
						}
					data[resource_id]["sell_price"] = sell_price

				"owner":
					var owner: StringName = trade_data["owner"]
					data[resource_id]["owner"] = owner

				_: Debug.log_warning("Ignoring unrecognized key: %s" % property)

	var out: TradeBlueprint = TradeBlueprint.new()
	out.datastore = data
	return out
