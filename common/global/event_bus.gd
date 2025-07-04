extends Node

signal camera_zoomed(p_zoom: Vector2)
signal config_changed
signal entered_building(p_building: Building)
signal exited_building(p_building: Building)
signal game_reset
signal menu_closed(p_menu: Control)
signal state_entered(p: ActiveState)
signal state_exited(p: ActiveState)
signal viewport_resized(p_size: Vector2)
