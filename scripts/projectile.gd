extends Node2D
class_name BattleProjectile

var team: int = 0
var damage: int = 8
var speed: float = 320.0
var target: Node2D
var _last_aim: Vector2 = Vector2.ZERO


func setup(p_team: int, from: Vector2, p_target: Node2D, p_damage: int) -> void:
	team = p_team
	global_position = from
	target = p_target
	damage = p_damage
	_last_aim = p_target.global_position if is_instance_valid(p_target) else from
	_build_visual()


func _process(delta: float) -> void:
	if is_instance_valid(target):
		if target.has_method("get_hit_position"):
			_last_aim = target.get_hit_position()
		else:
			_last_aim = target.global_position
	var to_aim := _last_aim - global_position
	var dist := to_aim.length()
	var step := speed * delta
	if dist <= step or dist < 8.0:
		_impact()
		return
	global_position += to_aim.normalized() * step
	rotation = to_aim.angle()


func _impact() -> void:
	if is_instance_valid(target) and target.has_method("take_damage"):
		if not ("team" in target) or target.team != team:
			target.take_damage(damage)
	queue_free()


func _build_visual() -> void:
	var body := Polygon2D.new()
	var glow := Color("c8e8ff") if team == 0 else Color("ffd0b8")
	body.color = glow
	body.polygon = PackedVector2Array([
		Vector2(10, 0), Vector2(0, 5), Vector2(-8, 0), Vector2(0, -5),
	])
	add_child(body)
	var core := Polygon2D.new()
	core.color = Color("ffffff")
	core.polygon = PackedVector2Array([
		Vector2(4, 0), Vector2(0, 2.5), Vector2(-3, 0), Vector2(0, -2.5),
	])
	add_child(core)
