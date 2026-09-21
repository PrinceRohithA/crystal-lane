extends Node

## Campaign wave director — L1 Early Grace softened (TesterBot 3e24ccf fail).
## Practice arcade knobs stay in game.gd; these are Campaign-only.

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
var _spawn_cd: float = 0.0
var _spawn_interval: float = 2.8
var _kinds: Array = []
var _kind_i: int = 0

# Campaign-only. L1 tuned for ≥45–60s blue survival (passive + light play).
# kinds: 0 Tank 1 Melee 2 Ranged 3 Support
const LEVEL_PLAN := {
	1: {
		"waves": 3,
		"lull": 14.0,
		"prep": 22.0,
		"per_wave": 2,
		"spawn_gap": 3.2,
		"kinds": [2, 3],
		"stat_scale": 0.42,
		"speed_scale": 0.72,
	},
	2: {
		"waves": 3,
		"lull": 11.0,
		"prep": 16.0,
		"per_wave": 3,
		"spawn_gap": 2.6,
		"kinds": [1, 3, 2],
		"stat_scale": 0.55,
		"speed_scale": 0.80,
	},
	3: {
		"waves": 3,
		"lull": 9.0,
		"prep": 14.0,
		"per_wave": 3,
		"spawn_gap": 2.2,
		"kinds": [2, 1, 3, 0],
		"stat_scale": 0.70,
		"speed_scale": 0.88,
	},
}


func setup(p_game: Node, p_level: int) -> void:
	game = p_game
	level = clampi(p_level, 1, 3)
	var plan: Dictionary = LEVEL_PLAN.get(level, LEVEL_PLAN[1])
	_total = int(plan["waves"])
	_wave = 0
	_in_lull = true
	_lull_left = float(plan["prep"])
	_spawn_interval = float(plan.get("spawn_gap", 2.5))
	_active = true
	_done = false
	_spawns_left = 0
	banner.emit("Prepare — Level %d (%.0fs)" % [level, _lull_left])


func _process(delta: float) -> void:
	if not _active or _done or game == null or game.is_over:
		return
	if _in_lull:
		_lull_left -= delta
		if _lull_left <= 0.0:
			_start_next_wave()
		return
	if _spawns_left > 0:
		_spawn_cd -= delta
		if _spawn_cd <= 0.0:
			_spawn_one()
			_spawn_cd = _spawn_interval
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
	_kinds = plan["kinds"]
	_kind_i = 0
	_spawn_interval = float(plan.get("spawn_gap", 2.5))
	_spawn_cd = 0.35
	var label := "Wave %d / %d" % [_wave, _total]
	wave_started.emit(_wave, _total, label)
	banner.emit(label)


func _spawn_one() -> void:
	if _spawns_left <= 0 or game == null:
		return
	if game.alive_count() >= game.MAX_ALIVE:
		_spawns_left = 0
		return
	var plan: Dictionary = LEVEL_PLAN.get(level, LEVEL_PLAN[1])
	var kind: int = int(_kinds[_kind_i % _kinds.size()])
	_kind_i += 1
	_spawns_left -= 1
	game._spawn_unit(1, kind)  # Team.ENEMY = 1
	# Soften freshly spawned campaign enemies (Early Grace — Campaign knobs).
	var enemies: Array = game.get_tree().get_nodes_in_group("enemy_units")
	if enemies.is_empty():
		return
	var u = enemies[enemies.size() - 1]
	if not is_instance_valid(u) or u.is_dead:
		return
	var s: float = float(plan.get("stat_scale", 1.0))
	var sp: float = float(plan.get("speed_scale", 1.0))
	if _wave == 1:
		s *= 0.85
		sp *= 0.90
	u.max_hp = maxi(6, int(round(float(u.max_hp) * s)))
	u.hp = u.max_hp
	u.damage = maxi(1, int(round(float(u.damage) * s)))
	u.move_speed *= sp
