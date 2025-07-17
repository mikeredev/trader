class_name Building extends Interactable

enum PlacementBias { NONE, SHORE }

var building_id: StringName
var city_id: StringName

var scene: BuildingScene
var view: View

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
	var character: Character = App.context.character.get_character(p_body.profile_id)
	print("hi %s" % character.get_profile_name())
	enter_building()


func enter_building() -> void:
	# load building scene
	scene = System.manage.scene.create_scene(FileLocation.IN_BUILDING_SCENE)
	scene.name = building_id
	view.add_scene(scene, View.ContainerType.SCENE)
	EventBus.building_entered.emit(self)

	# switch view
	System.manage.scene.activate_view(View.ViewType.INTERIOR)
	scene._on_viewport_resized(DisplayServer.window_get_size())


func exit_building() -> void:
	pass
