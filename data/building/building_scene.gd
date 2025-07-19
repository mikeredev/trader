class_name BuildingScene extends Node2D

var building_id: StringName
var city_id: StringName
var view: View
var tile_size: int

@onready var sprite_group: Node2D = %Sprites
@onready var entry_point: Marker2D = %EntryPoint
@onready var exit_point: Area2D = %ExitPoint
@onready var master_point: Marker2D = %MasterPoint # npc stands here
@onready var floor_layer: TileMapLayer = %Floor # must cover entire area for base_size
@onready var base_size: Vector2i = floor_layer.get_used_rect().size * tile_size


func _init() -> void:
	view = System.manage.scene.get_view(View.ViewType.INTERIOR)
	tile_size = ProjectSettings.get_setting("services/config/default_tile_size")


func _ready() -> void:
	# connect signals
	EventBus.building_exited.connect(_on_building_exited)
	EventBus.viewport_resized.connect(_on_viewport_resized)

	# set camera
	view.camera.update_limits(base_size)

	# set collisions
	exit_point.collision_layer = 0
	exit_point.collision_mask = Common.Collision.PHYSICS


func _on_building_exited(_p_building: Building, _p_body: CharacterBody) -> void:
	Debug.log_verbose("Freeing scene: %s" % get_path())
	queue_free()


func _on_viewport_resized(p_viewport_size: Vector2) -> void:
	view.camera.set_min_zoom(p_viewport_size, base_size)


func _on_exit_point_body_entered(p_body: CharacterBody) -> void:
	Debug.log_verbose("%s is leaving building: %s (%s)" % [p_body.get_rid(), building_id, city_id])

	# disable body physics (prevents extra collision when reparenting)
	p_body.process_mode = Node.PROCESS_MODE_DISABLED
	await System.get_tree().process_frame

	# exit
	var city: City = App.context.city.get_city(city_id)
	var building: Building = city.buildings.get(building_id)
	App.context.city.exit_building(building, p_body)
