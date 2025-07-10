class_name ModStaging extends RefCounted

var world_data: Dictionary[String, Dictionary] = {}
var country_data: Dictionary[String, Dictionary] = {}
var city_data: Dictionary[String, Dictionary] = {}
var trade_data: Dictionary[String, Dictionary] = {}

var cache: Dictionary[String, Dictionary] = {
	"manifest": {}, # WorldBlueprint
	"datastore": {}, # used during mod staging
	"country": {
		"country_id": {} # CityBlueprint
	},
	"city": {
		"city_id": {} # CountryBlueprint
	},
	"trade": {
		"market_id": {}, # CityBlueprint
		"resource_id": {}, # CityBlueprint
	},
}


func get_cached(p_cache: String, p_key: String) -> Dictionary:
	return cache[p_cache].get(p_key, {})


func merge(p_data: Dictionary[String, Dictionary], p_with: Dictionary) -> void:
	p_data.merge(p_with, true)
