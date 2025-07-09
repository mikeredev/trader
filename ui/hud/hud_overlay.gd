class_name HUDOverlay extends VBoxContainer

# reminder to unassigned theme from root when done

@onready var info_bar: InfoBar = %InfoBar
@onready var notification_area: NotificationArea = %NotificationArea
@onready var city_list: CityList = %CityList


func setup() -> void:
	info_bar.setup()
	notification_area.setup()
	city_list.setup()
