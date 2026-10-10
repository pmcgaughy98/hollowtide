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


## A panel: the moss fill, the brass edge, a faint inner line.
static func panel(c: CanvasItem, r: Rect2, alpha := 0.92) -> void:
	c.draw_rect(r, Color(PANEL, alpha))
	c.draw_rect(r, EDGE, false, 2.0)
	c.draw_rect(r.grow(-4.0), Color(EDGE, 0.22), false, 1.0)


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
