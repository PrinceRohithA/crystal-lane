extends Control

## P4 Barracks — starters + unlock path toward 15 player units (P05–P15).

const STARTERS := [
	"P01 Cragback (Stone)",
	"P02 Knuckhorn (Strike)",
	"P03 Veilray (Mind)",
	"P04 Gleamlet (Bloom)",
]
const UNLOCKS := [
	{"id": "P05", "name": "Cindercurl", "type": "Ember", "k": 0},
	{"id": "P06", "name": "Brinefin", "type": "Tide", "k": 1},
	{"id": "P07", "name": "Petalward", "type": "Bloom", "k": 2},
	{"id": "P08", "name": "Rivetfist", "type": "Strike", "k": 3},
	{"id": "P09", "name": "Zephyrick", "type": "Gale", "k": 4},
	{"id": "P10", "name": "Boulderbrace", "type": "Stone", "k": 5},
	{"id": "P11", "name": "Cognivolt", "type": "Mind", "k": 6},
	{"id": "P12", "name": "Duskneedle", "type": "Shade", "k": 7},
	{"id": "P13", "name": "Pyremaw", "type": "Ember", "k": 8},
	{"id": "P14", "name": "Abysshell", "type": "Tide", "k": 9},
	{"id": "P15", "name": "Squallwing", "type": "Gale", "k": 10},
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
	title.position = Vector2(0, 24)
	title.size = Vector2(1280, 40)
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color("1c2834"))
	add_child(title)

	var coins := Label.new()
	coins.name = "CoinsLabel"
	coins.text = "Meta coins: %d" % GameState.meta_coins
	coins.position = Vector2(40, 72)
	coins.size = Vector2(500, 24)
	coins.add_theme_font_size_override("font_size", 16)
	add_child(coins)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(40, 110)
	scroll.size = Vector2(1200, 500)
	add_child(scroll)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(col)

	var starters_h := Label.new()
	starters_h.text = "Starters (owned)"
	starters_h.add_theme_font_size_override("font_size", 18)
	col.add_child(starters_h)
	for s in STARTERS:
		var l := Label.new()
		l.text = "  %s" % s
		l.add_theme_font_size_override("font_size", 14)
		col.add_child(l)

	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 12)
	col.add_child(gap)

	var unlock_h := Label.new()
	unlock_h.text = "Unlocks (P05-P15 toward 15/15 roster)"
	unlock_h.add_theme_font_size_override("font_size", 18)
	col.add_child(unlock_h)

	for u in UNLOCKS:
		var cost: int = GddBalance.unlock_coins(int(u["k"]))
		var owned: bool = GameState.is_unlocked(str(u["id"]))
		var row := HBoxContainer.new()
		var lab := Label.new()
		lab.text = "%s %s (%s)  -  %d coins" % [u["id"], u["name"], u["type"], cost]
		lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lab.add_theme_font_size_override("font_size", 14)
		row.add_child(lab)
		var b := Button.new()
		b.text = "Owned" if owned else "Unlock"
		b.disabled = owned or GameState.meta_coins < cost
		b.custom_minimum_size = Vector2(120, 32)
		var id := str(u["id"])
		var c := cost
		b.pressed.connect(func() -> void:
			if GameState.try_unlock(id, c):
				get_tree().reload_current_scene()
		)
		row.add_child(b)
		col.add_child(row)

	var back := Button.new()
	back.text = "<- Main Menu"
	back.position = Vector2(40, 640)
	back.size = Vector2(200, 44)
	back.pressed.connect(func() -> void: GameState.go_main_menu())
	add_child(back)

	var hint := Label.new()
	hint.text = "Unlock soft-ceiling min(900, round(40*1.22^k)) - GDD App E. Combat still uses kernel 4 roles until deck wiring."
	hint.position = Vector2(260, 650)
	hint.size = Vector2(900, 24)
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color("5a5850"))
	add_child(hint)
