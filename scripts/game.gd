extends Node2D

## Crystal Lane — Practice (gold) + Campaign (mana + waves).

const UnitScript := preload("res://scripts/unit.gd")
const TowerScript := preload("res://scripts/tower.gd")
const FieldScript := preload("res://scripts/battlefield.gd")
const PulseFxScript := preload("res://scripts/pulse_fx.gd")
const WaveDirectorScript := preload("res://scripts/wave_director.gd")

const LANE_Y := 492.0
const PLAYER_SPAWN_X := 210.0
const ENEMY_SPAWN_X := 1070.0
const PLAYER_TOWER_POS := Vector2(132, 500)
const ENEMY_TOWER_POS := Vector2(1148, 500)

const LANE_LEFT := 160.0
const LANE_RIGHT := 1120.0
const PULSE_LEFT := LANE_LEFT + (LANE_RIGHT - LANE_LEFT) / 3.0
const PULSE_RIGHT := LANE_RIGHT - (LANE_RIGHT - LANE_LEFT) / 3.0

const START_GOLD := 160
const GOLD_PER_SEC := 16.0
const MAX_ALIVE := 8

const START_MANA := 40.0
const MAX_MANA := 100.0
const MANA_PER_SEC_ARCADE := 7.0
const SPELL_COST := 55.0
const SPELL_DAMAGE := 24
const SPELL_SLOW := 0.45
const SPELL_SLOW_TIME := 2.8

# Practice: delay free waves so affinity drill can finish before Victory.
const ENEMY_FIRST_SPAWN := 50.0
const ENEMY_INTERVAL := 12.0
const ENEMY_INTERVAL_MIN := 3.4
const ENEMY_RAMP_AFTER := 100.0
const ENEMY_EARLY_SOFT_CAP := 2
const ENEMY_EARLY_STAT_SCALE := 0.42
const ENEMY_EARLY_SPEED_SCALE := 0.65

const KILL_BOUNTY := 15
const TUTOR_WINDOW := 48.0

signal economy_changed(gold: int, mana: float, max_mana: float)
signal toast_requested(text: String)
signal match_over(player_won: bool)

var gold: int = START_GOLD
var mana: float = START_MANA
var gold_bank: float = 0.0
var is_over: bool = false
var campaign: bool = false
var _enemy_spawns: int = 0
var _late_spawns: int = 0
var _match_time: float = 0.0
var _did_spawn: bool = false
var _did_pulse: bool = false
var _tutor_step: int = 0
var _next_tutor_at: float = 0.9
var _toast_busy_until: float = 0.0
var _silence_bounty_toast: bool = false
var _affinity_toast_cd: float = 0.0
var _drill_spawned: bool = false

var player_tower
var enemy_tower
var hud: CanvasLayer
var _units_root: Node2D
var _pulse_fx
var _enemy_timer: Timer
var _waves: Node


func unit_cost(kind: int) -> int:
	if campaign:
		return GddBalance.troop_mana(1)
	return int(UnitScript.COST[kind])


func alive_count() -> int:
	var n := 0
	for u in get_tree().get_nodes_in_group("units"):
		if is_instance_valid(u) and not u.is_dead:
			n += 1
	return n


func _ready() -> void:
	randomize()
	add_to_group("crystal_game")
	campaign = GameState.campaign_mode
	_reset_economy()
	hud = $HUD
	if hud:
		hud.add_to_group("crystal_hud")
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
	if not campaign and enemy_tower.has_method("setup"):
		# Extra red HP so Victory does not race the resist path.
		if "max_hp" in enemy_tower:
			enemy_tower.max_hp = int(enemy_tower.max_hp * 1.8)
			enemy_tower.hp = enemy_tower.max_hp

	if campaign:
		_waves = WaveDirectorScript.new()
		add_child(_waves)
		_waves.banner.connect(_emit_toast)
		_waves.level_cleared.connect(_on_level_cleared)
		_waves.setup(self, GameState.selected_level)
	else:
		_enemy_timer = Timer.new()
		_enemy_timer.wait_time = ENEMY_FIRST_SPAWN
		_enemy_timer.one_shot = false
		_enemy_timer.timeout.connect(_on_enemy_timer)
		add_child(_enemy_timer)
		_enemy_timer.start()
		call_deferred("_spawn_affinity_drill")

	if hud.has_method("bind_game"):
		hud.bind_game(self)
	call_deferred("_emit_initial_state")


