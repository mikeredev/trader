class_name CharacterBody extends CharacterBody2D

var sprite: Sprite2D
var interaction_area: Area2D
var remote_transform: RemoteTransform2D = RemoteTransform2D.new()

var speed: int = 300
var moving: bool = false
var friction: int = 1


func _ready() -> void:
	add_child(remote_transform)
