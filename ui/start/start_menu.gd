class_name StartMenu extends UIControl

enum SubMenuType { NEW, LOAD, SETTINGS, MODS }

const FADE_INTRO: float = 9.0
const PAUSE: float = 0.5
const TITLE_IN: float = 2.0
const BUTTON_ALPHA: float = 0.1
const BUTTON_SLIDE: float = 0.2
const MENU_IN: float = 0.6
const MENU_OUT: float = 0.2

var tween: Tween
var buttons: Array[UIButtonStartMenu]
var cache: Dictionary[SubMenuType, UISubMenu]

@onready var margin_outer: MarginContainer = %MarginOuter
@onready var nav_main: Control = %NavMain
@onready var nav_menu: VBoxContainer = %NavMenu
@onready var nav_buttons: GridContainer = %NavButtons
@onready var nav_content: VBoxContainer = %NavContent

@onready var continue_button: UIButtonStartMenu = %ContinueButton
@onready var new_game_button: UIButtonStartMenu = %NewGameButton
@onready var load_game_button: UIButtonStartMenu = %LoadGameButton
@onready var mods_button: UIButtonStartMenu = %ModsButton
@onready var settings_button: UIButtonStartMenu = %SettingsButton
@onready var quit_button: UIButtonStartMenu = %QuitButton

@onready var arrow_icon_continue: TextureRect = %ArrowIconContinue
@onready var arrow_icon_new: TextureRect = %ArrowIconNew
@onready var arrow_icon_load: TextureRect = %ArrowIconLoad
@onready var arrow_icon_mods: TextureRect = %ArrowIconMods
@onready var arrow_icon_settings: TextureRect = %ArrowIconSettings
@onready var arrow_icon_quit: TextureRect = %ArrowIconQuit

@onready var sky_rect: ColorRect = %SkyRect
@onready var starfield_texture: TextureRect = %Starfield
@onready var atmosphere_rect: ColorRect = %Atmosphere
@onready var fade_rect: ColorRect = %Fade
@onready var label_title: Label = %LabelTitle


func _connect_signals() -> void:
	EventBus.viewport_resized.connect(_on_viewport_resized)

	continue_button.mouse_entered.connect(_on_mouse_entered.bind(arrow_icon_continue))
	continue_button.mouse_exited.connect(_on_mouse_exited.bind(arrow_icon_continue))
	continue_button.pressed_tweened.connect(get_submenu.bind(SubMenuType.NEW, FileLocation.UI_NEW_GAME_MENU)) # tbd

	new_game_button.mouse_entered.connect(_on_mouse_entered.bind(arrow_icon_new))
	new_game_button.mouse_exited.connect(_on_mouse_exited.bind(arrow_icon_new))
	new_game_button.pressed_tweened.connect(get_submenu.bind(SubMenuType.NEW, FileLocation.UI_NEW_GAME_MENU))

	load_game_button.mouse_entered.connect(_on_mouse_entered.bind(arrow_icon_load))
	load_game_button.mouse_exited.connect(_on_mouse_exited.bind(arrow_icon_load))
	load_game_button.pressed_tweened.connect(get_submenu.bind(SubMenuType.NEW, FileLocation.UI_LOAD_MENU))

	mods_button.mouse_entered.connect(_on_mouse_entered.bind(arrow_icon_mods))
	mods_button.mouse_exited.connect(_on_mouse_exited.bind(arrow_icon_mods))
	mods_button.pressed_tweened.connect(get_submenu.bind(SubMenuType.MODS, FileLocation.UI_MOD_MENU))

	settings_button.mouse_entered.connect(_on_mouse_entered.bind(arrow_icon_settings))
	settings_button.mouse_exited.connect(_on_mouse_exited.bind(arrow_icon_settings))
	settings_button.pressed_tweened.connect(get_submenu.bind(SubMenuType.SETTINGS, FileLocation.UI_SETTINGS_MENU))

	quit_button.mouse_entered.connect(_on_mouse_entered.bind(arrow_icon_quit))
	quit_button.mouse_exited.connect(_on_mouse_exited.bind(arrow_icon_quit))
	quit_button.pressed_tweened.connect(_on_quit_pressed)


func _set_color_scheme() -> void:
	var primary_bg: Color = ProjectSettings.get_setting("gui/theme/scheme/primary_bg")
	var secondary_bg: Color = ProjectSettings.get_setting("gui/theme/scheme/secondary_bg")
	var ternary_bg: Color = ProjectSettings.get_setting("gui/theme/scheme/ternary_bg")

	(sky_rect.material as ShaderMaterial).set_shader_parameter("sky_color", primary_bg)
	(sky_rect.material as ShaderMaterial).set_shader_parameter("sea_color", secondary_bg)
	(sky_rect.material as ShaderMaterial).set_shader_parameter("crest_color", secondary_bg.darkened(0.1))
	(atmosphere_rect.material as ShaderMaterial).set_shader_parameter("fog_color", ternary_bg)
	fade_rect.color = ProjectSettings.get_setting("gui/theme/scheme/primary_bg")


