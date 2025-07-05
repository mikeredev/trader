class_name SetupState extends ActiveState

var active_mods: PackedStringArray
var save_data: Dictionary
var save_is_dirty: bool


func _init(p_active_mods: PackedStringArray, p_save_data: Dictionary = {}, p_save_is_dirty: bool = false) -> void:
	state_id = "setup"
	active_mods = p_active_mods
	save_data = p_save_data # unused
	save_is_dirty = p_save_is_dirty


func _main() -> void:
	if not stage_core_content():
		Debug.log_error("Fatal: failed to stage core mod")
		return

	verify_user_content()
	stage_user_content()

	Debug.log_info("Generating blueprint: %s" % str(Service.mod_manager.get_active_mods(true).keys()))
	Service.mod_manager.generate_blueprint()
	#Service.mod_manager.clear_staging()
	System.change_state(StartState.new())


func stage_core_content() -> bool:
	Debug.log_info("Staging core mod...")
	var core_mod_directory: String = FileLocation.CORE_MOD_DIR
	var manifest: ModManifest = Service.mod_manager.create_manifest(core_mod_directory)
	if not manifest: return false
	return Service.mod_manager.stage_mod(manifest)


func verify_user_content() -> void:
	Debug.log_info("Verifying user mods...")
	var user_mod_directory: String = FileLocation.USER_ROOT_MOD_DIR
	for subfolder: String in DirAccess.get_directories_at(user_mod_directory):
		var path: String = "%s/%s" % [user_mod_directory, subfolder]
		if not Service.mod_manager.create_manifest(path):
			Debug.log_error("Failed to verify manifest: %s" % path)


func stage_user_content() -> void:
	Debug.log_info("Staging user mods...")
	if active_mods.is_empty():
		Debug.log_debug("No user mods found")

	for mod_id: StringName in active_mods:
		var manifest: ModManifest = Service.mod_manager.get_manifest(mod_id)
		if not manifest:
			Debug.log_warning("Could not find manifest: %s" % mod_id)
			continue

		if not Service.mod_manager.stage_mod(manifest):
			Debug.log_error("Failed to stage mod: %s" % mod_id)
			continue


func _start_services() -> void:
	System.start_service(ModManager.new(), Service.ServiceType.MOD_MANAGER)
