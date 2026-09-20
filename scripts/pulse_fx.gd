extends Node2D
class_name TypePulseFx

## Lane-wide crest; damage/slow still apply only in the middle third.

const LANE_LEFT := 160.0
const LANE_RIGHT := 1120.0
const PULSE_LEFT := LANE_LEFT + (LANE_RIGHT - LANE_LEFT) / 3.0
const PULSE_RIGHT := LANE_RIGHT - (LANE_RIGHT - LANE_LEFT) / 3.0

var flash: float = 0.0
var wave_x: float = -1.0


func _ready() -> void:
	z_index = 20
	z_as_relative = false


func trigger() -> void:
	flash = 0.7
	wave_x = LANE_LEFT
	queue_redraw()


func _process(delta: float) -> void:
	var dirty := false
	if flash > 0.0:
		flash = maxf(flash - delta, 0.0)
		dirty = true
	if wave_x >= 0.0:
		wave_x += 1600.0 * delta
		if wave_x > LANE_RIGHT + 40.0:
			wave_x = -1.0
		dirty = true
	if dirty:
		queue_redraw()


func _draw() -> void:
	if flash <= 0.0 and wave_x < 0.0:
		return
	if flash > 0.0:
		var a := flash * 0.42
		var x := PULSE_LEFT
		var w := PULSE_RIGHT - PULSE_LEFT
		draw_rect(Rect2(x, 430, w, 120), Color(0.62, 0.42, 0.95, a))
		var y := 448.0
		while y < 540.0:
			var px := x + 8.0
			while px < PULSE_RIGHT - 8.0:
				draw_line(Vector2(px, y + 16), Vector2(px + 14, y), Color(0.85, 0.7, 1.0, a * 1.5), 2.0)
				px += 28.0
			y += 20.0
	if wave_x >= 0.0:
		var wx := wave_x
		draw_rect(Rect2(wx - 22, 428, 44, 124), Color(0.9, 0.78, 1.0, 0.38))
		draw_line(Vector2(wx, 428), Vector2(wx, 552), Color(1.0, 0.92, 1.0, 0.9), 4.0)
		var wash := clampf((wx - LANE_LEFT) / (LANE_RIGHT - LANE_LEFT), 0.0, 1.0)
		draw_rect(Rect2(LANE_LEFT, 430, (LANE_RIGHT - LANE_LEFT) * wash, 120), Color(0.72, 0.55, 0.95, 0.08))
