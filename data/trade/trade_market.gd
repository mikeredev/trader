class_name TradeMarket extends RefCounted

var market_id: StringName
var buy_price: Dictionary[StringName, int]
var sell_price: Dictionary[StringName, Dictionary] # contains price and required econ
