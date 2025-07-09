class_name View extends SubViewportContainer

enum ViewType { OVERWORLD, CITY, INTERIOR }
enum ContainerType { MAP, VILLAGE, CITY, SUPPLY_PORT, SHIP, SCENE }

var subviewport: SubViewport
var _containers: Dictionary[ContainerType, NodeContainer] # everything in a container is freed on soft reset
var _camera: Camera
var _active: bool: # debug mode
	set(p):
		_active = p
		set_active(_active)
		return _active


func add_camera(p_camera: Camera) -> void:
	_camera = p_camera


func add_container(p_type: ContainerType, p_container: NodeContainer) -> void:
	_containers[p_type] = p_container


#func add_scene(p_scene: Node, p_container: ContainerType) -> Node:
	#var container: NodeContainer = get_container(p_container)
	#container.add_child(p_scene)
	#Debug.log_debug("Created scene: %s" % p_scene.get_path())
	#return p_scene


#func clear_container(p_type: ContainerType) -> void:
	#var container: NodeContainer = get_container(p_type)
	#container.clear()


func clear_view() -> void:
	for container: NodeContainer in _containers.values():
		container.clear()
	Debug.log_verbose("Cleared view: %s" % name)


func get_camera() -> Camera:
	return _camera


func get_container(p_type: ContainerType) -> NodeContainer:
	return _containers.get(p_type, null)


func set_active(p_toggled_on: bool) -> void:
	var camera: Camera = get_camera()
	camera.enabled = p_toggled_on
	visible = p_toggled_on
	Debug.log_verbose("Set view active: %s, %s" % [self.name, p_toggled_on])


func setup() -> bool:
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
	Debug.log_verbose("  Created container parent: %s" % container_parent.get_path())

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

		# register for lookup
		add_container(container_type, container)
		Debug.log_verbose("  Created container: %s" % container.get_path())

	# create camera under container_parent
	var camera: Camera = Camera.new()
	camera.name = "%sCamera" % name
	container_parent.add_child(camera)
	add_camera(camera)
	Debug.log_verbose("  Created camera: %s" % camera.get_path())

	# start disabled
	set_active(false)

	# register View for lookup
	Service.scene_manager.register_view(type, self)
	return true
