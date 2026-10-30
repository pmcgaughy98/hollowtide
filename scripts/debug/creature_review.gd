extends Node2D
## Creature review reel (Claude, 2026-10-28; Preston: "make short video thatd show me what I need for each one to see
## any issues so I can list them for you for all animations views and other things").
## Plays each creature's dungeon art the way the dungeon draws it (the creature finish shader, the 16 by 6 shadow, the
## feet stood on the game's foot row, the idle bob) through numbered parts, so a fault can be named by creature, part
## and facing. Run under Movie Maker; tools/art/review_videos.py does that and cuts one video per creature.
##   godot --path . --write-movie out.png --fixed-fps 30 res://scenes/debug/creature_review.tscn -- --forms=a,b --out=ranges.json

const FINISH := preload("res://scripts/arena/creature_finish.gd")
const DUNGEON := preload("res://scripts/dungeon/dungeon.gd")   # for its FOOTPRINT_SHADOW list
const FACINGS := ["s", "se", "e", "ne", "n", "nw", "w", "sw"]
const TAG := {"s": "S  front", "se": "SE", "e": "E", "ne": "NE", "n": "N  back", "nw": "NW", "w": "W", "sw": "SW"}
const STEP := {"e": Vector2i(1, 0), "se": Vector2i(1, 1), "s": Vector2i(0, 1), "sw": Vector2i(-1, 1),
	"w": Vector2i(-1, 0), "nw": Vector2i(-1, -1), "n": Vector2i(0, -1), "ne": Vector2i(1, -1)}
const T := 24                                   # the dungeon's tile (dungeon.gd T)
const STEP_SECS := 0.3                          # one tile per 0.3 s while walking around (the game takes 0.11)
const ACT_FPS := {"attack": 10.0, "hurt": 10.0, "sleep": 6.0}
const FOOT_FIX := {"troughspine": {"n": 31, "nw": 31, "ne": 31}}   # as dungeon.gd FOOT_FIX for the dungeon set
const BG := Color(0.25, 0.28, 0.25)

var forms: PackedStringArray = []
var out_path := ""
var form_i := -1
var frame := 0
var plan: Array = []
var part_i := 0
var part_t := 0.0
var art := {}
var zoom := 3.0                                 # whole-pixel zoom per creature, so a stage 1 is as easy to read as a stage 3
var ranges := {}
var world: Node2D
var floor_node: Node2D
var grid: Array = []
var walker := {}
var ref := {}
var head: Label
var big: Label
var tags: Array = []


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--forms="):
			forms = a.substr(8).split(",")
		elif a.begins_with("--out="):
			out_path = a.substr(6)
	RenderingServer.set_default_clear_color(BG)
	world = Node2D.new()
	add_child(world)
	floor_node = Node2D.new()
	floor_node.draw.connect(_draw_floor)
	world.add_child(floor_node)
	for i in 8:
		grid.append(_actor())
	walker = _actor()
	ref = _actor()
	var ui := CanvasLayer.new()
	add_child(ui)
	head = _label(ui, 26)
	head.position = Vector2(12, 4)
	big = _label(ui, 56)
	big.position = Vector2(0, 250)
	big.size = Vector2(1152, 80)
	big.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for i in 10:
		tags.append(_label(ui, 18))


func _label(parent: Node, px: int) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", px)
	l.add_theme_constant_override("outline_size", 5)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	parent.add_child(l)
	return l


func _actor() -> Dictionary:
	var node := Node2D.new()
	var shadow := Polygon2D.new()
	var pts := PackedVector2Array()
	for k in 12:
		pts.append(Vector2(cos(k * TAU / 12.0) * 8.0, sin(k * TAU / 12.0) * 3.0))
	shadow.polygon = pts
	shadow.color = Color(0, 0, 0, 0.3)
	node.add_child(shadow)
	var sprite := Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.add_child(sprite)
	FINISH.apply(sprite)
	world.add_child(node)
	node.visible = false
	return {"node": node, "sprite": sprite}


## The dungeon's foot rules (dungeon.gd _count_foot_row and the planted row of a walk).
func _foot(tex: Texture2D) -> float:
	var img := tex.get_image()
	for y in range(img.get_height() - 1, -1, -1):
		var n := 0
		for x in img.get_width():
			if img.get_pixel(x, y).a > 0.1:
				n += 1
		if n >= 4:
			return float(y + 1)
	return float(img.get_height())


func _planted(frames: Array) -> float:
	var rows: Array[float] = []
	for tex in frames:
		rows.append(_foot(tex))
	if rows.is_empty():
		return 0.0
	rows.sort()
	var median: float = rows[rows.size() / 2]
	var planted := 0.0
	for r in rows:
		if r <= median + 4.0:
			planted = maxf(planted, r)
	return planted


