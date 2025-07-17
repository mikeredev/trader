class_name ControlSettings extends ConfigUtility

var key_map: Dictionary[StringName, String] = {
	"interact": "E",
	"move_up": "W",
	"move_left": "A",
	"move_down": "S",
	"move_right": "D",
}

func apply_config() -> void:
	Debug.log_info("Applying control settings...")
	create_mappings(key_map)


func to_dict() -> Dictionary[String, String]:
	var out: Dictionary[String, String] = {}
	for action: String in key_map.keys():
		out[action] = key_map[action]
	return out


func to_grid() -> GridContainer:
	var grid: GridContainer = GridContainer.new()
	grid.name = "ControlSettings"
	grid.columns = 2

	for action: StringName in key_map.keys():
		var label_name: Label = Label.new()
		var ui_key: Button = Button.new()

		label_name.text = tr(action)
		ui_key.text = str(key_map[action])

		label_name.name = "%s%s" % ["Label", label_name.text.to_pascal_case()]
		ui_key.name = "%s%s" % ["Option", label_name.text.to_pascal_case()]
		grid.add_child(label_name)
		grid.add_child(ui_key)
#
	return grid


static func from_dict(p_dict: Dictionary) -> ControlSettings:
	var out: ControlSettings = ControlSettings.new()
	out.key_map["interact"] = p_dict.get("interact", out.key_map["interact"])
	out.key_map["move_up"] = p_dict.get("move_up", out.key_map["move_up"])
	out.key_map["move_left"] = p_dict.get("move_left", out.key_map["move_left"])
	out.key_map["move_down"] = p_dict.get("move_down", out.key_map["move_down"])
	out.key_map["move_right"] = p_dict.get("move_right", out.key_map["move_right"])
	return out


func create_mappings(p_key_map: Dictionary[StringName, String]) -> void:
	for action: StringName in p_key_map.keys():
		var key: String = p_key_map.get(action)
		set_key_binding(action, key)


func set_key_binding(p_action: StringName, p_event: String) -> void:
	var event: InputEventKey = InputEventKey.new()
	var new_key: Key = OS.find_keycode_from_string(p_event)
	event.keycode = new_key
	if not InputMap.has_action(p_action):
		InputMap.add_action(p_action)
		InputMap.action_add_event(p_action, event)
		Debug.log_debug("set action %s: %s" % [p_action, event.as_text()])
