extends Node

signal camera_zoomed(p: Vector2)
signal config_changed
signal entered_building(p: Building)
signal exited_building(p: Building)
signal game_reset
signal menu_closed(p: Control)
signal state_entered(p: ActiveState)
signal state_exited(p: ActiveState)
signal viewport_resized(p: Vector2)
