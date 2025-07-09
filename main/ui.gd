class_name UI extends CanvasLayer

@onready var menu: UIOverlay = %Menu
@onready var dialog: UIOverlay = %Dialog
@onready var hud: UIOverlay = %HUD


func clear_all() -> void:
	for node: UIOverlay in get_children():
		node.clear()
	Debug.log_verbose("Cleared all UI overlays")
