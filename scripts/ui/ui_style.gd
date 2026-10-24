extends RefCounted
## Hollowtide's one UI look (Claude, 2026-10-10; Preston: "Do U.I upgrades and visuals... including
## from main menu to town to battle everything"). Taken from Codex's title and pause menu so every
## screen speaks the same language: deep moss panels with a worn brass edge, parchment text, Alegreya
## Sans SC at sizes that read at 1152x648 (16 and up for anything a player must read).
## Screens that draw their own HUD (the dungeon, the town) call these instead of drawing boxes.
##   const UI := preload("res://scripts/ui/ui_style.gd")
##   UI.panel(canvas, rect); UI.text(canvas, pos, "Lv 3", 18); UI.bar(canvas, rect, 0.5, UI.hp_col(0.5))

const HEAD := preload("res://assets/fonts/AlegreyaSansSC-Bold.ttf")   # kept for screens not yet on a role

## Type by job (Claude, 2026-10-10; Preston: "font is the next thing that will make this look non-AI...
## not every area is going to use the same font, and it needs to look a certain way when it's a button").
## Structure from Explorers of Sky and the Pokemon handhelds (nothing copied): one warm proportional pixel
## face for everything read as prose, a compact capital face for buttons and labels, steady digits for
## numbers, a display face for place names and title cards. Every face is drawn on its own pixel grid
## at a whole multiple (px), antialiasing off, so its pixels match the art's. `native` is the font size
## at which one design pixel is one screen pixel, measured from the fonts (2026-10-10).
const PIXELIFY := "res://assets/fonts/PixelifySans-Variable.ttf"   # OFL; mixed case, warm
const SILK := "res://assets/fonts/Silkscreen-Regular.ttf"          # OFL; capitals, compact
const JERSEY := "res://assets/fonts/Jersey10-Regular.ttf"          # OFL; tall condensed capitals
const TYPE := {
	# Prose is Jersey 10 (Preston, 2026-10-10, picked from docs/ui/type-2026-10-10/font_choice.png: Pixelify's
	# T and k were hard to make out). Pixelify stays on disk, unused.
	"story": {"file": JERSEY, "native": 18.65, "px": 2},               # dialogue and narration
	"body": {"file": JERSEY, "native": 18.65, "px": 1},                # message log, descriptions, panels
	"name": {"file": JERSEY, "native": 18.65, "px": 2},                # the speaker's name plate
	"button": {"file": SILK, "native": 8.0, "px": 3},                  # buttons and menu rows
	"label": {"file": SILK, "native": 8.0, "px": 2},                   # small labels, key hints
	"number": {"file": SILK, "native": 8.0, "px": 2},                  # HP, levels, counts (outlined)
	"title": {"file": JERSEY, "native": 18.65, "px": 3},               # place names, banners, headings
	"display": {"file": JERSEY, "native": 18.65, "px": 4},             # title cards
	"tight": {"file": JERSEY, "native": 18.65, "px": 1},               # last resort where a name must fit a chip
}
## When text is given a width and does not fit, it steps down this chain (Preston, 2026-10-10: move names
## did not fit their chips; 47 of 65 were wider than the 96 pixels a chip gives them).
const FIT := {"story": "body", "name": "body", "button": "label", "label": "tight", "title": "button"}
const INK := Color("#2a1f14")          # dark ink on brass (name plates)
const SHADOW := Color(0.05, 0.06, 0.05, 0.85)   # the 1-pixel drop under prose, as handheld text boxes do
static var _type := {}


## The font for a job, set up for pixels: no smoothing, no hinting, whole-pixel placement, drawn at its
## own size and scaled with the art, and sized so one design pixel is exactly `px` screen pixels.
static func font(role: String) -> Font:
	if not _type.has(role):
		var t: Dictionary = TYPE[role]
		var base: FontFile = load(t["file"])
		base.antialiasing = TextServer.FONT_ANTIALIASING_NONE
		base.hinting = TextServer.HINTING_NONE
		base.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
		base.oversampling = 1.0
		var v := FontVariation.new()
		v.base_font = base
		var k: float = float(t["native"]) * float(t["px"]) / float(type_size(role))
		v.variation_transform = Transform2D(0.0, Vector2(k, k), 0.0, Vector2.ZERO)
		var ts := TextServerManager.get_primary_interface()
		if t.has("wght"):
			v.variation_opentype = {ts.name_to_tag("wght"): int(t["wght"])}
		# No joined letters: Pixelify's fi/fl ligatures drew "Kithflare" as "KithAare".
		v.opentype_features = {ts.name_to_tag("liga"): 0, ts.name_to_tag("clig"): 0, ts.name_to_tag("dlig"): 0}
		_type[role] = v
	return _type[role]


static func type_size(role: String) -> int:
	return int(round(float(TYPE[role]["native"]) * float(TYPE[role]["px"])))


## Text in a role, at its own size: prose gets its drop shadow, numbers a dark outline.
static func say(c: CanvasItem, pos: Vector2, s: String, role := "body", col := TEXT, width := -1.0, align := HORIZONTAL_ALIGNMENT_LEFT) -> void:
	if width > 0.0:
		role = fit(s, role, width)
	var f := font(role)
	var n := type_size(role)
	var px := float(TYPE[role]["px"])
	if width > 0.0 and align != HORIZONTAL_ALIGNMENT_LEFT:
		# Still too wide at the smallest role: grow the box toward the left (right-aligned) or both ways
		# (centred) instead of running off its right edge, which at a screen edge cut words off
		# ("The Hollow's mouth starts a r"). Claude, 2026-10-14.
		var over: float = width_in(s, role) - width
		if over > 0.0:
			pos.x -= over if align == HORIZONTAL_ALIGNMENT_RIGHT else over * 0.5
			width += over
	pos = pos.round()
	if role == "number":
		c.draw_string_outline(f, pos, s, align, width, n, int(px) * 2, Color(0.05, 0.05, 0.05, col.a))
	elif col.v > 0.5:
		c.draw_string(f, pos + Vector2(px, px), s, align, width, n, Color(SHADOW, SHADOW.a * col.a))
	c.draw_string(f, pos, s, align, width, n, col)


## The first role down the FIT chain from `role` in which `s` fits `width` (the last one if none does).
static func fit(s: String, role: String, width: float) -> String:
	while width_in(s, role) > width and FIT.has(role):
		role = FIT[role]
	return role


static func width_in(s: String, role: String) -> float:
	return font(role).get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, type_size(role)).x


## `s` cut short with ".." so it fits `width` in `role` (whole when it already fits).
static func clip(s: String, role: String, width: float) -> String:
	if width_in(s, role) <= width:
		return s
	var cut := s
	while cut.length() > 1 and width_in(cut.strip_edges() + "..", role) > width:
		cut = cut.substr(0, cut.length() - 1)
	return cut.strip_edges() + ".."


## Which role an older call's font size stands for, so screens not yet given roles still land on the grid.
static func role_for(old_size: int) -> String:
	return "label" if old_size <= 15 else "body"


## A Button in the button role: capitals, cream; focused or hovered goes gold (the row's cursor);
## pressed sinks a pixel; disabled dims. Used by menus and choice rows.
static func style_button(b: Button) -> void:
	b.add_theme_font_override("font", font("button"))
	b.add_theme_font_size_override("font_size", type_size("button"))
	b.add_theme_color_override("font_color", TEXT)
	b.add_theme_color_override("font_hover_color", EDGE_LIGHT)
	b.add_theme_color_override("font_focus_color", EDGE_LIGHT)
	b.add_theme_color_override("font_hover_pressed_color", EDGE_LIGHT)
	b.add_theme_color_override("font_pressed_color", EDGE_LIGHT.darkened(0.15))
	b.add_theme_color_override("font_disabled_color", Color(MUTED, 0.45))
	if b.has_theme_stylebox_override("normal"):
		b.add_theme_stylebox_override("disabled", b.get_theme_stylebox("normal"))   # dimmed, still framed
	for state in ["pressed", "hover_pressed"]:
		var sb: StyleBox = b.get_theme_stylebox(state)
		if sb != null:
			sb = sb.duplicate()
			sb.content_margin_top = maxf(sb.content_margin_top, 0.0) + 3.0   # the label sinks one art pixel
			sb.content_margin_bottom = maxf(sb.content_margin_bottom - 3.0, 0.0)   # without the button growing
			b.add_theme_stylebox_override(state, sb)
