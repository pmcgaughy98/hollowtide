extends Node2D
## The ruin and its stone path rising out of the river (Claude, 2026-10-10; Preston: "fix the scene where the
## structure and stone path appear out of the river, so it could be like our team was first to explore it").
## Plays once, on the waking riverbank during the flood (scripts/riverbank_journey.gd, before the Hollow Mouth
## is cleared). Drawn over Codex's bank painting (waking_native.png), under the creatures:
##   1. the ruin and the walkway are covered with river, copied from the water and treeline beside them;
##   2. a rumble; the ruin climbs out of the water behind the waterline, foam and spray at its foot;
##   3. the walkway's stones break the surface one after another, from the ruin's door down to the bank;
##   4. the cover goes and the painting is whole again, exactly as Codex drew it.
## `finished` fires at the end; the host gives control back then.

signal finished

const STRUCT := Rect2i(252, 0, 90, 50)     # the ruin, from the top of the picture to below its waterline
const WATERLINE := 47                       # where its foundation meets the river
const WALK := Rect2i(228, 42, 76, 38)      # the walkway, from the ruin's foot to the bank's lip
const REFLECT := Rect2i(246, 47, 100, 18)   # the ruin's glow on the water below it
const PATH_FROM := Vector2(300, 45)         # the walkway's top, at the ruin
const PATH_TO := Vector2(236, 73)           # its foot, on the bank
const SHIFT := 90                           # the river and treeline this far to the left stand in for them
const STEPS := 8                            # the walkway surfaces in this many beats

var source: Image                           # the bank painting as it is drawn (after Codex's finish)
var finish: Material                        # and its finish material; every layer here is full size so the
                                            # material's mask lines up pixel for pixel
var reduce_motion := false
var _cover: Texture2D
var _struct: Texture2D
var _walk_stages: Array[Texture2D] = []
var rise := 0.0                             # 0 under the water, 1 fully up
var walk_stage := -1                        # how many walkway beats have surfaced (-1 none)
var foam := 0.0
var _t := 0.0
var _spray: Array = []                      # {p, v, life}


func _ready() -> void:
	z_index = 1   # over the painting, under the creatures (they sort by their feet, far above 1)
	material = finish
	# The river without them. Above the waterline the ruin's whole box is the river and treeline to its left;
	# below it, and on the walkway, only water is swapped for water (the bank and the stones already on it
	# stay), so no box or step shows. The ruin's glow on the water goes with it (REFLECT).
	var cover := Image.create(source.get_width(), source.get_height(), false, Image.FORMAT_RGBA8)
	for y in range(STRUCT.position.y, WATERLINE):
		for x in range(STRUCT.position.x, STRUCT.end.x):
			# A dithered seam at the box's sides, so the swapped river meets the painted one without a line.
			if (x - STRUCT.position.x < 3 or STRUCT.end.x - 1 - x < 3) and (x + y) % 2 == 0:
				continue
			cover.set_pixel(x, y, source.get_pixel(x - SHIFT, y))
	for r in [REFLECT, WALK]:
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				var from := source.get_pixel(x - SHIFT, y)
				if _water(from) and (_water(source.get_pixel(x, y)) or y < WATERLINE + 13):
					cover.set_pixel(x, y, from)
	# The path's stones already on the bank go too (Preston, 2026-10-10: "hide the stones for the walkway"):
	# grey stone and its dark edge are filled from the nearest clean bank in the same row.
	var stone := {}
	for y in range(WALK.position.y, WALK.end.y):
		for x in range(WALK.position.x, WALK.end.x):
			if cover.get_pixel(x, y).a == 0.0 and _stone(source.get_pixel(x, y)):
				stone[Vector2i(x, y)] = true
	for p in stone.keys():   # and the dark edge round each stone
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var q: Vector2i = p + d
			if WALK.has_point(q) and cover.get_pixel(q.x, q.y).a == 0.0 and source.get_pixel(q.x, q.y).get_luminance() < 0.3:
				stone[q] = true
	for p in stone:
		for d in range(1, 40):
			var side := -1 if (d + p.y) % 2 == 0 else 1
			for s in [side, -side]:
				var q := Vector2i(p.x + s * d, p.y)
				if q.x >= 0 and q.x < source.get_width() and not stone.has(q) and not _stone(source.get_pixel(q.x, q.y)):
					cover.set_pixel(p.x, p.y, source.get_pixel(q.x + s * ((p.x + p.y) % 3), q.y))
					break
			if cover.get_pixel(p.x, p.y).a > 0.0:
				break
	_cover = ImageTexture.create_from_image(cover)
	# What rises and surfaces: only the pixels that differ from the river (stone, windows, the glow).
	var only := Image.create(source.get_width(), source.get_height(), false, Image.FORMAT_RGBA8)
	for y in range(STRUCT.position.y, STRUCT.end.y):
		for x in range(STRUCT.position.x, STRUCT.end.x):
			if _differs(x, y, cover):
				only.set_pixel(x, y, source.get_pixel(x, y))
	_struct = ImageTexture.create_from_image(only)
	# The walkway in beats: a pixel shows once the surfacing has passed its place along the path.
	var dir := (PATH_TO - PATH_FROM).normalized()
	var length := PATH_FROM.distance_to(PATH_TO)
	for k in STEPS:
		var stage := Image.create(source.get_width(), source.get_height(), false, Image.FORMAT_RGBA8)
		for r in [WALK, REFLECT]:
			for y in range(r.position.y, r.end.y):
				for x in range(r.position.x, r.end.x):
					var along := clampf((Vector2(x, y) - PATH_FROM).dot(dir) / length, 0.0, 1.0)
					if along <= float(k + 1) / STEPS and _differs(x, y, cover):
						stage.set_pixel(x, y, source.get_pixel(x, y))
		_walk_stages.append(ImageTexture.create_from_image(stage))


