class_name GameOptionsPanel extends VBoxContainer

@onready var ui_save: UIButton = %ButtonSave
@onready var ui_load: UIButton = %ButtonLoad
@onready var ui_pause: UIButton = %ButtonPause
@onready var ui_quit: UIButton = %ButtonQuit


func setup() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	ui_save.pressed_tweened.connect(_on_game_saved)
	ui_load.pressed_tweened.connect(_on_game_load)
	ui_pause.toggle_mode = true
	ui_pause.toggled.connect(_on_game_paused)
	ui_quit.pressed_tweened.connect(_on_game_quit)


func _on_game_saved() -> void:
	System.manage.session.save_session()


func _on_game_load() -> void:
	pass


func _on_game_paused(p_toggled: bool) -> void:
	System.pause_game(p_toggled)


func _on_game_quit() -> void:
	System.soft_reset()
