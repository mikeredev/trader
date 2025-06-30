class_name UIContainer extends Control

#func _ready() -> void:
	#size = get_parent_area_size()
	#set_anchors_preset(Control.PRESET_FULL_RECT)
	#mouse_filter = Control.MOUSE_FILTER_IGNORE
