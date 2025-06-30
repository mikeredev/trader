class_name UI extends CanvasLayer

enum ContainerType { SPLASH, MENU, DIALOG, NOTIFICATION }

var containers: Dictionary[ContainerType, UIContainer]


func setup() -> void:
	# create UI containers
	for container_name: String in ContainerType.keys():
		var node: UIContainer = UIContainer.new()
		node.name = container_name.to_pascal_case()
		self.add_child(node)

		node.size = node.get_parent_area_size()
		node.set_anchors_preset(Control.PRESET_FULL_RECT)
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE

		# match name to type
		var type: ContainerType
		for i: int in range(ContainerType.size()):
			if container_name == ContainerType.keys()[i]:
				type = ContainerType.values()[i]
				containers[type] = node
				Debug.log_verbose("󱣴  Created UI container: %s" % node.get_path())

		# set theme by type
		match type:
			ContainerType.DIALOG: node.theme = load(FileLocation.THEME_DIALOG)
			ContainerType.MENU: node.theme = load(FileLocation.THEME_MENU)


func get_container(p_type: ContainerType) -> UIContainer:
	return containers.get(p_type, null)
