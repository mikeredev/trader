class_name ReadyState extends ActiveState

var is_new_game: bool


func _init(p_is_new_game: bool = false) -> void:
	name = "Ready"
	is_new_game = p_is_new_game


func _main() -> void:
	print("new game %s" % is_new_game)
	var city: City = Service.city_manager.get_city("C_ALEXANDRIA")
	print(Service.city_manager.get_support_normalized(city))
	city = Service.city_manager.get_city("C_ATHENS")
	print(Service.city_manager.get_support_normalized(city))
	city = Service.city_manager.get_city("C_LISBON")
	print(Service.city_manager.get_support_normalized(city))


func _start_services() -> void:
	AppContext.start_service(DialogManager.new(), Service.Type.DIALOG_MANAGER)
