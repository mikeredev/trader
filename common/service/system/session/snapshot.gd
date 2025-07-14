class_name Snapshot extends RefCounted

var timestamp: int


func _init(p_timestamp: int) -> void:
	timestamp = p_timestamp


func to_dict() -> Dictionary:
	return {
		"data": {
			"app": {
				"character": App.context.character.to_dict(),
				"city": App.context.city.to_dict(),
				"country": App.context.country.to_dict(),
				#"ship": App.context.ship.to_dict(),
				#"trade": App.context.trade.to_dict(),
			},
			"player": App.context.character.get_savedata(App.context.character.get_player().profile.profile_id),
			"system": {
				"mods": System.manage.content.to_dict(),
				"state": System.state.to_dict(),
			},
		},
		"timestamp": timestamp,
		"version": "0.3",
	}
