class_name NotificationArea extends ScrollContainer

const BOX: PackedScene = FileLocation.NOTIFICATION_BOX
var tween: Tween

@export var duration: float = 0.5
@export var _in_type: Tween.TransitionType = Tween.TRANS_SPRING
@export var _in_ease: Tween.EaseType = Tween.EASE_OUT
@export var _out_type: Tween.TransitionType = Tween.TRANS_BACK
@export var _out_ease: Tween.EaseType = Tween.EASE_OUT

@onready var alert_stack: VBoxContainer = %AlertStack


func setup() -> void:
	EventBus.create_notification.connect(create_notification)
	mouse_filter = Control.MOUSE_FILTER_IGNORE # TBD dynamically set this to ignore when alerts > 0


func create_notification(p_text: String) -> void:
	var box: NotificationBox = BOX.instantiate()
	box.remove.connect(remove_notification.bind(box))
	box.modulate.a = 0.0
	var height: int = int(box.size.y)

	# expand notification area fit first alert
	if alert_stack.get_child_count() == 0:
		alert_stack.size.y = height

	else: # or move the existing boxes downward
		for child: NotificationBox in alert_stack.get_children():
			var target: int = int(child.position.y) + height
			tween = get_tree().create_tween()
			tween.tween_property(child, "position:y", target, duration). \
			set_trans(_in_type).set_ease(_in_ease)
		await tween.finished

	# with the space cleared, add the invisible object to the stack
	alert_stack.add_child(box)
	alert_stack.move_child(box, 0)
	box.configure(p_text)

	# and reveal it
	tween = get_tree().create_tween()
	tween.tween_property(box, "modulate:a", 1.0, duration)

	# add a self-destruct timer (TBD needs severity)
	var timer: Timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	box.add_child(timer)
	timer.timeout.connect(func() -> void: remove_notification(box) )
	timer.start()


func remove_notification(p_box: NotificationBox) -> void:
	# prevent further clicks
	p_box.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# fade it out while retaining its space
	tween = get_tree().create_tween()
	tween.tween_property(p_box, "modulate:a", 0.0, duration)

	# reposition every box underneath it
	var idx: int = _get_index(p_box)
	var offset: int = int(p_box.size.y)
	for i: int in range(idx + 1, alert_stack.get_child_count()):
		var box: NotificationBox = alert_stack.get_child(i)
		var target: int = int(box.position.y - offset)
		tween = get_tree().create_tween()
		tween.tween_property(box, "position:y", target, duration). \
		set_trans(_out_type).set_ease(_out_ease)

	# and remove it
	await tween.finished
	p_box.queue_free()


func _get_index(p_box: NotificationBox) -> int:
	for i: int in range(alert_stack.get_child_count()):
		var box: NotificationBox = alert_stack.get_child(i)
		if box == p_box:
			return i
	return -1