const PANEL := Color("#242b25")      # Codex's pause panel
const EDGE := Color("#b69b6d")       # its brass edge
const EDGE_LIGHT := Color("#e4ca8e") # its focus edge: headings, the leader, what is ready
const FOCUS := Color("#3f5140")      # its focused row
const TEXT := Color("#fff4e8")       # its parchment text
const MUTED := Color("#c9bfa9")
const HP_GOOD := Color("#6fd486")
const HP_MID := Color("#e8c547")
const HP_LOW := Color("#e8574a")
const LIGHT := Color("#f2c14e")      # the lantern
const EVO := Color("#c9a3ff")        # the evolve bar
const ALLY := Color("#8fd3ff")       # your creatures' names in messages
const FOE := Color("#ff9a7a")        # wild creatures' names
const PORTRAIT_BG := Color("#63a9a6")  # the square behind a headshot: the normal dialogue face's river blue (Preston, 2026-10-10: not white)


## The pixel frames (tools/ui/build_frames.py): drawn by hand at 1x and saved at the world's 3x, so a
## UI pixel is a world pixel. Godot stretches them as 9-slices: the corners stay put, the edges and
## the woven fill repeat. Margins are the frame's border in screen pixels.
const FRAME := "res://assets/sprites/ui/frame/"
const FRAME_MARGIN := {"panel": 24, "panel_focus": 24, "panel_dim": 24, "nameplate": 12, "portrait": 21}
static var _boxes := {}


static func frame(name: String) -> StyleBoxTexture:
	if not _boxes.has(name):
		var sb := StyleBoxTexture.new()
		sb.texture = load(FRAME + name + ".png")
		var m: int = FRAME_MARGIN.get(name, 24)
		sb.set_texture_margin_all(m)
		sb.set_content_margin_all(m)
		sb.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
		sb.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
		_boxes[name] = sb
	return _boxes[name]


## A panel: moss weave inside a bevelled brass frame with corner studs. `alpha` under 0.9 uses the
## see-through variant; `focus` brightens the brass (a chosen button). Panels shorter than the two
## frame borders are grown to fit them rather than squashed.
static func panel(c: CanvasItem, r: Rect2, alpha := 0.92, focus := false) -> void:
	var name := "panel_focus" if focus else ("panel" if alpha >= 0.9 else "panel_dim")
	var need: float = 2.0 * float(FRAME_MARGIN[name])
	r = r.grow_individual(maxf(0.0, need - r.size.x) * 0.5, maxf(0.0, need - r.size.y) * 0.5, maxf(0.0, need - r.size.x) * 0.5, maxf(0.0, need - r.size.y) * 0.5)
	c.draw_style_box(frame(name), r)


## The speaker's brass name tab, sized to the name, its text in dark ink. Returns its rect.
static func nameplate(c: CanvasItem, pos: Vector2, s: String, size := 20) -> Rect2:
	var f := font("name")
	var r := Rect2(pos, Vector2(maxf(96.0, f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, type_size("name")).x + 40.0), 36.0))
	c.draw_style_box(frame("nameplate"), r)
	c.draw_string(f, (pos + Vector2(0, 25)).round(), s, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, type_size("name"), INK)
	return r


## A portrait in its frame: `r` is where the 40x40 portrait shows (120x120 at 3x); the frame sits
## 15 pixels outside it. Behind the creature, a background coloured by its face (as hand-made portrait
## sets colour them: calm blue, happy yellow with rays, sad pink, angry red with a jagged line), and
## for some faces a mark drawn over the corner. Pass `face` "" for a plain parchment well.
static func portrait(c: CanvasItem, r: Rect2, tex: Texture2D, flip := false, face := "normal") -> void:
	c.draw_style_box(frame("portrait"), r.grow(15.0))
	if face != "":
		_face_bg(c, r, face)
	var crew_layer := c.get_node_or_null("CrewPortraitFinish")
	var crew_finished := tex != null and crew_layer != null and preload("res://scripts/arena/creature_finish.gd").portrait_target(tex.resource_path)
	if tex != null:
		var dst := r
		if flip:
			dst = Rect2(r.position + Vector2(r.size.x, 0), Vector2(-r.size.x, r.size.y))
		if crew_finished:
			crew_layer.paint(tex, dst, face, r)
		else:
			c.draw_texture_rect(tex, dst, false)
	if face != "" and not crew_finished:
		_face_mark(c, r, face)


const FACE_BG := {   # top and bottom of the gradient, and the motif's colour
	# Hollowtide's own (Preston, 2026-10-10: the first set came straight from Explorers of Sky). Each emotion
	# keeps the reading it had, moved onto the river-and-earth palette; joyous now has its own colour.
	"normal": [Color("#94cfc6"), Color("#3c8586"), Color("#c6ebe2")],       # river teal
	"happy": [Color("#f4e1a0"), Color("#cfa246"), Color("#fbf1d0")],        # meadow gold
	"joyous": [Color("#ffd9b8"), Color("#ec9a62"), Color("#fff0e0")],       # blossom peach
	"surprised": [Color("#dbe8b0"), Color("#8aa95a"), Color("#f1f6dc")],    # spring leaf, olive
	"sad": [Color("#e8c4cf"), Color("#a9748e"), Color("#f5e2e8")],          # dusk rose
	"worried": [Color("#cfcce4"), Color("#7c7aab"), Color("#ebeaf6")],      # twilight slate
	"angry": [Color("#f0a68f"), Color("#b94a3a"), Color("#f9d4c8")],        # ember brick
	"determined": [Color("#f3bb82"), Color("#c46a32"), Color("#fbe0c4")],   # copper
	"mischievous": [Color("#c9a3c6"), Color("#68406f"), Color("#eadbe9")],  # bog plum: the crew's sly, bullying face
}


## One background pixel (3x3 on screen) at (x, y) in the 40x40 portrait.
static func _pp(c: CanvasItem, r: Rect2, x: int, y: int, col: Color) -> void:
	if x >= 0 and y >= 0 and x < 40 and y < 40:
		c.draw_rect(Rect2(r.position + Vector2(x, y) * 3.0, Vector2(3, 3)), col)


static func _face_bg(c: CanvasItem, r: Rect2, face: String) -> void:
	var cols: Array = FACE_BG.get(face, FACE_BG["normal"])
	for y in 40:   # a gradient in five bands, stepped like pixel art
		var band := floorf(y / 40.0 * 5.0) / 4.0
		c.draw_rect(Rect2(r.position + Vector2(0, y * 3.0), Vector2(r.size.x, 3)), Color(cols[0]).lerp(cols[1], band))
	var m: Color = cols[2]
	match face:
		"happy", "joyous":
			for k in 9:   # rays from below the creature
				var a := PI + PI * (k + 0.5) / 9.0
				for step in range(6, 40, 2):
					_pp(c, r, 20 + int(round(cos(a) * step)), 44 + int(round(sin(a) * step)), Color(m, 0.55))
		"surprised":
			for ring in [12, 18]:   # a burst behind the head
				for k in 32:
					var a2 := TAU * k / 32.0
					_pp(c, r, 22 + int(round(cos(a2) * ring)), 16 + int(round(sin(a2) * ring * 0.9)), Color(m, 0.6))
		"angry":
			var y0 := 9
			for x in 40:   # a jagged line across the top, like a spiking graph
				var y := y0 + (x % 8 if (x / 8) % 2 == 0 else 8 - x % 8)
				_pp(c, r, x, y, Color(m, 0.8))
				_pp(c, r, x, y + 1, Color(m, 0.4))
		"determined":
			for k in 6:   # speed lines
				for step in 9:
					_pp(c, r, k * 7 + step, 30 - step * 3 + k % 2, Color(m, 0.5))
		"sad", "worried":
			for k in 12:   # soft falling specks
				_pp(c, r, (k * 13) % 38 + 1, (k * 7) % 30 + 2, Color(m, 0.6))


## Marks over the portrait's top-right corner: the anger vein, the sweat drop.
static func _face_mark(c: CanvasItem, r: Rect2, face: String) -> void:
	match face:
		"angry":
			var red := Color("#d8243a")
			for p in [Vector2i(31, 3), Vector2i(32, 3), Vector2i(31, 4), Vector2i(35, 3), Vector2i(36, 3), Vector2i(36, 4),
					Vector2i(31, 7), Vector2i(31, 8), Vector2i(32, 8), Vector2i(36, 7), Vector2i(35, 8), Vector2i(36, 8)]:
				_pp(c, r, p.x, p.y, red)
		"worried":
			var blue := Color("#6fb4e8")
			for p in [Vector2i(34, 3), Vector2i(33, 4), Vector2i(34, 4), Vector2i(35, 4), Vector2i(33, 5), Vector2i(34, 5), Vector2i(35, 5), Vector2i(34, 6)]:
				_pp(c, r, p.x, p.y, blue)
			_pp(c, r, 33, 4, Color("#e8f6ff"))


