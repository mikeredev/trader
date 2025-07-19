class_name CityManager extends Service

var datastore: Dictionary[StringName, City] = {}


func enter_building(p_city: City, p_building: Building, p_character: Character) -> void:
	Debug.log_verbose("%s is entering building %s" % [p_character.profile.profile_id, p_building.building_id])
	if not p_building.interior_scene:
		Debug.log_warning("No interior scene: %s" % p_building.building_id)
		return
	p_building.scene = System.manage.scene.create_scene(p_building.interior_scene)
	p_building.scene.name = p_building.building_id
	p_building.scene.city_id = p_city.city_id
	p_building.scene.building_id = p_building.building_id
	p_building.view.add_scene(p_building.scene, View.ContainerType.SCENE)

	# add NPC master
	p_building.master = NPC.new()
	p_building.master.body = NPCBody.new(p_building.master)
	p_building.master.actions = p_building.actions
	p_building.scene.sprite_group.add_child(p_building.master.body)
	p_building.master.body.position = p_building.scene.master_point.position

	# add character
	p_character.body.reparent(p_building.scene.sprite_group)
	p_character.body.position = p_building.scene.entry_point.position

	# switch view and kick camera
	System.manage.scene.activate_view(View.ViewType.INTERIOR)

	# broadcast
	EventBus.building_entered.emit(p_building)


func exit_building(p_building: Building, body: CharacterBody) -> void:
	EventBus.building_exited.emit(p_building, body)


func get_city(p_city_id: StringName) -> City:
	return datastore.get(p_city_id, null)


func get_cities() -> Array[City]:
	return datastore.values()


#func get_general_price_index(p_city: City) -> int:
	#var market: Market = p_city.get_market()
	#var price_index: Dictionary[StringName, int] = market.price_index
	#var total: int = 0
	#var size: int = price_index.size()
	#for value: int in price_index.values():
		#total += value
	#return int(total / float(size))


func get_support_normalized(p_city: City) -> Dictionary[StringName, float]:
	var support: Dictionary[StringName, float] = p_city.support.duplicate()
	var total: float = 0.0
	for value: float in support.values():
		total += value

	# return as-is if total is <= 100
	if total < 100.0 or is_equal_approx(total, 100.0):
		return support

	# otherwise normalize
	var normalized: Dictionary[StringName, float] = {}
	for country_id: StringName in support.keys():
		var share: float = (support[country_id] / total) * 100.0
		normalized[country_id] = snappedf(share, 0.1)
	return normalized


func register_city(p_city: City) -> void:
	if datastore.has(p_city.city_id):
		Debug.log_warning("Overwriting existing city: %s" % p_city.city_id)
	datastore[p_city.city_id] = p_city


func to_dict() -> Dictionary[String, Variant]:
	var dict: Dictionary[String, Variant] = {}
	for city_id: StringName in datastore.keys():
		dict[city_id] = {
			"production": {
				"economy": datastore[city_id]["economy"],
				"industry": datastore[city_id]["industry"]
			},
			"support": {},
		}
	return dict
