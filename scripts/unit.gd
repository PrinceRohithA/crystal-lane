extends Node2D
class_name BattleUnit

signal died(unit)
signal combat_note(text: String)

enum Team { PLAYER, ENEMY }
enum Kind { TANK, MELEE, RANGED, SUPPORT }

const STATS := {
	Kind.TANK: {
		"max_hp": 150, "damage": 8, "speed": 52.0, "attack_range": 44.0,
		"cooldown": 1.05, "projectile": false, "heal": 0,
	},
	Kind.MELEE: {
		"max_hp": 82, "damage": 14, "speed": 82.0, "attack_range": 46.0,
		"cooldown": 0.8, "projectile": false, "heal": 0,
	},
	Kind.RANGED: {
		"max_hp": 48, "damage": 10, "speed": 70.0, "attack_range": 168.0,
		"cooldown": 1.15, "projectile": true, "heal": 0,
	},
	Kind.SUPPORT: {
		"max_hp": 58, "damage": 5, "speed": 68.0, "attack_range": 52.0,
		"cooldown": 1.1, "projectile": false, "heal": 11,
	},
}

const COST := {
	Kind.TANK: 70,
	Kind.MELEE: 45,
	Kind.RANGED: 60,
	Kind.SUPPORT: 55,
}

const DISPLAY := {
	Kind.TANK: { "name": "Cragback", "role": "Tank", "affinity": "Stone" },
	Kind.MELEE: { "name": "Knuckhorn", "role": "Melee", "affinity": "Strike" },
	Kind.RANGED: { "name": "Veilray", "role": "Ranged", "affinity": "Mind" },
	Kind.SUPPORT: { "name": "Gleamlet", "role": "Support", "affinity": "Bloom" },
}

# Inline 4x4 GDD subset (Stone/Strike/Mind/Bloom) — do not rely on GddBalance statics in HTML5.
# Rows = attacker kind, cols = defender kind. 1.5 SE / 1.0 neutral / 0.5 resist.
const KERNEL_MULT := [
	[1.0, 0.5, 1.0, 1.0], # Stone: resist vs Strike
	[1.5, 1.0, 0.5, 1.5], # Strike: SE vs Stone + Bloom; resist vs Mind
	[1.0, 1.5, 1.0, 1.0], # Mind: SE vs Strike
	[1.0, 0.5, 1.0, 1.0], # Bloom: resist vs Strike
]

var team: Team = Team.PLAYER
var kind: Kind = Kind.MELEE
var hp: int = 1
var max_hp: int = 1
var damage: int = 1
var move_speed: float = 70.0
var attack_range: float = 40.0
var cooldown: float = 1.0
var uses_projectile: bool = false
var heal_amount: int = 0

var enemy_tower: Node2D
var is_dead: bool = false

var _cd: float = 0.0
var _heal_cd: float = 0.0
var _slow: float = 1.0
var _slow_left: float = 0.0
var _haste: float = 1.0
var _haste_left: float = 0.0
var _bob: float = 0.0
var _moving: bool = false
var _visual: Node2D
var _flash: float = 0.0
var _using_sprites: bool = false
var _note_cd: float = 0.0


func setup(p_team: Team, p_kind: Kind, pos: Vector2, p_tower: Node2D) -> void:
	team = p_team
	kind = p_kind
	position = pos
	enemy_tower = p_tower
	var stats: Dictionary = STATS[kind]
	max_hp = int(stats["max_hp"])
	hp = max_hp
	damage = int(stats["damage"])
	move_speed = float(stats["speed"])
	attack_range = float(stats["attack_range"])
	cooldown = float(stats["cooldown"])
	uses_projectile = bool(stats["projectile"])
	heal_amount = int(stats["heal"])
	add_to_group("units")
	if team == Team.PLAYER:
		add_to_group("player_units")
	else:
		add_to_group("enemy_units")
	_build_visual()
	if team == Team.ENEMY and _visual:
		_visual.scale.x = -absf(_visual.scale.x)
	z_index = 2


func get_hit_position() -> Vector2:
	return global_position + Vector2(0, -18)


