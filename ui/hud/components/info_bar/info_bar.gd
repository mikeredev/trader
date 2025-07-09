class_name InfoBar extends PanelContainer

@onready var component_stack: HBoxContainer = %ComponentStack
@onready var ui_location: Label = %LabelLocation
@onready var ui_fps: Label = %LabelFPS
@onready var ui_cam_devmode: CheckButton = %CameraDevMode
@onready var ui_cam_zoom: Label = %CameraZoom
@onready var ui_clock: Label = %LabelClock


func setup() -> void:
	EventBus.camera_zoomed.connect(_on_camera_zoomed)
	EventBus.city_entered.connect(_on_city_entered)
	ui_cam_devmode.toggled.connect(_on_cam_devmode_toggled)
	#add_location()
	#add_fps()
	#add_zoom()
	#add_clock()


func add_location() -> void:
	ui_location = Label.new()
	ui_location.text = "NO_LOCATION"
	component_stack.add_child(ui_location)


#func add_fps() -> void:
	#var label: Label = Label.new()
	#label.text = "%d FPS" % 0.0
	#component_stack.add_child(label)
#
#
#func add_zoom() -> void:
	#var label: Label = Label.new()
	#label.text = "%.03f zoom" % 0.0
	#component_stack.add_child(label)
#
#
#func add_clock() -> void:
	#var label: Label = Label.new()
	#label.text = "1970-01-01T00:00:00"
	#component_stack.add_child(label)
	#label.size_flags_horizontal = Control.SIZE_SHRINK_END | Control.SIZE_EXPAND


func _on_cam_devmode_toggled(p_toggled_on: bool) -> void:
	var view: View = Service.scene_manager.get_active_view()
	if not view: return

	Debug.log_info("Camera devmode toggled: %s" % p_toggled_on)
	view.camera.enable_devmode(p_toggled_on)


func _on_camera_zoomed(p_zoom_level: Vector2) -> void:
	var zoom: float = max(p_zoom_level.x, p_zoom_level.y)
	ui_cam_zoom.text = "%.03fx" % zoom


func _on_city_entered(p_city: City) -> void:
	ui_location.text = p_city.city_id
