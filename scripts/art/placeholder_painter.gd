class_name PlaceholderPainter
extends RefCounted
## Coded placeholders for art slots (Claude, 2026-10-26, placeholder factory contract). Flat shapes at the slot's exact
## size in the house colours: lit from the upper left, shaded to the lower right, a 1 px ink edge, a contact shadow
## under props. Binary alpha (0 or 255) or fully opaque, as the slot's kind says, and nothing on a canvas edge the slot
## does not allow. Every painter here returns exactly the slot's sheet_size (all frames and state rows).
## A slot can name its own painter in its row ("placeholder": "res://x.gd:method", a static func (id, spec) -> Image);
## paint() uses it when it returns the right size, and falls back to the kind's painter here otherwise. Lanes write
## those per-slot painters (today's code drawing, so the screen does not change); this file is the shared fallback.

# House colours (the same values as building_exteriors.gd, ui_style.gd and the town brief).
const INK := Color("#0b0e11")          # building_exteriors.gd INK: purposeful detail
const WOOD := Color("#80694a")         # building_exteriors.gd WOOD
const WOOD_LIT := Color("#bba17a")     # building_exteriors.gd WOOD_LIT
const STONE := Color("#8f805e")        # building_exteriors.gd STONE
const STONE_LIT := Color("#bea986")    # building_exteriors.gd LIGHT
const LANTERN := Color("#f2c14e")      # ui_style.gd LIGHT, the lantern
const WINDOW := Color("#e2bd72")       # lit windows (02 section 4.4)
const DOOR_DARK := Color("#333b2f")    # the doorway (02 section 4.4)
const DOOR_FRAME := Color("#987b46")
const ROOF := Color("#5f6f45")         # a moss roof
const SHADOW := Color("#2b3326")       # contact shadow, opaque (binary alpha)
const GRASS := Color("#53673e")        # building_exteriors.gd GRASS
const PANEL := Color("#242b25")        # ui_style.gd PANEL
const EDGE := Color("#b69b6d")         # ui_style.gd EDGE
const EDGE_LIGHT := Color("#e4ca8e")   # ui_style.gd EDGE_LIGHT
const FOCUS := Color("#3f5140")        # ui_style.gd FOCUS
const TEXT := Color("#fff4e8")         # ui_style.gd TEXT
const PORTRAIT_BG := Color("#63a9a6")  # ui_style.gd PORTRAIT_BG
const PARCHMENT := Color("#e3c89a")    # building_exteriors.gd CARD
const SLATE := Color("#5b6470")
const SEAL := Color("#3fa79b")
## A palette family's base colour, when the row has no "tint".
const FAMILY := {
	"town_stone": STONE, "town_timber": WOOD, "lantern": LANTERN, "brass_ui": EDGE, "night_bank": Color("#1b2a33"),
	"dawn": Color("#c9a77a"), "ruin": SLATE, "room_chamber": Color("#3f7f7a"), "room_runners": Color("#8a6a48"),
	"room_shop": Color("#9a7853"), "room_scrolls_cellar": Color("#6f6a5e"),
}
const KIND_BASE := {"building": STONE, "landmark": STONE, "ground": GRASS, "room": WOOD, "backdrop": Color("#3b4a3f"),
	"prop": WOOD, "lamp": WOOD, "character": STONE, "hud_piece": EDGE, "hud_icon": EDGE, "frame9": EDGE, "effect": LANTERN}


## The placeholder image for a slot, exactly spec.sheet_size.
static func paint(id: String, spec: Dictionary) -> Image:
	var want: Vector2i = spec.get("sheet_size", Vector2i.ONE)
	var hook := String(spec.get("placeholder", ""))
	if hook != "":
		var img := _hook(hook, id, spec)
		if img != null:
			if img.get_size() == want:
				return _rgba(img)
			push_warning("PlaceholderPainter: %s painted %dx%d for %s, which wants %dx%d; using the kind painter" % [hook, img.get_width(), img.get_height(), id, want.x, want.y])
	return by_kind(id, spec)


## The kind's own placeholder: every state row and frame, painted cell by cell into one sheet.
static func by_kind(id: String, spec: Dictionary) -> Image:
	var want: Vector2i = spec.get("sheet_size", Vector2i.ONE)
	var size: Vector2i = spec.get("size", want)
	var sheet := Image.create(maxi(1, want.x), maxi(1, want.y), false, Image.FORMAT_RGBA8)
	var states: Dictionary = spec.get("states", {"static": [1, 0]})
	var row := 0
	for st in states:
		for f in maxi(1, int(states[st][0])):
			var cell := _cell(id, spec, size, String(st), f)
			sheet.blit_rect(cell, Rect2i(Vector2i.ZERO, size), Vector2i(f * size.x, row * size.y))
		row += 1
	return sheet


