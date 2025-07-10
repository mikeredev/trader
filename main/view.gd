class_name View extends SubViewportContainer

enum ViewType { OVERWORLD, CITY, INTERIOR }
enum ContainerType { MAP, VILLAGE, CITY, SUPPLY_PORT, SHIP, SCENE }

var subviewport: SubViewport
var camera: Camera
var _containers: Dictionary[ContainerType, NodeContainer] # everything in a container is freed on soft reset


func add_container(p_type: ContainerType, p_container: NodeContainer) -> void:
	_containers[p_type] = p_container


func add_scene(p_scene: Node, p_container: ContainerType) -> Node:
	var container: NodeContainer = get_container(p_container)
	container.add_child(p_scene)
	Debug.log_debug("Created scene: %s" % p_scene.get_path())
	return p_scene


#func clear_container(p_type: ContainerType) -> void:
	#var container: NodeContainer = get_container(p_type)
	#_clear_container(container)


func clear_view() -> void:
	Debug.log_debug("Clearing view: %s" % get_path())
	for container: NodeContainer in _containers.values():
		_clear_container(container)


func get_container(p_type: ContainerType) -> NodeContainer:
	return _containers.get(p_type, null)


func set_active(p_toggled_on: bool) -> void:
	camera.enabled = p_toggled_on
	visible = p_toggled_on
	#Debug.log_verbose("Set view active: %s, %s" % [self.name, p_toggled_on])


func _clear_container(p_container: NodeContainer) -> void:
	for node: Node in p_container.get_children():
		p_container.remove_child(node)
		node.call_deferred("queue_free")
		Debug.log_verbose("Freed scene: %s" % node)


func setup() -> bool:
	# match name to enum
	if not View.ViewType.keys().has(name.to_upper()):
		Debug.log_error("Invalid view name: %s, expected: %s" % [name, View.ViewType.keys()])
		return false

	# verify subviewport
	if not (get_child_count() > 0 and get_child(0) is SubViewport):
		Debug.log_error("%s requires subviewport" % self)
		return false

	# get View type
	var type: View.ViewType
	for i: int in range(View.ViewType.size()):
		if View.ViewType.keys()[i] == name.to_upper():
			type = View.ViewType.values()[i]

	# set properties common across all Views
	subviewport = get_child(0)
	stretch = true

	# create parent Node2D for containers
	var container_parent: Node2D = Node2D.new()
	container_parent.name = "View"
	container_parent.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	subviewport.add_child(container_parent)
	Debug.log_verbose("  Created container: %s" % container_parent.get_path())

	# assign containers
	var default_containers: Array[View.ContainerType] = []
	match type:
		View.ViewType.OVERWORLD:
			default_containers = [
				View.ContainerType.MAP, View.ContainerType.VILLAGE, View.ContainerType.SUPPLY_PORT,
				View.ContainerType.CITY, View.ContainerType.SHIP ]
		View.ViewType.CITY:
			default_containers = [ View.ContainerType.SCENE ]
		View.ViewType.INTERIOR:
			default_containers = [ View.ContainerType.SCENE ]

	# add containers to container parent
	for container_type: View.ContainerType in default_containers:
		var container: NodeContainer = NodeContainer.new()
		container.name = str(View.ContainerType.keys()[container_type]).to_pascal_case()
		container_parent.add_child(container)

		# register container for lookup
		add_container(container_type, container)
		Debug.log_verbose("  Created layer: %s/%s" % [container.get_parent().name, container.name])

	# create camera under container_parent
	camera = Camera.new()
	camera.name = "Camera"
	container_parent.add_child(camera)
	Debug.log_verbose("  Created camera: %s/%s" % [camera.get_parent().name, camera.name])

	# start disabled
	set_active(false)

	# register view for lookup
	System.manage.scene.add_view(type, self)
	return true
