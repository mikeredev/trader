class_name ModalOverlay extends Control

@onready var background: FadeRect = %Background
@onready var notifications: UIOverlay = %Notifications


func setup() -> void:
	EventBus.modal_closed.connect(_on_modal_closed)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	notifications.mouse_filter = Control.MOUSE_FILTER_IGNORE


func add_modal(p_scene: Variant, p_text: String, p_confirm_text: String, p_cancel_text: String) -> Control:
	var modal: Control = System.manage.scene.create_scene(p_scene)
	background.fade(true)
	notifications.add_scene(modal)
	modal.configure(p_text, p_confirm_text, p_cancel_text)
	return modal


func _on_modal_closed() -> void:
	background.fade(false)
