class_name CharacterManager extends Service

var datastore: Dictionary[StringName, Character] = {}
var player: Character # quick lookup for player access


func cache(p_body: CharacterBody) -> void:
	var node_cache: Node2D = System.get_cache()
	p_body.velocity = Vector2.ZERO

	if p_body.get_parent(): p_body.reparent(node_cache)
	else: node_cache.add_child(p_body)

	p_body.position = Vector2.ZERO
	Debug.log_debug("Cached body: %s" % p_body)


func create_body(p_character: Character) -> CharacterBody:
	var body: CharacterBody
	match p_character.role:
		Character.Role.PLAYER:
			var player_body: PlayerBody = PlayerBody.new()
			body = player_body
		_:
			var npc_body: NPCBody = NPCBody.new()
			body = npc_body

	var name: String = p_character.profile.profile_name
	body.name = name

	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = name
	sprite.texture = load("uid://crmdb02jrkw8o") # base sprite flat
	body.add_child(sprite)
	body.sprite = sprite

	Debug.log_debug("Created body: %s" % p_character.profile.profile_name)
	return body

func create_character(p_role: Character.Role, p_name: String, p_country_id: StringName,
	p_rank: Rank.Level, p_title: String = "") -> Character:

	# assign role / profile / inventory / fleet as needed
	var character: Character = Character.new()
	character.role = p_role
	character.profile = _create_profile(p_name, p_country_id, p_rank, p_title)

	# register for lookup
	datastore[character.profile.profile_id] = character

	if character.role == Character.Role.PLAYER:
		player = character # register player for quick lookup

	Debug.log_verbose("  Registered character: %s" % character.profile.profile_id)
	return character


func get_character(p_profile_id: StringName) -> Character:
	return datastore.get(p_profile_id, null)


func get_player() -> Character:
	return player


func _create_profile(p_name: String, p_country_id: StringName, p_rank: Rank.Level, p_title: String = "") -> Profile:
	var profile: Profile = Profile.new()
	profile.profile_name = p_name
	profile.profile_id = _get_uid(p_name)
	profile.country_id = p_country_id
	profile.rank = _create_rank(p_rank, p_title)
	return profile


func _create_rank(p_level: Rank.Level, p_title: String = "") -> Rank:
	var rank: Rank = Rank.new()
	var _min: int = Rank.Level.COMMONER
	var _max: int = Rank.Level.size()
	rank.level = clampi(p_level, _min, _max) as Rank.Level
	rank.title = p_title if p_title else ""
	return rank


func _get_uid(p_name: String) -> StringName:
	var regex: RegEx = RegEx.new() # used in filenames: lowercase, strips special chars, 32 len max
	regex.compile("[^a-zA-Z0-9 _\\-]")
	var cleaned: String = regex.sub(p_name, "", true)
	var result: String = cleaned.substr(0, 32)
	return "%s_%d" % [result.to_snake_case().to_lower(), Time.get_unix_time_from_system()]