## A dialogue portrait by form ("kithflare", "warden"), or form and face ("kithflare:joyous", made by
## tools/ui/rd_expressions.py); a face the creature has no portrait for falls back to its normal one.
## Null when the creature has none yet.
static func dialogue_portrait(form: String) -> Texture2D:
	if ":" in form:
		var face: Texture2D = icon("dialogue/%s_%s" % [form.get_slice(":", 0), form.get_slice(":", 1)])
		return face if face != null else icon("dialogue/" + form.get_slice(":", 0))
	return icon("dialogue/" + form)


## The "next" arrow, bobbing a pixel-step every half second. `t` is any running clock in seconds.
static func next_arrow(c: CanvasItem, pos: Vector2, t: float) -> void:
	var tex: Texture2D = icon("frame/arrow")
	if tex != null:
		c.draw_texture(tex, pos + Vector2(0, 3.0 * float(int(t * 2.0) % 2)))


## A whole scene line in our own frame (R7 of docs/design/genre-synthesis-2026-10-12.md, Claude, 2026-10-12):
## the portrait set into the box's left end, its frame straddling the top edge like a photograph slipped
## into a ledger, the name on a brass tab beside it, the line to its right in parchment, the arrow when
## there is more. Explorers of Sky floats its portrait above the box's corner; ours sits in the box.
## `portrait_tex` may be null (an unseen speaker), and then the line takes the whole width.
const PORTRAIT_INSET := 162.0   # how far the line and the name step right of a set-in portrait

static func dialogue(c: CanvasItem, box: Rect2, speaker: String, line: String, portrait_tex: Texture2D, t: float, size := 20, face := "normal") -> void:
	panel(c, box, 0.95)
	var inset := 0.0
	if portrait_tex != null:
		portrait(c, Rect2(box.position + Vector2(42, -34), Vector2(120, 120)), portrait_tex, false, face)
		inset = PORTRAIT_INSET
	var lift := 0.0
	if speaker != "":
		nameplate(c, box.position + Vector2(24 + inset, -22), speaker)
		lift = 10.0
	var f := font("story")
	var at := (box.position + Vector2(30 + inset, 44 + lift)).round()
	var width: float = box.size.x - 70 - inset
	# Two rows at a time: a longer line pages inside the box, as the genre's boxes do.
	var rows := _dialogue_rows(line, width)
	_line_pages(line, ceili(rows.size() / 2.0))
	var page := int(_line["page"])
	var page_text := "\n".join(rows.slice(page * 2, page * 2 + 2)).rstrip("\n")   # a one-row page's empty second row
	var shown := page_text.substr(0, typed(line, page_text))
	c.draw_multiline_string(f, at + Vector2(2, 2), shown, HORIZONTAL_ALIGNMENT_LEFT, width + 10, type_size("story"), -1, SHADOW)
	c.draw_multiline_string(f, at, shown, HORIZONTAL_ALIGNMENT_LEFT, width + 10, type_size("story"), -1, TEXT)
	if _line["done"]:
		next_arrow(c, box.end - Vector2(48, 36), t)   # more on the next page, or the next line


## The rows of a dialogue line at `width`, two to a page (Claude, 2026-10-23, U7 for L06; it replaces the
## 2026-10-22 widow rule). A page ends where a sentence ends whenever the next page would otherwise open
## mid-sentence ("sure where they come from."). A sentence splits across pages only when it is longer than two
## rows by itself, and then at least ORPHAN of its words go over together. A short sentence is not left alone on
## a page ahead of one that splits anyway, and a last page under ORPHAN words takes the sentence before it when
## both fit. A page that ends on its first row gets an empty second row, so pages stay pairs of rows. The words
## never change. Cached per line and width, as the box is drawn every frame.
const ORPHAN := 4
static var _rows_cache := {}


static func _dialogue_rows(line: String, width: float) -> PackedStringArray:
	var key := "%d|%s" % [roundi(width), line]
	if not _rows_cache.has(key):
		if _rows_cache.size() > 64:
			_rows_cache.clear()
		_rows_cache[key] = _page_rows(line, width)
	return _rows_cache[key]


static func _page_rows(line: String, width: float) -> PackedStringArray:
	var plain := wrap_text(line, width, "story").split("\n")
	if "\n" in line:
		return plain   # a line that breaks itself
	if plain.size() <= 2:
		return _page_wrap(line, width)   # one page
	var words := line.split(" ")
	var n := words.size()
	var pages: Array = []   # [first word, end] of each page
	var i := 0
	while i < n:
		var j := mini(n, i + _fit_words(words, i, width))
		if j >= n:
			pages.append([i, n])
			break
		var k := _last_break(words, i, j)
		if k > i and k - i < ORPHAN and _rows_of(words, k, _sentence_end(words, k), width) > 2:
			k = -1   # a short sentence ahead of a long one: fill the page, the long one splits anyway
		if k <= i:
			k = _split_at(words, i, j)
		pages.append([i, k])
		i = k
	if pages.size() >= 2 and int(pages[-1][1]) - int(pages[-1][0]) < ORPHAN:
		var before: Array = pages[-2]
		var k := _last_break(words, int(before[0]), int(before[1]) - 1)
		if k > int(before[0]) and _rows_of(words, k, n, width) <= 2:
			before[1] = k
			pages[-1][0] = k
	var rows := PackedStringArray()
	for p: Array in pages:
		var page := _page_wrap(" ".join(words.slice(int(p[0]), int(p[1]))), width)
		rows.append_array(page)
		if page.size() == 1 and p != pages[-1]:
			rows.append("")
	return rows


## One page's rows. A second row under WIDOW letters ("spring.") is evened out: the page is re-wrapped a little
## narrower, a step at a time, while it still takes two rows (the 2026-10-22 widow rule, now for every page).
const WIDOW := 12


static func _page_wrap(s: String, width: float) -> PackedStringArray:
	var rows := wrap_text(s, width, "story").split("\n")
	if rows.size() != 2 or rows[1].length() >= WIDOW:
		return rows
	var w := width
	for k in 8:
		w *= 0.92
		var again := wrap_text(s, w, "story").split("\n")
		if again.size() > 2:
			break
		if again[1].length() >= WIDOW:
			return again
	return rows


## How many words from `i` two rows hold.
static func _fit_words(words: PackedStringArray, i: int, width: float) -> int:
	var rows := wrap_text(" ".join(words.slice(i)), width, "story").split("\n")
	var n := 0
	for r in mini(2, rows.size()):
		n += rows[r].split(" ").size()
	return n


static func _rows_of(words: PackedStringArray, from: int, to: int, width: float) -> int:
	return wrap_text(" ".join(words.slice(from, to)), width, "story").split("\n").size()


## Where a sentence too long for one page splits, from the page's middle to the most words it holds (`j`): before a
## word with a capital ("told me / I needed"), else after a comma, semicolon, colon or dash, else as full as it
## goes. At least ORPHAN of the sentence's words go over together.
static func _split_at(words: PackedStringArray, i: int, j: int) -> int:
	var e := _sentence_end(words, j)
	var hi := j
	if e - j < ORPHAN and e - ORPHAN > i:
		hi = e - ORPHAN
	var lo := maxi(i + 1, i + (j - i + 1) / 2)
	for k in range(hi, lo - 1, -1):
		var c := words[k].lstrip("'\"(‘“").left(1)
		if c != c.to_lower():
			return k
	for k in range(hi, lo - 1, -1):
		if ",;:-".contains(words[k - 1].right(1)):
			return k
	return hi


## A sentence ends before word `k`: the word ahead ends in . ! or ? (a closing quote or bracket may follow) and
## word `k` does not start in lower case ("Well... maybe" runs on).
static func _breaks_before(words: PackedStringArray, k: int) -> bool:
	if k <= 0 or k >= words.size():
		return false
	var ahead := words[k - 1].rstrip("'\")]\u2019\u201d")
	var next := words[k].lstrip("'\"(\u2018\u201c")
	return ahead != "" and ".!?".contains(ahead.right(1)) and next != "" and next.left(1) == next.left(1).to_upper()


## The last sentence break after word `i`, up to and including `j`; -1 when there is none.
static func _last_break(words: PackedStringArray, i: int, j: int) -> int:
	for k in range(j, i, -1):
		if _breaks_before(words, k):
			return k
	return -1


## Where the sentence holding word `k` ends: the next break after it, or the end of the line.
static func _sentence_end(words: PackedStringArray, k: int) -> int:
	for e in range(k + 1, words.size()):
		if _breaks_before(words, e):
			return e
	return words.size()


