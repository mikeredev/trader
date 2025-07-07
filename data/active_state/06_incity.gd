class_name InCityState extends ActiveState

var city: City
var scene: CityScene
var camera: Camera
var base_size: Vector2i


func _init(p_city_id: StringName) -> void:
	state_id = "InCity"
	city = Service.city_manager.get_city(p_city_id)


func _connect_signals() -> void:
	EventBus.viewport_resized.connect(_on_viewport_resized)


func _main() -> void:
	Debug.log_info("Building city scene: %s (%d)" % [city.city_id, city.uid])
	build_scene()

	Debug.log_info("Configuring view...")
	configure_view()


func build_scene() -> void:
	# add city scene
	scene = Service.scene_manager.add_to_view(
		FileLocation.IN_CITY_SCENE, View.ViewType.CITY, View.ContainerType.SCENE )
	scene.name = city.city_id

	# build city scene
	var builder: CityBuilder = CityBuilder.new(city, scene)
	builder.build()


func configure_view() -> void:
	var view: View = Service.scene_manager.activate_view(View.ViewType.CITY)
	base_size = ProjectSettings.get_setting("services/config/scene_base_size")
	camera = view.get_camera()
	camera.set_limits(scene.tile_grid.area)
	camera.cam_control = true # TESTING


func _on_viewport_resized(p_viewport_size: Vector2) -> void:
	camera.set_min_zoom(p_viewport_size, base_size)


#func _exit() -> void:
	#var ui: UI = Service.scene_manager.get_ui()
	#ui.clear_container(UI.ContainerType.MENU)
