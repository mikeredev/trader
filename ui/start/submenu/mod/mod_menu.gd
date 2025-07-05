extends UISubMenu

@onready var manifests: Dictionary[StringName, ModManifest] = Service.mod_manager.get_manifests()
@onready var active_mods: Dictionary[StringName, ModManifest] = Service.mod_manager.get_active_mods(true)

@onready var available_list: ItemList = %AvailableList
@onready var enabled_list: ItemList = %EnabledList
@onready var mod_info_label: Label = %ModInfoLabel
@onready var enable_button: Button = %EnableButton
@onready var disable_button: Button = %DisableButton
@onready var increase_prio_button: Button = %IncreasePrioButton
@onready var decrease_prio_button: Button = %DecreasePrioButton
@onready var confirm_button: UIButton = %ConfirmButton
@onready var return_button: UIButton = %ReturnButton


func _ui_ready() -> void:
	populate_enabled()
	populate_available()


func populate_enabled() -> void:
	for mod_id: StringName in active_mods.keys():
		var manifest: ModManifest = manifests.get(mod_id)
		var disabled: bool = true if manifest.core_mod == true else false
		add_to_enabled(manifest, disabled)


func populate_available() -> void:
	for mod_id: StringName in manifests.keys():
		if not active_mods.has(mod_id): # already present in enabled list
			var manifest: ModManifest = manifests.get(mod_id)
			add_to_available(manifest)


func add_to_enabled(p_manifest: ModManifest, p_disabled: bool = false) -> void:
	var idx: int = enabled_list.add_item(p_manifest.name, p_manifest.icon)
	enabled_list.set_item_metadata(idx, p_manifest)
	if p_disabled:
		enabled_list.set_item_disabled(idx, true)


func add_to_available(p_manifest: ModManifest) -> void:
	var idx: int = available_list.add_item(p_manifest.name, p_manifest.icon)
	available_list.set_item_metadata(idx, p_manifest)


func _connect_signals() -> void:
	available_list.item_activated.connect(_on_available_list_item_activated)
	available_list.item_selected.connect(_on_available_list_item_selected)
	enabled_list.item_activated.connect(_on_enabled_list_item_activated)
	enable_button.pressed.connect(_on_enable_button_pressed)
	disable_button.pressed.connect(_on_disable_button_pressed)
	increase_prio_button.pressed.connect(_on_increase_prio_button_pressed)
	decrease_prio_button.pressed.connect(_on_decrease_prio_button_pressed)
	confirm_button.pressed_tweened.connect(_on_confirm_pressed)
	return_button.pressed_tweened.connect(_on_return_button_pressed)


func _set_button_shortcuts() -> void:
	var shortcut: Shortcut = Shortcut.new()
	var event: InputEventAction = InputEventAction.new()
	event.action = "ui_cancel"
	shortcut.events.append(event)
	return_button.shortcut = shortcut


func _on_available_list_item_activated(index: int) -> void: # moves mod to enabled list
	var manifest: ModManifest = available_list.get_item_metadata(index)
	available_list.remove_item(index)
	add_to_enabled(manifest)


func _on_available_list_item_selected(index: int) -> void:
	var manifest: ModManifest = available_list.get_item_metadata(index)
	mod_info_label.text = "%s v%.01f by %s (%s)" % [
		manifest.name,
		manifest.version,
		manifest.author,
		manifest.contact
	]


func _on_enabled_list_item_activated(index: int) -> void: # moves mod to available list (i.e., disables)
	var manifest: ModManifest = enabled_list.get_item_metadata(index)
	enabled_list.remove_item(index)
	add_to_available(manifest)


func _on_enable_button_pressed() -> void:
	if not available_list.is_anything_selected(): return
	var selected: int = available_list.get_selected_items()[0]
	_on_available_list_item_activated(selected)


func _on_disable_button_pressed() -> void:
	if not enabled_list.is_anything_selected(): return
	var selected: int = enabled_list.get_selected_items()[0]
	_on_enabled_list_item_activated(selected)


func _on_increase_prio_button_pressed() -> void:
	if not enabled_list.is_anything_selected(): return
	var selected: int = enabled_list.get_selected_items()[0]
	if selected == 1: return # core mod in slot 0
	enabled_list.move_item(selected - 1, selected)


func _on_decrease_prio_button_pressed() -> void:
	if not enabled_list.is_anything_selected(): return
	var selected: int = enabled_list.get_selected_items()[0]
	if selected == enabled_list.get_item_count() - 1: return
	enabled_list.move_item(selected, selected + 1)


func _on_confirm_pressed() -> void:
	Debug.log_info("Processing new mod order...")
	var new_active_mods: PackedStringArray = []

	for i: int in range(1, enabled_list.get_item_count()): # ignore slot 0
		var manifest: ModManifest = enabled_list.get_item_metadata(i)
		new_active_mods.append(manifest.mod_id)

	if new_active_mods == Service.config_manager.get_active_mods(): # includes core
		Debug.log_debug("No change to mod order")
		return

	if await Service.dialog_manager.get_confirmation("RELOAD WITH NEW MOD ORDER?"):
		Debug.log_debug("Reloading new mod order: %s" % new_active_mods)
		Service.config_manager.set_active_mods(new_active_mods)
		Service.config_manager.save_config()
		Debug.log_info("Returning to setup...")
		Service.state_manager.change_state(SetupState.new(new_active_mods))


func _on_return_button_pressed() -> void:
	EventBus.menu_closed.emit(self)
