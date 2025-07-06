class_name ModManager extends Service

enum Category { WORLD, COUNTRY, CITY, TRADE, SHIP }

const TAG_TO_CATEGORY: Dictionary[String, Category] = {
	"world": Category.WORLD,
	"city": Category.CITY,
	"country": Category.COUNTRY,
	"trade": Category.TRADE,
	"ship": Category.SHIP, }

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
	var json_path: String = "%s/%s" % [p_directory, MANIFEST]
	var raw: Dictionary = Common.Util.json.get_dict(json_path)
	if not raw: return null

	# assumes valid types in user manifest
	var mod_name: String = raw.get("name", "")
	var mod_version: float = raw.get("version", 0.0)
	var mod_author: String = raw.get("author", "")
	var mod_contact: String = raw.get("contact", "")
	var mod_minimum: float = raw.get("minimum", 0.1)
	var tags: PackedStringArray = raw.get("tags", [])

	# check valid data
	if not mod_name or not mod_author:
		Debug.log_warning("Mod name and author are required")
		return null

	if not mod_version > 0:
		Debug.log_warning("Mod version number is required")
		return null

	if tags.is_empty():
		Debug.log_warning("No tags were provided")
		return null

	# generate mod ID
	var to_hash: String = "%s%s" % [mod_name, mod_author]
	var uid: int = to_hash.hash()
	var mod_id: String = "%s_%s" % [mod_name.to_pascal_case(), uid]
	if _manifests.has(mod_id):
		Debug.log_warning("Mod ID already in-use: %s" % mod_id)
		return null
	Debug.log_verbose("Generating manifest: %s (%s)" % [mod_id, p_directory])

	# parse tags into an Array[Category]
	Debug.log_verbose("Validating tags: %s" % tags)
	var categories: Array[Category] = []
	for tag: String in tags:
		var category: Category = TAG_TO_CATEGORY.get(tag.to_lower(), -1)
		if category < 0:
			Debug.log_warning("Unrecognized tag: %s" % tag)
			return null
		categories.append(category)
	categories.sort()

	# prepare cache
	staging.cache["datastore"][p_directory] = {}
	for category: Category in categories:
		var tag: String = str(Category.keys()[category]).to_lower()
		json_path = "%s/%s/%s" % [p_directory, tag, DATAFILE]
		raw = Common.Util.json.get_dict(json_path)
		if not raw:
			Debug.log_warning("Failed to cache '%s': %s" % [tag, json_path])
			return null
		staging.cache["datastore"][p_directory][category] = raw

	# assign icon
	var icon: Texture2D
	var icon_png: String = "%s/%s" % [p_directory, ICONFILE]
	if FileAccess.file_exists(icon_png):
		icon = Common.Util.get_texture(icon_png)
	else:
		icon = Common.Util.get_texture(FileLocation.DEFAULT_MOD_ICON)

	# create manifest
	var manifest: ModManifest = ModManifest.new()
	manifest.name = mod_name
	manifest.mod_id = mod_id
	manifest.version = mod_version
	manifest.author = mod_author
	manifest.contact = mod_contact
	manifest.minimum = mod_minimum
	manifest.icon = icon
	manifest.local_path = p_directory
	for category: Category in categories: # only hashed during staging
		manifest.categories[category] = -1

	if p_directory.begins_with("res://"):
		manifest.core_mod = true # flag core mod

	# store manifest
	_manifests[manifest.mod_id] = manifest

	# done
	Debug.log_debug("Created manifest: %s" % manifest.mod_id)
	return manifest


func generate_blueprint() -> void:
	_blueprint = Blueprint.new(
		staging.world_data.duplicate(),
		staging.country_data.duplicate(),
		staging.city_data.duplicate(),
		staging.trade_data.duplicate(),
	)
	Debug.log_verbose("  Generated blueprint")


func get_active_mods() -> Dictionary[StringName, ModManifest]:
	return _active_mods


func get_blueprint() -> Blueprint:
	return _blueprint


func get_manifest(p_id: StringName) -> ModManifest:
	return _manifests.get(p_id)


func get_manifests() -> Dictionary[StringName, ModManifest]:
	return _manifests


func stage_mod(p_manifest: ModManifest) -> bool:
	Debug.log_verbose("Staging mod: %s" % p_manifest.mod_id)
	var raw: Dictionary = staging.get_cached("datastore", p_manifest.local_path)

	var metadata: Dictionary[Category, Dictionary] = {}
	for category: Category in raw:
		var data: Dictionary = raw[category]
		metadata[category] = data # stores a dict of category.json
		p_manifest.categories[category] = data.hash() # compare category hash against save data etc

	# build context cache for later cross-checks
	Debug.log_verbose("Building cache...")
	for category: Category in metadata.keys():
		match category:
			Category.WORLD: # builds full path to map texture
				staging.cache["manifest"]["directory"] = p_manifest.local_path

			Category.CITY:
				for city_id: String in metadata[category]:
					var _dict: Dictionary = metadata[category][city_id]
					if _dict.get("remove", false):
						Debug.log_warning("City marked for removal: %s (%s)" % [
							city_id, p_manifest.mod_id])
					else: # bool flag toggled true by country validation if capital
						staging.cache["city"]["city_id"][city_id] = false

			Category.COUNTRY:
				for country_id: String in metadata[category]:
					var _dict: Dictionary = metadata[category][country_id]
					if _dict.get("remove", false):
						Debug.log_warning("Country marked for removal: %s (%s)" % [
							country_id, p_manifest.mod_id])
					else: # used for key lookup only
						staging.cache["country"]["country_id"][country_id] = true

			Category.TRADE:
				for resource_id: String in metadata[category]: # check city specialities exist
					var _dict: Dictionary = metadata[category][resource_id]
					if _dict.get("remove", false):
						Debug.log_warning("Trade resource marked for removal: %s (%s)" % [
							resource_id, p_manifest.mod_id])
					else:
						# cache resource_id
						staging.cache["trade"]["resource_id"][resource_id] = false

						# cache market_id
						var cache: Dictionary
						for market_id: String in metadata[category][resource_id]["buy_price"]:
							cache = staging.get_cached("trade", "market_id")
							if not cache.has(market_id): # add market_id to cache
								cache[market_id] = false # used for lookup only

	# cross-checks (i.e., each market_id referenced in a city json actually exists)
	Debug.log_verbose("Performing cross-check...")
	for category: Category in metadata.keys():
		match category:
			Category.WORLD:
				if not WorldBlueprint.validate(metadata[category], staging.cache): return false
			Category.COUNTRY:
				if not CountryBlueprint.validate(metadata[category], staging.cache): return false
			Category.CITY:
				if not CityBlueprint.validate(metadata[category], staging.cache): return false
			Category.TRADE:
				if not TradeBlueprint.validate(metadata[category], staging.cache): return false

	# prepare for staging
	Debug.log_verbose("Merging with staging...")
	for category: Category in metadata.keys():
		var mod_data: Dictionary = metadata[category] # keyed by variants (string/string names)

		# add owner information
		for property: String in mod_data:
			mod_data[property]["owner"] = p_manifest.mod_id

		# merge with staging
		match category:
			Category.WORLD: staging.merge(staging.world_data, mod_data)
			Category.COUNTRY: staging.merge(staging.country_data, mod_data)
			Category.CITY: staging.merge(staging.city_data, mod_data)
			Category.TRADE: staging.merge(staging.trade_data, mod_data)

	# update active mods
	_active_mods[p_manifest.mod_id] = p_manifest

	# done
	Debug.log_debug("Staged mod: %s (%s)" % [p_manifest.mod_id, p_manifest.local_path])
	return true
