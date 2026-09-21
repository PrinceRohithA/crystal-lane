extends Control

## Title screen (P1–P4).


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("9ec8e0")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := Label.new()
	title.text = "CRYSTAL LANE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 100)
	title.size = Vector2(1280, 64)
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color("1c2834"))
	var font_title := load("res://assets/ui/KenneyFuture.ttf") as Font
	if font_title:
		title.add_theme_font_override("font", font_title)
	add_child(title)

	var sub := Label.new()
	sub.text = "Stick War–style lane · CC0 creatures · GDD v1.3.2"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.position = Vector2(0, 170)
	sub.size = Vector2(1280, 28)
	sub.add_theme_font_size_override("font_size", 16)
	sub.add_theme_color_override("font_color", Color("3a4a58"))
	add_child(sub)

	var campaign := _btn("Campaign (L1–3)", Vector2(480, 240))
	campaign.pressed.connect(func() -> void: GameState.go_level_select())
	add_child(campaign)

	var barracks := _btn("Barracks", Vector2(480, 310))
	barracks.pressed.connect(func() -> void: GameState.go_barracks())
	add_child(barracks)

	var lab := _btn("Mana Lab", Vector2(480, 380))
	lab.pressed.connect(func() -> void: GameState.go_mana_lab())
	add_child(lab)

	var practice := _btn("Practice Lane", Vector2(480, 450))
	practice.pressed.connect(func() -> void: GameState.start_practice())
	add_child(practice)

	var coins := Label.new()
	coins.text = "Meta coins: %d" % GameState.meta_coins
	coins.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coins.position = Vector2(0, 540)
	coins.size = Vector2(1280, 24)
	coins.add_theme_font_size_override("font_size", 16)
	add_child(coins)

	var hint := Label.new()
	hint.text = "Campaign = mana + waves · Barracks unlocks · Mana Lab upgrades · Practice = gold arcade"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.position = Vector2(0, 590)
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
