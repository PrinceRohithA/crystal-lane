extends CanvasLayer

const UnitScript := preload("res://scripts/unit.gd")

var game: Node

var _gold_label: Label
var _mana_fill: ColorRect
var _mana_label: Label
var _field_label: Label
var _player_hp: Label
var _enemy_hp: Label
var _toast: Label
var _spawn_btns: Array[Button] = []
var _spell_btn: Button
var _end_panel: Panel
var _end_title: Label
var _toast_time: float = 0.0


func bind_game(p_game: Node) -> void:
	game = p_game
	game.economy_changed.connect(_on_economy)
	game.toast_requested.connect(show_toast)
	game.match_over.connect(_on_match_over)


func _ready() -> void:
	layer = 10
	_build_ui()


func _process(delta: float) -> void:
	if _toast_time > 0.0:
		_toast_time -= delta
		if _toast_time <= 0.0:
			_toast.visible = false
	_refresh_buttons()


func set_player_hp(current: int, maximum: int) -> void:
	_player_hp.text = "Blue crystal  %d / %d" % [current, maximum]


func set_enemy_hp(current: int, maximum: int) -> void:
	_enemy_hp.text = "Red crystal  %d / %d" % [current, maximum]


func show_toast(text: String) -> void:
	_toast.text = text
	_toast.visible = true
	_toast_time = 1.4


func _on_economy(gold: int, mana: float, max_mana: float) -> void:
	_gold_label.text = "Gold  %d" % gold
	var ratio := clampf(mana / max_mana, 0.0, 1.0)
	_mana_fill.size = Vector2(220.0 * ratio, 22.0)
	_mana_label.text = "Mana  %d / %d" % [int(mana), int(max_mana)]
	if game:
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
	if game == null or game.is_over:
		return
	var full: bool = game.alive_count() >= game.MAX_ALIVE
	for i in _spawn_btns.size():
		var cost: int = game.unit_cost(i)
		_spawn_btns[i].disabled = full or game.gold < cost
	_spell_btn.disabled = game.mana < game.SPELL_COST


func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	root.add_child(_panel_label("CRYSTAL LANE", Vector2(24, 16), 18, Color("1c2834"), true))

	_player_hp = _panel_label("Blue crystal  —", Vector2(24, 48), 16, Color("2d6eae"), true)
	root.add_child(_player_hp)
	_enemy_hp = _panel_label("Red crystal  —", Vector2(980, 48), 16, Color("b33d32"), true)
	_enemy_hp.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_enemy_hp.size = Vector2(276, 28)
	root.add_child(_enemy_hp)

	var econ := _card(Vector2(16, 608), Vector2(268, 100))
	root.add_child(econ)
	_gold_label = _make_label("Gold  0", 18, Color("6b5340"))
	_gold_label.position = Vector2(12, 8)
	econ.add_child(_gold_label)
	_field_label = _make_label("Field  0 / 8", 14, Color("1c2834"))
	_field_label.position = Vector2(150, 10)
	econ.add_child(_field_label)

	var mana_bg := ColorRect.new()
	mana_bg.color = Color("d8d3c4")
	mana_bg.position = Vector2(12, 44)
	mana_bg.size = Vector2(220, 22)
	econ.add_child(mana_bg)
	_mana_fill = ColorRect.new()
	_mana_fill.color = Color("8a6ad4")
	_mana_fill.position = Vector2.ZERO
	_mana_fill.size = Vector2(88, 22)
	mana_bg.add_child(_mana_fill)
	_mana_label = _make_label("Mana  0 / 100", 14, Color("1c2834"))
	_mana_label.position = Vector2(16, 44)
	_mana_label.size = Vector2(212, 22)
	econ.add_child(_mana_label)

	var hint2 := _make_label("Gold trains units. Mana is Type Pulse only.", 12, Color("5a5850"))
	hint2.position = Vector2(12, 72)
	hint2.size = Vector2(244, 20)
	econ.add_child(hint2)

	var actions := _card(Vector2(292, 600), Vector2(972, 108))
	root.add_child(actions)

	var kinds := [UnitScript.Kind.TANK, UnitScript.Kind.MELEE, UnitScript.Kind.RANGED, UnitScript.Kind.SUPPORT]
	for i in kinds.size():
		var kind: int = kinds[i]
		var info: Dictionary = UnitScript.DISPLAY[kind]
		var cost: int = int(UnitScript.COST[kind])
		var label := "%d  %s\n%s · %dg" % [i + 1, info["name"], info["role"], cost]
		var btn := _make_button(label, Vector2(12 + i * 178, 14), Vector2(168, 80))
		var captured := kind
		btn.pressed.connect(func() -> void: game.try_spawn_player(captured))
		actions.add_child(btn)
		_spawn_btns.append(btn)

	_spell_btn = _make_button("Type Pulse\nSpace · 55 mana", Vector2(724, 14), Vector2(232, 80))
	_spell_btn.pressed.connect(func() -> void: game.try_cast_type_pulse())
	actions.add_child(_spell_btn)

	_toast = _make_label("", 22, Color("1c2834"))
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.position = Vector2(340, 120)
	_toast.size = Vector2(600, 36)
	_toast.visible = false
	root.add_child(_toast)

	var hint := _make_label("1 Tank  ·  2 Melee  ·  3 Ranged  ·  4 Support     Space Type Pulse (middle third of the lane)", 14, Color("1c2834"))
	hint.position = Vector2(280, 16)
	hint.size = Vector2(760, 24)
	root.add_child(hint)

	_end_panel = Panel.new()
	_end_panel.visible = false
	_end_panel.position = Vector2(440, 220)
	_end_panel.size = Vector2(400, 220)
	_end_panel.add_theme_stylebox_override("panel", _stylebox(Color("f4f1e4"), Color("1c2834")))
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

	var restart := _make_button("Play again", Vector2(120, 130), Vector2(160, 44))
	restart.pressed.connect(func() -> void: get_tree().reload_current_scene())
	_end_panel.add_child(restart)


func _card(pos: Vector2, size: Vector2) -> Panel:
	var p := Panel.new()
	p.position = pos
	p.size = size
	p.add_theme_stylebox_override("panel", _stylebox(Color("f4f1e4"), Color("1c2834")))
	return p


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
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l


func _make_button(text: String, pos: Vector2, size: Vector2) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = size
	b.add_theme_font_size_override("font_size", 13)
	b.add_theme_color_override("font_color", Color("1c2834"))
	b.add_theme_stylebox_override("normal", _stylebox(Color("e7f0d8"), Color("1c2834")))
	b.add_theme_stylebox_override("hover", _stylebox(Color("fff6c8"), Color("1c2834")))
	b.add_theme_stylebox_override("pressed", _stylebox(Color("d5e4c4"), Color("1c2834")))
	b.add_theme_stylebox_override("disabled", _stylebox(Color("d0ccc0"), Color("7a7a72")))
	b.focus_mode = Control.FOCUS_NONE
	return b


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
