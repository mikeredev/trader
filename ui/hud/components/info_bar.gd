class_name InfoBar extends PanelContainer

@onready var component_stack: HBoxContainer = %ComponentStack
@onready var ui_location: Label = %LabelLocation
@onready var ui_sublocation: Label = %LabelSublocation
@onready var ui_fps: Label = %LabelFPS
@onready var ui_cam_devmode: CheckButton = %CameraDevMode
@onready var ui_cam_zoom: Label = %CameraZoom
@onready var ui_clock: Label = %LabelClock


func _ready() -> void:
	ui_sublocation.visible = false


func setup() -> void:
	EventBus.camera_zoomed.connect(_on_camera_zoomed)
	EventBus.city_entered.connect(_on_city_entered)
	EventBus.building_entered.connect(_on_building_entered)
	ui_cam_devmode.toggled.connect(_on_cam_devmode_toggled)


func _on_building_entered(p_building: Building) -> void:
	ui_sublocation.visible = true
	ui_sublocation.text = p_building.building_id


func _on_cam_devmode_toggled(p_toggled_on: bool) -> void:
	var view: View = System.manage.scene.get_active_view()
	if not view: return

	Debug.log_info("Camera devmode toggled: %s" % p_toggled_on)
	view.camera.enable_devmode(p_toggled_on)


func _on_camera_zoomed(p_zoom_level: Vector2) -> void:
	var zoom: float = max(p_zoom_level.x, p_zoom_level.y)
	ui_cam_zoom.text = "%.03fx" % zoom


func _on_city_entered(p_city: City) -> void:
	ui_location.text = p_city.city_id
