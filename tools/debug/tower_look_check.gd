extends SceneTree
## The Tower's pass 9 look items, measured on the blockouts themselves (Claude, pass 9 W4 to W7):
##   W4 the Waiting Lamp's glow over the slate sky (#4a5e73, the reveal's sky at the lamp): each step's colour once
##      added, its hue, and the lamp plus glow as one box. Pass 8's inner step (brass-hi at 35 %) is shown beside it.
##   W5 the Reach's curl: brass lashings on it, and its thickness where it leaves the shaft against near the hook.
##   W6 the wayline post's lantern in each state: frame, cap, bar, base, and the state's own mark.
##   W7 the rise stair's roots: each breaks out of a riser (under the tread's lip), none lies on its own step's tread.
## Run: python tools/debug/run_checks.py tower_look (the runner adds --fixed-fps 30).

const TP := preload("res://scripts/town/tower_parts.gd")
const SKY := Color("#4a5e73")

var fails := 0


func _initialize() -> void:
	_glow()
	_reach()
	_post()
	_stair()
	print("TOWER LOOK CHECK: %s" % ("PASS" if fails == 0 else "FAIL (%d)" % fails))
	quit(0 if fails == 0 else 1)


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


static func _add(dst: Color, src: Color) -> Color:
	return Color(minf(1.0, dst.r + src.r * src.a), minf(1.0, dst.g + src.g * src.a), minf(1.0, dst.b + src.b * src.a))


static func _say(c: Color) -> String:
	return "%s (hue %d, sat %d%%, red minus blue %+d, green minus red %+d)" % [c.to_html(false), int(round(c.h * 360.0)),
		int(round(c.s * 100.0)), int(round((c.r - c.b) * 255.0)), int(round((c.g - c.r) * 255.0))]


## W4.
func _glow() -> void:
	for step in TP.GLOW_STEPS:
		var src := Color(TP.AMBER[String(step[2])], float(step[1]))
		print("  glow step to %.2f, amber-%s at %d%%: over the sky %s" % [float(step[0]), String(step[2]), int(float(step[1]) * 100.0), _say(_add(SKY, src))])
	var inner := _add(SKY, Color(TP.AMBER[String(TP.GLOW_STEPS[0][2])], float(TP.GLOW_STEPS[0][1])))
	var brass := _add(SKY, Color(TP.BRASS["hi"], 0.35))
	print("  pass 8's inner step, brass-hi at 35%%: over the sky %s" % _say(brass))
	print("  the sky alone: %s" % _say(SKY))
	_ok("The glow's inner step leans warm, not green: red over blue and green no higher than red (%s)" % _say(inner),
		inner.r > inner.b and inner.g - inner.r <= 1.0 / 255.0)
	# The lamp (lit, frame 0) with the glow behind it, over the sky: the whole glow box as one colour.
	var lamp := TP.paint_part("town.building.hall.lamp", "lit", 0)
	var g := TP.glow_image()
	var beacon := Vector2i(16, 26)   # the glass centre, frame (216, 118) less the lamp's frame_at (200, 92)
	var at := Vector2i(g.get_width() / 2, g.get_height() / 2) - beacon
	var sum := Color(0, 0, 0, 0)
	var n := 0
	for y in g.get_height():
		for x in g.get_width():
			var c := _add(SKY, g.get_pixel(x, y))
			var lx := x - at.x
			var ly := y - at.y
			if lx >= 0 and ly >= 0 and lx < lamp.get_width() and ly < lamp.get_height() and lamp.get_pixel(lx, ly).a > 0.5:
				c = lamp.get_pixel(lx, ly)
			sum += Color(c.r, c.g, c.b, 0.0)
			n += 1
	var mean := Color(sum.r / n, sum.g / n, sum.b / n)
	_ok("The lamp with its glow, over the slate sky, as one box %dx%d: red over blue (%s)" % [g.get_width(), g.get_height(), _say(mean)],
		mean.r > mean.b)
	var own := Color(0, 0, 0, 0)
	var m := 0
	for y in lamp.get_height():
		for x in lamp.get_width():
			var c := lamp.get_pixel(x, y)
			if c.a > 0.5:
				own += Color(c.r, c.g, c.b, 0.0)
				m += 1
	var lamp_mean := Color(own.r / m, own.g / m, own.b / m)
	_ok("The lamp's own pixels (lit, frame 0) read warm: %s" % _say(lamp_mean), lamp_mean.h * 360.0 < 60.0 and lamp_mean.r > lamp_mean.b)


## W5.
func _reach() -> void:
	var img := TP.paint_part("town.building.hall.reach")
	var off := Vector2i(128, 24)   # the part's frame_at: frame px less this is the picture's px
	var brass := 0
	for y in range(0, 120 - off.y):
		for x in range(160 - off.x, img.get_width()):
			var c := img.get_pixel(x, y)
			if c.a > 0.5 and (c.is_equal_approx(TP.BRASS["lit"]) or c.is_equal_approx(TP.BRASS["sh"]) or c.is_equal_approx(TP.BRASS["hi"])):
				brass += 1
	_ok("The Reach's curl carries brass lashings: %d brass px over the curl (above frame row 120, right of x 160)" % brass, brass >= 20)
	var at_shaft := _ray(img, off, 200.0)
	var at_hook := _ray(img, off, 350.0)
	_ok("The curl tapers toward the hook: %d px thick at 200 degrees, %d at 350 (%.2f)" % [at_shaft, at_hook, float(at_hook) / maxf(1.0, at_shaft)],
		at_hook < at_shaft)