## A box with a 1 px ink edge, its top and left inner line lit, its bottom and right inner line shaded.
static func block(img: Image, r: Rect2i, base: Color) -> void:
	var c := r.intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	if c.size.x <= 0 or c.size.y <= 0:
		return
	var rp := ramp(base)
	img.fill_rect(c, rp[1])
	if r.size.x > 2 and r.size.y > 2:
		_fill(img, Rect2i(r.position.x + 1, r.position.y + 1, r.size.x - 2, 1), rp[0])
		_fill(img, Rect2i(r.position.x + 1, r.position.y + 1, 1, r.size.y - 2), rp[0])
		_fill(img, Rect2i(r.position.x + 1, r.end.y - 2, r.size.x - 2, 1), rp[2])
		_fill(img, Rect2i(r.end.x - 2, r.position.y + 2, 1, r.size.y - 3), rp[2])
	_outline(img, r, INK)


## An opaque contact shadow under what is drawn: fills the empty pixels of `foot`, one step right of the content.
static func shadow(img: Image, foot: Rect2i) -> void:
	var c := foot.intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	for y in range(c.position.y, c.end.y):
		for x in range(c.position.x, c.end.x):
			if img.get_pixel(x, y).a == 0.0:
				img.set_pixel(x, y, SHADOW)


## Fills the whole image in `rows` horizontal bands, top to bottom, cycling through `tones` (a ramp). Opaque.
static func bands(img: Image, tones: Array[Color], rows: int) -> void:
	var n := maxi(1, rows)
	var h := img.get_height()
	for i in n:
		var y0 := h * i / n
		var y1 := h * (i + 1) / n
		img.fill_rect(Rect2i(0, y0, img.get_width(), y1 - y0), tones[i % tones.size()])


## Four tones from one base: lit, base, shade, deep. Quantised to 8 bits so colour counts are exact.
static func ramp(base: Color) -> Array[Color]:
	var out: Array[Color] = [_q(base.lightened(0.2)), _q(base), _q(base.darkened(0.22)), _q(base.darkened(0.45))]
	return out


# ---------------------------------------------------------------------------------------------------------------------

static func _cell(id: String, spec: Dictionary, size: Vector2i, state: String, f: int) -> Image:
	var img := Image.create(maxi(1, size.x), maxi(1, size.y), false, Image.FORMAT_RGBA8)
	var kind := String(spec.get("kind", "prop"))
	var base := _base(spec, kind)
	var name := id.get_slice(".", id.get_slice_count(".") - 1)
	match kind:
		"backdrop":
			_backdrop(img, id, base)
		"ground":
			_ground(img, base)
		"room":
			_room(img, name, base)
		"building":
			_building(img, spec, base)
		"landmark":
			_landmark(img, base)
		"lamp":
			_lamp(img, spec, state == "lit")
		"frame9":
			_frame9(img, name)
		"effect":
			_effect(img, base, f)
		"hud_piece":
			_hud_piece(img, name, base, f)
		_:
			_prop(img, spec, name, base)
	_clear_edges(img, spec)
	return img


static func _base(spec: Dictionary, kind: String) -> Color:
	if spec.has("tint"):
		return _q(Color(String(spec["tint"])))
	var fam := String(spec.get("palette", {}).get("family", ""))
	if FAMILY.has(fam):
		return FAMILY[fam]
	return KIND_BASE.get(kind, STONE)


static func _backdrop(img: Image, id: String, base: Color) -> void:
	if id.begins_with("ui.backdrop.stage_"):
		# Parchment with three essence-colour bands along the bottom (party_screen.gd draws plain parchment today).
		var rp := ramp(base)
		var bandset: Array[Color] = [_q(PARCHMENT), _q(PARCHMENT.darkened(0.06)), rp[0], rp[1], rp[2]]
		bands(img, bandset, 5)
		return
	var rp2 := ramp(base)
	var steps: Array[Color] = [rp2[1], rp2[2], rp2[3]]   # three stepped bands, lightest at the top
	bands(img, steps, 3)


static func _ground(img: Image, base: Color) -> void:
	var rp := ramp(base)
	img.fill(rp[1])
	for y in range(0, img.get_height(), 24):
		for x in range(0, img.get_width(), 24):
			var k := ((x / 24) + (y / 24)) % 2
			_fill(img, Rect2i(x + 3, y + 3, 6, 3), rp[0] if k == 0 else rp[2])
			_fill(img, Rect2i(x + 13, y + 14, 5, 3), rp[2] if k == 0 else rp[0])


