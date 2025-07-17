class_name Interactable extends Resource

func interact_with(p_character: CharacterBody) -> void:
	Debug.log_verbose("Character %s interacting with %s" % [p_character, self])
