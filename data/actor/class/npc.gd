class_name NPC extends RefCounted

var body: NPCBody
var actions: Array[Action]


func get_actions() -> Array[Action]:
	return actions


func interact_with(p_character: Character) -> void:
	if not actions:
		Debug.log_warning("No actions defined")
		return

	#System.manage.scene.create_scene()

	Debug.log_info("Showing Action Menu...")
	var action_menu: ActionMenu = System.manage.scene.create_scene(FileLocation.ACTION_MENU)
	System.manage.scene.ui.menu.add_scene(action_menu)
	action_menu.setup(actions, p_character)
