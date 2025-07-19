class_name NPC extends RefCounted

var body: NPCBody
var actions: Array[Action]


func get_actions() -> Array[Action]:
	return actions
