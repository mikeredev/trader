class_name Common extends RefCounted

const PROJECT_SETTINGS: Dictionary[String, Variant] = {
	"services/config/scene_base_size": Vector2i(640, 360), # tilemaps are designed around this base size
	"services/config/max_autosaves": 10, # user-configured autosaves cannot exceed this value
	"services/city/max_production": 1000, # city economy/industry maximum value
	"service/city/default_buildings": [ "B_MARKET" ], # an array of default building ids created in every city
	"services/trade/max_price": 65536, # an individual trade resource's maximum buy or sell price
	"services/trade/max_monthly_investment": 50000, # a city cannot received more than this per month in investments
}

class Util:
	static var json: JSONUtil = JSONUtil.new()

	static func get_texture(p_path: String) -> Texture2D:
		var texture: Texture2D

		if p_path.begins_with("res://") or p_path.begins_with("uid://"):
			texture = load(p_path) as Texture2D

		if p_path.begins_with("user://"):
			var image: Image = Image.new()
			image.load(p_path)
			texture = ImageTexture.create_from_image(image) as Texture2D
		return texture


	static func create_tween(p_object: Object, p_property: NodePath, p_final: Variant,
		p_duration: float, p_trans: Tween.TransitionType = Tween.TRANS_LINEAR,
		p_ease: Tween.EaseType = Tween.EASE_IN) -> Tween:

			var tween: Tween = AppContext.create_tween() # needs any node reference
			tween.tween_property(p_object, p_property, p_final, p_duration) \
			.set_trans(p_trans) \
			.set_ease(p_ease)
			return tween


	static func pause(p_paused: bool) -> void:
		Debug.log_debug("Paused: %s" % p_paused)
		AppContext.get_tree().paused = p_paused


	static func quit() -> void:
		Debug.log_info("Goodbye.")
		AppContext.get_tree().quit()


	static func touch_directory(p_path: String) -> bool:
		if not DirAccess.dir_exists_absolute(p_path):
			var error: Error = DirAccess.make_dir_absolute(p_path)
			if error: return false
		return true
