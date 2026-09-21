extends Node

## Session state for menu → lane (P1–P4).

var campaign_mode: bool = false
var selected_level: int = 1
var meta_coins: int = 200
var unlocked: Dictionary = {
	"P01": true, "P02": true, "P03": true, "P04": true,
}
var mana_regen_level: int = 0
var mana_cap_level: int = 0


func is_unlocked(id: String) -> bool:
	return bool(unlocked.get(id, false))


func try_unlock(id: String, cost: int) -> bool:
	if is_unlocked(id):
		return false
	if meta_coins < cost:
		return false
	meta_coins -= cost
	unlocked[id] = true
	return true


func grant_level_coins(level: int) -> int:
	var gain: int = GddBalance.level_coins(level)
	meta_coins += gain
	return gain


func buy_regen_upgrade() -> bool:
	if mana_regen_level >= 7:
		return false
	var cost: int = GddBalance.regen_coin(mana_regen_level)
	if meta_coins < cost:
		return false
	meta_coins -= cost
	mana_regen_level += 1
	return true


func buy_cap_upgrade() -> bool:
	if mana_cap_level >= 7:
		return false
	var cost: int = GddBalance.cap_coin(mana_cap_level)
	if meta_coins < cost:
		return false
	meta_coins -= cost
	mana_cap_level += 1
	return true


func campaign_regen() -> float:
	return GddBalance.CAMPAIGN_BASE_REGEN * pow(1.12, float(mana_regen_level))


func campaign_cap() -> float:
	return GddBalance.CAMPAIGN_BASE_CAP + 25.0 * float(mana_cap_level)


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


func go_barracks() -> void:
	get_tree().change_scene_to_file("res://scenes/barracks.tscn")


func go_mana_lab() -> void:
	get_tree().change_scene_to_file("res://scenes/mana_lab.tscn")
