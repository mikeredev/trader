class_name TradeBlueprint extends RefCounted

var datastore: Dictionary[StringName, Dictionary]


static func from_dict(p_data: Dictionary[String, Dictionary]) -> TradeBlueprint:
	var data: Dictionary[StringName, Dictionary]

	for resource_id: StringName in p_data.keys():
		data[resource_id] = {}

		for property: String in p_data[resource_id]:
			match property:
				"category":
					var category_id: StringName = p_data[resource_id]["category"]
					data[resource_id]["category"] = category_id

				"buy_price":
					var buy_price: Dictionary[StringName, int] = {}
					var price_data: Dictionary = p_data[resource_id]["buy_price"]
					for market_id: StringName in price_data.keys():
						if not buy_price.has(market_id):
							var price: int = price_data[market_id]
							buy_price[market_id] = price
					data[resource_id]["buy_price"] = buy_price

				"sell_price":
					var sell_price: Dictionary[StringName, Dictionary] = {}
					var price_data: Dictionary = p_data[resource_id]["sell_price"]
					for market_id: StringName in price_data.keys():
						var price: int = price_data[market_id]["price"]
						var required: int = price_data[market_id]["required"]
						sell_price[market_id] = {
							"price": price,
							"required": required,
						}
					data[resource_id]["sell_price"] = sell_price

				"owner":
					var owner: StringName = p_data[resource_id]["owner"]
					data[resource_id]["owner"] = owner

	var out: TradeBlueprint = TradeBlueprint.new()
	out.datastore = data
	return out