func _load_art(form: String) -> Dictionary:
	var base := "res://assets/sprites/arena/%s/dungeon/" % form
	var still := {}
	var foot := {}
	var walk := {}
	var walk_foot := {}
	var acts := {}
	for f in FACINGS:
		still[f] = load(base + f + ".png")
		foot[f] = _foot(still[f])
		var frames := []
		for i in 8:
			var p := base + "walk_%s_f%d.png" % [f, i]
			if ResourceLoader.exists(p):
				frames.append(load(p))
		walk[f] = frames
		walk_foot[f] = _planted(frames)
		var fix: Dictionary = FOOT_FIX.get(form, {})
		if fix.has(f):
			walk_foot[f] -= foot[f] - float(fix[f])
			foot[f] = float(fix[f])
	for act in ["attack", "hurt", "sleep"]:
		var by := {}
		for f in FACINGS:
			var got := []
			for i in 8:
				var p := base + "%s_%s_f%d.png" % [act, f, i]
				if ResourceLoader.exists(p):
					got.append(load(p))
			if not got.is_empty():
				by[f] = [got, _planted(got)]
		if not by.is_empty():
			acts[act] = by
	return {"still": still, "foot": foot, "walk": walk, "walk_foot": walk_foot, "acts": acts}


func _start(form: String) -> void:
	art = _load_art(form)
	ranges[form] = [frame, frame]
	var tall := 1
	for f in FACINGS:
		var used: Rect2i = art["still"][f].get_image().get_used_rect()
		tall = maxi(tall, used.size.y)
	zoom = clampf(floorf(230.0 / tall), 3.0, 8.0)
	plan = [["", 1.2, "title"], ["STANDING, with the idle bob", 3.0, "views"],
		["WALK, slowed to 8 frames a second", 4.0, "walk_slow"], ["WALK at game speed", 2.0, "walk_fast"],
		["WALKING AROUND, two tiles each way, slowed to 0.3 s a tile", STEP_SECS * 16.0, "around"]]
	for act in ["attack", "hurt", "sleep"]:
		if art["acts"].has(act):
			plan.append(["%s, %d frames a second" % [act.to_upper(), int(ACT_FPS[act])], 3.0 if act != "hurt" else 2.0, act])
	var missing := []
	for act in ["attack", "hurt", "sleep"]:
		if not art["acts"].has(act):
			missing.append(act)
	if not missing.is_empty():
		plan.append(["NO %s ART YET" % " / ".join(missing).to_upper(), 1.5, "missing"])
	plan.append(["SIZE next to Kithflare (stage 1) and its own side view", 2.0, "size"])
	part_i = 0
	part_t = 0.0


func _show(a: Dictionary, tex: Texture2D, foot: float, at: Vector2, bob: float = 0.0) -> void:
	var s: Sprite2D = a["sprite"]
	s.texture = tex
	s.offset = Vector2(0, tex.get_height() * 0.5 - foot + bob)
	a["node"].position = at
	a["node"].visible = true
	var shadow: Polygon2D = a["node"].get_child(0)
	if a != ref and forms[form_i] in DUNGEON.FOOTPRINT_SHADOW:
		# As dungeon.gd _fit_shadow: centre and size from the pose's opaque outline.
		var used: Rect2i = tex.get_image().get_used_rect()
		var c := Vector2(used.position) + Vector2(used.size) * 0.5
		shadow.position = Vector2(c.x - tex.get_width() * 0.5, (c.y - foot) * 0.5 + 2.0)
		shadow.scale = Vector2(used.size.x * 0.45, maxf(3.0, used.size.y * 0.28)) / Vector2(8.0, 3.0)
		shadow.color = Color(0, 0, 0, 0.34)
	else:
		shadow.position = Vector2.ZERO
		shadow.scale = Vector2.ONE
		shadow.color = Color(0, 0, 0, 0.3)


## The two rows of four, placed on the screen and turned into world points at this creature's zoom.
func _cell(i: int) -> Vector2:
	return Vector2(144 + 288 * (i % 4), 300 + 300 * (i / 4)) / zoom


func _tag(i: int, text: String, at: Vector2) -> void:
	var l: Label = tags[i]
	l.text = text
	l.position = at * zoom + world.position - Vector2(60, 0)
	l.size = Vector2(120, 24)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.visible = true


