class_name CharacterBody extends CharacterBody2D

var speed: int = 300
var moving: bool = false
var friction: int = 1

var profile_id: StringName
var sprite: Sprite2D
var interact: InterationArea2D
var collide: CollisionShape2D
var remote_transform: RemoteTransform2D


func _init(p_interact_with: Object) -> void:
	interact = InterationArea2D.new(p_interact_with)
	collide = CollisionShape2D.new()
	remote_transform = RemoteTransform2D.new()


func _ready() -> void:
	add_child(remote_transform)
	add_collision()
	add_interact()


func add_collision() -> void:
	var shape: CapsuleShape2D = CapsuleShape2D.new()
	collide.shape = shape
	add_child(collide)


func add_interact() -> void:
	interact.collision_layer = Common.Collision.INTERACT
	interact.collision_mask = Common.Collision.INTERACT
	add_child(interact)
	var interact_collision: CollisionShape2D = CollisionShape2D.new()
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = 30
	interact_collision.shape = shape
	interact.add_child(interact_collision)
