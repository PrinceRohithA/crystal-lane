extends Control

## P1 — title screen.


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("9ec8e0")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := Label.new()
	title.text = "CRYSTAL LANE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 140)
	title.size = Vector2(1280, 64)
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color("1c2834"))
	var font_title := load("res://assets/ui/KenneyFuture.ttf") as Font
	if font_title:
		title.add_theme_font_override("font", font_title)
	add_child(title)

	var sub := Label.new()
	sub.text = "Stick War–style lane · CC0 creatures · GDD v1.3.1"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.position = Vector2(0, 210)
	sub.size = Vector2(1280, 28)
	sub.add_theme_font_size_override("font_size", 16)
	sub.add_theme_color_override("font_color", Color("3a4a58"))
	add_child(sub)

	var campaign := _btn("Campaign (L1–3)", Vector2(480, 320))
	campaign.pressed.connect(func() -> void: GameState.go_level_select())
	add_child(campaign)

	var practice := _btn("Practice Lane", Vector2(480, 400))
	practice.pressed.connect(func() -> void: GameState.start_practice())
	add_child(practice)

	var hint := Label.new()
	hint.text = "Campaign uses wave stubs for L1–3 · Practice is the arcade lane"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.position = Vector2(0, 500)
	hint.size = Vector2(1280, 24)
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color("5a5850"))
	add_child(hint)


func _btn(text: String, pos: Vector2) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = Vector2(320, 56)
	b.add_theme_font_size_override("font_size", 20)
	var font := load("res://assets/ui/KenneyFutureNarrow.ttf") as Font
	if font:
		b.add_theme_font_override("font", font)
	b.focus_mode = Control.FOCUS_NONE
	return b
