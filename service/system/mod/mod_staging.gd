class_name ModStaging extends RefCounted

var world_data: Dictionary[String, Dictionary] = {}
var country_data: Dictionary[String, Dictionary] = {}
var city_data: Dictionary[String, Dictionary] = {}
var trade_data: Dictionary[String, Dictionary] = {}

var cache: Dictionary[String, Dictionary] = {
	"manifest": {},
	"datastore": {},
	"country": {
		"country_id": {}
	},
	"city": {
		"city_id": {}
	},
	"trade": {
		"market_id": {},
		"category_id": {},
		"resource_id": {},
	},
}

func get_cached(p_cache: String, p_key: String) -> Dictionary:
	return cache[p_cache].get(p_key, {})


func merge(p_data: Dictionary[String, Dictionary], p_with: Dictionary) -> void:
	p_data.merge(p_with, true)
