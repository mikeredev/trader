extends Node

var context: AppServiceLocator = AppServiceLocator.new()

var _cache: Node2D # ensure wiped on reset NOTE


func create_cache() -> void:
	_cache = Node2D.new()
	_cache.name = "Cache"
	_cache.visible = false
	_cache.process_mode = Node.PROCESS_MODE_DISABLED
	self.add_child(_cache)
	Debug.log_debug("Created node cache: %s" % _cache.get_path())


func get_cache() -> Node2D:
	return _cache
