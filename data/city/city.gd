class_name City extends RefCounted

var city_id: StringName
var uid: int
var position: Vector2i
var body: CityBody
var buildings: Dictionary[StringName, Building]
var support: Dictionary[StringName, float] = {}
var economy: int
var industry: int