## The line typing itself out (Claude, 2026-10-10; Preston: the Mystery Dungeon text sound, "like the old
## military computer"): letters appear at TYPE_CPS a second with a blip (tools/audio/make_text_blip.py)
## every other letter, none on spaces or punctuation. The first press shows the rest (finish_line), the
## next one moves on; callers ask line_done(line) first. One line types at a time, as one box shows.
const TYPE_CPS := 36.0   # with a blip every other letter, 18 a second: inside the 9 to 18 measured in Explorers of Sky
static var _line := {"text": "", "start": 0, "blips": 0, "done": true, "page": 0, "pages": 1}
static var _blip: AudioStreamPlayer
static var _blips: Array = []


## A new line starts typing from the first time it is drawn, on its first page.
static func _line_pages(line: String, pages: int) -> void:
	if _line["text"] != line:
		_line = {"text": line, "start": Time.get_ticks_msec(), "blips": 0, "done": line.is_empty(), "page": 0, "pages": pages}
	_line["pages"] = pages


## How many letters of the page `shown` (part of `line`) show now, blipping as they appear.
static func typed(line: String, shown := "") -> int:
	if shown == "":
		shown = line
	if _line["text"] != line:
		_line_pages(line, 1)
	if _line["done"]:
		return shown.length()
	var speed := float(text_speed())   # the Text pref (Claude, 2026-10-22): 1 normal, 2 fast, 0 instant
	if speed <= 0.0:
		_line["done"] = true
		return shown.length()
	var n := mini(int((Time.get_ticks_msec() - int(_line["start"])) / 1000.0 * TYPE_CPS * speed), shown.length())
	if n >= shown.length():
		_line["done"] = true
	line = shown
	var due := n >> 1   # a blip every other letter
	if due > int(_line["blips"]):
		_line["blips"] = due
		var ch := line.substr(maxi(n - 1, 0), 1)
		if ch != " " and ch != "\n" and not ".,!?'-:;".contains(ch):
			_play_blip()
	return n


## Whether `line` is fully on screen (or not being typed at all: a check that never draws it).
static func line_done(line: String) -> bool:
	return _line["text"] != line or (bool(_line["done"]) and int(_line["page"]) >= int(_line["pages"]) - 1)


## A press while a line is up: show the rest of this page, or turn to the next page.
static func finish_line() -> void:
	if not _line["done"]:
		_line["done"] = true
	elif int(_line["page"]) < int(_line["pages"]) - 1:
		_line["page"] = int(_line["page"]) + 1
		_line["start"] = Time.get_ticks_msec()
		_line["blips"] = 0
		_line["done"] = false


static func _play_blip() -> void:
	if _blips.is_empty():
		for k in 3:
			_blips.append(load("res://assets/audio/sfx/ui/text_blip_%d.wav" % k))
	if _blip == null or not is_instance_valid(_blip):
		var tree := Engine.get_main_loop() as SceneTree
		if tree == null:
			return
		_blip = AudioStreamPlayer.new()
		_blip.volume_db = -16.0
		_blip.bus = &"UI"   # blips with the clicks, off the effects slider (Claude, 2026-10-22)
		_blip.max_polyphony = 2
		tree.root.add_child.call_deferred(_blip)
		return
	if _blip.is_inside_tree():
		_blip.stream = _blips[randi() % _blips.size()]
		_blip.play()


## `s` with line breaks put where it wraps at `width` in a role's face. Spaces become breaks, so the text
## keeps its length and a line typed out letter by letter never jumps a word to the next line.
static func wrap_text(s: String, width: float, role: String) -> String:
	var f := font(role)
	var n := type_size(role)
	var out := ""
	for para in s.split("\n"):
		var cur := ""
		for word in para.split(" "):
			var next := word if cur.is_empty() else cur + " " + word
			if not cur.is_empty() and f.get_string_size(next, HORIZONTAL_ALIGNMENT_LEFT, -1, n).x > width:
				out += cur + "\n"
				cur = word
			else:
				cur = next
		out += cur + "\n"
	return out.substr(0, out.length() - 1)


static func text(c: CanvasItem, pos: Vector2, s: String, size := 18, col := TEXT, width := -1.0, align := HORIZONTAL_ALIGNMENT_LEFT) -> void:
	say(c, pos, s, role_for(size), col, width, align)


static func width_of(s: String, size: int) -> float:
	var role := role_for(size)
	return font(role).get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, type_size(role)).x


## A gauge: a dark well, the fill, a thin brass rim.
static func bar(c: CanvasItem, r: Rect2, frac: float, col: Color) -> void:
	c.draw_rect(r, Color(0, 0, 0, 0.55))
	c.draw_rect(Rect2(r.position, Vector2(r.size.x * clampf(frac, 0.0, 1.0), r.size.y)), col)
	c.draw_rect(r, Color(EDGE, 0.55), false, 1.0)


static func hp_col(frac: float) -> Color:
	return HP_GOOD if frac > 0.5 else (HP_MID if frac > 0.25 else HP_LOW)


## One line of text with some words in their own colour (creature names in the message log, as
## Explorers of Sky colours them). `marks` maps a word to its colour; the earliest match wins.
static func rich(c: CanvasItem, pos: Vector2, s: String, size: int, marks: Dictionary, alpha := 1.0, max_w := -1.0) -> void:
	var x := pos.x
	var rest := s
	var role := role_for(size)
	if max_w > 0.0:
		role = fit(s, role, max_w)   # the whole line steps down together, so its words match
	while rest != "":
		var at := -1
		var word := ""
		for w in marks:
			var k := rest.find(w)
			if k >= 0 and (at < 0 or k < at):
				at = k
				word = w
		var plain := rest if at < 0 else rest.substr(0, at)
		if plain != "":
			say(c, Vector2(x, pos.y), plain, role, Color(TEXT, alpha))
			x += width_in(plain, role)
		if at < 0:
			break
		say(c, Vector2(x, pos.y), word, role, Color(marks[word], alpha))
		x += width_in(word, role)
		rest = rest.substr(at + word.length())
		if max_w > 0.0 and x - pos.x > max_w:
			break


static var _icons := {}


## Hollowtide's hand-drawn icons (tools/ui/build_icons.py), 32 px: an essence ("EMBER", "TIDE"...)
## or an item kind (a scroll of any move uses the scroll icon). Null when there is none.
static func icon(path: String) -> Texture2D:
	if not _icons.has(path):
		var full := "res://assets/sprites/ui/%s.png" % path
		_icons[path] = load(full) if ResourceLoader.exists(full) else null
	return _icons[path]


static func essence_icon(essence: String) -> Texture2D:
	return icon("essence/" + essence.to_lower())


static func item_icon(kind: String) -> Texture2D:
	return icon("item/scroll" if kind.begins_with("scroll:") else "item/" + kind)


## The pixels of a res:// picture, in RGBA8, in the editor and in an exported game alike (Claude, 2026-10-24, A4
## for LV-19). An export carries the imported texture and not the PNG, so Image.load_from_file on a globalized
## path found nothing there and every art layer quietly fell back to its stand-in painting. The imported texture
## is read first (on the main thread, where the renderer hands its pixels back), the file itself only when there
## is no import. A copy every time, so a painter can draw on it. Null when neither exists.
static func res_image(path: String) -> Image:
	var img: Image = null
	if ResourceLoader.exists(path) and OS.get_thread_caller_id() == OS.get_main_thread_id():
		var res := load(path)
		if res is Texture2D:
			img = (res as Texture2D).get_image()
		elif res is Image:
			img = res
	if (img == null or img.is_empty()) and FileAccess.file_exists(path):
		img = Image.load_from_file(path)
	if img == null or img.is_empty():
		return null
	img = img.duplicate()
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	return img


## Whether res_image(path) has a picture to give: an imported texture (all an export has) or the file.
static func res_exists(path: String) -> bool:
	return ResourceLoader.exists(path) or FileAccess.file_exists(path)


## Menu preferences (Claude, 2026-10-22, the factory contract), read once and kept. Reduce motion
## (menu/reduce_motion) halves the fades; text speed (menu/text_speed: 1 normal, 2 fast, 0 instant) scales the
## typing in typed(); the screen mode (display/fullscreen) is set and saved by apply_screen_mode. A menu that
## saves a pref with save_pref sees it at once; one that writes a file itself calls reload_prefs().
## Two files (Claude, 2026-10-23, U1 for LO-01): the title saves user://menu_preferences.cfg whole from a fresh
## ConfigFile, so that file keeps only the keys the title writes (TITLE_KEYS: the three volumes, reduce motion,
## the courier). Every other pref (text speed, full screen, InputPrefs' [input] bindings) lives in
## user://game_prefs.cfg, where a title save cannot wipe it. A game key found in the title's file (an older
## build's prefs, or a menu that still saves one there) moves into game_prefs.cfg the next time prefs are read,
## so a missing game_prefs.cfg is filled from the old file once.
const PREFS_PATH := "user://menu_preferences.cfg"
const GAME_PREFS_PATH := "user://game_prefs.cfg"
const TITLE_KEYS := {"audio": ["master", "music", "sfx"], "menu": ["reduce_motion", "courier"]}
static var _prefs: ConfigFile = null
static var _game_prefs: ConfigFile = null


