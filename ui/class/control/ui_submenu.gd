## A template for in-menu subsections, e.g., [code]Start>Settings[/code].
## Overwrite [method _connect_signals] and [method _set_button_shortcuts] and call [method _ui_ready].
## Usually used from within a [UIControl].
class_name UISubMenu extends Control


func _ready() -> void:
	_connect_signals()
	_set_button_shortcuts()
	_ui_ready()


func _connect_signals() -> void: ## Connect signals here.
	pass


func _set_button_shortcuts() -> void: ## Set button shortcuts here.
	pass


func _ui_ready() -> void: ## Runs after signals and shortcuts are connected.
	pass
