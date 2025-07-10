class_name TradeManager extends Service

var category_datastore: Dictionary[StringName, TradeCategory] = {}
var resource_datastore: Dictionary[StringName, TradeResource] = {}
var market_datastore: Dictionary[StringName, TradeMarket] = {}


func get_category(p_category_id: StringName) -> TradeCategory:
	return category_datastore.get(p_category_id, null)


func get_market(p_market_id: StringName) -> TradeMarket:
	return market_datastore.get(p_market_id, null)


func get_resource(p_resource_id: StringName) -> TradeResource:
	return resource_datastore.get(p_resource_id, null)
