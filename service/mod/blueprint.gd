class_name Blueprint extends RefCounted

#var player: Player
var city: CityBlueprint
var country: CountryBlueprint
var trade: TradeBlueprint
var world: WorldBlueprint


func _init(p_world: Dictionary[String, Dictionary],
	p_country: Dictionary[String, Dictionary],
	p_city: Dictionary[String, Dictionary],
	p_trade: Dictionary[String, Dictionary]) -> void:

	world = WorldBlueprint.from_dict(p_world)
	country = CountryBlueprint.from_dict(p_country)
	city = CityBlueprint.from_dict(p_city)
	trade = TradeBlueprint.from_dict(p_trade)
