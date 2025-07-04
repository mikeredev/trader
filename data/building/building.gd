class_name Building extends Resource

@export var building_id: StringName # for lookup
#var city_id: StringName # which city it is in
@export var size: Vector2i # representing the tile size in the atlas map (e.g., 5,4)
@export var exterior_scene: PackedScene # tscn, the building in the city
@export var interior_scene: PackedScene # tscn, the building interior (NPCs will be in here)
#var actions: Dictionary[StringName, BuildingAction] # TBD - assign actions to building, or to NPCs? eg "open trade menu"
