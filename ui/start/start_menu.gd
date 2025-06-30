class_name StartMenu extends UIControl

enum SubMenu { NEW, LOAD, SETTINGS, MODS }

var active: Dictionary[SubMenu, Control]
var buttons: Array[UIButtonStartMenu]

@onready var margin_outer: MarginContainer = %MarginOuter
@onready var nav_main: Control = %NavMain
@onready var nav_menu: VBoxContainer = %NavMenu
@onready var nav_buttons: VBoxContainer = %NavButtons
@onready var nav_content: VBoxContainer = %NavContent

@onready var new_game_button: UIButtonStartMenu = %NewGameButton
@onready var load_game_button: UIButtonStartMenu = %LoadGameButton
@onready var settings_button: UIButtonStartMenu = %SettingsButton
@onready var mods_button: UIButtonStartMenu = %ModsButton
@onready var quit_button: UIButtonStartMenu = %QuitButton

@onready var sky_rect: ColorRect = %SkyRect
@onready var starfield_texture: TextureRect = %Starfield
@onready var atmosphere_rect: ColorRect = %Atmosphere
@onready var fade_rect: ColorRect = %Fade
@onready var label_title: Label = %LabelTitle


func _ui_ready() -> void:
	apply_color_scheme()
	play_animation()


func apply_color_scheme() -> void:
	var primary_bg: Color = ProjectSettings.get_setting("gui/theme/scheme/primary_bg")
	var secondary_bg: Color = ProjectSettings.get_setting("gui/theme/scheme/secondary_bg")
	var ternary_bg: Color = ProjectSettings.get_setting("gui/theme/scheme/ternary_bg")

	sky_rect.material.set_shader_parameter("sky_color", primary_bg)
	sky_rect.material.set_shader_parameter("sea_color", secondary_bg)
	sky_rect.material.set_shader_parameter("crest_color", secondary_bg.darkened(0.1))
	atmosphere_rect.material.set_shader_parameter("fog_color", ternary_bg)

	new_game_button.set_theme_type_variation("StartMenuButton")
	load_game_button.set_theme_type_variation("StartMenuButton")
	settings_button.set_theme_type_variation("StartMenuButton")
	mods_button.set_theme_type_variation("StartMenuButton")
	quit_button.set_theme_type_variation("StartMenuButton")


func play_animation() -> void:
	var tween: Tween
	var fade_duration: float = 9.0
	fade_rect.color = ProjectSettings.get_setting("gui/theme/scheme/ternary_bg")

	# skip fade-in if so configured
	var play_animation: bool = !Service.config_manager.general_settings.skip_intro
	if not play_animation:
		fade_rect.visible = false
		return

	# prepare titlebar and buttons
	label_title.modulate.a = 0.0
	for child: Control in nav_buttons.get_children():
		if child is UIButtonStartMenu:
			var button: UIButtonStartMenu = child
			button.modulate.a = 0.0
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button.focus_mode = Control.FOCUS_NONE
			buttons.append(button)

	# start intro
	# fade out: TRANS_CUBIC/EASE_OUT unfolds starfield over fade_duration
	tween = Common.Util.new_tween(fade_rect, "modulate:a", 0.0, fade_duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)

	# wait a little, and play the rest
	await get_tree().create_timer(0.5).timeout

	# fade in titlebar: TRANS_BACK/EASE_OUT creates a pop effect
	tween = Common.Util.new_tween(label_title, "modulate:a", 1.0, 2.0, Tween.TRANS_BACK, Tween.EASE_OUT)
	await get_tree().create_timer(0.5).timeout

	# fade in menu buttons: reposition x with TRANS_QUAD/EASE_OUT creates a snap-back effect
	buttons.reverse()
	for button: Button in buttons:
		var pos: int = button.position.x
		button.position.x += 100
		tween = Common.Util.new_tween(button, "modulate:a", 1.0, 0.1, Tween.TRANS_BACK, Tween.EASE_OUT)
		await tween.finished
		tween = Common.Util.new_tween(button, "position:x", pos, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.focus_mode = Control.FOCUS_ALL

	# highlight continue button if available
	#var highlight: Color = Color("#D7A54D")
	#if ui_continue.visible:
		#ui_continue.scale = Vector2(1.2, 1.2)
		#var return_to: Color = ui_continue.modulate
		#ui_continue.modulate = highlight
		#tween = Common.Util.new_tween(ui_continue, "scale", Vector2(1.0, 1.0), 1, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
		#tween.parallel().tween_property(ui_continue, "modulate", return_to, 1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		#await tween.finished
		##ui_continue.grab_focus()


func transition_to(p_menu: SubMenu, p_path: String) -> void:
	var tween: Tween
	label_title.visible = false

	var menu: Control
	if active.has(p_menu):
		menu = active.get(p_menu)
		nav_menu.visible = false
		menu.visible = true
	else:
		nav_menu.visible = false
		menu = Service.scene_manager._create_from_path(p_path)#, UI.ContainerType.MENU)
		nav_content.add_child(menu)
		active[p_menu] = menu

	# modulate menu to transparent and fade in
	menu.modulate.a = 0.0
	tween = Common.Util.new_tween(menu, "modulate:a", 1.0, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)


func _connect_signals() -> void:
	EventBus.menu_closed.connect(_on_menu_closed)
	EventBus.viewport_resized.connect(_on_viewport_resized)

	new_game_button.tweened.connect(transition_to.bind(SubMenu.NEW, FileLocation.UI_NEW_GAME_MENU))
	# load
	settings_button.tweened.connect(transition_to.bind(SubMenu.SETTINGS, FileLocation.UI_SETTINGS_MENU))
	mods_button.tweened.connect(transition_to.bind(SubMenu.MODS, FileLocation.UI_MOD_MENU))
	quit_button.tweened.connect(_on_quit_pressed)


func _on_menu_closed(p_menu: Control) -> void:
	var tween: Tween

	# fade out menu (reset menu here if needed)
	tween = Common.Util.new_tween(p_menu, "modulate:a", 0.0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	await tween.finished
	p_menu.visible = false

	# set title/menu as transparent, and fade back in
	label_title.modulate.a = 0.0
	nav_menu.modulate.a = 0.0

	label_title.visible = true
	nav_menu.visible = true

	tween = Common.Util.new_tween(nav_menu, "modulate:a", 1.0, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.parallel().tween_property(label_title, "modulate:a", 1.0, 0.6)


func _on_quit_pressed() -> void:
	if await Service.dialog_manager.get_confirmation("QUIT TO DESKTOP?"):
		Common.Util.quit()


func _on_viewport_resized(p_viewport_size: Vector2) -> void:
	starfield_texture.material.set_shader_parameter("viewport_size", p_viewport_size)
