class_name InCityState extends ActiveState

var city_id: StringName
var view: View = Service.scene_manager.get_view(View.ViewType.CITY)


func _init(p_city_id: StringName) -> void:
	state_id = "InCity"
	city_id = p_city_id


func _main() -> void:
	Debug.log_info("In city: %s" % city_id)

	# activate viewport
	Service.scene_manager.activate_view(View.ViewType.CITY)

	# add city scene
	var scene: CityScene = Service.scene_manager.add_to_view(
		FileLocation.IN_CITY_SCENE,
		View.ViewType.CITY,
		View.ContainerType.SCENE )
	scene.name = city_id

	# build logical city model
	var city: City = Service.city_manager.get_city(city_id)
	var builder: CityBuilder = CityBuilder.new(city, scene)
	#builder.tile_grid_created.connect(_bind_camera)
	builder.build()

	# inject city model into city scene

	# test stuff
	view.get_camera().cam_control = true

#func build_city() -> void:
	#var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	#rng.seed = scene.city.uid
#
	#var builder: CityBuilder = CityBuilder.new(scene, rng)
	#builder.tile_grid_created.connect(_bind_camera)


func _start_services() -> void:
	pass #System.start_service(SessionManager.new(), Service.ServiceType.SESSION_MANAGER)


#func _exit() -> void:
	#var ui: UI = Service.scene_manager.get_ui()
	#ui.clear_container(UI.ContainerType.MENU)

#func _bind_camera(p_grid_size: Vector2i) -> void:
	#view.get_camera().set_limits(Vector2i(p_grid_size.x, p_grid_size.y))
	#print("pol?dfgdfg")
