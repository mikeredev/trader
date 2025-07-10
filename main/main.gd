extends Control

@export var log_level: Debug.Severity = Debug.Severity.DEBUG:
	set(p):
		log_level = p
		Debug.threshold = log_level
		Debug.log_info("Set log threshold %d: %s" % [log_level, Debug.Severity.keys()[log_level]])
		return log_level

@export var color_scheme: ColorScheme


func _ready() -> void:
	# connect project-wide signals
	item_rect_changed.connect(_on_item_rect_changed)

	# apply runtime overrides / pass this to init state TBD
	color_scheme.apply()

	# connect statics
	Debug.connect_signals()

	# move to first core loop state: initialize environment
	var node_tree: Array[Node] = self.get_children()
	System.state.change(InitState.new(node_tree))


func _on_item_rect_changed() -> void:
	EventBus.viewport_resized.emit(DisplayServer.window_get_size())
