class_name CharacterManager extends Service

var datastore: Dictionary[StringName, Character]


static func create_character_no_register(
	p_role: Character.Role,
	p_name: String,
	p_country_id: StringName,
	p_rank: Rank.Level,
	p_title: String = ""
	) -> Character:

	var character: Character = Character.new()
	character.role = p_role
	character.profile = _create_profile(p_name, p_country_id, p_rank, p_title)
	return character # characters must be registered separately


static func _create_profile(p_name: String, p_country_id: StringName, p_rank: Rank.Level, p_title: String = "") -> Profile:
	var profile: Profile = Profile.new()
	profile.profile_name = p_name
	profile.profile_id = _get_uid(p_name)
	profile.country_id = p_country_id
	profile.rank = _create_rank(p_rank, p_title)
	return profile


static func _create_rank(p_level: Rank.Level, p_title: String = "") -> Rank:
	var rank: Rank = Rank.new()
	var _min: int = Rank.Level.COMMONER
	var _max: int = Rank.Level.size()
	rank.level = clampi(p_level, _min, _max) as Rank.Level
	rank.title = p_title if p_title else ""
	return rank


static func _get_uid(p_name: String) -> StringName:
	var regex: RegEx = RegEx.new() # used in filenames: lowercase, strips special chars, 32 len max
	regex.compile("[^a-zA-Z0-9 _\\-]")
	var cleaned: String = regex.sub(p_name, "", true)
	var result: String = cleaned.substr(0, 32)
	return "%s_%d" % [result.to_snake_case().to_lower(), Time.get_unix_time_from_system()]


func register_character(p_character: Character) -> void:
	datastore[p_character.profile.profile_id] = p_character
	Debug.log_verbose("  Registered character: %s" % p_character.profile.profile_id)


func get_character(p_profile_id: StringName) -> Character:
	return datastore.get(p_profile_id, null)