## The curl's thickness at `a` degrees: the unbroken opaque run along the ray from its middle (frame 182, 84) that
## holds radius 32, the curl's centre line, in distinct px.
static func _ray(img: Image, off: Vector2i, a: float) -> int:
	var cells: Array = []
	for k in range(0, 641):
		var r := k / 10.0
		var p := Vector2i((Vector2(182, 84) + Vector2(cos(deg_to_rad(a)), sin(deg_to_rad(a))) * r).round()) - off
		if cells.is_empty() or cells[cells.size() - 1][0] != p:
			var inside := p.x >= 0 and p.y >= 0 and p.x < img.get_width() and p.y < img.get_height()
			cells.append([p, inside and img.get_pixel(p.x, p.y).a > 0.5, r])
	var mid := 0
	for i in cells.size():
		if float(cells[i][2]) <= 32.0:
			mid = i
	if not cells[mid][1]:
		return 0
	var a0 := mid
	while a0 > 0 and cells[a0 - 1][1]:
		a0 -= 1
	var a1 := mid
	while a1 < cells.size() - 1 and cells[a1 + 1][1]:
		a1 += 1
	return a1 - a0 + 1


## W6.
func _post() -> void:
	for state: String in ["strung", "waiting", "quiet"]:
		var img := TP.paint_part("town.prop.hall.wayline_post", state)
		var colours := {}
		for y in range(14, 29):
			for x in range(15, 23):
				var c := img.get_pixel(x, y)
				if c.a > 0.5:
					colours[c.to_html(false)] = true
		var frame := img.get_pixel(16, 23).is_equal_approx(TP.BRASS["lit"]) and img.get_pixel(22, 23).is_equal_approx(TP.BRASS["sh"])
		var bar := img.get_pixel(19, 23).is_equal_approx(TP.BRASS["mid"])
		var cap := img.get_pixel(18, 19).is_equal_approx(TP.BRASS["lit"]) and img.get_pixel(18, 18).is_equal_approx(TP.BRASS["hi"])
		var base := img.get_pixel(18, 27).is_equal_approx(TP.BRASS["lit"])
		var mark := ""
		var marked := false
		match state:
			"strung":
				var hot := 0
				for y in range(20, 27):
					for x in range(16, 23):
						hot += 1 if img.get_pixel(x, y).is_equal_approx(TP.AMBER["hi"]) else 0
				mark = "%d px of hot spot" % hot
				marked = hot >= 4
			"waiting":
				marked = img.get_pixel(17, 21).is_equal_approx(TP.STONE["mid"]) and img.get_pixel(18, 24).is_equal_approx(TP.TIMB["dk"])
				mark = "cold glass with a glint" if marked else "no glint"
			"quiet":
				var crack := 0
				for y in range(20, 27):
					for x in range(16, 23):
						crack += 1 if img.get_pixel(x, y).is_equal_approx(TP.INK) else 0
				mark = "%d px of crack in grey glass" % crack
				marked = crack >= 3 and img.get_pixel(18, 24).is_equal_approx(TP.STONE["sh"])
		_ok("The post's lantern, %s: frame %s, bar %s, cap %s, base %s, %s; %d colours in the lantern" % [state, frame, bar, cap, base, mark, colours.size()],
			frame and bar and cap and base and marked and colours.size() >= 6)


## W7.
func _stair() -> void:
	var img := TP.paint_part("town.prop.hall.rise_stair")
	for r: Array in TP.STAIR_ROOTS:
		var at: Vector2 = r[0]
		var step := int(at.y) / 12
		var top := 999
		var on_tread := 0
		var lo := int(at.x) - 4
		var hi := int(at.x) + 4
		for y in img.get_height():
			for x in range(maxi(0, lo), mini(img.get_width(), hi + 1)):
				var c := img.get_pixel(x, y)
				var root := false
				for k: String in TP.ROOTC:
					root = root or c.is_equal_approx(TP.ROOTC[k])
				if not root:
					continue
				top = mini(top, y)
				if y >= step * 12 and y <= step * 12 + 7:
					on_tread += 1
		var lip := img.get_pixel(int(at.x), int(at.y) - 2).is_equal_approx(TP.INK)
		_ok("The stair root at %s breaks out of step %d's riser: its top row %d (riser rows %d to %d), %d px on that step's tread, ink lip %s" % [str(at),
			step, top, step * 12 + 8, step * 12 + 10, on_tread, lip], top >= step * 12 + 8 and top <= step * 12 + 11 and on_tread == 0 and lip)