static func _pref(section: String, key: String, default: Variant) -> Variant:
	if _prefs == null or _game_prefs == null:
		_move_game_keys()
		_prefs = ConfigFile.new()
		_prefs.load(PREFS_PATH)   # no file yet reads as every default
		_game_prefs = ConfigFile.new()
		_game_prefs.load(GAME_PREFS_PATH)
	return (_prefs if is_title_pref(section, key) else _game_prefs).get_value(section, key, default)


## Forget the cached preferences, so the next read sees what a menu just saved.
static func reload_prefs() -> void:
	_prefs = null
	_game_prefs = null


## Whether a pref belongs in the title's file (one the title's Options write) rather than game_prefs.cfg.
static func is_title_pref(section: String, key: String) -> bool:
	return TITLE_KEYS.has(section) and (TITLE_KEYS[section] as Array).has(key)


## Save one pref in the file it belongs to; the file is loaded first, so its other keys stay.
static func save_pref(section: String, key: String, value: Variant) -> bool:
	if is_title_pref(section, key):
		var title := ConfigFile.new()
		title.load(PREFS_PATH)
		title.set_value(section, key, value)
		return write_prefs(title, PREFS_PATH)
	var game := load_game_prefs()
	game.set_value(section, key, value)
	return write_prefs(game)


## game_prefs.cfg as it is on disk (empty when there is none yet), once any game key left in the title's file
## has moved in. InputPrefs edits it and hands it back to write_prefs.
static func load_game_prefs() -> ConfigFile:
	_move_game_keys()
	var cfg := ConfigFile.new()
	cfg.load(GAME_PREFS_PATH)
	return cfg


## `cfg` written whole to `path`: to <path>.tmp first, the file before it kept as <path>.bak, then the .tmp takes
## the name (the team save's crash-safe write, team_state.gd). The cached prefs are dropped after.
static func write_prefs(cfg: ConfigFile, path := GAME_PREFS_PATH) -> bool:
	var tmp := path + ".tmp"
	var err := cfg.save(tmp)
	if err == OK:
		var main := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(path):
			DirAccess.rename_absolute(main, main + ".bak")   # replaces the older .bak
		err = DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp), main)
	reload_prefs()
	if err != OK:
		push_warning("Prefs: could not save %s (%s)" % [path, error_string(err)])
	return err == OK


## Every game key still in the title's file moves into game_prefs.cfg. Nothing of ours saves a game key there
## now, so one found there was saved after game_prefs.cfg was, and it wins. The title's file loses the keys
## only once game_prefs.cfg holds them.
static func _move_game_keys() -> void:
	var title := ConfigFile.new()
	if title.load(PREFS_PATH) != OK:
		return
	var moving: Array = []
	for section in title.get_sections():
		for key in title.get_section_keys(section):
			if not is_title_pref(section, key):
				moving.append([section, key])
	if moving.is_empty():
		return
	var game := ConfigFile.new()
	game.load(GAME_PREFS_PATH)
	for sk: Array in moving:
		game.set_value(sk[0], sk[1], title.get_value(sk[0], sk[1]))
		title.erase_section_key(sk[0], sk[1])
	if write_prefs(game):
		write_prefs(title, PREFS_PATH)


static func reduce_motion() -> bool:
	return bool(_pref("menu", "reduce_motion", false))


## 1 normal, 2 fast, 0 instant; anything else on disk reads as normal.
static func text_speed() -> int:
	var v := int(_pref("menu", "text_speed", 1))
	return v if v in [0, 1, 2] else 1


## The saved screen mode, for whoever applies it at launch.
static func screen_full() -> bool:
	return bool(_pref("display", "fullscreen", false))


## Full screen or windowed, now and on the next launch: the pref is written and the other keys kept. InputPrefs
## restores the saved mode at launch with `save` false (Claude, 2026-10-23, U2).
static func apply_screen_mode(full: bool, save := true) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if full else DisplayServer.WINDOW_MODE_WINDOWED)
	if save:
		save_pref("display", "fullscreen", full)


## `secs` as the player asked for it: half under reduce motion, never negative.
static func motion_secs(secs: float) -> float:
	return maxf(secs, 0.0) * (0.5 if reduce_motion() else 1.0)


static func _tree(tree: SceneTree) -> SceneTree:
	return tree if tree != null else Engine.get_main_loop() as SceneTree


## Menu sounds (Claude, 2026-10-22): cursor, confirm and cancel are the chiptune takes under
## assets/audio/sfx/ui; open and close are the dungeon's menu pair. One player a kind, kept on the root
## once made, all on the "UI" bus at -8 dB so the effects slider leaves them alone and they play while the
## tree is paused. UI.tick("cursor") on a focus change, "confirm" on a choice, "cancel" on a back,
## "open" and "close" for a menu or page.
const TICKS := {
	"cursor": "res://assets/audio/sfx/ui/cursor.wav",
	"confirm": "res://assets/audio/sfx/ui/confirm.wav",
	"cancel": "res://assets/audio/sfx/ui/cancel.wav",
	"open": "res://assets/audio/sfx/dungeon/menu_open.wav",
	"close": "res://assets/audio/sfx/dungeon/menu_close.wav",
}
const TICK_DB := -8.0
static var _ticks := {}


static func tick(kind: String) -> void:
	if not TICKS.has(kind):
		return
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	var p := _tick_player(kind, tree)
	if p.is_inside_tree():
		p.play()
	elif not p.ready.is_connected(p.play):
		p.ready.connect(p.play, CONNECT_ONE_SHOT)   # the first tick of a run lands a frame later; a second tick in that frame must not connect again


static func _tick_player(kind: String, tree: SceneTree) -> AudioStreamPlayer:
	var p: AudioStreamPlayer = _ticks.get(kind)
	if p != null and is_instance_valid(p):
		return p
	p = AudioStreamPlayer.new()
	p.name = "UITick_" + kind
	p.stream = load(TICKS[kind])
	p.bus = &"UI"
	p.volume_db = TICK_DB
	p.max_polyphony = 2
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	_ticks[kind] = p
	tree.root.add_child.call_deferred(p)   # deferred: the root may be busy setting up a scene
	return p


## A short notice in the top right ("Saved.", "Lantern Oil x2"): a label-role strip in the panel frame on
## its own CanvasLayer over the root, so it outlives a scene change; it fades after `secs`. A new toast
## replaces the one before it.
const TOAST_LAYER := 105
const TOAST_NAME := "UIToast"


static func toast(tree: SceneTree, text: String, secs := 1.5) -> void:
	tree = _tree(tree)
	if tree == null:
		return
	var old := tree.root.get_node_or_null(TOAST_NAME)
	if old != null:
		old.queue_free()
	var layer := CanvasLayer.new()
	layer.name = TOAST_NAME
	layer.layer = TOAST_LAYER
	var strip := PanelContainer.new()
	strip.add_theme_stylebox_override("panel", frame("panel"))
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", font("label"))
	label.add_theme_font_size_override("font_size", type_size("label"))
	label.add_theme_color_override("font_color", TEXT)
	label.add_theme_color_override("font_shadow_color", SHADOW)
	label.add_theme_constant_override("shadow_offset_x", int(TYPE["label"]["px"]))
	label.add_theme_constant_override("shadow_offset_y", int(TYPE["label"]["px"]))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.add_child(label)
	strip.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 24)
	strip.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	strip.grow_vertical = Control.GROW_DIRECTION_END
	layer.add_child(strip)
	tree.root.add_child.call_deferred(layer)
	var tw := layer.create_tween()   # bound to the layer: freeing the layer ends it cleanly
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_interval(maxf(secs, 0.0))
	tw.tween_property(strip, "modulate:a", 0.0, motion_secs(0.25))
	tw.tween_callback(layer.queue_free)