static func _room(img: Image, name: String, base: Color) -> void:
	var rp := ramp(base)
	var w := img.get_width()
	var h := img.get_height()
	img.fill(rp[1])
	if name in ["floor", "home", "hall", "shell", "shell_mask"]:
		for y in range(0, h, 12):   # boards or flags, 12 px courses
			_fill(img, Rect2i(0, y, w, 1), rp[2])
			var off := 0 if (y / 12) % 2 == 0 else 24
			for x in range(off, w, 48):
				_fill(img, Rect2i(x, y, 1, 12), rp[2])
		if name != "floor":   # a whole room in one picture: a north wall band and side rims
			img.fill_rect(Rect2i(0, 0, w, mini(48, h)), rp[3])
			_fill(img, Rect2i(0, mini(46, h - 1), w, 2), rp[0])
			_fill(img, Rect2i(0, 0, mini(24, w), h), rp[3])
			_fill(img, Rect2i(maxi(0, w - 24), 0, mini(24, w), h), rp[3])
		return
	img.fill(rp[3])
	match name:
		"north":
			_fill(img, Rect2i(0, 0, w, 3), INK)
			for x in range(0, w, 24):
				_fill(img, Rect2i(x, 3, 1, h - 6), rp[2])
			_fill(img, Rect2i(0, h - 6, w, 3), rp[0])
			_fill(img, Rect2i(0, h - 3, w, 3), rp[2])
		"south":
			_fill(img, Rect2i(0, 0, w, 2), rp[0])
			_fill(img, Rect2i(0, h - 2, w, 2), INK)
		"west":
			_fill(img, Rect2i(0, 0, 2, h), INK)
			_fill(img, Rect2i(w - 2, 0, 2, h), rp[0])
		"east":
			_fill(img, Rect2i(w - 2, 0, 2, h), INK)
			_fill(img, Rect2i(0, 0, 2, h), rp[2])


static func _building(img: Image, spec: Dictionary, base: Color) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var cls := String(spec.get("building_class", "cottage"))
	var door: Rect2i = spec.get("door_px", Rect2i())
	var eave := 6
	var wall_top := (door.position.y - 12) if door.size.y > 0 else h - 60
	if cls == "stall":
		# A counter along the bottom, two posts and an awning over it (02 section 4.2).
		block(img, Rect2i(eave, h - 20, w - 2 * eave, 20), WOOD)
		block(img, Rect2i(eave + 2, h - 84, 6, 64), WOOD)
		block(img, Rect2i(w - eave - 8, h - 84, 6, 64), WOOD)
		block(img, Rect2i(1, h - 120 + 1, w - 2, 36), base)
		return
	if cls == "hall" and h > 2 * w:
		# The Wayline Tower: the wide base with its double door, a shaft, a lantern room and the beacon mast.
		block(img, Rect2i(eave, wall_top, w - 2 * eave, h - wall_top), base)
		var sw := w * 2 / 5
		var sx := (w - sw) / 2
		block(img, Rect2i(sx, 40, sw, wall_top - 40 + 1), base)
		for y in range(64, wall_top - 24, 48):
			_fill(img, Rect2i(w / 2 - 4, y, 8, 12), WINDOW)
		block(img, Rect2i(w / 2 - 18, 18, 36, 24), LANTERN)
		_fill(img, Rect2i(w / 2 - 1, 1, 2, 17), INK)
	else:
		block(img, Rect2i(1, 1, w - 2, wall_top), ROOF)
		_fill(img, Rect2i(1, wall_top - 2, w - 2, 1), INK)   # the drip line
		block(img, Rect2i(eave, wall_top, w - 2 * eave, h - wall_top), base)
	if String(spec.get("id", "")).ends_with("lot_before_shop"):
		# Shuttered: plain boards where the door and windows will be.
		for y in range(wall_top + 8, h - 6, 10):
			_fill(img, Rect2i(w / 2 - 12, y, 24, 4), WOOD_LIT)
	if door.size.x > 0:
		_fill(img, door, DOOR_FRAME)
		_fill(img, door.grow(-2), DOOR_DARK)
		var wy := wall_top + 12
		if door.position.x - eave > 30:
			_fill(img, Rect2i(eave + 10, wy, 12, 10), WINDOW)
			_fill(img, Rect2i(w - eave - 22, wy, 12, 10), WINDOW)


