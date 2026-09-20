extends Control

## P1 — Level Select L1–3 wave stubs (P2 expands waves).


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("8eb8d4")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := Label.new()
	title.text = "LEVEL SELECT"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 80)
	title.size = Vector2(1280, 48)
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color("1c2834"))
	var font_title := load("res://assets/ui/KenneyFuture.ttf") as Font
	if font_title:
		title.add_theme_font_override("font", font_title)
	add_child(title)

	var labels := [
		"L1 · Force intro (Stone / Strike)",
		"L2 · Soft support (Bloom)",
		"L3 · Mind / Ember tease",
	]
	for i in 3:
		var level := i + 1
		var b := Button.new()
		b.text = labels[i]
		b.position = Vector2(400, 200 + i * 80)
		b.size = Vector2(480, 60)
		b.add_theme_font_size_override("font_size", 18)
		var font := load("res://assets/ui/KenneyFutureNarrow.ttf") as Font
		if font:
			b.add_theme_font_override("font", font)
		b.focus_mode = Control.FOCUS_NONE
		var captured := level
		b.pressed.connect(func() -> void: GameState.start_level(captured))
		add_child(b)

	var back := Button.new()
	back.text = "← Main Menu"
	back.position = Vector2(40, 640)
	back.size = Vector2(200, 44)
	back.pressed.connect(func() -> void: GameState.go_main_menu())
	back.focus_mode = Control.FOCUS_NONE
	add_child(back)

	var note := Label.new()
	note.text = "Wave director + Barracks unlocks land in P2 · Type chart in P3"
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.position = Vector2(0, 480)
	note.size = Vector2(1280, 24)
	note.add_theme_font_size_override("font_size", 14)
	note.add_theme_color_override("font_color", Color("3a4a58"))
	add_child(note)