## Water as Codex's bank tells it (waking_bank.gd water_at): blue over red, green over red.
static func _water(c: Color) -> bool:
	return c.b > c.r * 1.25 and c.g > c.r * 1.10 and c.b > c.g * 0.80


## The path's stone: grey, little colour, not dark (the bank's clay is brown, its grass green).
static func _stone(c: Color) -> bool:
	return maxf(c.r, maxf(c.g, c.b)) - minf(c.r, minf(c.g, c.b)) < 0.17 and c.get_luminance() > 0.17 and c.r < c.g + 0.06   # wet stone runs a little blue


## Whether the painting at (x, y) is something the river cover hid (not just the river itself).
func _differs(x: int, y: int, cover: Image) -> bool:
	var c := cover.get_pixel(x, y)
	if c.a == 0.0:
		return false
	var o := source.get_pixel(x, y)
	return absf(o.r - c.r) + absf(o.g - c.g) + absf(o.b - c.b) > 0.16


func play() -> void:
	var tree := get_tree()
	await tree.create_timer(0.3 if reduce_motion else 0.8).timeout
	_sfx("pond_rumble", -2.0)
	foam = 1.0
	await tree.create_timer(0.2 if reduce_motion else 0.9).timeout
	var tw := create_tween()
	tw.tween_property(self, "rise", 1.0, 0.6 if reduce_motion else 2.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw.finished
	_sfx("pond_burst", -4.0)
	for k in STEPS:
		walk_stage = k
		var at := PATH_FROM.lerp(PATH_TO, float(k + 1) / STEPS)
		for n in 6:
			_spray.append({"p": at + Vector2(randf_range(-4, 4), 0), "v": Vector2(randf_range(-14, 14), randf_range(-40, -18)), "life": 0.6})
		if k % 2 == 0:
			_sfx("hop_splash", -10.0)
		await tree.create_timer(0.05 if reduce_motion else 0.22).timeout
	tw = create_tween()
	tw.tween_property(self, "foam", 0.0, 0.8)
	await tw.finished
	finished.emit()
	queue_free()


func _process(delta: float) -> void:
	_t += delta
	for s in _spray:
		s["v"].y += 120.0 * delta
		s["p"] += s["v"] * delta
		s["life"] -= delta
	_spray = _spray.filter(func(s: Dictionary) -> bool: return s["life"] > 0.0)
	queue_redraw()


func _draw() -> void:
	draw_texture(_cover, Vector2.ZERO)
	# The ruin, pushed down by what has not risen yet, cut off at the waterline.
	var d := int(round((1.0 - rise) * STRUCT.size.y))
	var shown := STRUCT.size.y - d if rise < 1.0 else STRUCT.size.y
	if rise >= 1.0:
		draw_texture(_struct, Vector2.ZERO)
	elif d < WATERLINE:
		shown = mini(shown, WATERLINE - d)
		draw_texture_rect_region(_struct, Rect2(STRUCT.position.x, STRUCT.position.y + d, STRUCT.size.x, shown), Rect2(STRUCT.position.x, STRUCT.position.y, STRUCT.size.x, shown))
	if walk_stage >= 0:
		draw_texture(_walk_stages[walk_stage], Vector2.ZERO)
	# Foam churning along the waterline while it rises.
	if foam > 0.0:
		for k in 26:
			var x := STRUCT.position.x - 6 + int(fposmod(k * 37.0 + _t * 23.0 * (1 + k % 3), STRUCT.size.x + 12))
			var y := WATERLINE - 1 + (k % 3)
			draw_rect(Rect2(x, y, 2 + k % 3, 1), Color(0.86, 0.94, 0.92, foam * (0.5 + 0.4 * sin(_t * 9.0 + k))))
	for s in _spray:
		draw_rect(Rect2(s["p"].round(), Vector2(1, 1)), Color(0.85, 0.95, 0.95, clampf(s["life"] / 0.6, 0.0, 1.0)))


func _sfx(name: String, db: float) -> void:
	var path := "res://assets/audio/sfx/dungeon/%s.wav" % name
	if not ResourceLoader.exists(path):
		return
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	p.volume_db = db
	p.bus = &"SFX"
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)
