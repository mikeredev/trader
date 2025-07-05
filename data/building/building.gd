class_name Building extends RefCounted

#enum Type { MARKET }
#const MAP: Dictionary[StringName, Type] = {
	#"B_MARKET": Type.MARKET
#}
#
#var type: Type
var building_id: StringName # for lookup
#var city_id: StringName # which city it is in
var size: Vector2i # representing the tile size in the atlas map (e.g., 5,4)
var exterior_scene: PackedScene # tscn, the building in the city
var interior_scene: PackedScene # tscn, the building interior (NPCs will be in here)
#var actions: Dictionary[StringName, BuildingAction] # TBD - assign actions to building, or to NPCs? eg "open trade menu"


#static func create_building(p_building_id: StringName) -> Building:
	#var type: Type = MAP.get(p_building_id, null)
	#if not type:
		#return null
