extends Control

## P2 — Barracks: view starters + unlock P05–P08 with soft-ceiling coins.

const STARTERS := ["P01 Cragback", "P02 Knuckhorn", "P03 Veilray", "P04 Gleamlet"]
const UNLOCKS := [
	{"id": "P05", "name": "Cindercurl", "k": 0},
	{"id": "P06", "name": "Brinefin", "k": 1},
	{"id": "P07", "name": "Petalward", "k": 2},
	{"id": "P08", "name": "Rivetfist", "k": 3},
]


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("d8c8a8")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := Label.new()
	title.text = "BARRACKS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 40)
	title.size = Vector2(1280, 48)
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color("1c2834"))
	add_child(title)

	var coins := Label.new()
	coins.name = "CoinsLabel"
	coins.text = "Meta coins: %d" % GameState.meta_coins
	coins.position = Vector2(40, 100)
	coins.size = Vector2(400, 28)
	coins.add_theme_font_size_override("font_size", 18)
	add_child(coins)

	var y := 150
	for s in STARTERS:
		var l := Label.new()
		l.text = "%s  ·  Owned (starter)" % s
		l.position = Vector2(80, y)
		l.size = Vector2(600, 28)
		l.add_theme_font_size_override("font_size", 16)
		add_child(l)
		y += 32

	y += 20
	for u in UNLOCKS:
		var cost: int = GddBalance.unlock_coins(int(u["k"]))
		var owned: bool = GameState.is_unlocked(str(u["id"]))
		var row := HBoxContainer.new()
		row.position = Vector2(80, y)
		row.size = Vector2(900, 40)
		var lab := Label.new()
		lab.text = "%s %s  ·  unlock %d coins" % [u["id"], u["name"], cost]
		lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lab.add_theme_font_size_override("font_size", 16)
		row.add_child(lab)
		var b := Button.new()
		b.text = "Owned" if owned else "Unlock"
		b.disabled = owned or GameState.meta_coins < cost
		b.custom_minimum_size = Vector2(120, 36)
		var id := str(u["id"])
		var c := cost
		b.pressed.connect(func() -> void:
			if GameState.try_unlock(id, c):
				get_tree().reload_current_scene()
		)
		row.add_child(b)
		add_child(row)
		y += 48

	var back := Button.new()
	back.text = "← Main Menu"
	back.position = Vector2(40, 640)
	back.size = Vector2(200, 44)
	back.pressed.connect(func() -> void: GameState.go_main_menu())
	add_child(back)

	var hint := Label.new()
	hint.text = "Unlocks use soft-ceiling min(900, round(40×1.22^k)) — GDD App E"
	hint.position = Vector2(300, 650)
	hint.size = Vector2(700, 24)
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color("5a5850"))
	add_child(hint)
