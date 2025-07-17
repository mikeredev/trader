class_name Building extends Interactable

enum PlacementBias { NONE, SHORE }

var building_id: StringName
var city_id: StringName


@export_category("Exterior")
@export var placement_bias: PlacementBias
@export var exterior_scene: PackedScene # tscn, the building in the city
@export var exterior_size: Vector2i # representing the tile size in the atlas map (e.g., 5,4)

@export_category("Interior")
@export var interior_scene: PackedScene # tscn, the building interior (NPCs will be in here)
#var actions: Dictionary[StringName, BuildingAction] # TBD - assign actions to building, or to NPCs? eg "open trade menu"
