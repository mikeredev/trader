class_name CityOptionsPanel extends PanelContainer

@onready var ui_source_city: OptionButton = %SourceCity
@onready var ui_dest_city: OptionButton = %DestCity
@onready var ui_teleport: Button = %Teleport


func setup() -> void:
	EventBus.game_started.connect(populate)
	ui_teleport.pressed.connect(_on_ui_teleport_pressed)
	ui_teleport.text = Glyph.PLANE


func populate() -> void:
	for city: City in App.context.city.get_cities():
		for button: OptionButton in [ui_source_city, ui_dest_city]:
			button.add_item(city.city_id)


func _on_ui_teleport_pressed() -> void:
	if ui_dest_city.get_selected_id() > 0:
		var city_id: StringName = ui_dest_city.get_item_text(ui_dest_city.selected)
		Debug.log_info("Teleporting to: %s" % city_id)
		System.state.change(InCityState.new(city_id))
