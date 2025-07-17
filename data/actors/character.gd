class_name Character extends RefCounted

enum Role { PLAYER, LEADER, NPC }

var role: Role
var profile: Profile
var inventory: Inventory
var fleet: Fleet
var body: CharacterBody


func merge_savedata(p_save_data: Variant) -> void:
	# verify valid dictionary
	if not typeof(p_save_data) == TYPE_DICTIONARY:
		Debug.log_warning("Invalid save data")
		return

	# crea
	var _raw: Dictionary = p_save_data
	var save_data: Dictionary[String, Dictionary] = {}
	for property: String in _raw.keys():
		if property != "profile":
			save_data[property] = _raw[property]

	for property: String in save_data.keys():
		match property:
			#"inventory":
				#var balance: int = save_data["inventory"]["balance"]
				#self.inventory.balance = clampi(balance, 0, Common.Game.MAX_CURRENCY)
			_:
				Debug.log_warning("Unrecognised property: %s" % property)
				return # force handling

	Debug.log_debug("-> Merged player")
