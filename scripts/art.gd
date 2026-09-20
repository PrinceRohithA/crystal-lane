extends RefCounted
class_name CrystalArt

## Shared CC0 texture helpers. Geometric placeholders stay as fallbacks.

const BIT_COLORED := preload("res://assets/env/kenney_1bit_colored_packed.png")
const BIT_MONO := preload("res://assets/env/kenney_1bit_monochrome_packed.png")
const TILE := 16

# Kind ints match BattleUnit.Kind: TANK, MELEE, RANGED, SUPPORT.
const BODY_SHAPE := {0: "square", 1: "rhombus", 2: "circle", 3: "squircle"}
const FACE_KEY := {0: "e", 1: "g", 2: "i", 3: "c"}
const HAND_KEY := {0: "closed", 1: "rock", 2: "open", 3: "peace"}
const UNIT_SCALE := {0: 0.78, 1: 0.70, 2: 0.66, 3: 0.62}


static func tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	if FileAccess.file_exists(path):
		return load(path) as Texture2D
	return null


static func bit_atlas(col: int, row: int, mono: bool = false) -> AtlasTexture:
	var at := AtlasTexture.new()
	at.atlas = BIT_MONO if mono else BIT_COLORED
	at.region = Rect2(col * TILE, row * TILE, TILE, TILE)
	at.filter_clip = true
	return at


static func bit_sprite(col: int, row: int, pos: Vector2, px_scale: float = 3.0, mono: bool = false) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = bit_atlas(col, row, mono)
	s.position = pos
	s.scale = Vector2(px_scale, px_scale)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.centered = true
	return s


static func unit_body_path(team: int, kind: int) -> String:
	var prefix := "blue" if team == 0 else "red"
	return "res://assets/units/%s_body_%s.png" % [prefix, BODY_SHAPE[kind]]


static func unit_hand_path(team: int, kind: int) -> String:
	var prefix := "blue" if team == 0 else "red"
	return "res://assets/units/%s_hand_%s.png" % [prefix, HAND_KEY[kind]]


static func unit_face_path(kind: int) -> String:
	return "res://assets/units/face_%s.png" % FACE_KEY[kind]
