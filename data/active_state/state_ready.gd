class_name ReadyState extends ActiveState

var is_new_game: bool


func _init(p_is_new_game: bool = false) -> void:
	name = "Ready"
	is_new_game = p_is_new_game


func _main() -> void:
	print("new game %s" % is_new_game)


func _start_services() -> void:
	AppContext.start_service(DialogManager.new(), Service.Type.DIALOG_MANAGER)