static func _landmark(img: Image, base: Color) -> void:
	var w := img.get_width()
	var h := img.get_height()
	block(img, Rect2i(0, 0, w, h), base)
	var rp := ramp(base)
	for y in range(6, h - 6, 12):
		var off := 0 if (y / 12) % 2 == 0 else 12
		for x in range(6 + off, w - 6, 24):
			_fill(img, Rect2i(x, y, 1, 12), rp[2])
		_fill(img, Rect2i(1, y, w - 2, 1), rp[2])


static func _prop(img: Image, spec: Dictionary, name: String, base: Color) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var foot := int(spec.get("anchor", Vector2i(w / 2, h - 1)).y) if String(spec.get("anchor_mode", "")) == "foot" else h - 1
	if name == "fence_h":
		block(img, Rect2i(-1, h - 16, w + 2, 4), base)
		block(img, Rect2i(-1, h - 9, w + 2, 4), base)
		block(img, Rect2i(w / 2 - 2, h - 20, 4, 20), base)
		return
	if name == "fence_v":
		block(img, Rect2i(w / 2 - 3, -1, 6, h + 2), base)
		return
	if name == "fence_corner":
		block(img, Rect2i(w / 2, h - 16, w / 2 + 1, 4), base)
		block(img, Rect2i(w / 2 - 3, h - 20, 6, 21), base)
		return
	if name.begins_with("sign_"):
		block(img, Rect2i(w / 2 - 1, h - 8, 2, 8), WOOD)
		block(img, Rect2i(2, 2, w - 4, h - 10), base)
		_fill(img, Rect2i(w / 2 - 3, 7, 6, 6), INK)   # where the pictogram sits
		return
	if name == "shut_rope":
		block(img, Rect2i(2, 2, 4, h - 2), WOOD)
		block(img, Rect2i(w - 6, 2, 4, h - 2), WOOD)
		_fill(img, Rect2i(6, 6, w - 12, 2), PARCHMENT)
		return
	if name == "shut_chain":
		for y in range(3, h - 10, 6):
			_fill(img, Rect2i(4, y, w - 8, 2), SLATE)
		block(img, Rect2i(w / 2 - 5, h - 12, 10, 11), EDGE)
		return
	if name == "stairs_sealed":
		block(img, Rect2i(1, 1, w - 2, h - 1), SLATE)
		_outline(img, Rect2i(w / 2 - 6, h / 2 - 6, 12, 12), SEAL)
		return
	if name in ["rug", "window_wide", "window", "river_map"]:
		block(img, Rect2i(0, 0, w, h), base)
		if name != "rug":
			_fill(img, Rect2i(3, 3, w - 6, h - 6), WINDOW if name.begins_with("window") else PARCHMENT)
		return
	# Stacked blocks: a body and a lighter top, with a shadow under the right side of the foot.
	var body_h := maxi(4, (foot + 1) * 2 / 3)
	var body := Rect2i(1, foot + 1 - body_h, maxi(2, w - 4), body_h - 1)
	block(img, body, base)
	var top_h := maxi(3, (foot + 1 - body_h) - 1)
	block(img, Rect2i(3, 1, maxi(2, w - 8), top_h), _q(base.lightened(0.12)))
	shadow(img, Rect2i(body.end.x, foot - 1, w - body.end.x - 1, 2))


static func _lamp(img: Image, spec: Dictionary, lit: bool) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var la: Vector2i = spec.get("light_anchor", Vector2i(w / 2, 8))
	block(img, Rect2i(w / 2 - 2, la.y + 6, 4, h - la.y - 6), WOOD)
	block(img, Rect2i(w / 2 - 6, h - 4, 12, 4), STONE)
	block(img, Rect2i(la.x - 5, la.y - 6, 10, 12), SLATE)
	_fill(img, Rect2i(la.x - 3, la.y - 4, 6, 8), LANTERN if lit else _q(SLATE.darkened(0.3)))


static func _frame9(img: Image, name: String) -> void:
	var w := img.get_width()
	var h := img.get_height()
	match name:
		"bar_fill":
			img.fill(TEXT)
		"bar_well":
			img.fill(_q(PANEL.darkened(0.4)))
			_outline(img, Rect2i(0, 0, w, h), EDGE)
		"focus_row":
			img.fill(FOCUS)
			_outline(img, Rect2i(0, 0, w, h), EDGE_LIGHT)
		"headshot":
			img.fill(PORTRAIT_BG)
			_outline(img, Rect2i(0, 0, w, h), EDGE)
		"banner":
			img.fill(PANEL)
			_fill(img, Rect2i(0, 3, w, 3), EDGE)
			_fill(img, Rect2i(0, h - 6, w, 3), EDGE)
		_:
			img.fill(PANEL)
			_outline(img, Rect2i(0, 0, w, h), EDGE)


