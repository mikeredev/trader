class_name InterationArea2D extends Area2D


func _init(p_object: Object) -> void:
	set_meta("interact", p_object)


func _ready() -> void: # bidirectional (e.g., player interaction area can interact with a building door)
	collision_layer = Common.Collision.INTERACT
	collision_mask = Common.Collision.INTERACT
	monitoring = true
	monitorable = true


func interact_with_body(p_body: CharacterBody) -> void:
	var object: Object = get_meta("interact")
	var character: Character = App.context.character.get_character(p_body.profile_id)
	object.call("interact_with", character) # avoids editor warnings
