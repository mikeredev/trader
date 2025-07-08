class_name InfoBar extends PanelContainer

@onready var component_stack: HBoxContainer = %ComponentStack
@onready var ui_location: Label = %LabelLocation
@onready var ui_fps: Label = %LabelFPS
@onready var ui_zoom: Label = %LabelZoom
@onready var ui_clock: Label = %LabelClock


func setup() -> void:
	EventBus.camera_zoomed.connect(_on_camera_zoomed)
	#add_location()
	#add_fps()
	#add_zoom()
	#add_clock()


func add_location() -> void:
	var label: Label = Label.new()
	label.text = "NO_LOCATION"
	component_stack.add_child(label)


func add_fps() -> void:
	var label: Label = Label.new()
	label.text = "%d FPS" % 0.0
	component_stack.add_child(label)


func add_zoom() -> void:
	var label: Label = Label.new()
	label.text = "%.03f zoom" % 0.0
	component_stack.add_child(label)


func add_clock() -> void:
	var label: Label = Label.new()
	label.text = "1970-01-01T00:00:00"
	component_stack.add_child(label)
	label.size_flags_horizontal = Control.SIZE_SHRINK_END | Control.SIZE_EXPAND


func _on_camera_zoomed(p_zoom_level: Vector2) -> void:
	var zoom: float = max(p_zoom_level.x, p_zoom_level.y)
	ui_zoom.text = "%.03fx zoom" % zoom


func _on_check_cam_control_toggled(p_toggled_on: bool) -> void:
	var view: View = Service.scene_manager.get_active_view()
	if not view: return

	var camera: Camera = view.get_camera()
	camera.set_cam_control(p_toggled_on)