static func _effect(img: Image, base: Color, f: int) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var rp := ramp(base)
	var c := Vector2i(w / 2, h / 2)
	_fill(img, Rect2i(c.x - 2, c.y - 1, 4, 2), rp[1])
	_fill(img, Rect2i(c.x - 1, c.y - 2, 2, 4), rp[1])
	_fill(img, Rect2i(c.x - 1, c.y - 1, 2, 2), rp[0] if f % 2 == 0 else _q(TEXT))
	_fill(img, Rect2i(c.x - 2 + f % 2, c.y + 1, 1, 1), rp[2])


static func _hud_piece(img: Image, name: String, base: Color, f: int) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var rp := ramp(base)
	if name == "sleep_mark":
		# A pixel z: top bar, diagonal, bottom bar; the whole mark bobs one pixel on frame 1.
		var dy := 1 if f == 1 else 0
		_fill(img, Rect2i(1, 1 + dy, 5, 1), rp[0])
		for i in 3:
			_fill(img, Rect2i(4 - i, 2 + i + dy, 1, 1), rp[1])
		_fill(img, Rect2i(1, 5 + dy, 5, 1), rp[2])
		return
	# The menu cursor (or any small piece): an arrowhead pointing right.
	for y in range(1, h - 1):
		var half := mini(y - 1, h - 2 - y)
		_fill(img, Rect2i(1, y, maxi(1, half + 1), 1), rp[0] if y < h / 2 else rp[2])
	_fill(img, Rect2i(1, h / 2, 1, 1), INK)


## Clears the outer rows and columns the slot's edges rule does not allow, so the placeholder passes C4.
static func _clear_edges(img: Image, spec: Dictionary) -> void:
	if String(spec.get("alpha", "binary")) == "opaque":
		return
	var allowed := allowed_sides(spec.get("edges", "bottom"))
	var w := img.get_width()
	var h := img.get_height()
	var clear := Color(0, 0, 0, 0)
	if not allowed.has("top"):
		img.fill_rect(Rect2i(0, 0, w, 1), clear)
	if not allowed.has("bottom"):
		img.fill_rect(Rect2i(0, h - 1, w, 1), clear)
	if not allowed.has("left"):
		img.fill_rect(Rect2i(0, 0, 1, h), clear)
	if not allowed.has("right"):
		img.fill_rect(Rect2i(w - 1, 0, 1, h), clear)


## The canvas sides a slot's art may touch: "none", "bottom", "all", or a list of "top", "bottom", "left", "right".
static func allowed_sides(edges: Variant) -> Array:
	if edges is Array:
		return edges
	match String(edges):
		"all":
			return ["top", "bottom", "left", "right"]
		"bottom":
			return ["bottom"]
	return []


static func _hook(hook: String, id: String, spec: Dictionary) -> Image:
	var cut := hook.rfind(":")
	if cut <= 6:
		return null
	var path := hook.substr(0, cut)
	var method := hook.substr(cut + 1)
	if not ResourceLoader.exists(path):
		return null
	var scr: Script = load(path)
	if scr == null:
		return null
	for m in scr.get_script_method_list():
		if String(m["name"]) == method:
			var out: Variant = scr.call(method, id, spec)
			return out as Image if out is Image else null
	return null


static func _fill(img: Image, r: Rect2i, c: Color) -> void:
	var cut := r.intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	if cut.size.x > 0 and cut.size.y > 0:
		img.fill_rect(cut, c)


static func _outline(img: Image, r: Rect2i, c: Color) -> void:
	_fill(img, Rect2i(r.position.x, r.position.y, r.size.x, 1), c)
	_fill(img, Rect2i(r.position.x, r.end.y - 1, r.size.x, 1), c)
	_fill(img, Rect2i(r.position.x, r.position.y, 1, r.size.y), c)
	_fill(img, Rect2i(r.end.x - 1, r.position.y, 1, r.size.y), c)


static func _q(c: Color) -> Color:
	return Color(roundf(c.r * 255.0) / 255.0, roundf(c.g * 255.0) / 255.0, roundf(c.b * 255.0) / 255.0, 1.0)


static func _rgba(img: Image) -> Image:
	if img.get_format() == Image.FORMAT_RGBA8:
		return img
	var out := img.duplicate() as Image
	out.convert(Image.FORMAT_RGBA8)
	return out