func _ui_ready() -> void:
	_housekeeping()
	play_animation()


func get_submenu(p_submenu: SubMenuType, p_path: String) -> void:
	# fade out label_title and nav_menu
	tween = Service.scene_manager.create_tween(nav_buttons, "modulate:a", 0.0, MENU_OUT)
	tween.parallel().tween_property(label_title, "modulate:a", 0.0, MENU_OUT)
	await tween.finished

	var submenu: UISubMenu
	if cache.has(p_submenu):
		submenu = cache.get(p_submenu)
		submenu.visible = true # already modulated to 0
	else:
		submenu = Service.scene_manager.create_scene(p_path)
		submenu.submenu_closed.connect(_on_menu_closed.bind(submenu))
		submenu.modulate.a = 0.0
		nav_content.add_child(submenu)
		cache[p_submenu] = submenu

	# modulate submenu to transparent and fade in
	tween = Service.scene_manager.create_tween(submenu, "modulate:a", 1.0, MENU_IN)


func play_animation() -> void:
	if not Service.config_manager.general_settings.show_intro: return

	# prepare tween, title, buttons
	fade_rect.visible = true
	label_title.modulate.a = 0.0
	for button: UIButtonStartMenu in buttons:
		button.modulate.a = 0.0
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.focus_mode = Control.FOCUS_NONE

	# fade out: TRANS_CUBIC/EASE_OUT unfolds starfield over fade_duration
	tween = Service.scene_manager.create_tween(fade_rect, "modulate:a", 0.0, FADE_INTRO, Tween.TRANS_CUBIC, Tween.EASE_OUT)

	# wait a little, and play the rest
	await get_tree().create_timer(PAUSE).timeout

	# fade in title: TRANS_BACK/EASE_OUT creates a pop effect
	tween = Service.scene_manager.create_tween(label_title, "modulate:a", 1.0, TITLE_IN, Tween.TRANS_BACK, Tween.EASE_OUT)
	await get_tree().create_timer(PAUSE).timeout

	# fade in menu buttons: reposition x with TRANS_QUAD/EASE_OUT creates a snap-back effect
	buttons.reverse()
	for button: Button in buttons:
		var pos: float = button.position.x
		button.position.x += 100
		tween = Service.scene_manager.create_tween(button, "modulate:a", 1.0, BUTTON_ALPHA, Tween.TRANS_BACK, Tween.EASE_OUT)
		await tween.finished
		tween = Service.scene_manager.create_tween(button, "position:x", pos, BUTTON_SLIDE, Tween.TRANS_QUAD, Tween.EASE_OUT)
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.focus_mode = Control.FOCUS_ALL

	# highlight continue button if available
	var highlight: Color = Color("#D7A54D")
	if continue_button.visible:
		var return_to: Color = continue_button.modulate
		continue_button.scale = Vector2(1.2, 1.2)
		continue_button.modulate = highlight
		tween = Service.scene_manager.create_tween(continue_button, "scale", Vector2(1.0, 1.0), 1.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
		tween.parallel().tween_property(continue_button, "modulate", return_to, 1.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		await tween.finished


func _housekeeping() -> void:
	fade_rect.visible = false # remains unused unless playing animation

	for node: Control in nav_buttons.get_children():
		if node is UIButtonStartMenu:
			var button: UIButtonStartMenu = node
			button.set_theme_type_variation("StartMenuButton")
			buttons.append(button)

		if node is TextureRect: # arrow selector is modulated back in on mouseover
			var texture: TextureRect = node
			texture.modulate.a = 0.0


func _on_menu_closed(p_submenu: Control) -> void:
	# fade out submenu (reset menu here if needed)
	tween = Service.scene_manager.create_tween(p_submenu, "modulate:a", 0.0, MENU_OUT, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	await tween.finished
	p_submenu.visible = false

	# fade back in button nav/label, modulated out in get_submenu
	nav_buttons.visible = true
	label_title.visible = true
	tween = Service.scene_manager.create_tween(nav_buttons, "modulate:a", 1.0, MENU_IN, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.parallel().tween_property(label_title, "modulate:a", 1.0, MENU_IN)


func _on_quit_pressed() -> void:
	if await Service.scene_manager.get_confirmation("QUIT TO DESKTOP?"):
		System.quit_game()


func _on_mouse_entered(p_icon: TextureRect) -> void:
	p_icon.modulate.a = 1.0


func _on_mouse_exited(p_icon: TextureRect) -> void:
	p_icon.modulate.a = 0.0


func _on_viewport_resized(p_viewport_size: Vector2) -> void:
	(starfield_texture.material as ShaderMaterial).set_shader_parameter("viewport_size", p_viewport_size)
