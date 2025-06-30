class_name ModManager extends Service

enum Category { WORLD, COUNTRY, CITY, TRADE, SHIP }

const CATEGORY_MAP: Dictionary[String, Category] = {
	"world": Category.WORLD,
	"city": Category.CITY,
	"country": Category.COUNTRY,
	"trade": Category.TRADE,
	"ship": Category.SHIP,
}

const MANIFEST: String = "manifest.json"
const DATAFILE: String = "data.json"
const ICONFILE: String = "icon.ico"

var staging: ModStaging = ModStaging.new()
var _blueprint: Blueprint
var _active_mods: Dictionary[StringName, ModManifest]
var _manifests: Dictionary[StringName, ModManifest]


func clear_staging() -> void:
	staging = null
	Debug.log_verbose("Cleared mod staging area")


func create_manifest(p_directory: String) -> ModManifest:
	var path: String = "%s/%s" % [p_directory, MANIFEST]
	var data: Dictionary = Common.Util.json.get_dict(path)
	if not data: return null

	# assumes valid types in user manifest
	var mod_name: String = data.get("name", "")
	var mod_version: float = data.get("version", 0.0)
	var mod_author: String = data.get("author", "")
	var mod_contact: String = data.get("contact", "")
	var mod_minimum: float = data.get("minimum", 0.1)
	var tags: PackedStringArray = data.get("tags", [])

	# check valid data
	if not mod_name or not mod_author:
		Debug.log_warning("Mod name and author are required")
		return null

	if not mod_version > 0:
		Debug.log_warning("Mod version number is required")
		return null

	if tags.is_empty():
		Debug.log_warning("No category tags were provided")
		return null

	# create mod ID
	var to_hash: String = "%s%s" % [mod_name, mod_author]
	var hashed: int = to_hash.hash()
	var mod_id: String = "%s_%s" % [mod_name.to_pascal_case(), hashed]
	Debug.log_verbose("Generating manifest: %s (%s)" % [mod_id, p_directory])

	if is_verified(mod_id):
		Debug.log_warning("Mod ID already in-use: %s" % mod_id)
		return null

	# parse category tags
	Debug.log_verbose("Validating tags: %s" % tags)
	var categories: Array[Category] = []
	for tag: String in tags:
		if not Category.keys().has(tag.to_upper()):
			Debug.log_warning("Unrecognized tag: %s" % tag)
			return null
		var category: Category = CATEGORY_MAP.get(tag.to_lower())
		categories.append(category)
	categories.sort()

	# prepare cache (content is not cached for staging unless mod is being enabled)
	staging.cache["datastore"][p_directory] = {}
	for category: Category in categories:
		var _name: String = Category.keys()[category]
		path = "%s/%s/%s" % [p_directory, _name.to_lower(), DATAFILE]
		data = Common.Util.json.get_dict(path)
		if not data:
			Debug.log_warning("Unable to get %s data: %s" % [_name.to_upper(), path])
			return null
		staging.cache["datastore"][p_directory][category] = data

	# assign icon
	var icon: Texture2D
	path = "%s/%s" % [p_directory, ICONFILE]
	if FileAccess.file_exists(path):
		icon = Common.Util.get_texture(path)
	else:
		icon = Common.Util.get_texture(FileLocation.DEFAULT_MOD_ICON)

	# create manifest
	var manifest: ModManifest = ModManifest.new()
	manifest.name = mod_name
	manifest.id = mod_id
	manifest.version = mod_version
	manifest.author = mod_author
	manifest.contact = mod_contact
	manifest.minimum = mod_minimum
	manifest.icon = icon
	manifest.local_path = p_directory
	for category: Category in categories:
		manifest.categories[category] = -1

	if p_directory.begins_with("res://"):
		manifest.core_mod = true

	# get checksum after filling manifest fields
	#var checksum: int = get_checksum(manifest)
	#manifest.checksum = checksum

	# store manifest and return
	Debug.log_debug("Created manifest: %s" % manifest.id)
	_manifests[manifest.id] = manifest
	return manifest


