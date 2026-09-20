extends CanvasLayer

const UnitScript := preload("res://scripts/unit.gd")

var game: Node

var _gold_label: Label
var _mana_bar: TextureProgressBar
var _mana_label: Label
var _field_label: Label
var _player_hp: Label
var _enemy_hp: Label
var _player_bar: TextureProgressBar
var _enemy_bar: TextureProgressBar
var _toast: Label
var _spawn_btns: Array[Button] = []
var _spell_btn: Button
var _end_panel: Control
var _end_title: Label
var _toast_time: float = 0.0
var _font: Font
var _font_title: Font


func bind_game(p_game: Node) -> void:
	game = p_game
	game.economy_changed.connect(_on_economy)
	game.toast_requested.connect(show_toast)
	game.match_over.connect(_on_match_over)


func _ready() -> void:
	layer = 10
	_font = load("res://assets/ui/KenneyFutureNarrow.ttf") as Font
	_font_title = load("res://assets/ui/KenneyFuture.ttf") as Font
	_build_ui()


func _process(delta: float) -> void:
	if _toast_time > 0.0:
		_toast_time -= delta
		if _toast_time <= 0.0:
			_toast.visible = false
	_refresh_buttons()


func set_player_hp(current: int, maximum: int) -> void:
	_player_hp.text = "Blue  %d/%d" % [current, maximum]
	if _player_bar:
		_player_bar.max_value = maximum
		_player_bar.value = current


func set_enemy_hp(current: int, maximum: int) -> void:
	_enemy_hp.text = "Red  %d/%d" % [current, maximum]
	if _enemy_bar:
		_enemy_bar.max_value = maximum
		_enemy_bar.value = current


func show_toast(text: String) -> void:
	if _toast == null:
		return
	_toast.text = text
	_toast.visible = true
	_toast_time = 2.8 if text.length() > 22 else 1.6


func _on_economy(gold: int, mana: float, max_mana: float) -> void:
	if _gold_label:
		_gold_label.text = "Gold  %d" % gold
	if _mana_bar:
		_mana_bar.max_value = max_mana
		_mana_bar.value = mana
	if _mana_label:
		_mana_label.text = "Mana  %d / %d" % [int(mana), int(max_mana)]
	if game and _field_label:
		_field_label.text = "Field  %d / %d" % [game.alive_count(), game.MAX_ALIVE]


func _on_match_over(player_won: bool) -> void:
	_end_panel.visible = true
	if player_won:
		_end_title.text = "Victory"
		_end_title.add_theme_color_override("font_color", Color("2e6b3a"))
	else:
		_end_title.text = "Defeat"
		_end_title.add_theme_color_override("font_color", Color("8b2e28"))
	for b in _spawn_btns:
		b.disabled = true
	_spell_btn.disabled = true


func _refresh_buttons() -> void:
	if game == null or game.is_over or _spell_btn == null:
		return
	var full: bool = game.alive_count() >= game.MAX_ALIVE
	for i in _spawn_btns.size():
		if _spawn_btns[i] == null:
			continue
		var cost: int = game.unit_cost(i)
		_spawn_btns[i].disabled = full or game.gold < cost
	_spell_btn.disabled = game.mana < game.SPELL_COST


