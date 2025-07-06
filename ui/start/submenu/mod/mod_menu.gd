extends UISubMenu # vbox

@onready var manifests: Dictionary[StringName, ModManifest] = Service.mod_manager.get_manifests()
@onready var active_mods: Dictionary[StringName, ModManifest] = Service.mod_manager.get_active_mods()

@onready var ui_available_list: ItemList = %AvailableList
@onready var ui_enabled_list: ItemList = %EnabledList
@onready var ui_mod_info_label: Label = %ModInfoLabel
@onready var ui_enable_button: Button = %EnableButton
@onready var ui_disable_button: Button = %DisableButton
@onready var ui_increase_prio_button: Button = %IncreasePrioButton
@onready var ui_decrease_prio_button: Button = %DecreasePrioButton
@onready var ui_confirm_button: UIButton = %ConfirmButton
@onready var ui_return_button: UIButton = %ReturnButton


func _ui_ready() -> void:
	populate_enabled()
	populate_available()


func populate_enabled() -> void:
	for mod_id: StringName in active_mods.keys():
		var manifest: ModManifest = manifests.get(mod_id)
		var is_disabled: bool = true if manifest.core_mod == true else false
		add_to_enabled(manifest, is_disabled)


func populate_available() -> void:
	for mod_id: StringName in manifests.keys():
		if not active_mods.has(mod_id): # already present in enabled list
			var manifest: ModManifest = manifests.get(mod_id)
			add_to_available(manifest)


func add_to_enabled(p_manifest: ModManifest, p_disabled: bool = false) -> void:
	var idx: int = ui_enabled_list.add_item(p_manifest.name, p_manifest.icon)
	ui_enabled_list.set_item_metadata(idx, p_manifest)
	if p_disabled:
		ui_enabled_list.set_item_disabled(idx, true)


func add_to_available(p_manifest: ModManifest) -> void:
	var idx: int = ui_available_list.add_item(p_manifest.name, p_manifest.icon)
	ui_available_list.set_item_metadata(idx, p_manifest)


func _connect_signals() -> void:
	ui_available_list.item_activated.connect(_on_ui_available_list_item_activated)
	ui_available_list.item_selected.connect(_on_ui_available_list_item_selected)
	ui_enabled_list.item_activated.connect(_on_ui_enabled_list_item_activated)
	ui_enable_button.pressed.connect(_on_ui_enable_button_pressed)
	ui_disable_button.pressed.connect(_on_ui_disable_button_pressed)
	ui_increase_prio_button.pressed.connect(_on_ui_increase_prio_button_pressed)
	ui_decrease_prio_button.pressed.connect(_on_ui_decrease_prio_button_pressed)
	ui_confirm_button.pressed_tweened.connect(_on_confirm_pressed)
	ui_return_button.pressed_tweened.connect(_on_ui_return_button_pressed)


func _set_button_shortcuts() -> void:
	var shortcut: Shortcut = Shortcut.new()
	var event: InputEventAction = InputEventAction.new()
	event.action = "ui_cancel"
	shortcut.events.append(event)
	ui_return_button.shortcut = shortcut


func _on_ui_available_list_item_activated(index: int) -> void: # moves mod to enabled list
	var manifest: ModManifest = ui_available_list.get_item_metadata(index)
	ui_available_list.remove_item(index)
	add_to_enabled(manifest)


func _on_ui_available_list_item_selected(index: int) -> void:
	var manifest: ModManifest = ui_available_list.get_item_metadata(index)
	ui_mod_info_label.text = "%s v%.01f by %s (%s)" % [
		manifest.name,
		manifest.version,
		manifest.author,
		manifest.contact
	]


func _on_ui_enabled_list_item_activated(index: int) -> void: # moves mod to available list (i.e., disables)
	var manifest: ModManifest = ui_enabled_list.get_item_metadata(index)
	ui_enabled_list.remove_item(index)
	add_to_available(manifest)


func _on_ui_enable_button_pressed() -> void:
	if not ui_available_list.is_anything_selected(): return
	var selected: int = ui_available_list.get_selected_items()[0]
	_on_ui_available_list_item_activated(selected)


func _on_ui_disable_button_pressed() -> void:
	if not ui_enabled_list.is_anything_selected(): return
	var selected: int = ui_enabled_list.get_selected_items()[0]
	_on_ui_enabled_list_item_activated(selected)


func _on_ui_increase_prio_button_pressed() -> void:
	if not ui_enabled_list.is_anything_selected(): return
	var selected: int = ui_enabled_list.get_selected_items()[0]
	if selected == 1: return # core mod in slot 0
	ui_enabled_list.move_item(selected - 1, selected)


func _on_ui_decrease_prio_button_pressed() -> void:
	if not ui_enabled_list.is_anything_selected(): return
	var selected: int = ui_enabled_list.get_selected_items()[0]
	if selected == ui_enabled_list.get_item_count() - 1: return
	ui_enabled_list.move_item(selected, selected + 1)


func _on_confirm_pressed() -> void:
	Debug.log_info("Processing new mod order...")
	var mods_to_save: PackedStringArray = []

	# add each mod_id to list
	for i: int in range(1, ui_enabled_list.get_item_count()): # ignore slot 0
		var manifest: ModManifest = ui_enabled_list.get_item_metadata(i)
		mods_to_save.append(manifest.mod_id)

	# compare list to currently active mods
	if mods_to_save == Service.config_manager.mod_settings.get_saved_mods():
		Debug.log_debug("No change to mod order")
		return

	if await Service.dialog_manager.get_confirmation("RELOAD WITH NEW MOD ORDER?"):
		Debug.log_debug("Reloading new mod order: %s" % mods_to_save)
		Service.config_manager.mod_settings.set_saved_mods(mods_to_save, true)
		Debug.log_info("Returning to setup...")
		System.change_state(SetupState.new(mods_to_save))


func _on_ui_return_button_pressed() -> void:
	EventBus.menu_closed.emit(self)