## The black fade between scenes (Claude, 2026-10-22): fade_out darkens over `secs` and returns the
## tween's finished signal (await UI.fade_out(get_tree()), then change the scene); fade_in on the next
## scene clears it and frees the layer, and returns its finished signal too. A fade_in with nothing to
## clear starts black, so a scene can open from dark. Both halve under reduce motion and run while the
## tree is paused. The layer sits above every menu (the pause menu is 80, evolution 95).
const FADE_LAYER := 110
const FADE_NAME := "UIFade"
static var _fade: CanvasLayer = null


static func fade_out(tree: SceneTree, secs := 0.2) -> Signal:
	tree = _tree(tree)
	var rect := _fade_rect(tree, 0.0)
	var tw := tree.create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(rect, "color:a", 1.0, motion_secs(secs))
	return tw.finished


static func fade_in(tree: SceneTree, secs := 0.2) -> Signal:
	tree = _tree(tree)
	var rect := _fade_rect(tree, 1.0)
	var layer := _fade
	_fade = null   # a fade_out during this fade_in starts a fresh layer
	var tw := tree.create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(rect, "color:a", 0.0, motion_secs(secs))
	tw.tween_callback(func() -> void:
		if is_instance_valid(layer):
			layer.queue_free())
	return tw.finished


## The fade's ColorRect, made (at `alpha`) and put on the root the first time, reused after.
static func _fade_rect(tree: SceneTree, alpha: float) -> ColorRect:
	if _fade != null and is_instance_valid(_fade):
		return _fade.get_node("Rect") as ColorRect
	_fade = CanvasLayer.new()
	_fade.name = FADE_NAME
	_fade.layer = FADE_LAYER
	var rect := ColorRect.new()
	rect.name = "Rect"
	rect.color = Color(0, 0, 0, alpha)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.add_child(rect)
	tree.root.add_child.call_deferred(_fade)
	return rect


## Input (Claude, 2026-10-23, factory pass 2: controller support and rebinding). Every key and button the game
## reads is an action in project.godot's Input Map, keeping the keyboard defaults the raw reads had (physical keys,
## so W sits in the same place on every layout) with an Xbox-layout pad beside them. Screens ask for actions here:
##   UI.tapped("attack")               a fresh press. Kept per key or button, as the dungeon's old _tapped kept
##                                     _keys_was: a press made while a scene was busy still counts the next time
##                                     it asks, if the key is still down. Two actions sharing J never both fire.
##   UI.held("run")                    down now
##   UI.tapped_any(UI.INPUT_ADVANCE)   any of them, every one read (no short cut): "the next line"
##   UI.dir8()                         the step asked for: keys, D-pad or left stick, one of eight ways or ZERO
##   UI.pressed(event, "pause")        for screens that take events in _input or _unhandled_input
##   UI.last_device()                  "keyboard" or "pad", from the last press (InputPrefs.device_changed says when)
##   UI.binding_text("bag")            "I" on a keyboard, "Y" on a pad: what to print in a hint
## The pad's moves are chords (INPUT_CHORDS): hold RB (moves_hold) and press A, X or Y for moves 1 to 3, B to rest.
## While RB is down, A, X, Y and B mean nothing else, so a move never also attacks, takes the stairs or opens the
## bag. Only these helpers know that rule: Input.is_action_pressed("move_slot_1") is also true for a bare A.
## Saved rebinds and the device watch live in the InputPrefs autoload (scripts/ui/input_prefs.gd).

## Which actions are live together, for the rebind clash rule and the input check: one input may not be bound to
## two actions that share a context, except two INPUT_ADVANCE actions (they all mean "next" where they meet).
## Godot's focus moves (ui_up, ui_down, ui_left, ui_right) stay the engine's and are not rebound.
const INPUT_CONTEXTS := {
	# Walking a Hollow's floor: J or Space attacks, E takes the stairs, Esc or B opens the pause menu.
	"hollow": ["move_left", "move_right", "move_up", "move_down", "attack", "move_slot_1", "move_slot_2", "move_slot_3",
		"moves_hold", "rest", "bag", "interact", "tactics", "log", "autopilot", "run", "turn", "cancel", "pause", "fullscreen"],
	# A question in a Hollow: take a recruit, let a move go. Y or Enter, N or Esc.
	"hollow_prompt": ["yes", "no", "pause", "fullscreen"],
	# The bag and the move lists in a Hollow: up and down choose, J or Enter takes, Esc or I closes.
	"hollow_menu": ["move_up", "move_down", "confirm", "cancel", "bag", "pause", "fullscreen"],
	# Walking Highbank and its rooms: E, J or Enter uses what is ahead, Esc closes a panel.
	"town": ["move_left", "move_right", "move_up", "move_down", "interact", "confirm", "cancel", "pause", "fullscreen"],
	# The board, storage, the shrine and the way-down list: R takes one out of storage, Page Up and Down scroll.
	"town_menu": ["move_left", "move_right", "move_up", "move_down", "confirm", "interact", "cancel", "take_out",
		"page_up", "page_down", "pause", "fullscreen"],
	# A line or a scene anywhere (the soul's prologue, a Hollow's scenes, the faint screen, which also takes rest).
	"story": ["confirm", "attack", "interact", "rest", "cancel", "move_left", "move_right", "move_up", "move_down", "pause",
		"fullscreen"],
	# The title, the pause menu and the party screen: Godot's focus, read through ui_accept and ui_cancel.
	"menus": ["ui_accept", "ui_cancel", "pause", "fullscreen"],
}
## The actions that move a line or a scene on (J, Enter, Space and E today; A and X on a pad).
const INPUT_ADVANCE := ["confirm", "attack", "interact"]
## Pad chords: the pad buttons of these actions count only while the named action is held.
const INPUT_CHORDS := {"move_slot_1": "moves_hold", "move_slot_2": "moves_hold", "move_slot_3": "moves_hold", "rest": "moves_hold"}
## The words a rebinding page shows for each action (proposals; Preston's to change).
const INPUT_NAMES := {
	"move_up": "Up", "move_down": "Down", "move_left": "Left", "move_right": "Right",
	"attack": "Attack", "move_slot_1": "Move 1", "move_slot_2": "Move 2", "move_slot_3": "Move 3",
	"moves_hold": "Hold for moves", "rest": "Rest", "bag": "Bag", "interact": "Use / stairs", "tactics": "Team orders",
	"log": "Messages", "autopilot": "Autopilot", "run": "Run", "turn": "Turn", "confirm": "Choose", "cancel": "Back",
	"yes": "Yes", "no": "No", "take_out": "Take out", "page_up": "Scroll up", "page_down": "Scroll down",
	"pause": "Pause", "fullscreen": "Full screen",
}
const TAP_DEAD := 0.5      # how far a stick or trigger must go to count as a press
const DIR_DEAD := 0.5      # dir8's dead zone, round the stick's centre
const DIAG_RATIO := 0.577  # tan 30 degrees: a stick reads diagonal only inside the middle 30 of each 90 degrees
const KEY_WORDS := {KEY_ESCAPE: "Esc", KEY_ENTER: "Enter", KEY_KP_ENTER: "Enter", KEY_SPACE: "Space", KEY_PERIOD: ".",
	KEY_PAGEUP: "PgUp", KEY_PAGEDOWN: "PgDn", KEY_CTRL: "Ctrl", KEY_SHIFT: "Shift", KEY_TAB: "Tab"}
const PAD_WORDS := {JOY_BUTTON_A: "A", JOY_BUTTON_B: "B", JOY_BUTTON_X: "X", JOY_BUTTON_Y: "Y", JOY_BUTTON_BACK: "Back",
	JOY_BUTTON_GUIDE: "Guide", JOY_BUTTON_START: "Start", JOY_BUTTON_LEFT_STICK: "L3", JOY_BUTTON_RIGHT_STICK: "R3",
	JOY_BUTTON_LEFT_SHOULDER: "LB", JOY_BUTTON_RIGHT_SHOULDER: "RB", JOY_BUTTON_DPAD_UP: "D-pad Up",
	JOY_BUTTON_DPAD_DOWN: "D-pad Down", JOY_BUTTON_DPAD_LEFT: "D-pad Left", JOY_BUTTON_DPAD_RIGHT: "D-pad Right"}
static var _was := {}               # an input's id -> it was down the last time any action read it
static var _device := "keyboard"
static var _axis_on := {}           # for pressed(): a stick direction was past TAP_DEAD at its last motion event
static var _edge_event := 0         # the motion event last judged, so two actions reading one event agree
static var _edge_fire := {}


## A fresh press of `action` since the last time its keys or buttons were read.
static func tapped(action: StringName) -> bool:
	if not InputMap.has_action(action):
		return false
	var hit := false
	for ev: InputEvent in InputMap.action_get_events(action):
		if _muted(action, ev):
			continue   # left unread, so the press is still fresh for the action it belongs to
		var id := _input_id(ev)
		if id == "":
			continue
		var now := _down(ev)
		if now and not bool(_was.get(id, false)):
			hit = true
		_was[id] = now
	return hit