func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var title := _panel_label("CRYSTAL LANE", Vector2(24, 12), 20, Color("1c2834"), true)
	if _font_title:
		title.add_theme_font_override("font", _font_title)
	root.add_child(title)

	# Crystal HP — left blue, right red
	var hp_left := _nine("res://assets/ui/panel.png", Vector2(16, 42), Vector2(268, 52))
	root.add_child(hp_left)
	_player_bar = _hp_bar("res://assets/ui/blue_bar.png", Vector2(28, 68), Vector2(244, 16))
	if _player_bar:
		root.add_child(_player_bar)
	_player_hp = _panel_label("Blue  —", Vector2(28, 44), 14, Color("2d6eae"), false)
	root.add_child(_player_hp)

	var hp_right := _nine("res://assets/ui/panel.png", Vector2(996, 42), Vector2(268, 52))
	root.add_child(hp_right)
	_enemy_bar = _hp_bar("res://assets/ui/red_bar.png", Vector2(1008, 68), Vector2(244, 16))
	if _enemy_bar:
		root.add_child(_enemy_bar)
	_enemy_hp = _panel_label("Red  —", Vector2(1008, 44), 14, Color("b33d32"), false)
	_enemy_hp.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_enemy_hp.size = Vector2(244, 24)
	root.add_child(_enemy_hp)

	var econ := _nine("res://assets/ui/panel.png", Vector2(16, 608), Vector2(268, 100))
	root.add_child(econ)

	var coin := TextureRect.new()
	var coin_tex := CrystalArt.tex("res://assets/ui/star_gold.png")
	if coin_tex == null:
		coin_tex = CrystalArt.tex("res://assets/units/tile_coin.png")
	coin.texture = coin_tex
	coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin.position = Vector2(10, 8)
	coin.size = Vector2(28, 28)
	econ.add_child(coin)

	_gold_label = _make_label("Gold  0", 18, Color("6b5340"))
	_gold_label.position = Vector2(42, 10)
	econ.add_child(_gold_label)
	_field_label = _make_label("Field  0 / 8", 13, Color("1c2834"))
	_field_label.position = Vector2(150, 12)
	econ.add_child(_field_label)

	_mana_bar = _hp_bar("res://assets/ui/blue_bar.png", Vector2(12, 46), Vector2(244, 18))
	if _mana_bar:
		_mana_bar.modulate = Color(0.78, 0.62, 1.12)
		econ.add_child(_mana_bar)
	_mana_label = _make_label("Mana  0 / 100", 13, Color("1c2834"))
	_mana_label.position = Vector2(16, 44)
	_mana_label.size = Vector2(236, 20)
	econ.add_child(_mana_label)

	var hint2 := _make_label("Kills +15 gold. Mana is Type Pulse.", 11, Color("5a5850"))
	hint2.position = Vector2(12, 72)
	hint2.size = Vector2(244, 20)
	econ.add_child(hint2)

	var actions := _nine("res://assets/ui/panel.png", Vector2(292, 600), Vector2(972, 108))
	root.add_child(actions)

	var kinds := [UnitScript.Kind.TANK, UnitScript.Kind.MELEE, UnitScript.Kind.RANGED, UnitScript.Kind.SUPPORT]
	var btn_colors := [
		"res://assets/ui/grey_button_gloss.png",
		"res://assets/ui/red_button_gloss.png",
		"res://assets/ui/blue_button_gloss.png",
		"res://assets/ui/green_button_gloss.png",
	]
	for i in kinds.size():
		var kind: int = kinds[i]
		var info: Dictionary = UnitScript.DISPLAY[kind]
		var cost: int = int(UnitScript.COST[kind])
		var label := "%d  %s\n%s / %s · %dg" % [i + 1, info["name"], info["role"], info["affinity"], cost]
		var btn := _make_button(label, Vector2(12 + i * 178, 14), Vector2(168, 80), btn_colors[i])
		var icon := CrystalArt.tex(CrystalArt.unit_body_path(0, kind))
		if icon:
			btn.icon = icon
			btn.expand_icon = true
			btn.add_theme_constant_override("icon_max_width", 36)
		var captured := kind
		btn.pressed.connect(func() -> void: game.try_spawn_player(captured))
		actions.add_child(btn)
		_spawn_btns.append(btn)

	_spell_btn = _make_button("Type Pulse\nSpace · 55 mana", Vector2(724, 14), Vector2(232, 80), "res://assets/ui/yellow_button_gloss.png")
	_spell_btn.pressed.connect(func() -> void: game.try_cast_type_pulse())
	actions.add_child(_spell_btn)

	_toast = _make_label("", 22, Color("1c2834"))
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.position = Vector2(280, 112)
	_toast.size = Vector2(720, 44)
	_toast.visible = false
	root.add_child(_toast)

	var hint := _make_label("1 Tank  ·  2 Melee  ·  3 Ranged  ·  4 Support     Space Type Pulse     Rock > Fighting > Fairy > Psychic", 13, Color("1c2834"))
	hint.position = Vector2(280, 14)
	hint.size = Vector2(980, 24)
	root.add_child(hint)

	_end_panel = _nine("res://assets/ui/panel.png", Vector2(440, 220), Vector2(400, 220))
	_end_panel.visible = false
	root.add_child(_end_panel)

	_end_title = _make_label("Victory", 32, Color("2e6b3a"))
	_end_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_end_title.position = Vector2(0, 28)
	_end_title.size = Vector2(400, 40)
	_end_panel.add_child(_end_title)

	var end_body := _make_label("Press R or Enter to play again", 16, Color("1c2834"))
	end_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_body.position = Vector2(0, 78)
	end_body.size = Vector2(400, 28)
	_end_panel.add_child(end_body)

	var restart := _make_button("Play again", Vector2(120, 130), Vector2(160, 44), "res://assets/ui/green_button_gloss.png")
	restart.pressed.connect(func() -> void: get_tree().reload_current_scene())
	_end_panel.add_child(restart)


