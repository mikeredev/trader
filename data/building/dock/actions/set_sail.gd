class_name SetSail extends Action


func _init() -> void:
	action_name = "SET_SAIL"


func execute(p_character: Character) -> void:
	print("execute here %s" % p_character)
