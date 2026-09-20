extends Node2D
class_name BattleTower

signal hp_changed(current: int, maximum: int)
signal destroyed

enum Team { PLAYER, ENEMY }

const MAX_HP := 420

var team: Team = Team.PLAYER
var hp: int = MAX_HP
var is_destroyed: bool = false

var _flash: float = 0.0
var _visual: Node2D


func setup(p_team: Team, pos: Vector2) -> void:
	team = p_team
	position = pos
	hp = MAX_HP
	add_to_group("towers")
	if team == Team.PLAYER:
		add_to_group("player_towers")
	else:
		add_to_group("enemy_towers")
	z_index = 1
	_build_visual()
	_attach_crystal_sprite()


func _process(delta: float) -> void:
	if _flash > 0.0:
		_flash = maxf(_flash - delta * 4.0, 0.0)
		modulate = Color(1.0, 1.0, 1.0).lerp(Color(1.6, 1.6, 1.6), _flash)
	queue_redraw()


func take_damage(amount: int) -> void:
	if is_destroyed:
		return
	hp = maxi(hp - amount, 0)
	_flash = 1.0
	hp_changed.emit(hp, MAX_HP)
	if hp <= 0:
		is_destroyed = true
		_collapse()
		destroyed.emit()


func get_hit_position() -> Vector2:
	return global_position + Vector2(0, -36)


func _build_visual() -> void:
	_visual = Node2D.new()
	add_child(_visual)

	var pal := _palette()
	var shadow := Polygon2D.new()
	shadow.color = Color(0.12, 0.14, 0.1, 0.35)
	shadow.polygon = PackedVector2Array([
		Vector2(-40, 16), Vector2(44, 16), Vector2(30, 30), Vector2(-28, 30),
	])
	_visual.add_child(shadow)

	# Stone plinth
	var plinth_side := Polygon2D.new()
	plinth_side.color = pal["plinth_side"]
	plinth_side.polygon = PackedVector2Array([
		Vector2(16, -8), Vector2(40, 0), Vector2(40, 18), Vector2(16, 18),
	])
	_visual.add_child(plinth_side)
	var plinth := Polygon2D.new()
	plinth.color = pal["plinth"]
	plinth.polygon = PackedVector2Array([
		Vector2(-32, -8), Vector2(16, -8), Vector2(16, 18), Vector2(-32, 18),
	])
	_visual.add_child(plinth)

	# Faceted crystal (2.5D) — hidden when MELLE sprites load.
	var crystal_side := Polygon2D.new()
	crystal_side.name = "GeomCrystal"
	crystal_side.color = pal["side"]
	crystal_side.polygon = PackedVector2Array([
		Vector2(4, -108), Vector2(28, -70), Vector2(22, -8), Vector2(4, -8),
	])
	_visual.add_child(crystal_side)
	var crystal := Polygon2D.new()
	crystal.name = "GeomCrystal"
	crystal.color = pal["front"]
	crystal.polygon = PackedVector2Array([
		Vector2(-6, -118), Vector2(4, -108), Vector2(4, -8), Vector2(-28, -8), Vector2(-34, -64),
	])
	_visual.add_child(crystal)
	var facet := Polygon2D.new()
	facet.name = "GeomCrystal"
	facet.color = pal["gem"]
	facet.polygon = PackedVector2Array([
		Vector2(-18, -86), Vector2(-4, -100), Vector2(0, -70), Vector2(-16, -58),
	])
	_visual.add_child(facet)
	var shard := Polygon2D.new()
	shard.name = "GeomCrystal"
	shard.color = pal["flag"]
	shard.polygon = PackedVector2Array([
		Vector2(-38, -20), Vector2(-30, -44), Vector2(-24, -12),
	])
	_visual.add_child(shard)
	var shard2 := Polygon2D.new()
	shard2.name = "GeomCrystal"
	shard2.color = pal["gem"]
	shard2.polygon = PackedVector2Array([
		Vector2(18, -24), Vector2(30, -40), Vector2(34, -10),
	])
	_visual.add_child(shard2)


func _attach_crystal_sprite() -> void:
	var path := "res://assets/crystals/crystal_blue.png" if team == Team.PLAYER else "res://assets/crystals/crystal_red.png"
	var tex := CrystalArt.tex(path)
	if tex == null:
		return
	# Hide the geometric gem; keep the stone plinth + shadow.
	for child in _visual.get_children():
		if str(child.name).begins_with("GeomCrystal"):
			child.visible = false
	var sprite := Sprite2D.new()
	sprite.texture = tex
	sprite.centered = true
	sprite.position = Vector2(4, -62)
	sprite.scale = Vector2(0.36, 0.36)
	sprite.z_index = 1
	_visual.add_child(sprite)


func _palette() -> Dictionary:
	if team == Team.PLAYER:
		return {
			"front": Color("5aa8e8"),
			"side": Color("2f6aa8"),
			"plinth": Color("8a8e92"),
			"plinth_side": Color("6a6e74"),
			"gem": Color("c8f0ff"),
			"flag": Color("7ec8ff"),
		}
	return {
		"front": Color("e85d55"),
		"side": Color("a33832"),
		"plinth": Color("8a8e92"),
		"plinth_side": Color("6a6e74"),
		"gem": Color("ffd0c0"),
		"flag": Color("ff8b7a"),
	}


func _collapse() -> void:
	var tw := create_tween()
	tw.tween_property(self, "modulate", Color(0.4, 0.4, 0.4, 0.85), 0.35)
	tw.parallel().tween_property(self, "rotation", 0.12 if team == Team.ENEMY else -0.12, 0.35)


func _draw() -> void:
	var w := 54.0
	var ratio := clampf(float(hp) / float(MAX_HP), 0.0, 1.0)
	var top := Vector2(-w * 0.5, -132)
	draw_rect(Rect2(top, Vector2(w, 7)), Color(0.12, 0.12, 0.14, 0.85))
	var fill := Color("6edc6a") if team == Team.PLAYER else Color("e86b5b")
	draw_rect(Rect2(top, Vector2(w * ratio, 7)), fill)
	draw_rect(Rect2(top, Vector2(w, 7)), Color("1b1d1a"), false, 1.2)
