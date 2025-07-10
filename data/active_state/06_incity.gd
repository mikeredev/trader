class_name InCityState extends ActiveState

var city: City
var scene: CityScene
var view: View
var _base_size: Vector2i


func _init(p_city_id: StringName) -> void:
	state_id = "InCity"
	city = System.service.city_manager.get_city(p_city_id)
	view = System.service.scene_manager.get_view(View.ViewType.CITY)
	_base_size = ProjectSettings.get_setting("services/config/scene_base_size")


func _connect_signals() -> void:
	EventBus.viewport_resized.connect(_on_viewport_resized)


func _main() -> void:
	Debug.log_info("Building city scene: %s (%d)" % [city.city_id, city.uid])
	build_scene()

	Debug.log_info("Configuring view...")
	configure_view()

	EventBus.city_entered.emit(city) # broadcast update


func _exit() -> void:
	view.clear_view()


func build_scene() -> void:
	# create InCity scene
	scene = System.service.scene_manager.create_scene(FileLocation.IN_CITY_SCENE)
	scene.name = city.city_id
	view.add_scene(scene, View.ContainerType.SCENE)

	# build city scene
	var builder: CityBuilder = CityBuilder.new(city, scene)
	builder.build()


func configure_view() -> void:
	view = System.service.scene_manager.activate_view(View.ViewType.CITY)
	view.camera.update_limits(scene.tile_grid.area)


func _on_viewport_resized(p_viewport_size: Vector2) -> void:
	view.camera.set_min_zoom(p_viewport_size, _base_size)
