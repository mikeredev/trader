class_name Character extends RefCounted

var profile: Profile
var inventory: Inventory
var fleet: Fleet
var body: CharacterBody


func get_profile_name() -> String:
	return profile.profile_name


func get_profile_id() -> StringName:
	return profile.profile_id



func interact_with(p_character: CharacterBody)-> void:
	print("hi")
