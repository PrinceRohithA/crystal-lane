extends Node

## P2 — simple PvZ-style wave director for campaign L1–3 stubs.
## Full App D bands land with more levels later.

signal wave_started(index: int, total: int, label: String)
signal wave_cleared(index: int)
signal level_cleared
signal banner(text: String)

var game: Node
var level: int = 1
var _wave: int = 0
var _total: int = 3
var _spawns_left: int = 0
var _in_lull: bool = true
var _lull_left: float = 8.0
var _active: bool = false
var _done: bool = false

# L1–3 stub tables: [wave_count, lull_s, fodder_per_wave, kinds cycle]
const LEVEL_PLAN := {
	1: {"waves": 3, "lull": 9.0, "prep": 14.0, "per_wave": 3, "kinds": [1, 0, 1]},
	2: {"waves": 3, "lull": 8.5, "prep": 14.0, "per_wave": 4, "kinds": [1, 3, 0, 1]},
	3: {"waves": 3, "lull": 8.0, "prep": 12.0, "per_wave": 4, "kinds": [2, 1, 3, 0]},
}


func setup(p_game: Node, p_level: int) -> void:
	game = p_game
	level = clampi(p_level, 1, 3)
	var plan: Dictionary = LEVEL_PLAN.get(level, LEVEL_PLAN[1])
	_total = int(plan["waves"])
	_wave = 0
	_in_lull = true
	_lull_left = float(plan["prep"])
	_active = true
	_done = false
	banner.emit("Prepare — Level %d" % level)


func _process(delta: float) -> void:
	if not _active or _done or game == null or game.is_over:
		return
	if _in_lull:
		_lull_left -= delta
		if _lull_left <= 0.0:
			_start_next_wave()
		return
	if _spawns_left > 0:
		return
	if game._enemy_alive_count() == 0:
		wave_cleared.emit(_wave)
		if _wave >= _total:
			_done = true
			_active = false
			banner.emit("Level clear!")
			level_cleared.emit()
		else:
			var plan: Dictionary = LEVEL_PLAN.get(level, LEVEL_PLAN[1])
			_in_lull = true
			_lull_left = float(plan["lull"])
			banner.emit("Wave clear — next in %ds" % int(_lull_left))


func _start_next_wave() -> void:
	_wave += 1
	_in_lull = false
	var plan: Dictionary = LEVEL_PLAN.get(level, LEVEL_PLAN[1])
	_spawns_left = int(plan["per_wave"])
	var label := "Wave %d / %d" % [_wave, _total]
	wave_started.emit(_wave, _total, label)
	banner.emit(label)
	_spawn_wave_batch(plan)


func _spawn_wave_batch(plan: Dictionary) -> void:
	var kinds: Array = plan["kinds"]
	for i in _spawns_left:
		var kind: int = int(kinds[i % kinds.size()])
		if game.alive_count() >= game.MAX_ALIVE:
			break
		game._spawn_unit(1, kind)  # Team.ENEMY = 1
	_spawns_left = 0
