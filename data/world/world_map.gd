class_name WorldMap extends Sprite2D


func _init(p_path: String) -> void:
	name = "WorldMap"
	texture = Common.Util.image.get_texture(p_path)
	position = texture.get_size() / 2.0
	Debug.log_debug("Created world map: %s" % [texture.get_size()])
