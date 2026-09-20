extends Node2D

## Crystal Lane — tiny 1-lane battler.

const UnitScript := preload("res://scripts/unit.gd")
const TowerScript := preload("res://scripts/tower.gd")
const FieldScript := preload("res://scripts/battlefield.gd")
const PulseFxScript := preload("res://scripts/pulse_fx.gd")

const LANE_Y := 492.0
const PLAYER_SPAWN_X := 210.0
const ENEMY_SPAWN_X := 1070.0
const PLAYER_TOWER_POS := Vector2(132, 500)
const ENEMY_TOWER_POS := Vector2(1148, 500)

const LANE_LEFT := 160.0
const LANE_RIGHT := 1120.0
const PULSE_LEFT := LANE_LEFT + (LANE_RIGHT - LANE_LEFT) / 3.0
const PULSE_RIGHT := LANE_RIGHT - (LANE_RIGHT - LANE_LEFT) / 3.0

const START_GOLD := 90
const GOLD_PER_SEC := 12.0
const MAX_ALIVE := 8

const START_MANA := 40.0
const MAX_MANA := 100.0
const MANA_PER_SEC := 7.0
const SPELL_COST := 55.0
const SPELL_DAMAGE := 24
const SPELL_SLOW := 0.45
const SPELL_SLOW_TIME := 2.8

const ENEMY_FIRST_SPAWN := 2.2
const ENEMY_INTERVAL := 3.8

signal economy_changed(gold: int, mana: float, max_mana: float)
signal toast_requested(text: String)
signal match_over(player_won: bool)

var gold: int = START_GOLD
var mana: float = START_MANA
var gold_bank: float = 0.0
var is_over: bool = false
var _enemy_spawns: int = 0

var player_tower
var enemy_tower
var hud: CanvasLayer
var _units_root: Node2D
var _pulse_fx
var _enemy_timer: Timer


func unit_cost(kind: int) -> int:
	return int(UnitScript.COST[kind])


func alive_count() -> int:
	var n := 0
	for u in get_tree().get_nodes_in_group("units"):
		if is_instance_valid(u) and not u.is_dead:
			n += 1
	return n


func _ready() -> void:
	randomize()
	hud = $HUD
	var field := FieldScript.new()
	add_child(field)

	_units_root = Node2D.new()
	_units_root.name = "Units"
	add_child(_units_root)

	_pulse_fx = PulseFxScript.new()
	_pulse_fx.name = "TypePulse"
	add_child(_pulse_fx)

	player_tower = TowerScript.new()
	add_child(player_tower)
	player_tower.setup(TowerScript.Team.PLAYER, PLAYER_TOWER_POS)
	player_tower.destroyed.connect(_on_player_tower_down)
	player_tower.hp_changed.connect(_on_player_hp)

	enemy_tower = TowerScript.new()
	add_child(enemy_tower)
	enemy_tower.setup(TowerScript.Team.ENEMY, ENEMY_TOWER_POS)
	enemy_tower.destroyed.connect(_on_enemy_tower_down)
	enemy_tower.hp_changed.connect(_on_enemy_hp)

	_enemy_timer = Timer.new()
	_enemy_timer.wait_time = ENEMY_FIRST_SPAWN
	_enemy_timer.one_shot = false
	_enemy_timer.timeout.connect(_on_enemy_timer)
	add_child(_enemy_timer)
	_enemy_timer.start()

	if hud.has_method("bind_game"):
		hud.bind_game(self)
	call_deferred("_emit_initial_state")


func _emit_initial_state() -> void:
	economy_changed.emit(gold, mana, MAX_MANA)
	if hud.has_method("set_player_hp"):
		hud.set_player_hp(player_tower.hp, TowerScript.MAX_HP)
	if hud.has_method("set_enemy_hp"):
		hud.set_enemy_hp(enemy_tower.hp, TowerScript.MAX_HP)


