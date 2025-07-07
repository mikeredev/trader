class_name Common extends RefCounted

const PROJECT_SETTINGS: Dictionary[String, Variant] = {
	"services/config/scene_base_size": Vector2i(640, 360), # tilemaps are designed around this base size
	"services/config/max_autosaves": 10, # user-configured autosaves cannot exceed this value
	"services/config/default_tile_size": 16, # all tiles are 16px
	"services/city/max_production": 1000, # city economy/industry maximum value
	"services/city/default_buildings": [ "B_DOCK", "B_MARKET"],#, "B_INN", "B_SHIPYARD", "B_MARKET" ], # an array of default building ids created in every city
	"services/trade/max_price": 65536, # an individual trade resource's maximum buy or sell price
	"services/trade/max_monthly_investment": 50000, # a city cannot received more than this per month in investments
}


class Util:
	static var json: JSONUtil = JSONUtil.new()
	static var image: ImageUtil = ImageUtil.new()
	static var file: FileUtil = FileUtil.new()
