class_name ActionMenu extends Control

@onready var ui_actions: GridContainer = %Actions


func setup(p_actions: Array[Action], p_character: Character) -> void:
	for action: Action in p_actions:
		var button: Button = Button.new()
		button.text = action.action_name
		button.pressed.connect(action.execute.bind(p_character))
		ui_actions.add_child(button)

	var ui_close: Button = Button.new()
	ui_close.text = "CLOSE"
	ui_close.pressed.connect(queue_free)
	ui_actions.add_child(ui_close)