static func affinity_multiplier(attacker_kind: int, defender_kind: int) -> float:
	if attacker_kind < 0 or defender_kind < 0:
		return 1.0
	if attacker_kind >= KERNEL_MULT.size() or defender_kind >= KERNEL_MULT[attacker_kind].size():
		return 1.0
	return float(KERNEL_MULT[attacker_kind][defender_kind])


func apply_slow(multiplier: float, duration: float) -> void:
	_slow = multiplier
	_slow_left = duration
	modulate = Color(0.78, 0.62, 1.15)


func apply_haste(multiplier: float, duration: float) -> void:
	_haste = multiplier
	_haste_left = duration


func heal(amount: int) -> void:
	if is_dead or amount <= 0:
		return
	hp = mini(hp + amount, max_hp)
	_flash = 0.55
	modulate = Color(0.75, 1.25, 0.9)
	queue_redraw()


func take_damage(amount: int) -> void:
	if is_dead:
		return
	if kind == Kind.TANK:
		amount = maxi(1, int(round(float(amount) * 0.72)))
	hp = maxi(hp - amount, 0)
	_flash = 1.0
	queue_redraw()
	if hp <= 0:
		_die()


func _process(delta: float) -> void:
	if is_dead:
		return
	_note_cd = maxf(_note_cd - delta, 0.0)
	if _slow_left > 0.0:
		_slow_left -= delta
		if _slow_left <= 0.0:
			_slow = 1.0
			modulate = Color.WHITE
	if _haste_left > 0.0:
		_haste_left -= delta
		if _haste_left <= 0.0:
			_haste = 1.0
	if _flash > 0.0:
		_flash = maxf(_flash - delta * 6.0, 0.0)
		var flash_col := Color(1.5, 1.5, 1.5)
		var base := Color(0.78, 0.62, 1.15) if _slow_left > 0.0 else Color.WHITE
		modulate = base.lerp(flash_col, _flash)

	_cd = maxf(_cd - delta, 0.0)
	_heal_cd = maxf(_heal_cd - delta, 0.0)
	if heal_amount > 0:
		_try_heal()

	var target := _find_target()
	_moving = false
	var pace := move_speed * _slow * _haste
	if target != null and _distance_to(target) <= attack_range:
		_try_attack(target)
		var not_tower := target.is_in_group("units")
		if uses_projectile and not_tower and _distance_to(target) < attack_range * 0.52:
			var back := -1.0 if team == Team.PLAYER else 1.0
			_moving = true
			position.x += back * pace * 0.65 * delta
	else:
		if not _ally_blocking():
			_moving = true
			var dir := 1.0 if team == Team.PLAYER else -1.0
			position.x += dir * pace * delta

	_bob += delta * (10.0 if _moving else 3.5)
	if _visual:
		_visual.position.y = sin(_bob) * (3.2 if _moving else 1.2)
	queue_redraw()


func _try_heal() -> void:
	if _heal_cd > 0.0:
		return
	var best: Node2D = null
	var best_missing := 0
	for u in get_tree().get_nodes_in_group("units"):
		if not is_instance_valid(u) or u.is_dead or u.team != team:
			continue
		if global_position.distance_to(u.global_position) > 92.0:
			continue
		var missing: int = u.max_hp - u.hp
		if missing > best_missing:
			best_missing = missing
			best = u
	if best == null:
		return
	_heal_cd = 1.55
	best.heal(heal_amount)
	if best.has_method("apply_haste"):
		best.apply_haste(1.35, 1.6)


func _distance_to(node: Node2D) -> float:
	var hit := node.global_position
	if node.has_method("get_hit_position"):
		hit = node.get_hit_position()
	return global_position.distance_to(hit)


func _find_target() -> Node2D:
	var best: Node2D = null
	var best_d := INF
	var best_tank: Node2D = null
	var best_tank_d := 100.0
	for u in get_tree().get_nodes_in_group("units"):
		if u == self or not is_instance_valid(u) or u.is_dead or u.team == team:
			continue
		if not _is_in_front(u):
			continue
		var d := _distance_to(u)
		if d < best_d:
			best_d = d
			best = u
		if int(u.kind) == Kind.TANK and d < best_tank_d:
			best_tank = u
			best_tank_d = d
	if best_tank != null:
		return best_tank
	if best != null:
		return best
	if is_instance_valid(enemy_tower) and not enemy_tower.is_destroyed:
		return enemy_tower
	return null