func _process(delta: float) -> void:
	if is_over:
		return
	gold_bank += GOLD_PER_SEC * delta
	if gold_bank >= 1.0:
		var add := int(gold_bank)
		gold += add
		gold_bank -= float(add)
	mana = minf(mana + MANA_PER_SEC * delta, MAX_MANA)
	economy_changed.emit(gold, mana, MAX_MANA)


func _unhandled_input(event: InputEvent) -> void:
	if is_over:
		if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_R):
			get_tree().reload_current_scene()
		return
	if event.is_action_pressed("spawn_tank"):
		try_spawn_player(UnitScript.Kind.TANK)
	elif event.is_action_pressed("spawn_melee"):
		try_spawn_player(UnitScript.Kind.MELEE)
	elif event.is_action_pressed("spawn_ranged"):
		try_spawn_player(UnitScript.Kind.RANGED)
	elif event.is_action_pressed("spawn_support"):
		try_spawn_player(UnitScript.Kind.SUPPORT)
	elif event.is_action_pressed("cast_spell"):
		try_cast_type_pulse()


func try_spawn_player(kind: int) -> void:
	if is_over:
		return
	if alive_count() >= MAX_ALIVE:
		toast_requested.emit("Lane is full (%d)" % MAX_ALIVE)
		return
	var cost := unit_cost(kind)
	if gold < cost:
		toast_requested.emit("Not enough gold")
		return
	gold -= cost
	economy_changed.emit(gold, mana, MAX_MANA)
	_spawn_unit(UnitScript.Team.PLAYER, kind)


func try_cast_type_pulse() -> void:
	if is_over:
		return
	if mana < SPELL_COST:
		toast_requested.emit("Not enough mana")
		return
	mana -= SPELL_COST
	economy_changed.emit(gold, mana, MAX_MANA)
	if _pulse_fx:
		_pulse_fx.trigger()
	var hit := 0
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if not is_instance_valid(u) or u.is_dead:
			continue
		if u.global_position.x < PULSE_LEFT or u.global_position.x > PULSE_RIGHT:
			continue
		u.take_damage(SPELL_DAMAGE)
		if is_instance_valid(u) and not u.is_dead:
			u.apply_slow(SPELL_SLOW, SPELL_SLOW_TIME)
		hit += 1
	if hit == 0:
		toast_requested.emit("Type Pulse — no enemies in mid-lane")
	else:
		toast_requested.emit("Type Pulse!")


func _on_enemy_timer() -> void:
	if is_over:
		return
	if alive_count() >= MAX_ALIVE:
		return
	_enemy_spawns += 1
	_enemy_timer.wait_time = maxf(ENEMY_INTERVAL - _enemy_spawns * 0.06, 2.6)
	var cycle := [
		UnitScript.Kind.MELEE,
		UnitScript.Kind.TANK,
		UnitScript.Kind.RANGED,
		UnitScript.Kind.MELEE,
		UnitScript.Kind.SUPPORT,
	]
	var kind: int = cycle[(_enemy_spawns - 1) % cycle.size()]
	_spawn_unit(UnitScript.Team.ENEMY, kind)


func _spawn_unit(team: int, kind: int) -> void:
	var unit := UnitScript.new()
	_units_root.add_child(unit)
	var x := PLAYER_SPAWN_X if team == UnitScript.Team.PLAYER else ENEMY_SPAWN_X
	var y := LANE_Y + randf_range(-14.0, 14.0)
	var tower: Node2D = enemy_tower if team == UnitScript.Team.PLAYER else player_tower
	unit.setup(team, kind, Vector2(x, y), tower)


func _on_player_tower_down() -> void:
	_end_match(false)


func _on_enemy_tower_down() -> void:
	_end_match(true)


func _on_player_hp(current: int, maximum: int) -> void:
	if hud.has_method("set_player_hp"):
		hud.set_player_hp(current, maximum)


func _on_enemy_hp(current: int, maximum: int) -> void:
	if hud.has_method("set_enemy_hp"):
		hud.set_enemy_hp(current, maximum)


func _end_match(player_won: bool) -> void:
	if is_over:
		return
	is_over = true
	match_over.emit(player_won)