## Any of `actions` tapped. Every one is read, so none keeps a stale press for a later frame.
static func tapped_any(actions: Array) -> bool:
	var hit := false
	for a in actions:
		if tapped(a):
			hit = true
	return hit


static func held(action: StringName) -> bool:
	if not InputMap.has_action(action):
		return false
	for ev: InputEvent in InputMap.action_get_events(action):
		if not _muted(action, ev) and _down(ev):
			return true
	# Input.action_press (how some checks walk) sets an action with nothing down behind it. Actions in the chord
	# rule skip this: the engine also sets move_slot_1 for a bare A.
	return not _chord_role(action) and Input.is_action_pressed(action)


## Count what is down now as already seen (all actions when `actions` is empty): a run started by Ctrl and a
## direction must not take that held direction as a key that stops it.
static func sync_taps(actions: Array = []) -> void:
	for a in (actions if not actions.is_empty() else InputMap.get_actions()):
		if InputMap.has_action(a):
			for ev: InputEvent in InputMap.action_get_events(a):
				var id := _input_id(ev)
				if id != "":
					_was[id] = _down(ev)


## Forget every press, as a screen with a fresh _keys_was used to start.
static func forget_taps() -> void:
	_was.clear()


## The step asked for: (-1..1, -1..1), or ZERO. Keys give the same steps the raw reads did (D and S together is
## down-right, A and D cancel); a stick inside DIR_DEAD is still, and under 30 degrees off a straight line it is straight.
static func dir8() -> Vector2i:
	var v := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down", DIR_DEAD)
	if v.length() < 0.01:
		return Vector2i.ZERO
	var x := int(signf(v.x))
	var y := int(signf(v.y))
	if absf(v.x) < absf(v.y) * DIAG_RATIO:
		x = 0
	elif absf(v.y) < absf(v.x) * DIAG_RATIO:
		y = 0
	return Vector2i(x, y)


## `event` is a fresh press of `action`, chord rule kept. For _input and _unhandled_input.
static func pressed(event: InputEvent, action: StringName) -> bool:
	if event == null or event.is_echo() or not InputMap.has_action(action) or not event.is_action_pressed(action, false, false):
		return false
	if event is InputEventJoypadButton:
		if INPUT_CHORDS.has(String(action)):
			return _hold_down(INPUT_CHORDS[String(action)])
		if event.button_index in _chord_buttons() and _any_hold_down():
			return false
	elif event is InputEventJoypadMotion:
		return _motion_edge(event)   # a stick sends a stream of motion: only the crossing counts
	return true


static func last_device() -> String:
	return _device


## Note the device behind `event` (the InputPrefs autoload calls this for every event). True when it changed.
static func note_input(event: InputEvent) -> bool:
	var d := ""
	if (event is InputEventKey or event is InputEventMouseButton) and event.pressed:
		d = "keyboard"   # the mouse reads as the keyboard: its hints are the keyboard's
	elif event is InputEventJoypadButton and event.pressed:
		d = "pad"
	elif event is InputEventJoypadMotion and absf(event.axis_value) > TAP_DEAD:
		d = "pad"
	return d != "" and set_device(d)


static func set_device(d: String) -> bool:
	if d == _device or d not in ["keyboard", "pad"]:
		return false
	_device = d
	return true


## The binding a hint prints for `action` on `device` ("keyboard" or "pad"; the last one used when ""): "J",
## "Space", "A", "RB+A". `every` lists them all ("J / Space"). "" when the device has none (full screen on a pad).
static func binding_text(action: StringName, device := "", every := false) -> String:
	if device == "":
		device = _device
	var out := PackedStringArray()
	if not InputMap.has_action(action):
		return ""
	for ev: InputEvent in InputMap.action_get_events(action):
		if _is_pad(ev) != (device == "pad"):
			continue
		var s := event_text(ev)
		if s != "" and ev is InputEventJoypadButton and INPUT_CHORDS.has(String(action)):
			s = binding_text(INPUT_CHORDS[String(action)], "pad") + "+" + s
		if s != "" and not out.has(s):
			out.append(s)
		if not every and not out.is_empty():
			break
	return " / ".join(out)


## The actions that already use the input in `event` where `action` is live too (the clash rule above), so a
## rebinding page can ask before it takes the input from them.
static func binding_clashes(action: StringName, event: InputEvent) -> PackedStringArray:
	var out := PackedStringArray()
	var want := _bind_id(action, event)
	if want == "":
		return out
	var me := String(action)
	for ctx in INPUT_CONTEXTS:
		var live: Array = INPUT_CONTEXTS[ctx]
		if not live.has(me):
			continue
		for other in live:
			if other == me or out.has(other) or (INPUT_ADVANCE.has(other) and INPUT_ADVANCE.has(me)):
				continue
			if InputMap.has_action(other):
				for ev: InputEvent in InputMap.action_get_events(other):
					if _bind_id(other, ev) == want:
						out.append(other)
						break
	return out


static func _is_pad(ev: InputEvent) -> bool:
	return ev is InputEventJoypadButton or ev is InputEventJoypadMotion


## One id per physical input, shared by every action bound to it.
static func _input_id(ev: InputEvent) -> String:
	if ev is InputEventKey:
		if ev.physical_keycode != KEY_NONE:
			return "k%d" % ev.physical_keycode
		if ev.keycode != KEY_NONE:
			return "l%d" % ev.keycode
		return "t%d" % ev.key_label if ev.key_label != KEY_NONE else ""
	if ev is InputEventJoypadButton:
		return "b%d" % ev.button_index
	if ev is InputEventJoypadMotion:
		return "a%d%s" % [ev.axis, "+" if ev.axis_value > 0.0 else "-"]
	if ev is InputEventMouseButton:
		return "m%d" % ev.button_index
	return ""


## A binding's id for the clash rule: a chord's pad button is its own input ("RB then A" is not "A").
static func _bind_id(action: StringName, ev: InputEvent) -> String:
	var id := _input_id(ev)
	if id != "" and ev is InputEventJoypadButton and INPUT_CHORDS.has(String(action)):
		return "%s+%s" % [INPUT_CHORDS[String(action)], id]
	return id


static func _down(ev: InputEvent) -> bool:
	if ev is InputEventKey:
		if ev.physical_keycode != KEY_NONE:
			return Input.is_physical_key_pressed(ev.physical_keycode)
		if ev.keycode != KEY_NONE:
			return Input.is_key_pressed(ev.keycode)
		return ev.key_label != KEY_NONE and Input.is_key_label_pressed(ev.key_label)
	if ev is InputEventJoypadButton:
		for d in _pads(ev.device):
			if Input.is_joy_button_pressed(d, ev.button_index):
				return true
		return false
	if ev is InputEventJoypadMotion:
		var s := signf(ev.axis_value)
		for d in _pads(ev.device):
			if Input.get_joy_axis(d, ev.axis) * s > TAP_DEAD:
				return true
		return false
	if ev is InputEventMouseButton:
		return Input.is_mouse_button_pressed(ev.button_index)
	return false


## The pads to read: one device, or every connected pad and device 0 (where a check's made-up events land).
static func _pads(device: int) -> Array:
	if device >= 0:
		return [device]
	var p: Array = Input.get_connected_joypads()
	if not p.has(0):
		p.append(0)
	return p


## The pad buttons the chords use (A, X, Y and B by default).
static func _chord_buttons() -> Array:
	var out := []
	for a in INPUT_CHORDS:
		if InputMap.has_action(a):
			for ev: InputEvent in InputMap.action_get_events(a):
				if ev is InputEventJoypadButton and not out.has(ev.button_index):
					out.append(ev.button_index)
	return out


static func _chord_role(action: StringName) -> bool:
	var a := String(action)
	if INPUT_CHORDS.has(a):
		return true
	if INPUT_CHORDS.values().has(a) or not InputMap.has_action(action):
		return false
	var used := _chord_buttons()
	for ev: InputEvent in InputMap.action_get_events(action):
		if ev is InputEventJoypadButton and used.has(ev.button_index):
			return true
	return false


## A pad press of `action` that the chord rule hides: a chord's button without its hold, or a plain action's
## button while a hold is down. Keys are never hidden.
static func _muted(action: StringName, ev: InputEvent) -> bool:
	if not (ev is InputEventJoypadButton):
		return false
	var a := String(action)
	if INPUT_CHORDS.has(a):
		return not _hold_down(INPUT_CHORDS[a])
	if INPUT_CHORDS.values().has(a):
		return false   # the hold itself
	return ev.button_index in _chord_buttons() and _any_hold_down()


