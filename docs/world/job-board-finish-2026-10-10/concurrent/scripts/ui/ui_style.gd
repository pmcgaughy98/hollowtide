extends RefCounted
## Hollowtide's one UI look (Claude, 2026-10-10; Preston: "Do U.I upgrades and visuals... including
## from main menu to town to battle everything"). Taken from Codex's title and pause menu so every
## screen speaks the same language: deep moss panels with a worn brass edge, parchment text, Alegreya
## Sans SC at sizes that read at 1152x648 (16 and up for anything a player must read).
## Screens that draw their own HUD (the dungeon, the town) call these instead of drawing boxes.
##   const UI := preload("res://scripts/ui/ui_style.gd")
##   UI.panel(canvas, rect); UI.text(canvas, pos, "Lv 3", 18); UI.bar(canvas, rect, 0.5, UI.hp_col(0.5))

const HEAD := preload("res://assets/fonts/AlegreyaSansSC-Bold.ttf")
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
const PORTRAIT_BG := Color("#efe6d2")  # the pale square behind a headshot, as Mystery Dungeon's portraits sit on white


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
	var r := Rect2(pos, Vector2(maxf(96.0, width_of(s, size) + 40.0), 36.0))
	c.draw_style_box(frame("nameplate"), r)
	c.draw_string(HEAD, pos + Vector2(0, 25), s, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, size, Color("#2a1f14"))
	return r


## A portrait in its frame: `r` is where the 40x40 portrait shows (120x120 at 3x); the frame sits
## 15 pixels outside it, on the parchment well.
static func portrait(c: CanvasItem, r: Rect2, tex: Texture2D, flip := false) -> void:
	c.draw_style_box(frame("portrait"), r.grow(15.0))
	if tex != null:
		var dst := r
		if flip:
			dst = Rect2(r.position + Vector2(r.size.x, 0), Vector2(-r.size.x, r.size.y))
		c.draw_texture_rect(tex, dst, false)


## A dialogue portrait by form ("kithflare", "warden"); null when that creature has none yet.
static func dialogue_portrait(form: String) -> Texture2D:
	return icon("dialogue/" + form)


## The "next" arrow, bobbing a pixel-step every half second. `t` is any running clock in seconds.
static func next_arrow(c: CanvasItem, pos: Vector2, t: float) -> void:
	var tex: Texture2D = icon("frame/arrow")
	if tex != null:
		c.draw_texture(tex, pos + Vector2(0, 3.0 * float(int(t * 2.0) % 2)))


## A whole scene line the Explorers of Sky way: the portrait framed above the box's left corner, the
## name on a brass tab, the line in parchment, the arrow when there is more. `portrait_tex` may be null
## (an unseen speaker), and then no portrait shows.
static func dialogue(c: CanvasItem, box: Rect2, speaker: String, line: String, portrait_tex: Texture2D, t: float, size := 20) -> void:
	if portrait_tex != null:
		portrait(c, Rect2(box.position + Vector2(18, -150), Vector2(120, 120)), portrait_tex)
	panel(c, box, 0.95)
	var lift := 0.0
	if speaker != "":
		nameplate(c, box.position + Vector2(160 if portrait_tex != null else 24, -22), speaker)
		lift = 10.0
	c.draw_multiline_string(HEAD, box.position + Vector2(30, 40 + lift), line, HORIZONTAL_ALIGNMENT_LEFT, box.size.x - 70, size, -1, TEXT)
	next_arrow(c, box.end - Vector2(48, 36), t)


static func text(c: CanvasItem, pos: Vector2, s: String, size := 18, col := TEXT, width := -1.0, align := HORIZONTAL_ALIGNMENT_LEFT) -> void:
	c.draw_string(HEAD, pos, s, align, width, size, col)


static func width_of(s: String, size: int) -> float:
	return HEAD.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x


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
			c.draw_string(HEAD, Vector2(x, pos.y), plain, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(TEXT, alpha))
			x += width_of(plain, size)
		if at < 0:
			break
		c.draw_string(HEAD, Vector2(x, pos.y), word, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(marks[word], alpha))
		x += width_of(word, size)
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