func _is_in_front(other: Node2D) -> bool:
	if team == Team.PLAYER:
		return other.global_position.x >= global_position.x - 24.0
	return other.global_position.x <= global_position.x + 24.0


func _ally_blocking() -> bool:
	for u in get_tree().get_nodes_in_group("units"):
		if u == self or not is_instance_valid(u) or u.team != team or u.is_dead:
			continue
		var dx: float = u.position.x - position.x
		var dy: float = absf(u.position.y - position.y)
		if dy > 22.0:
			continue
		var hold := 38.0 if kind == Kind.TANK else 30.0
		if team == Team.PLAYER and dx > 6.0 and dx < hold:
			return true
		if team == Team.ENEMY and dx < -6.0 and dx > -hold:
			return true
	return false


func _notify_affinity(text: String) -> void:
	# Triple path for HTML5: signal, game group, HUD group.
	combat_note.emit(text)
	if is_inside_tree():
		get_tree().call_group("crystal_game", "_on_combat_note", text)
		get_tree().call_group("crystal_hud", "show_toast", text)


func _try_attack(target: Node2D) -> void:
	if _cd > 0.0:
		return
	_cd = cooldown
	if _visual:
		var tw := create_tween()
		var lunge := 8.0 if team == Team.PLAYER else -8.0
		tw.tween_property(_visual, "position:x", lunge, 0.08)
		tw.tween_property(_visual, "position:x", 0.0, 0.12)
	var dmg := damage
	var hit_unit: bool = target != null and is_instance_valid(target) and target.is_in_group("units")
	if hit_unit:
		var def_kind: int = int(target.get("kind"))
		var mult: float = affinity_multiplier(int(kind), def_kind)
		dmg = maxi(1, int(round(float(dmg) * mult)))
		if team == Team.PLAYER and _note_cd <= 0.0 and absf(mult - 1.0) > 0.05:
			var atk: String = str(DISPLAY[int(kind)]["affinity"])
			var def: String = str(DISPLAY[def_kind]["affinity"])
			if mult > 1.05:
				_notify_affinity("SE! %s > %s" % [atk, def])
			else:
				_notify_affinity("resist %s vs %s" % [atk, def])
			_note_cd = 1.2
	elif kind == Kind.MELEE and target != null and target.has_method("take_damage") and not hit_unit:
		dmg += 4
	if uses_projectile:
		var proj := preload("res://scripts/projectile.gd").new()
		var spawn_at := global_position + Vector2(18 * (1.0 if team == Team.PLAYER else -1.0), -16)
		get_parent().add_child(proj)
		proj.setup(team, spawn_at, target, dmg)
	else:
		if target.has_method("take_damage"):
			target.take_damage(dmg)


func _die() -> void:
	is_dead = true
	died.emit(self)
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.22)
	tw.parallel().tween_property(self, "position:y", position.y + 10.0, 0.22)
	tw.tween_callback(queue_free)


func _build_visual() -> void:
	_visual = Node2D.new()
	add_child(_visual)
	if _try_build_sprites():
		return
	var shadow := Polygon2D.new()
	shadow.color = Color(0.1, 0.12, 0.08, 0.4)
	var wide := 20.0 if kind == Kind.TANK else 16.0
	shadow.polygon = PackedVector2Array([
		Vector2(-wide, 10), Vector2(wide, 10), Vector2(wide - 4, 18), Vector2(-wide + 4, 18),
	])
	add_child(shadow)
	move_child(shadow, 0)
	match kind:
		Kind.TANK:
			_build_cragback()
		Kind.MELEE:
			_build_knuckhorn()
		Kind.RANGED:
			_build_veilray()
		Kind.SUPPORT:
			_build_gleamlet()


