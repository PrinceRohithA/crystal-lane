extends Node2D
class_name Battlefield

## Clean 2.5D side-lane: slight perspective path, original shapes.

const W := 1280.0
const H := 720.0

func _ready() -> void:
	z_index = -10
	queue_redraw()


func _draw() -> void:
	_draw_sky()
	_draw_hills()
	_draw_far_trees()
	_draw_far_grass()
	_draw_path()
	_draw_near_grass()
	_draw_route_sign()


func _draw_sky() -> void:
	var bands := [
		[Rect2(0, 0, W, 90), Color("9ec8e0")],
		[Rect2(0, 90, W, 80), Color("b7d6e8")],
		[Rect2(0, 170, W, 80), Color("cfe3ef")],
		[Rect2(0, 250, W, 90), Color("e4eef4")],
	]
	for band in bands:
		draw_rect(band[0], band[1])
	draw_circle(Vector2(1040, 92), 34, Color(1.0, 0.96, 0.78, 0.95))
	draw_circle(Vector2(1040, 92), 48, Color(1.0, 0.96, 0.78, 0.18))


func _draw_hills() -> void:
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(0, 360), Vector2(180, 300), Vector2(340, 328),
			Vector2(520, 286), Vector2(740, 318), Vector2(960, 274),
			Vector2(1180, 310), Vector2(W, 292), Vector2(W, 400), Vector2(0, 400),
		]),
		Color("7aa56a")
	)
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(0, 390), Vector2(220, 348), Vector2(430, 372),
			Vector2(680, 338), Vector2(900, 366), Vector2(W, 344),
			Vector2(W, 420), Vector2(0, 420),
		]),
		Color("5f8f52")
	)


func _draw_far_trees() -> void:
	var positions := [90.0, 250.0, 410.0, 820.0, 980.0, 1190.0]
	for x in positions:
		_tree(Vector2(x, 352), 0.72, Color("3e6b45"), Color("2d5134"))


func _draw_far_grass() -> void:
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(0, 400), Vector2(W, 400), Vector2(W, 448), Vector2(0, 448),
		]),
		Color("6aaa58")
	)
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(70, 430), Vector2(1210, 430), Vector2(1248, 448), Vector2(32, 448),
		]),
		Color("7d9a4e")
	)


func _draw_path() -> void:
	var far_left := Vector2(48, 448)
	var far_right := Vector2(1232, 448)
	var near_left := Vector2(-40, 545)
	var near_right := Vector2(1320, 545)
	draw_colored_polygon(
		PackedVector2Array([far_left, far_right, near_right, near_left]),
		Color("d8c48a")
	)
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(78, 456), Vector2(1202, 456), Vector2(1288, 538), Vector2(-8, 538),
		]),
		Color("c9b06e")
	)
	var y := 492.0
	var x := 160.0
	while x < 1120.0:
		draw_rect(Rect2(x, y, 36, 5), Color(0.94, 0.89, 0.74, 0.7))
		x += 72.0
	draw_line(far_left, near_left, Color("a89050"), 3.0)
	draw_line(far_right, near_right, Color("a89050"), 3.0)


func _draw_near_grass() -> void:
	draw_rect(Rect2(0, 545, W, H - 545), Color("4f8a42"))
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(0, 545), Vector2(W, 545), Vector2(W, 580), Vector2(0, 600),
		]),
		Color("5c9b4c")
	)
	var tufts := [40.0, 120.0, 210.0, 330.0, 980.0, 1090.0, 1200.0]
	for x in tufts:
		_grass_tuft(Vector2(x, 620), Color("3f7436"))
	_grass_tuft(Vector2(70, 670), Color("356330"))
	_grass_tuft(Vector2(1180, 680), Color("356330"))


func _draw_route_sign() -> void:
	var origin := Vector2(600, 318)
	draw_rect(Rect2(origin.x + 34, origin.y + 36, 8, 52), Color("6b5340"))
	draw_rect(Rect2(origin.x, origin.y, 76, 40), Color("f4f1e4"))
	draw_rect(Rect2(origin.x, origin.y, 76, 40), Color("2a2e28"), false, 3.0)
	var font := ThemeDB.fallback_font
	if font:
		draw_string(font, origin + Vector2(8, 17), "CRYSTAL", HORIZONTAL_ALIGNMENT_LEFT, 64, 11, Color("1c2834"))
		draw_string(font, origin + Vector2(8, 32), "LANE", HORIZONTAL_ALIGNMENT_LEFT, 64, 10, Color("2d6eae"))


func _tree(pos: Vector2, scale: float, canopy: Color, trunk: Color) -> void:
	var t := 8.0 * scale
	draw_rect(Rect2(pos.x - t * 0.4, pos.y, t * 0.8, 28.0 * scale), trunk)
	draw_colored_polygon(
		PackedVector2Array([
			pos + Vector2(0, -46 * scale),
			pos + Vector2(22 * scale, -8 * scale),
			pos + Vector2(-22 * scale, -8 * scale),
		]),
		canopy
	)
	draw_colored_polygon(
		PackedVector2Array([
			pos + Vector2(0, -30 * scale),
			pos + Vector2(26 * scale, 8 * scale),
			pos + Vector2(-26 * scale, 8 * scale),
		]),
		canopy.darkened(0.08)
	)


func _grass_tuft(pos: Vector2, color: Color) -> void:
	draw_colored_polygon(
		PackedVector2Array([
			pos + Vector2(-10, 8), pos + Vector2(-4, -16), pos + Vector2(0, 8),
		]),
		color
	)
	draw_colored_polygon(
		PackedVector2Array([
			pos + Vector2(-2, 8), pos + Vector2(4, -20), pos + Vector2(8, 8),
		]),
		color.lightened(0.08)
	)
	draw_colored_polygon(
		PackedVector2Array([
			pos + Vector2(4, 8), pos + Vector2(12, -12), pos + Vector2(14, 8),
		]),
		color
	)
