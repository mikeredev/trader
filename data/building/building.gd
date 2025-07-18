class_name Building extends Interactable

enum PlacementBias { NONE, SHORE }

var building_id: StringName
var city_id: StringName

var scene: BuildingScene
var view: View

var _is_leaving: bool

@export_category("Exterior")
@export var placement_bias: PlacementBias
@export var exterior_scene: PackedScene # tscn, the building in the city
@export var exterior_size: Vector2i # representing the tile size in the atlas map (e.g., 5,4)

@export_category("Interior")
@export var interior_scene: PackedScene # tscn, the building interior (NPCs will be in here)
#var actions: Dictionary[StringName, BuildingAction] # TBD - assign actions to building, or to NPCs? eg "open trade menu"


func _init() -> void:
	view = System.manage.scene.get_view(View.ViewType.INTERIOR)


func interact_with(p_body: CharacterBody) -> void:
	#var character: Character = App.context.character.get_character(p_body.profile_id)
	enter_building(self, p_body)


func enter_building(p_building: Building, p_body: CharacterBody) -> void:
	Debug.log_verbose("%s is entering building %s" % [p_body.profile_id, p_building.building_id])
	p_building.scene = System.manage.scene.create_scene(p_building.interior_scene)
	p_building.scene.name = p_building.building_id
	p_building.scene.city_id = city_id
	p_building.scene.building_id = building_id
	p_building.view.add_scene(p_building.scene, View.ContainerType.SCENE)

	# switch view and kick camera
	System.manage.scene.activate_view(View.ViewType.INTERIOR)
	p_building.scene._on_viewport_resized(DisplayServer.window_get_size())

	# add character
	p_body.reparent(p_building.scene.sprite_group)
	p_body.position = p_building.scene.spawn_point.position

	# broadcast
	EventBus.building_entered.emit(p_building)


func exit_building(p_body: CharacterBody) -> void:
	EventBus.building_exited.emit(self, p_body)
