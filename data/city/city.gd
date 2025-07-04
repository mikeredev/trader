class_name City extends RefCounted

var city_id: StringName
var uid: int
var position: Vector2i

var economy: int
var industry: int

var support: Dictionary[StringName, float] = {}

var market_id: StringName
var trade_specialty: Dictionary[String, Variant] = {
	"resource_id": "",
	"price": 0,
	"required": 0,
}

var market: Market

#var body: CityBody # overworld
#var buildings: Array[Building]
