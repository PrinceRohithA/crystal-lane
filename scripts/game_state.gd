extends Node

## Lightweight session state for menu → lane (P1).

var campaign_mode: bool = false
var selected_level: int = 1
var meta_coins: int = 0


func start_practice() -> void:
	campaign_mode = false
	selected_level = 0
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func start_level(level: int) -> void:
	campaign_mode = true
	selected_level = clampi(level, 1, 20)
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func go_main_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func go_level_select() -> void:
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")
