class_name SetupState extends ActiveState

var core_mod_dir: String
var user_mod_dir: String
var saved_mods: PackedStringArray # Array[ModManifest.mod_id]


func _init(p_saved_mods: PackedStringArray) -> void:
	state_id = "Setup"
	saved_mods = p_saved_mods
	core_mod_dir = FileLocation.CORE_MOD_DIR
	user_mod_dir = FileLocation.USER_ROOT_MOD_DIR


func _start_services() -> void:
	System.manage.start_service(ModManager.new(), Service.Type.MOD_MANAGER)


func _main() -> void:
	# core mod is required
	if not stage_core_mod(core_mod_dir): return

	# process user content
	parse_all_mods(user_mod_dir)
	stage_saved_mods(saved_mods)

	# finalise blueprint
	System.manage.content.generate_blueprint()

	# tidy-up
	#System.manage.content.clear_staging()

	# notify
	EventBus.create_notification.emit("Enabled %d mods" % System.manage.content.get_active_mods().size())

	# show start menu
	System.state.change(StartState.new())


func stage_core_mod(p_core_mod_dir: String) -> bool:
	Debug.log_info("Staging core mod...")
	var success: bool

	# attempt to get manifest
	var manifest: ModManifest = System.manage.content.create_manifest(p_core_mod_dir)
	if not manifest: success = false

	# attempt to stage mod
	success = System.manage.content.stage_content(manifest)

	# return result
	if not success: Debug.log_error("Fatal: failed to stage core mod")
	return success


func parse_all_mods(p_user_mod_dir: String) -> void:
	Debug.log_info("Verifying user mods...")

	# attempt to generate manifest for any directory found under p_user_mod_dir
	for subfolder: String in DirAccess.get_directories_at(p_user_mod_dir):
		var path: String = "%s/%s" % [p_user_mod_dir, subfolder]
		var manifest: ModManifest = System.manage.content.create_manifest(path)
		if not manifest: Debug.log_error("Failed to generate manifest: %s" % path)


func stage_saved_mods(p_saved_mods: PackedStringArray) -> void:
	Debug.log_info("Staging saved mods (%d)..." % p_saved_mods.size())

	if p_saved_mods.is_empty():
		Debug.log_debug("No saved mods found")
		return

	# process saved mods
	for mod_id: StringName in p_saved_mods:

		# expect to find existing manifest for saved mod
		var manifest: ModManifest = System.manage.content.get_manifest(mod_id)
		if not manifest:
			Debug.log_warning("Could not find manifest: %s" % mod_id)
			continue # non-fatal error

		# enable saved mod via manifest
		if not System.manage.content.stage_content(manifest):
			Debug.log_error("Failed to stage mod: %s" % mod_id)
			continue # non-fatal error
