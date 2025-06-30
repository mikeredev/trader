class_name ColorScheme extends Resource

@export var primary_bg: Color = Color("1A2666FF")
@export var secondary_bg: Color = Color("1a334dff")
@export var ternary_bg: Color = Color("6a0866")


func import() -> void:
	ProjectSettings.set_setting("gui/theme/scheme/primary_bg", primary_bg)
	ProjectSettings.set_setting("gui/theme/scheme/secondary_bg", secondary_bg)
	ProjectSettings.set_setting("gui/theme/scheme/ternary_bg", ternary_bg)
