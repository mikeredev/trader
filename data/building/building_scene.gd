class_name BuildingScene extends Node2D

var view: View
var tile_size: int
@onready var background: TileMapLayer = %Background
@onready var base_size: Vector2i = background.get_used_rect().size * tile_size


func _init() -> void:
	view = System.manage.scene.get_view(View.ViewType.INTERIOR)
	tile_size = ProjectSettings.get_setting("services/config/default_tile_size")


func _ready() -> void:
	EventBus.viewport_resized.connect(_on_viewport_resized)
	view.camera.update_limits(base_size)


func _on_viewport_resized(p_viewport_size: Vector2) -> void:
	view.camera.set_min_zoom(p_viewport_size, base_size)
