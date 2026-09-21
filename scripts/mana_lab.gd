extends Control

## P4 — Mana Lab: buy regen/cap upgrades with meta coins (GDD App C).


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("b8a0d0")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := Label.new()
	title.text = "MANA LAB"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 48)
	title.size = Vector2(1280, 48)
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color("1c2834"))
	add_child(title)

	var coins := Label.new()
	coins.text = "Meta coins: %d" % GameState.meta_coins
	coins.position = Vector2(40, 110)
	coins.size = Vector2(400, 28)
	coins.add_theme_font_size_override("font_size", 18)
	add_child(coins)

	var regen_n: int = GameState.mana_regen_level
	var cap_n: int = GameState.mana_cap_level
	var regen_cost: int = GddBalance.regen_coin(regen_n)
	var cap_cost: int = GddBalance.cap_coin(cap_n)
	var regen_val: float = GddBalance.CAMPAIGN_BASE_REGEN * pow(1.12, float(regen_n))
	var cap_val: float = GddBalance.CAMPAIGN_BASE_CAP + 25.0 * float(cap_n)

	var regen_l := Label.new()
	regen_l.text = "Regen Lv%d → ~%.2f/s   next cost %d" % [regen_n, regen_val, regen_cost]
	regen_l.position = Vector2(80, 200)
	regen_l.size = Vector2(700, 32)
	regen_l.add_theme_font_size_override("font_size", 18)
	add_child(regen_l)
	var regen_b := Button.new()
	regen_b.text = "Upgrade regen"
	regen_b.position = Vector2(800, 190)
	regen_b.size = Vector2(200, 44)
	regen_b.disabled = regen_n >= 7 or GameState.meta_coins < regen_cost
	regen_b.pressed.connect(func() -> void:
		if GameState.buy_regen_upgrade():
			get_tree().reload_current_scene()
	)
	add_child(regen_b)

	var cap_l := Label.new()
	cap_l.text = "Cap Lv%d → %.0f   next cost %d" % [cap_n, cap_val, cap_cost]
	cap_l.position = Vector2(80, 280)
	cap_l.size = Vector2(700, 32)
	cap_l.add_theme_font_size_override("font_size", 18)
	add_child(cap_l)
	var cap_b := Button.new()
	cap_b.text = "Upgrade cap"
	cap_b.position = Vector2(800, 270)
	cap_b.size = Vector2(200, 44)
	cap_b.disabled = cap_n >= 7 or GameState.meta_coins < cap_cost
	cap_b.pressed.connect(func() -> void:
		if GameState.buy_cap_upgrade():
			get_tree().reload_current_scene()
	)
	add_child(cap_b)

	var note := Label.new()
	note.text = "GDD App C ladders · max 7 buys each · applies in Campaign battles"
	note.position = Vector2(80, 360)
	note.size = Vector2(900, 28)
	note.add_theme_font_size_override("font_size", 14)
	note.add_theme_color_override("font_color", Color("3a4a58"))
	add_child(note)

	var back := Button.new()
	back.text = "← Main Menu"
	back.position = Vector2(40, 640)
	back.size = Vector2(200, 44)
	back.pressed.connect(func() -> void: GameState.go_main_menu())
	add_child(back)
