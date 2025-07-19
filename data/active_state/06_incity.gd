class_name InCityState extends ActiveState

var city: City
var scene: CityScene
var view: View
var base_size: Vector2i
var tile_size: int


func _init(p_city_id: StringName) -> void:
	state_id = "InCity"
	city = App.context.city.get_city(p_city_id)
	view = System.manage.scene.get_view(View.ViewType.CITY)
	base_size = ProjectSettings.get_setting("services/config/scene_base_size")
	tile_size = ProjectSettings.get_setting("services/config/default_tile_size")

func _connect_signals() -> void:
	EventBus.viewport_resized.connect(_on_viewport_resized)
	EventBus.building_exited.connect(_on_building_exited)


func _main() -> void:
	# generate city scene
	build_scene()

	# drop player outside dock
	var player: Character = App.context.character.get_player()
	var dock: Dock = city.buildings.get("B_DOCK")
	add_character_at(dock, player.body)

	# configure camer and activate view
	configure_view()

	# broadcast update
	EventBus.city_entered.emit(city)


func _exit() -> void:
	view.clear_view()

	# clear any sublocation interior scenes
	var interior: View = System.manage.scene.get_view(View.ViewType.INTERIOR)
	interior.clear_view()


func build_scene() -> void:
	Debug.log_info("Building city scene: %s (%d)" % [city.city_id, city.uid])
	scene = System.manage.scene.create_scene(FileLocation.IN_CITY_SCENE)
	scene.name = city.city_id
	view.add_scene(scene, View.ContainerType.SCENE)

	# build city scene
	var builder: CityBuilder = CityBuilder.new(city, scene)
	builder.build()


func add_character_at(p_building: Building, p_body: CharacterBody) -> void:
	# body should exist in cache or other scene at this point
	Debug.log_info("Adding %s at %s %s..." % [p_body.profile_id, city.city_id, p_building.building_id])
	p_body.reparent(scene.sprite_group)

	# start outside p_building
	var access_point: Vector2i = scene.access_points.get(p_building)
	p_body.position.x = (access_point.x + 0.5) * tile_size # centered on door tile
	p_body.position.y = (access_point.y + 1) * tile_size # slightly below

	# camera follow
	if p_body is PlayerBody:
		view.camera.follow(p_body)


func configure_view() -> void:
	Debug.log_info("Configuring view...")
	view.camera.update_limits(scene.tile_grid.area)
	System.manage.scene.activate_view(View.ViewType.CITY)


func _on_viewport_resized(p_viewport_size: Vector2) -> void:
	view.camera.set_min_zoom(p_viewport_size, base_size)


func _on_building_exited(p_building: Building, p_body: CharacterBody) -> void:
	add_character_at(p_building, p_body)

	# re-enable body physics after reparent
	p_body.process_mode = Node.PROCESS_MODE_INHERIT

	# switch view and kick camera
	System.manage.scene.activate_view(View.ViewType.CITY)
