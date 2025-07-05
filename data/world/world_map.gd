class_name WorldMap extends Sprite2D


func _init(p_path: String) -> void:
	name = "WorldMap"

	# load project or user-provided texture
	if p_path.begins_with("res://") or p_path.begins_with("uid://"):
		texture = load(p_path) as Texture2D
	else:
		var image: Image = Image.new()
		image.load(p_path)
		texture = ImageTexture.create_from_image(image) as Texture2D

	# center map
	position = texture.get_size() / 2.0

	Debug.log_debug("Created map: %s" % Vector2i(texture.get_size()))
