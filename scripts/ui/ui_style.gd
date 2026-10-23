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
	var page_text := "\n".join(rows.slice(page * 2, page * 2 + 2))
	var shown := page_text.substr(0, typed(line, page_text))
	c.draw_multiline_string(f, at + Vector2(2, 2), shown, HORIZONTAL_ALIGNMENT_LEFT, width + 10, type_size("story"), -1, SHADOW)
	c.draw_multiline_string(f, at, shown, HORIZONTAL_ALIGNMENT_LEFT, width + 10, type_size("story"), -1, TEXT)
	if _line["done"]:
		next_arrow(c, box.end - Vector2(48, 36), t)   # more on the next page, or the next line


## The rows of a dialogue line at `width`, with the widow rule (Claude, 2026-10-22, LP-19): when the line
## pages and its last page is under 12 characters ("go again."), the rows are re-wrapped a little narrower,
## a step at a time, until the last page carries a real line; a wrap that would add a page is not taken.
const WIDOW := 12


static func _dialogue_rows(line: String, width: float) -> PackedStringArray:
	var rows := wrap_text(line, width, "story").split("\n")
	var pages := ceili(rows.size() / 2.0)
	if pages < 2 or _last_page_len(rows) >= WIDOW:
		return rows
	var w := width
	for k in 8:
		w *= 0.92
		var again := wrap_text(line, w, "story").split("\n")
		if ceili(again.size() / 2.0) > pages:
			break
		if _last_page_len(again) >= WIDOW:
			return again
	return rows


static func _last_page_len(rows: PackedStringArray) -> int:
	var first := (ceili(rows.size() / 2.0) - 1) * 2
	var n := 0
	for k in range(first, rows.size()):
		n += rows[k].strip_edges().length()
	return n


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


## Menu preferences (Claude, 2026-10-22, the factory contract): user://menu_preferences.cfg, the file the
## title and pause menus already write, read once and kept. Reduce motion (menu/reduce_motion) halves the
## fades; text speed (menu/text_speed: 1 normal, 2 fast, 0 instant) scales the typing in typed(); the
## screen mode (display/fullscreen) is set and saved by apply_screen_mode. A menu that saves a pref calls
## reload_prefs() so the change counts in the same session.
const PREFS_PATH := "user://menu_preferences.cfg"
static var _prefs: ConfigFile = null


static func _pref(section: String, key: String, default: Variant) -> Variant:
	if _prefs == null:
		_prefs = ConfigFile.new()
		_prefs.load(PREFS_PATH)   # no file yet reads as every default
	return _prefs.get_value(section, key, default)


## Forget the cached preferences, so the next read sees what a menu just saved.
static func reload_prefs() -> void:
	_prefs = null


static func reduce_motion() -> bool:
	return bool(_pref("menu", "reduce_motion", false))


## 1 normal, 2 fast, 0 instant; anything else on disk reads as normal.
static func text_speed() -> int:
	var v := int(_pref("menu", "text_speed", 1))
	return v if v in [0, 1, 2] else 1


## The saved screen mode, for whoever applies it at launch.
static func screen_full() -> bool:
	return bool(_pref("display", "fullscreen", false))


## Full screen or windowed, now and on the next launch: the pref is written and the other keys kept.
static func apply_screen_mode(full: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if full else DisplayServer.WINDOW_MODE_WINDOWED)
	var c := ConfigFile.new()
	c.load(PREFS_PATH)
	c.set_value("display", "fullscreen", full)
	c.save(PREFS_PATH)
	reload_prefs()


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
