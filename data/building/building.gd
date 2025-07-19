class_name Building extends Resource

enum PlacementBias { NONE, SHORE }

var building_id: StringName
var city_id: StringName
var master: NPC
var scene: BuildingScene
var view: View

@export_category("Interface")
@export var actions: Array[Action]

@export_category("Exterior")
@export var placement_bias: PlacementBias
@export var exterior_scene: PackedScene # tscn, the building in the city
@export var exterior_size: Vector2i # representing the tile size in the atlas map (e.g., 5,4)

@export_category("Interior")
@export var interior_scene: PackedScene # tscn, the building interior (NPCs will be in here)
#var actions: Dictionary[StringName, BuildingAction] # TBD - assign actions to building, or to NPCs? eg "open trade menu"


func _init() -> void:
	view = System.manage.scene.get_view(View.ViewType.INTERIOR)


func interact_with(p_character: Character) -> void:
	var city: City = App.context.city.get_city(city_id)
	App.context.city.enter_building(city, self, p_character)
