class_name PlayerBody extends CharacterBody


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		var interactions: Array[Area2D] = interact.get_overlapping_areas()
		if interactions.is_empty(): return
		var area: Area2D = interactions[0]
		if area is InterationArea2D:
			var object: InterationArea2D = area
			object.interact_with_body(self)
		else:
			Debug.log_warning("No interaction defined: %s" % area.name)


func _physics_process(_delta: float) -> void:
	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	moving = input.length() > 0

	if moving:
		velocity = input * speed
		_update_sprite(input)
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction)

	move_and_slide()


func to_dict() -> Dictionary[String, Variant]:
	return {
		"position": position as Vector2i,
	}


func _update_sprite(input: Vector2) -> void:
	match input:
		Vector2.LEFT:
			sprite.flip_h = true
			#interact.position = Vector2.ZERO - Vector2(10, 0)
		Vector2.RIGHT:
			sprite.flip_h = false
			#interact.position = Vector2.ZERO + Vector2(10, 0)
		#Vector2.UP:
			#interact.position = Vector2.ZERO + Vector2(0, -10)
		#Vector2.DOWN:
			#interact.position = Vector2.ZERO + Vector2(0, 10)