func enable_mod(p_manifest: ModManifest) -> bool:
	Debug.log_verbose("Enabling mod: %s" % p_manifest.id)
	var raw: Dictionary = staging.get_cached("datastore", p_manifest.local_path)

	var metadata: Dictionary[Category, Dictionary] = {}
	for category: Category in raw:
		var data: Dictionary = raw[category]
		metadata[category] = data
		p_manifest.categories[category] = data.hash()

	# build cache
	Debug.log_verbose("Building cache...")
	for category: Category in metadata.keys():
		match category:
			Category.WORLD:
				staging.cache["manifest"]["directory"] = p_manifest.local_path # builds path to map texture

			#Category.CITY:
				#for city_id: String in metadata[category]:
					#staging.cache["city"]["city_id"][city_id] = false # toggled during country validation
#
			#Category.COUNTRY:
				#for country_id: String in metadata[category]:
					#staging.cache["country"]["country_id"][country_id] = true # used for key lookup only
#
			#Category.TRADE:
				#for resource_id: String in metadata[category]:
					#staging.cache["trade"]["resource_id"][resource_id] = false
					#var cache: Dictionary
#
					#cache = staging.get_cached("trade", "category_id")
					#var category_id: String = metadata[category][resource_id]["category"]
					#if not cache.has(category_id):
						#cache[category_id] = false
#
					#for market_id: String in metadata[category][resource_id]["buy_price"]:
						#cache = staging.get_cached("trade", "market_id")
						#if not cache.has(market_id):
							#cache[market_id] = false

	# cross-check
	Debug.log_verbose("Performing cross-check...")
	for category: Category in metadata.keys():
		match category:
			Category.WORLD:
				if not WorldBlueprint.validate(metadata[category], staging.cache): return false
			#Category.COUNTRY:
				#if not CountryBlueprint.validate(metadata[category], staging.cache): return false
			#Category.CITY:
				#if not CityBlueprint.validate(metadata[category], staging.cache): return false
			#Category.TRADE: # TBD cross check market refs
				#pass #if not TradeBlueprint.validate(metadata[category], staging.cache): return false


	# set owner information
	Debug.log_verbose("Merging with staging...")
	for category: Category in metadata.keys():
		var mod_data: Dictionary = metadata[category]
		for property: String in mod_data:
			mod_data[property]["owner"] = p_manifest.local_path

		# merge with staging
		match category:
			Category.WORLD: staging.merge(staging.world_data, mod_data)
			Category.COUNTRY: staging.merge(staging.country_data, mod_data)
			Category.CITY: staging.merge(staging.city_data, mod_data)
			Category.TRADE: staging.merge(staging.trade_data, mod_data)

	# update active mods
	_active_mods[p_manifest.id] = p_manifest

	Debug.log_debug("Enabled mod: %s (%s)" % [p_manifest.id, p_manifest.local_path])
	return true


func generate_blueprint() -> void:
	_blueprint = Blueprint.new(
		staging.world_data.duplicate(),
		staging.country_data.duplicate(),
		staging.city_data.duplicate(),
		staging.trade_data.duplicate(),
	)
	Debug.log_verbose("-> Generated blueprint")


func get_active_mods(p_include_core: bool = false) -> Dictionary[StringName, ModManifest]:
	if p_include_core:
		return _active_mods
	var dict: Dictionary[StringName, ModManifest] = {}
	for mod: ModManifest in _active_mods.values():
		if not mod.core_mod == true:
			dict[mod.id] = _active_mods[mod.id]
	return dict


func get_manifest(p_id: StringName) -> ModManifest:
	return _manifests.get(p_id)


func get_manifests() -> Dictionary[StringName, ModManifest]:
	return _manifests


func is_enabled(p_id: StringName) -> bool:
	return _active_mods.has(p_id)


func is_verified(p_id: StringName) -> bool:
	return _manifests.has(p_id)
