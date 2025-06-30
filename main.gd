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

	# start services
	AppContext.start_service(StateManager.new(), Service.Type.STATE_MANAGER)

	# setup any statics
	Debug.setup()
	Service.setup()

	# bootstrap environment
	var node_tree: Array[Node] = self.get_children()
	Service.state_manager.change_state(BootstrapState.new(node_tree))


func _on_item_rect_changed() -> void:
	EventBus.viewport_resized.emit(DisplayServer.window_get_size())
