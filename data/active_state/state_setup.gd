class_name SetupState extends ActiveState

var active_mods: PackedStringArray
var save_data: Dictionary
var save_is_dirty: bool


func _init(p_active_mods: PackedStringArray, p_save_data: Dictionary = {},
	p_save_is_dirty: bool = false) -> void:
	name = "Setup"
	active_mods = p_active_mods


func _main() -> void:
	if not enable_core_content():
		Debug.log_error("Fatal: failed to enable core mod")
		return

	verify_user_content()
	enable_user_content()

	Debug.log_info("Running with mods: %s" % str(Service.mod_manager.get_active_mods().keys()))
	Service.mod_manager.generate_blueprint()
	Service.mod_manager.clear_staging()
	Service.state_manager.change_state(StartState.new(save_data, save_is_dirty))


func enable_core_content() -> bool:
	Debug.log_info("Enabling core mod...")
	var core_mod_directory: String = FileLocation.CORE_MOD_DIR
	var manifest: ModManifest = Service.mod_manager.create_manifest(core_mod_directory)
	if not manifest: return false
	return Service.mod_manager.enable_mod(manifest)


func verify_user_content() -> void:
	Debug.log_info("Verifying user mods...")
	var user_mod_directory: String = FileLocation.USER_MOD_DIR
	for subfolder: String in DirAccess.get_directories_at(user_mod_directory):
		var path: String = "%s/%s" % [user_mod_directory, subfolder]
		if not Service.mod_manager.create_manifest(path):
			Debug.log_warning("Failed to verify manifest: %s" % path)


func enable_user_content() -> void:
	Debug.log_info("Enabling user mods...")
	if active_mods.is_empty():
		Debug.log_debug("No user mods enabled")

	for mod_id: StringName in active_mods:
		var manifest: ModManifest = Service.mod_manager.get_manifest(mod_id)
		if not manifest:
			Debug.log_warning("Could not find manifest: %s" % mod_id)
			continue

		if not Service.mod_manager.enable_mod(manifest):
			Debug.log_warning("Failed to enable mod: %s" % mod_id)
			continue


func _start_services() -> void:
	Debug.log_info("Starting services...")
	AppContext.start_service(ModManager.new(), Service.Type.MOD_MANAGER)
