class_name ImageUtil extends RefCounted


func get_texture(p_path: String) -> Texture2D: # test this with valid path but invalid image eg map.txt
	var texture: Texture2D

	if p_path.begins_with("res://") or p_path.begins_with("uid://"):
		texture = load(p_path) as Texture2D

	if p_path.begins_with("user://"):
		var image: Image = Image.new()
		image.load(p_path)
		texture = ImageTexture.create_from_image(image) as Texture2D
	return texture