func _try_build_sprites() -> bool:
	var body_tex := CrystalArt.tex(CrystalArt.unit_body_path(team, kind))
	if body_tex == null:
		return false
	_using_sprites = true
	var blob := Sprite2D.new()
	blob.texture = CrystalArt.tex("res://assets/units/shadow.png")
	blob.position = Vector2(0, 14)
	blob.modulate = Color(1, 1, 1, 0.55)
	add_child(blob)
	move_child(blob, 0)
	var sc: float = float(CrystalArt.UNIT_SCALE[kind])
	_visual.scale = Vector2(sc, sc)
	var body := Sprite2D.new()
	body.texture = body_tex
	body.position = Vector2(0, -10)
	_visual.add_child(body)
	var face_tex := CrystalArt.tex(CrystalArt.unit_face_path(kind))
	if face_tex:
		var face := Sprite2D.new()
		face.texture = face_tex
		face.position = Vector2(2 if team == Team.PLAYER else -2, -12)
		_visual.add_child(face)
	var hand_tex := CrystalArt.tex(CrystalArt.unit_hand_path(team, kind))
	if hand_tex:
		var hl := Sprite2D.new()
		hl.texture = hand_tex
		hl.position = Vector2(-26, 6)
		_visual.add_child(hl)
		var hr := Sprite2D.new()
		hr.texture = hand_tex
		hr.position = Vector2(26, 6)
		hr.flip_h = true
		_visual.add_child(hr)
	return true


func _pal() -> Dictionary:
	var type_accent := Color("c4b48a")
	match kind:
		Kind.TANK:
			type_accent = Color("c4a574")
		Kind.MELEE:
			type_accent = Color("e08a5a")
		Kind.RANGED:
			type_accent = Color("b48ae0")
		Kind.SUPPORT:
			type_accent = Color("f0a0c8")
	if team == Team.PLAYER:
		return {"body": Color("4f9ad8"), "body_dark": Color("2d6eae"), "belly": Color("c5e4f7"), "accent": type_accent, "eye": Color("1c2834")}
	return {"body": Color("e86b5b"), "body_dark": Color("b33d32"), "belly": Color("f7d0c5"), "accent": type_accent, "eye": Color("1c2834")}


func _build_cragback() -> void:
	var pal := _pal()
	_rect_poly(_visual, Rect2(-14, 0, 8, 14), pal["body_dark"])
	_rect_poly(_visual, Rect2(6, 0, 8, 14), pal["body_dark"])
	var shell := Polygon2D.new()
	shell.color = pal["accent"]
	shell.polygon = PackedVector2Array([Vector2(-22, -4), Vector2(-12, -24), Vector2(8, -28), Vector2(22, -10), Vector2(18, 6), Vector2(-18, 8)])
	_visual.add_child(shell)
	var plate := Polygon2D.new()
	plate.color = pal["body"]
	plate.polygon = PackedVector2Array([Vector2(-8, -18), Vector2(6, -22), Vector2(14, -8), Vector2(-4, -4)])
	_visual.add_child(plate)
	var head := Polygon2D.new()
	head.color = pal["body"]
	head.polygon = PackedVector2Array([Vector2(10, -12), Vector2(26, -8), Vector2(24, 4), Vector2(8, 2)])
	_visual.add_child(head)
	_eye(Vector2(20, -4), pal["eye"])


func _build_knuckhorn() -> void:
	var pal := _pal()
	_rect_poly(_visual, Rect2(-8, 2, 6, 12), pal["body_dark"])
	_rect_poly(_visual, Rect2(4, 2, 6, 12), pal["body_dark"])
	var body := Polygon2D.new()
	body.color = pal["body"]
	body.polygon = PackedVector2Array([Vector2(-12, -6), Vector2(-6, -20), Vector2(10, -20), Vector2(16, -6), Vector2(12, 8), Vector2(-10, 8)])
	_visual.add_child(body)
	var belly := Polygon2D.new()
	belly.color = pal["belly"]
	belly.polygon = PackedVector2Array([Vector2(-4, 0), Vector2(8, 0), Vector2(6, 8), Vector2(-2, 8)])
	_visual.add_child(belly)
	var head := Polygon2D.new()
	head.color = pal["body"]
	head.polygon = PackedVector2Array([Vector2(6, -22), Vector2(20, -20), Vector2(24, -8), Vector2(10, -4), Vector2(4, -10)])
	_visual.add_child(head)
	var horn := Polygon2D.new()
	horn.color = pal["accent"]
	horn.polygon = PackedVector2Array([Vector2(12, -20), Vector2(16, -34), Vector2(20, -18)])
	_visual.add_child(horn)
	var fist := Polygon2D.new()
	fist.color = pal["accent"]
	fist.polygon = PackedVector2Array([Vector2(18, -2), Vector2(30, 0), Vector2(28, 8), Vector2(16, 6)])
	_visual.add_child(fist)
	_eye(Vector2(16, -12), pal["eye"])


