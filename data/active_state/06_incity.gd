class_name InCityState extends ActiveState

var city: City
var scene: CityScene
var view: View
var base_size: Vector2i


func _init(p_city_id: StringName) -> void:
	state_id = "InCity"
	city = App.context.city.get_city(p_city_id)
	view = System.manage.scene.get_view(View.ViewType.CITY)
	base_size = ProjectSettings.get_setting("services/config/scene_base_size")


func _connect_signals() -> void:
	EventBus.viewport_resized.connect(_on_viewport_resized)


func _main() -> void:
	build_scene()
	add_player()
	configure_view()
	EventBus.city_entered.emit(city) # broadcast update


func _exit() -> void:
	view.clear_view()


func build_scene() -> void:
	Debug.log_info("Building city scene: %s (%d)" % [city.city_id, city.uid])
	scene = System.manage.scene.create_scene(FileLocation.IN_CITY_SCENE)
	scene.name = city.city_id
	view.add_scene(scene, View.ContainerType.SCENE)

	# build city scene
	var builder: CityBuilder = CityBuilder.new(city, scene)
	builder.build()


func add_player() -> void:
	Debug.log_info("Adding player body...")
	var player: Character = App.context.character.get_player()
	player.body.reparent(scene.sprite_group)

	# start outside dock
	var dock: Dock = city.buildings.get("B_DOCK")
	var access_point: Vector2i = scene.access_points.get(dock)
	var modifider: int = ProjectSettings.get_setting("services/config/default_tile_size")
	player.body.position.x = (access_point.x + 0.5) * modifider # centered on door tile
	player.body.position.y = (access_point.y + 1) * modifider # slightly below

	# camera follow
	view.camera.follow(player.body)


func configure_view() -> void:
	Debug.log_info("Configuring view...")
	view = System.manage.scene.activate_view(View.ViewType.CITY)
	view.camera.update_limits(scene.tile_grid.area)


func _on_viewport_resized(p_viewport_size: Vector2) -> void:
	view.camera.set_min_zoom(p_viewport_size, base_size)
