class_name Market extends Building

var market_id: StringName
var specialty: Dictionary[String, Variant] = {
	"resource_id": "N/A",
	"price": 0,
	"required": 0 }

#var investment: int
#var general_index: int
	##get(): return city_manager.get_general_index(self)
#var price_index: Dictionary[StringName, int] = {}