func _build_veilray() -> void:
	var pal := _pal()
	var wing := Polygon2D.new()
	wing.color = pal["accent"]
	wing.polygon = PackedVector2Array([Vector2(-6, -8), Vector2(-4, -30), Vector2(14, -16), Vector2(8, -2)])
	_visual.add_child(wing)
	var body := Polygon2D.new()
	body.color = pal["body"]
	body.polygon = PackedVector2Array([Vector2(-12, -4), Vector2(0, -18), Vector2(14, -8), Vector2(8, 8), Vector2(-8, 8)])
	_visual.add_child(body)
	var gem := Polygon2D.new()
	gem.color = pal["belly"]
	gem.polygon = PackedVector2Array([Vector2(-2, -6), Vector2(6, -12), Vector2(10, -2), Vector2(2, 4)])
	_visual.add_child(gem)
	var crest := Polygon2D.new()
	crest.color = pal["accent"]
	crest.polygon = PackedVector2Array([Vector2(4, -16), Vector2(8, -28), Vector2(14, -10)])
	_visual.add_child(crest)
	_eye(Vector2(8, -8), pal["eye"])


func _build_gleamlet() -> void:
	var pal := _pal()
	var wing_l := Polygon2D.new()
	wing_l.color = Color(pal["accent"].r, pal["accent"].g, pal["accent"].b, 0.85)
	wing_l.polygon = PackedVector2Array([Vector2(-4, -8), Vector2(-22, -18), Vector2(-16, 2), Vector2(0, 4)])
	_visual.add_child(wing_l)
	var body := Polygon2D.new()
	body.color = pal["body"]
	body.polygon = PackedVector2Array([Vector2(-10, -4), Vector2(-4, -16), Vector2(10, -16), Vector2(14, -2), Vector2(8, 10), Vector2(-6, 10)])
	_visual.add_child(body)
	var puff := Polygon2D.new()
	puff.color = pal["belly"]
	puff.polygon = PackedVector2Array([Vector2(-4, 0), Vector2(8, 0), Vector2(6, 10), Vector2(-2, 10)])
	_visual.add_child(puff)
	var tuft := Polygon2D.new()
	tuft.color = pal["accent"]
	tuft.polygon = PackedVector2Array([Vector2(0, -16), Vector2(4, -28), Vector2(10, -14)])
	_visual.add_child(tuft)
	_eye(Vector2(6, -8), pal["eye"])


func _rect_poly(parent: Node, rect: Rect2, color: Color) -> void:
	var p := Polygon2D.new()
	p.color = color
	p.polygon = PackedVector2Array([rect.position, rect.position + Vector2(rect.size.x, 0), rect.position + rect.size, rect.position + Vector2(0, rect.size.y)])
	parent.add_child(p)


func _eye(pos: Vector2, color: Color) -> void:
	var white := Polygon2D.new()
	white.color = Color.WHITE
	white.polygon = PackedVector2Array([pos + Vector2(-3, -3), pos + Vector2(3, -3), pos + Vector2(3, 3), pos + Vector2(-3, 3)])
	_visual.add_child(white)
	var pupil := Polygon2D.new()
	pupil.color = color
	pupil.polygon = PackedVector2Array([pos + Vector2(-1.5, -1.5), pos + Vector2(2, -1.5), pos + Vector2(2, 2), pos + Vector2(-1.5, 2)])
	_visual.add_child(pupil)


func _draw() -> void:
	if is_dead:
		return
	var w := 30.0
	var ratio := clampf(float(hp) / float(max_hp), 0.0, 1.0)
	var top := Vector2(-w * 0.5, -46 if _using_sprites else -40)
	draw_rect(Rect2(top, Vector2(w, 4)), Color(0.1, 0.1, 0.12, 0.8))
	draw_rect(Rect2(top, Vector2(w * ratio, 4)), Color("6edc6a"))