## The hold action down (read straight from its events, so the chord rule never asks itself).
static func _hold_down(hold: String) -> bool:
	if not InputMap.has_action(hold):
		return false
	for ev: InputEvent in InputMap.action_get_events(hold):
		if _down(ev):
			return true
	return false


static func _any_hold_down() -> bool:
	var seen := []
	for a in INPUT_CHORDS:
		var hold: String = INPUT_CHORDS[a]
		if not seen.has(hold):
			seen.append(hold)
			if _hold_down(hold):
				return true
	return false


static func _motion_edge(ev: InputEventJoypadMotion) -> bool:
	if ev.get_instance_id() != _edge_event:
		_edge_event = ev.get_instance_id()
		for s in [-1, 1]:
			var id := "a%d%s" % [ev.axis, "+" if s > 0 else "-"]
			var on: bool = ev.axis_value * s > TAP_DEAD
			_edge_fire[s] = on and not bool(_axis_on.get(id, false))
			_axis_on[id] = on
	return bool(_edge_fire[1 if ev.axis_value > 0.0 else -1])


## What one key, button or stick push prints in a hint ("J", "Space", "A", "Left stick Up"); "" for none. Public
## since 2026-10-23 (Claude, U4): the rebinding page names what the player pressed with it.
static func event_text(ev: InputEvent) -> String:
	if ev is InputEventKey:
		var code: int = ev.physical_keycode
		if code != KEY_NONE:
			# What that key prints on this keyboard (a French layout's physical W is Z). Headless has no keyboard
			# map and prints an error for the question.
			if DisplayServer.get_name() != "headless":
				var shown := DisplayServer.keyboard_get_keycode_from_physical(code)
				if shown != KEY_NONE:
					code = shown
		else:
			code = ev.keycode
		if code == KEY_NONE:
			return ""
		return KEY_WORDS.get(code, OS.get_keycode_string(code))
	if ev is InputEventJoypadButton:
		return PAD_WORDS.get(ev.button_index, "Button %d" % ev.button_index)
	if ev is InputEventJoypadMotion:
		match ev.axis:
			JOY_AXIS_LEFT_X, JOY_AXIS_RIGHT_X:
				return ("Left stick " if ev.axis == JOY_AXIS_LEFT_X else "Right stick ") + ("Right" if ev.axis_value > 0.0 else "Left")
			JOY_AXIS_LEFT_Y, JOY_AXIS_RIGHT_Y:
				return ("Left stick " if ev.axis == JOY_AXIS_LEFT_Y else "Right stick ") + ("Down" if ev.axis_value > 0.0 else "Up")
			JOY_AXIS_TRIGGER_LEFT:
				return "LT"
			JOY_AXIS_TRIGGER_RIGHT:
				return "RT"
		return "Axis %d" % ev.axis
	return ""


## One pixel density for small faces (UI-05, Claude, 2026-10-23): the team row, the pause menu's team page and
## the party cards drew 48x48 portraits at 1x while dialogue faces are 40x40 at 3x. portrait_3x(form) is a
## `span` x `span` cut of the dialogue face (24 by default since Preston's 24 x 24 call, so 48x48 at 2x; 16 at 3x
## before), scaled with no smoothing and drawn at 1x in the old 48 px box. The cut is centred on FACE_AT, the middle of each face
## (picked by eye from the 40x40 faces, 2026-10-23; a form not listed is cut round (20, 18)). Pass 3 (Claude,
## 2026-10-23, U8 for LO-07) moved seven that sat off the face (Cairnshell, Crawdukes, Riftfin, Troughspine,
## Warden, Vitrecrag, Rampartroot) and set three that a 24 x 24 cut pushed back in at an edge to where it lands
## (Clinkerhide, Highsignal, Stillwade); tools/debug/face_crop_check.gd keeps every cut inside its face. A form with no
## dialogue face falls back to its portrait.png, then to its dungeon still in a 48 px box, as the team row did.
## Cached per form and span. "kithflare:joyous" cuts the joyous face round kithflare's centre.
const FACE_AT := {
	"archroot": Vector2i(24, 22), "cairnshell": Vector2i(20, 18), "caller": Vector2i(19, 21), "canvaswing": Vector2i(12, 17),
	"cinderhide": Vector2i(18, 12), "clinkerhide": Vector2i(28, 18), "crawdukes": Vector2i(18, 19), "dustkite": Vector2i(17, 21),
	"fusern": Vector2i(20, 19), "galeshear": Vector2i(21, 18), "grubbit": Vector2i(25, 20), "gruntle": Vector2i(20, 21),
	"highsignal": Vector2i(20, 12), "huskward": Vector2i(19, 18), "inkhoot": Vector2i(25, 20), "ironvent": Vector2i(18, 15),
	"kithflare": Vector2i(21, 13), "listener": Vector2i(18, 18), "mirekit": Vector2i(20, 21), "muskin": Vector2i(23, 19),
	"oathfen": Vector2i(17, 19), "oxbowarchon": Vector2i(16, 20), "ozbender": Vector2i(14, 18), "pouchbill": Vector2i(14, 12),
	"preostmar": Vector2i(21, 13), "rampartroot": Vector2i(16, 17), "riftfin": Vector2i(27, 21), "rimefin": Vector2i(24, 17),
	"rinsepaw": Vector2i(21, 16), "scourmaw": Vector2i(26, 16), "skimlet": Vector2i(17, 21), "slagglass": Vector2i(23, 24),
	"slipjaw": Vector2i(20, 14), "sparkwick": Vector2i(20, 16), "springvault": Vector2i(19, 12), "starward": Vector2i(23, 14),
	"stillwade": Vector2i(22, 12), "stormwick": Vector2i(18, 16), "swaphoard": Vector2i(24, 28), "tallowroot": Vector2i(21, 13),
	"troughspine": Vector2i(15, 23), "valvekin": Vector2i(13, 17), "vitrecrag": Vector2i(16, 18), "warden": Vector2i(19, 18),
	"wayling": Vector2i(24, 23), "waywhistle": Vector2i(14, 14), "whinet": Vector2i(24, 20), "wickglow": Vector2i(15, 21),
	"windcut": Vector2i(26, 25),
}
static var _faces3x := {}


## Preston, 2026-10-23: a 24 x 24 cut (the 16 x 16 one mostly showed one eye). It is scaled by the whole number that
## fills the 48 px face boxes (24 x 2, 16 x 3), never a fraction, so the pixels stay square.
static func portrait_3x(form: String, span := 24) -> Texture2D:
	var key := "%s@%d" % [form, span]
	if _faces3x.has(key):
		return _faces3x[key]
	var base := form.get_slice(":", 0)
	var out: Texture2D = null
	var face := dialogue_portrait(form)
	var img: Image = face.get_image() if face != null else null
	if img != null and not img.is_empty():
		if img.is_compressed():
			img.decompress()
		img.convert(Image.FORMAT_RGBA8)
		var s := clampi(span, 1, mini(img.get_width(), img.get_height()))
		var mid: Vector2i = FACE_AT.get(base, Vector2i(20, 18))
		var at := Vector2i(clampi(mid.x - s / 2, 0, img.get_width() - s), clampi(mid.y - s / 2, 0, img.get_height() - s))
		var cut := img.get_region(Rect2i(at, Vector2i(s, s)))
		var k := maxi(1, 48 / s)   # whole-number scale into the 48 px box
		cut.resize(s * k, s * k, Image.INTERPOLATE_NEAREST)
		out = ImageTexture.create_from_image(cut)
	if out == null:
		var path := "res://assets/sprites/arena/%s/portrait.png" % base
		var still := "res://assets/sprites/arena/%s/dungeon/s.png" % base
		if ResourceLoader.exists(path):
			out = load(path)
		elif ResourceLoader.exists(still):
			# The dungeon still centred in the 48 px box, its feet on the bottom edge (as dungeon.gd's portrait_of).
			var st: Image = load(still).get_image()
			st.convert(Image.FORMAT_RGBA8)
			var u := st.get_used_rect()
			var cut2 := Rect2i(u.position.x + (u.size.x - mini(u.size.x, 48)) / 2, u.position.y, mini(u.size.x, 48), mini(u.size.y, 48))
			var box := Image.create(48, 48, false, Image.FORMAT_RGBA8)
			box.blit_rect(st, cut2, Vector2i((48 - cut2.size.x) / 2, 48 - cut2.size.y))
			out = ImageTexture.create_from_image(box)
	_faces3x[key] = out
	return out