func _spawn_affinity_drill() -> void:
	if campaign or _drill_spawned or is_over:
		return
	_drill_spawned = true
	# Mid-lane soft Stone Tank for SE (press 2), then Strike Melee for resist (press 1).
	var tank := _spawn_unit_at(UnitScript.Team.ENEMY, UnitScript.Kind.TANK, Vector2(780, LANE_Y))
	if tank:
		tank.max_hp = 40
		tank.hp = 40
		tank.damage = 1
		tank.move_speed *= 0.35
	var melee := _spawn_unit_at(UnitScript.Team.ENEMY, UnitScript.Kind.MELEE, Vector2(920, LANE_Y + 10))
	if melee:
		melee.max_hp = 36
		melee.hp = 36
		melee.damage = 1
		melee.move_speed *= 0.35
	_emit_toast("Affinity drill: press 2 vs Tank (SE), then 1 vs Melee (resist)", 4.0)


func _reset_economy() -> void:
	gold = 0 if campaign else START_GOLD
	mana = GddBalance.CAMPAIGN_START_MANA if campaign else START_MANA
	gold_bank = 0.0
	is_over = false
	_enemy_spawns = 0
	_late_spawns = 0
	_match_time = 0.0
	_did_spawn = false
	_did_pulse = false
	_tutor_step = 0
	_next_tutor_at = 0.9
	_toast_busy_until = 0.0
	_silence_bounty_toast = false
	_affinity_toast_cd = 0.0
	_drill_spawned = false


func restart_match() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _mana_cap() -> float:
	return GameState.campaign_cap() if campaign else MAX_MANA


func _emit_initial_state() -> void:
	economy_changed.emit(gold, mana, _mana_cap())
	if hud.has_method("set_player_hp"):
		hud.set_player_hp(player_tower.hp, TowerScript.MAX_HP)
	if hud.has_method("set_enemy_hp"):
		hud.set_enemy_hp(enemy_tower.hp, TowerScript.MAX_HP)
	if campaign:
		_emit_toast("Campaign L%d - mana only" % GameState.selected_level)


func _process(delta: float) -> void:
	if is_over:
		return
	_match_time += delta
	_affinity_toast_cd = maxf(_affinity_toast_cd - delta, 0.0)
	if not campaign:
		gold_bank += GOLD_PER_SEC * delta
		if gold_bank >= 1.0:
			var add := int(gold_bank)
			gold += add
			gold_bank -= float(add)
	var regen := GameState.campaign_regen() if campaign else MANA_PER_SEC_ARCADE
	mana = minf(mana + regen * delta, _mana_cap())
	economy_changed.emit(gold, mana, _mana_cap())
	_maybe_tutor()


func _unhandled_input(event: InputEvent) -> void:
	if is_over:
		if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_R):
			if campaign:
				GameState.go_level_select()
			else:
				restart_match()
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
		_emit_toast("Lane is full (%d)" % MAX_ALIVE)
		return
	var cost := unit_cost(kind)
	if campaign:
		if mana < float(cost):
			_emit_toast("Not enough mana")
			return
		mana -= float(cost)
	else:
		if gold < cost:
			_emit_toast("Not enough gold")
			return
		gold -= cost
	economy_changed.emit(gold, mana, _mana_cap())
	_did_spawn = true
	_spawn_unit(UnitScript.Team.PLAYER, kind)


func try_cast_type_pulse() -> void:
	if is_over:
		return
	if mana < SPELL_COST:
		_emit_toast("Not enough mana")
		return
	mana -= SPELL_COST
	economy_changed.emit(gold, mana, _mana_cap())
	if _pulse_fx:
		_pulse_fx.trigger()
	var gold_before := gold
	_silence_bounty_toast = true
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
	_silence_bounty_toast = false
	_did_pulse = true
	var bounty := gold - gold_before
	if hit == 0:
		_emit_toast("Type Pulse - no enemies in mid-lane")
	elif not campaign and bounty > 0:
		_emit_toast("Type Pulse! +%d gold" % bounty)
	else:
		_emit_toast("Type Pulse!")