func _nine(path: String, pos: Vector2, size: Vector2) -> Control:
	var n := NinePatchRect.new()
	n.texture = CrystalArt.tex(path)
	n.position = pos
	n.size = size
	n.patch_margin_left = 12
	n.patch_margin_right = 12
	n.patch_margin_top = 12
	n.patch_margin_bottom = 12
	if n.texture == null:
		var p := Panel.new()
		p.position = pos
		p.size = size
		p.add_theme_stylebox_override("panel", _stylebox(Color("f4f1e4"), Color("1c2834")))
		return p
	return n


func _hp_bar(fill_path: String, pos: Vector2, size: Vector2) -> TextureProgressBar:
	var bar := TextureProgressBar.new()
	bar.position = pos
	bar.size = size
	bar.min_value = 0
	bar.max_value = 100
	bar.value = 100
	bar.nine_patch_stretch = true
	bar.stretch_margin_left = 8
	bar.stretch_margin_right = 8
	bar.stretch_margin_top = 4
	bar.stretch_margin_bottom = 4
	var under := CrystalArt.tex("res://assets/ui/grey_bar_under.png")
	var fill := CrystalArt.tex(fill_path)
	if under:
		bar.texture_under = under
	if fill:
		bar.texture_progress = fill
	return bar


func _panel_label(text: String, pos: Vector2, font_size: int, color: Color, boxed: bool) -> Label:
	var l := _make_label(text, font_size, color)
	l.position = pos
	l.size = Vector2(320, 28)
	if boxed:
		l.add_theme_color_override("font_shadow_color", Color(1, 1, 1, 0.7))
		l.add_theme_constant_override("shadow_offset_x", 1)
		l.add_theme_constant_override("shadow_offset_y", 1)
	return l


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	if _font:
		l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l


func _make_button(text: String, pos: Vector2, size: Vector2, tex_path: String = "") -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = size
	if _font:
		b.add_theme_font_override("font", _font)
	b.add_theme_font_size_override("font_size", 13)
	b.add_theme_color_override("font_color", Color("1c2834"))
	var tex := CrystalArt.tex(tex_path) if tex_path != "" else null
	if tex:
		var normal := _tex_style(tex)
		b.add_theme_stylebox_override("normal", normal)
		var hover_tex := CrystalArt.tex(tex_path.replace("_gloss", "_flat"))
		b.add_theme_stylebox_override("hover", _tex_style(hover_tex if hover_tex else tex))
		b.add_theme_stylebox_override("pressed", _tex_style(hover_tex if hover_tex else tex))
		var disabled_tex := CrystalArt.tex("res://assets/ui/grey_button_flat.png")
		if disabled_tex:
			b.add_theme_stylebox_override("disabled", _tex_style(disabled_tex))
	else:
		b.add_theme_stylebox_override("normal", _stylebox(Color("e7f0d8"), Color("1c2834")))
		b.add_theme_stylebox_override("hover", _stylebox(Color("fff6c8"), Color("1c2834")))
		b.add_theme_stylebox_override("pressed", _stylebox(Color("d5e4c4"), Color("1c2834")))
		b.add_theme_stylebox_override("disabled", _stylebox(Color("d0ccc0"), Color("7a7a72")))
	b.focus_mode = Control.FOCUS_NONE
	return b


func _tex_style(tex: Texture2D) -> StyleBoxTexture:
	var s := StyleBoxTexture.new()
	s.texture = tex
	s.texture_margin_left = 12
	s.texture_margin_right = 12
	s.texture_margin_top = 10
	s.texture_margin_bottom = 10
	return s


func _stylebox(bg: Color, border: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(3)
	s.set_corner_radius_all(4)
	s.content_margin_left = 8
	s.content_margin_right = 8
	s.content_margin_top = 4
	s.content_margin_bottom = 4
	return s
