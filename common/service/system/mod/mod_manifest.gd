class_name ModManifest extends RefCounted

var mod_id: StringName
var name: String
var local_path: StringName
var core_mod: bool
var minimum: float
var version: float
var author: String
var contact: String
var categories: Dictionary[ModManager.Category, int] # hash of individual cat data
var icon: Texture2D
