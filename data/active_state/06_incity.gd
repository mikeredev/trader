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
	Service.scene_manager.add_to_view(FileLocation.IN_CITY_SCENE, View.ViewType.CITY, View.ContainerType.SCENE)
	#Service.scene_manager.add_to_ui(FileLocation.UI_NEW_GAME_MENU, UI.ContainerType.MENU)


func _start_services() -> void:
	pass #System.start_service(SessionManager.new(), Service.ServiceType.SESSION_MANAGER)


#func _exit() -> void:
	#var ui: UI = Service.scene_manager.get_ui()
	#ui.clear_container(UI.ContainerType.MENU)
