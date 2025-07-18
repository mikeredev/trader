class_name BuildingScene extends Node2D

var view: View
var tile_size: int

var building_id: StringName
var city_id: StringName # return to city

@onready var sprite_group: Node2D = %Sprites
@onready var spawn_point: Marker2D = %SpawnPoint
@onready var exit_point: Area2D = %ExitPoint
@onready var floor_layer: TileMapLayer = %Floor # must cover entire area for base_size
@onready var base_size: Vector2i = floor_layer.get_used_rect().size * tile_size


func _init() -> void:
	view = System.manage.scene.get_view(View.ViewType.INTERIOR)
	tile_size = ProjectSettings.get_setting("services/config/default_tile_size")


func _ready() -> void:
	EventBus.viewport_resized.connect(_on_viewport_resized)
	view.camera.update_limits(base_size)
	exit_point.collision_layer = 0
	exit_point.collision_mask = Common.Collision.PHYSICS


func _on_viewport_resized(p_viewport_size: Vector2) -> void:
	view.camera.set_min_zoom(p_viewport_size, base_size)


func _on_exit_point_body_entered(p_body: CharacterBody) -> void:
	Debug.log_verbose("%s is leaving building: %s (%s)" % [p_body.get_rid(), building_id, city_id])

	# disable body physics and await frame (prevents extra collision when reparenting)
	p_body.process_mode = Node.PROCESS_MODE_DISABLED
	await System.get_tree().process_frame

	# exit
	var city: City = App.context.city.get_city(city_id)
	var building: Building = city.buildings.get(building_id)
	building.exit_building(p_body)