func _process(_delta: float) -> void:
	if form_i < 0 or part_i >= plan.size():
		form_i += 1
		if form_i > 0:
			ranges[forms[form_i - 1]][1] = frame - 1
		if form_i >= forms.size():
			if out_path != "":
				var fa := FileAccess.open(out_path, FileAccess.WRITE)
				fa.store_string(JSON.stringify(ranges))
			get_tree().quit()
			return
		_start(forms[form_i])
	_render(forms[form_i], plan[part_i], part_t)
	frame += 1
	part_t += 1.0 / 30.0
	if part_t >= plan[part_i][1] - 0.0001:
		part_i += 1
		part_t = 0.0


func _render(form: String, part: Array, t: float) -> void:
	for a in grid + [walker, ref]:
		a["node"].visible = false
	for l in tags:
		l.visible = false
	big.visible = false
	floor_node.visible = false
	var kind: String = part[2]
	world.scale = Vector2(zoom, zoom)
	world.position = Vector2.ZERO
	var number := plan.find(part)
	head.text = "%s     %d  %s" % [form.capitalize(), number, part[0]] if kind != "title" else ""
	match kind:
		"title":
			big.text = form.capitalize()
			big.visible = true
		"missing":
			big.text = part[0].capitalize()
			big.visible = true
		"views":
			var bob := -1.0 if fmod(t / 1.1, 1.0) < 0.5 else 0.0
			for i in 8:
				var f: String = FACINGS[i]
				_show(grid[i], art["still"][f], art["foot"][f], _cell(i), bob)
				_tag(i, TAG[f], _cell(i) + Vector2(0, 2))
		"walk_slow", "walk_fast":
			var k := int(t * 8.0) if kind == "walk_slow" else int(t / 0.11 * 4.0)
			if kind == "walk_slow":
				head.text += "     frame %d of 8" % (k % 8 + 1)
			for i in 8:
				var f: String = FACINGS[i]
				var frames: Array = art["walk"][f]
				if not frames.is_empty():
					_show(grid[i], frames[k % frames.size()], art["walk_foot"][f], _cell(i))
				_tag(i, TAG[f], _cell(i) + Vector2(0, 2))
		"around":
			floor_node.visible = true
			var order := ["e", "se", "s", "sw", "w", "nw", "n", "ne"]
			var step := mini(int(t / STEP_SECS), 15)
			var f: String = order[step / 2]
			var tile := Vector2i(8, 4)
			for s in step:
				tile += STEP[order[s / 2]]
			var u := clampf((t - step * STEP_SECS) / STEP_SECS, 0.0, 1.0)
			var from := Vector2(tile) * T + Vector2(T * 0.5, T * 0.78)
			var at := from + Vector2(STEP[f]) * T * u
			world.position = Vector2(576, 420) - at * zoom   # the camera follows the walker, as in the dungeon
			var frames: Array = art["walk"][f]
			if not frames.is_empty():
				# Four walk frames per tile, as the dungeon plays them.
				_show(walker, frames[int(t / STEP_SECS * 4.0) % frames.size()], art["walk_foot"][f], at)
			head.text += ":  going " + f.to_upper()
		"attack", "hurt", "sleep":
			var by: Dictionary = art["acts"][kind]
			for i in 8:
				var f: String = FACINGS[i]
				if by.has(f):
					var got: Array = by[f][0]
					_show(grid[i], got[int(t * ACT_FPS[kind]) % got.size()], by[f][1], _cell(i))
					_tag(i, TAG[f], _cell(i) + Vector2(0, 2))
			var n: int = by.values()[0][0].size()
			head.text += "     frame %d of %d" % [int(t * ACT_FPS[kind]) % n + 1, n]
		"size":
			var kith: Texture2D = load("res://assets/sprites/arena/kithflare/dungeon/s.png")
			var spots := [Vector2(330, 470), Vector2(576, 470), Vector2(840, 470)]
			_show(ref, kith, _foot(kith), spots[0] / zoom)
			_tag(0, "Kithflare", spots[0] / zoom + Vector2(0, 2))
			_show(grid[0], art["still"]["s"], art["foot"]["s"], spots[1] / zoom)
			_tag(1, form.capitalize(), spots[1] / zoom + Vector2(0, 2))
			_show(grid[1], art["still"]["e"], art["foot"]["e"], spots[2] / zoom)
			_tag(2, "side", spots[2] / zoom + Vector2(0, 2))


func _draw_floor() -> void:
	for y in range(-6, 20):
		for x in range(-6, 26):
			var c := Color(0.36, 0.33, 0.28) if (x + y) % 2 == 0 else Color(0.33, 0.30, 0.25)
			floor_node.draw_rect(Rect2(x * T, y * T, T, T), c)
