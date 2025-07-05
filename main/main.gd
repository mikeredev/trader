extends Control

@export var log_level: Debug.Severity:
	set(p):
		log_level = p
		Debug.threshold = log_level
		Debug.log_info("Set log threshold %d: %s" % [log_level, Debug.Severity.keys()[log_level]])
		return log_level

@export var color_scheme: ColorScheme


func _ready() -> void:
	# connect signals
	item_rect_changed.connect(_on_item_rect_changed)

	# apply run-time color scheme
	color_scheme.apply()

	# setup any statics
	Debug.connect_signals()
	Service.connect_signals()

	# initialize environment
	var node_tree: Array[Node] = self.get_children()
	System.change_state(InitState.new(node_tree))


func _on_item_rect_changed() -> void:
	EventBus.viewport_resized.emit(DisplayServer.window_get_size())
