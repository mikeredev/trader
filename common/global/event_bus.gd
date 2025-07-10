extends Node

signal camera_zoomed(p: Vector2)
signal config_changed
signal city_entered(p: City)
signal create_notification(p: String)
signal entered_building(p: Building)
signal exited_building(p: Building)
signal game_reset
signal game_started
signal modal_closed
signal state_entered(p: ActiveState)
signal state_exited(p: ActiveState)
signal viewport_resized(p: Vector2)