func _on_enemy_timer() -> void:
	if campaign or is_over:
		return
	if alive_count() >= MAX_ALIVE:
		return
	if _match_time < ENEMY_RAMP_AFTER and _enemy_alive_count() >= ENEMY_EARLY_SOFT_CAP:
		return
	_enemy_spawns += 1
	_enemy_timer.wait_time = _next_enemy_interval()
	var kind: int
	if _match_time < ENEMY_RAMP_AFTER:
		var early := [UnitScript.Kind.TANK, UnitScript.Kind.MELEE, UnitScript.Kind.TANK, UnitScript.Kind.RANGED, UnitScript.Kind.MELEE, UnitScript.Kind.SUPPORT]
		kind = early[(_enemy_spawns - 1) % early.size()]
	else:
		var late := [UnitScript.Kind.MELEE, UnitScript.Kind.TANK, UnitScript.Kind.RANGED, UnitScript.Kind.MELEE, UnitScript.Kind.SUPPORT]
		kind = late[_late_spawns % late.size()]
		_late_spawns += 1
	_spawn_unit(UnitScript.Team.ENEMY, kind)


func _next_enemy_interval() -> float:
	if _match_time < ENEMY_RAMP_AFTER:
		return ENEMY_INTERVAL
	var u := clampf((_match_time - ENEMY_RAMP_AFTER) / 40.0, 0.0, 1.0)
	return lerpf(ENEMY_INTERVAL, ENEMY_INTERVAL_MIN, u)


func _enemy_alive_count() -> int:
	var n := 0
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if is_instance_valid(u) and not u.is_dead:
			n += 1
	return n


func _spawn_unit(team: int, kind: int) -> void:
	var x := PLAYER_SPAWN_X if team == UnitScript.Team.PLAYER else ENEMY_SPAWN_X
	var y := LANE_Y + randf_range(-14.0, 14.0)
	_spawn_unit_at(team, kind, Vector2(x, y))


func _spawn_unit_at(team: int, kind: int, pos: Vector2):
	var unit := UnitScript.new()
	_units_root.add_child(unit)
	var tower: Node2D = enemy_tower if team == UnitScript.Team.PLAYER else player_tower
	unit.setup(team, kind, pos, tower, self)
	unit.died.connect(_on_unit_died)
	unit.combat_note.connect(_on_combat_note)
	if team == UnitScript.Team.ENEMY and (not campaign) and _match_time < ENEMY_RAMP_AFTER and not _drill_spawned:
		unit.max_hp = maxi(8, int(round(float(unit.max_hp) * ENEMY_EARLY_STAT_SCALE)))
		unit.hp = unit.max_hp
		unit.damage = maxi(1, int(round(float(unit.damage) * ENEMY_EARLY_STAT_SCALE)))
		unit.move_speed *= ENEMY_EARLY_SPEED_SCALE
	return unit


func _on_combat_note(text: String) -> void:
	if is_over:
		return
	if _affinity_toast_cd > 0.0:
		return
	_affinity_toast_cd = 1.0
	_emit_toast(text, 3.5)


func _on_unit_died(unit) -> void:
	if is_over or unit == null:
		return
	if unit.team != UnitScript.Team.ENEMY:
		return
	if campaign:
		return
	gold += KILL_BOUNTY
	economy_changed.emit(gold, mana, MAX_MANA)
	if not _silence_bounty_toast:
		_emit_toast("+%d gold (kill bounty)" % KILL_BOUNTY, 3.0)


func _emit_toast(text: String, hold: float = 1.8) -> void:
	toast_requested.emit(text)
	if hud != null and hud.has_method("show_toast"):
		hud.show_toast(text)
	_toast_busy_until = _match_time + hold


func _maybe_tutor() -> void:
	if is_over or _match_time > TUTOR_WINDOW:
		return
	if _match_time < _next_tutor_at or _match_time < _toast_busy_until:
		return
	var tip := ""
	while _tutor_step < 3 and tip == "":
		match _tutor_step:
			0:
				if not _did_spawn:
					tip = "Tutor: press 1-4 to deploy" if not campaign else "Tutor: 1-4 spend mana to deploy"
			1:
				if not _did_spawn:
					tip = "Tutor: 1 Tank  2 Melee  3 Ranged  4 Support"
			2:
				if not _did_pulse:
					tip = "Tutor: Space = Type Pulse (middle lane)"
		_tutor_step += 1
	if tip == "":
		_next_tutor_at = _match_time + 4.0
		return
	_emit_toast(tip, 3.2)
	_next_tutor_at = _match_time + 7.0


func _on_level_cleared() -> void:
	if is_over:
		return
	var gain := GameState.grant_level_coins(GameState.selected_level)
	_emit_toast("Victory! +%d coins" % gain, 3.0)
	_end_match(true)


func _on_player_tower_down() -> void:
	_end_match(false)


func _on_enemy_tower_down() -> void:
	if campaign:
		return
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
