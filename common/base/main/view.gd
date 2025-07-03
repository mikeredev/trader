class_name View extends SubViewportContainer

enum Type { OVERWORLD, PORT, INTERIOR }
enum ContainerType { MAP, VILLAGE, CITY, SUPPLY_PORT, SHIP, SCENE, CAMERA }

var type: Type
var subviewport: SubViewport
var containers: Dictionary[ContainerType, NodeContainer] # everything in a container is freed on soft reset


#func clear_all() -> void:
	#for container: ContainerType in containers:
		#clear_container(container)
	#Debug.log_debug("Cleared all containers: %s" % self.name)
#
#
#func clear_container(p_type: ContainerType) -> void:
	#var container: NodeContainer = get_container(p_type)
	#for child: Node in container.get_children():
		#container.remove_child(child)
		#child.call_deferred("queue_free")
	#Debug.log_verbose("Cleared container: %s" % ContainerType.keys()[p_type])


func get_camera() -> Camera:
	var container: NodeContainer = get_container(ContainerType.CAMERA)
	assert(container.get_child_count() > 0 and container.get_child(0) is Camera)
	return container.get_child(0) as Camera


func get_container(p_type: ContainerType) -> NodeContainer:
	return containers.get(p_type, null)


func setup() -> bool: # TBD most of these should be in scene manager, inc this
	# validate
	if not Type.keys().has(self.name.to_upper()):
		Debug.log_warning("Unrecognized view: %s" % self)
		return false

	if not (get_child_count() > 0 and get_child(0) is SubViewport):
		Debug.log_warning("%s requires subviewport" % self)
		return false

	# set type
	for i: int in range(Type.size()):
		if Type.keys()[i] == self.name.to_upper():
			type = Type.values()[i]

	# configure basic settings
	self.stretch = true
	self.subviewport = self.get_child(0)

	# assign node containers
	var node_containers: Array[ContainerType] = []
	match type:
		Type.OVERWORLD:
			node_containers = [
				ContainerType.MAP, ContainerType.VILLAGE, ContainerType.SUPPLY_PORT,
				ContainerType.CITY, ContainerType.SHIP, ContainerType.CAMERA ]
		Type.PORT:
			node_containers = [ ContainerType.SCENE, ContainerType.CAMERA ]
		Type.INTERIOR:
			node_containers = [ ContainerType.SCENE, ContainerType.CAMERA ]

	# create node container root
	var container_root: Node2D = Node2D.new()
	container_root.name = "Containers"
	self.subviewport.add_child(container_root)
	Debug.log_verbose("  Created root: %s" % container_root.get_path())

	# add containers to tree under container root
	for container_type: ContainerType in node_containers:
		var node_container: NodeContainer = NodeContainer.new()
		node_container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		node_container.name = str(ContainerType.keys()[container_type]).to_pascal_case()
		container_root.add_child(node_container)

		# register container for lookup within this view
		containers[container_type] = node_container
		Debug.log_verbose("  Created container: %s" % node_container.get_path())

	# create camera (disabled)
	var container: NodeContainer = get_container(ContainerType.CAMERA)
	var camera: Camera = Camera.new()
	camera.name = "%s%s" % [self.name, "Camera"]
	camera.enabled = false
	container.add_child(camera)
	Debug.log_verbose("  Created camera: %s" % camera.get_path())

	return true


func set_active(p_toggled_on: bool) -> void:
	var camera: Camera = get_camera()
	camera.enabled = p_toggled_on
	self.visible = p_toggled_on
	Debug.log_debug("Set %s active: %s" % [self.name, p_toggled_on])
