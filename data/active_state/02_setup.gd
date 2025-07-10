class_name SetupState extends ActiveState

var saved_mods: PackedStringArray # Array[ModManifest.mod_id]


func _init(p_saved_mods: PackedStringArray) -> void:
	state_id = "Setup"
	saved_mods = p_saved_mods


func _start_services() -> void:
	System.service.start_service(ModManager.new(), Service.ServiceType.MOD_MANAGER)


func _main() -> void:
	# core mod is required
	if not stage_core_mod(FileLocation.CORE_MOD_DIR): return

	# process user content
	parse_all_mods(FileLocation.USER_ROOT_MOD_DIR)
	stage_saved_mods(saved_mods)

	# finalise blueprint
	Service.mod_manager.generate_blueprint()

	# tidy-up
	#Service.mod_manager.clear_staging()

	# notify
	Service.scene_manager.create_notification("Enabled %d mods" % Service.mod_manager.get_active_mods().size())

	# show start menu
	System.change_state(StartState.new())


func stage_core_mod(p_core_mod_dir: String) -> bool:
	Debug.log_info("Staging core mod...")
	var success: bool

	# attempt to get manifest
	var manifest: ModManifest = Service.mod_manager.create_manifest(p_core_mod_dir)
	if not manifest: success = false

	# attempt to stage mod
	success = Service.mod_manager.stage_mod(manifest)

	# return result
	if not success: Debug.log_error("Fatal: failed to stage core mod")
	return success


func parse_all_mods(p_user_mod_dir: String) -> void:
	Debug.log_info("Verifying user mods...")

	# attempt to generate manifest for any directory found under p_user_mod_dir
	for subfolder: String in DirAccess.get_directories_at(p_user_mod_dir):
		var path: String = "%s/%s" % [p_user_mod_dir, subfolder]
		var manifest: ModManifest = Service.mod_manager.create_manifest(path)
		if not manifest: Debug.log_error("Failed to generate manifest: %s" % path)


func stage_saved_mods(p_saved_mods: PackedStringArray) -> void:
	Debug.log_info("Staging saved mods (%d)..." % p_saved_mods.size())

	if p_saved_mods.is_empty():
		Debug.log_debug("No saved mods found")
		return

	# process saved mods
	for mod_id: StringName in p_saved_mods:

		# expect to find existing manifest for saved mod
		var manifest: ModManifest = Service.mod_manager.get_manifest(mod_id)
		if not manifest:
			Debug.log_warning("Could not find manifest: %s" % mod_id)
			continue # non-fatal error

		# enable saved mod via manifest
		if not Service.mod_manager.stage_mod(manifest):
			Debug.log_error("Failed to stage mod: %s" % mod_id)
			continue # non-fatal error
