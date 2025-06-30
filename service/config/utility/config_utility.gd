class_name ConfigUtility extends RefCounted


func apply_config() -> void:
	pass


func to_dict() -> Dictionary[String, Variant]:
	return {}


func to_grid() -> GridContainer:
	return null


#func restore_config() -> void:
	#pass


## Returns a new instance hydrated with [code]p_dict[/code].
## Will use default values if any expected values are not found.
static func from_dict(_p_dict: Dictionary[String, Variant]) -> Variant:
	return null


func populate_dropdown(p_property: Variant, p_type: Variant.Type, p_menu: OptionButton, p_dict: Dictionary) -> Error:
	var error: Error = ERR_DOES_NOT_EXIST # allows follow-up if a running value is not matched

	for i: int in range(p_dict.size()):
		var option_name: String = p_dict.keys()[i]
		var option_metadata: Variant

		match p_type:
			TYPE_INT:
				var metadata: int = i
				option_metadata = metadata

			TYPE_VECTOR2I:
				var metadata: Vector2i = p_dict.get(option_name)
				option_metadata = metadata

		p_menu.add_item(tr(option_name), i)
		p_menu.set_item_metadata(i, option_metadata)

		if option_metadata == p_property:
			p_menu.select(i)
			error = OK

	return error
