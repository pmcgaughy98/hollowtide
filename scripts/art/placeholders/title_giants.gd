extends RefCounted
## The two giants on the title, layout A (Claude, 2026-10-28). Preston picked layout A of the vast-scale design, asked
## for the great tree's "leaves and branch top", then: "Remove the older tower from Title A too, its covering the new
## tower you made behind it that looks better". title_highbank.gd calls these two painters on its 384 x 216 picture.
##
## Design and numbers: docs/design/vast-scale-2026-10-27/VAST_SCALE_DESIGN.md. The mock this follows is
## final/title_1x.png, drawn by final/final_mocks.py (title_tree, Dome, paint_tower, draw_root and mock_title there);
## hn, vn and the root painter are the same sums, so the same pixels come out. Heights and widths are in tiles of 24 px.
##
## The Wayline Tower is 480 tiles tall, so only its foot fits here: the round Stack, 34 tiles wide, runs off the top
## and the right edge and comes down to the Rise on two plinth steps, with the doors at the top of the Rise stair. The
## great tree stands 340 tiles further off: a short stretch of trunk over the far hills, four limbs, and its whole crown
## as one even dome behind the town. Both are proposals in the design; "the great tree" and "the Wayline Tower" are the
## only names used.

# ---------------------------------------------------------------------------------------------------------------------
# The giant Tower (camera: level, 2.6 px a tile)

const TOWER_PPT := 2.6                     # px a tile: the Stack's 34 tiles come out 88 px wide
const TOWER_AXIS := 357.0                  # the Stack's middle; its west face lands on x 313, right of the shade's end
const FOOT := 168                          # the camera's ground row: the plinth's lowest row is 167, the Rise's grass
const SEED := 6                            # which windows are lit (the mock's seed)
## The bands that reach this picture, bottom up: [from tile, to tile, width in tiles, name]. Plinth step 1 is
## boulder footing, step 2 big ashlar, and the Stack's first section runs to tile 114, far above the frame.
const BANDS := [[0.0, 8.0, 52.0, "P1"], [8.0, 16.0, 42.0, "P2"], [16.0, 114.0, 34.0, "A"]]
## Each band's stone, lit to dark (the Tower's own colours, wayline_tower palette).
const STONE := {
	"P1": [Color("#c7a378"), Color("#9c8c68"), Color("#8e7f5e"), Color("#5d4b34")],
	"P2": [Color("#ccb290"), Color("#c7a378"), Color("#9c8c68"), Color("#5d4b34")],
	"A": [Color("#e6c697"), Color("#ccb290"), Color("#c49b69"), Color("#8e7f5e")],
}
const ROOT_RAMP := [Color("#23180e"), Color("#3f2716"), Color("#663f23"), Color("#8c6545"), Color("#b06b3d"),
	Color("#c49b69")]
const MOSS_RAMP := [Color("#44421a"), Color("#6b6f1d"), Color("#908940"), Color("#c6bb2a")]
const OLIVE := Color("#6b6d45")
const OLIVE_DK := Color("#44421a")
const MOSS_LIT := Color("#908940")
const BRASS_HI := Color("#f2d27a")
const BRASS := Color("#d4a94c")
const BRASS_MID := Color("#a37a32")
const BRASS_DK := Color("#6b4f1f")
const LIGHT_HI := Color("#fbd490")         # a lit window or door
const LIGHT := Color("#f1c177")
const LIGHT_DK := Color("#c49243")
const BARK_DK := Color("#3f2716")
const BARK := Color("#7c4a26")
const FRAME := Color("#5d4b34")            # door and window frames, the brace
const KEYSTONE := Color("#e6c697")
const WISP := Color("#9f946d")
const WISP_DK := Color("#8e7f5e")

## The Low Reel: a ring deck round the Stack at 34 tiles up (row 80), sticking out west of the face from x 300, where
## the town's waylines leave from the reel's sheaves.
const DECK_Y := 80
const DECK_X0 := 300

# ---------------------------------------------------------------------------------------------------------------------
# The great tree (camera: level, 0.36 px a tile, 340 tiles further off)

const TREE_PPT := 0.36
const TREE_AXIS := 209.0                   # the trunk's middle
const TREE_FOOT := 150.0                   # its foot row, hidden behind the ridge's woods
const TREE_SEED := 5
const TRUNK_W := 100.0                     # tiles across, flaring to FLARE_W at the ground
const FLARE_W := 260.0
const TREE_H := 400.0                      # to the crown's top
const CROWN_W := 440.0                     # the crown's widest line, centred CROWN_OFF tiles east of the trunk
## Centred on the trunk (Preston, 2026-10-28: the left side reached so much farther out than the right that the trunk
## looked off to one side; the mock had it 65 tiles west).
const CROWN_OFF := 0.0
const UNDER_RIM := 140.0                   # the crown's lowest leaves, at its rim
const UNDER_C := 165.0                     # its underside where the trunk goes in
const BELLY := 30.0                        # the widest line, this many tiles over the rim
## The limbs from the trunk into the crown: points in tiles (across, up), then their width at the trunk and the tip.
const LIMBS := [
	[[Vector2(-6, 112), Vector2(-30, 132), Vector2(-70, 150), Vector2(-110, 169)], 26.0, 12.0],
	[[Vector2(8, 120), Vector2(34, 140), Vector2(70, 156), Vector2(96, 167)], 22.0, 10.0],
	[[Vector2(0, 128), Vector2(-12, 150), Vector2(-34, 172)], 20.0, 12.0],
	[[Vector2(20, 125), Vector2(60, 136), Vector2(150, 150)], 14.0, 8.0],   # east, so the limbs spread both ways
]
const TREE_BARK := [Color("#23180e"), Color("#3f2716"), Color("#5d4b34"), Color("#7c4a26"), Color("#b8793e")]
const LEAF_BODY := Color("#1d2925")        # the crown's dark body: all it shows under the wordmark
const LEAF_RIM := Color("#33524e")         # its 1 px teal rim against the sky under the wordmark
const LEAF_SH := Color("#303e37")
const LEAF_MID := Color("#44421a")
const LEAF_LIT := Color("#6b6d45")
const LEAF_HI := Color("#908940")
## The wordmark's calm box (x 90 to 295, rows 0 to 51): the crown keeps to its body and rim colours there.
const CALM := Rect2i(90, 0, 206, 52)


# =====================================================================================================================
# The great tree

## Trunk, limbs, then the crown, painted only where the sky or the far hills are (title_highbank.gd calls this after
## _far_hills and before the clouds, so the cloud streaks stay in front of it).
static func great_tree(img: Image) -> void:
	var under: Image = img.duplicate()   # what was there before: the tree goes only on sky and far-hill pixels
	var bg := func(x: int, y: int) -> bool:
		return x >= 0 and y >= 0 and x < under.get_width() and y < under.get_height() and under.get_pixel(x, y).a > 0.0
	_trunk(img, bg)
	_limbs(img, bg)
	_crown(img, bg)


## The trunk's half width in tiles at a height: 50 up the bole, flaring to 130 at the ground (final_mocks trunk_hw).
static func trunk_hw(h: float) -> float:
	if h >= 45.0:
		return TRUNK_W / 2.0 - 5.0 * (h - 45.0) / 130.0
	return TRUNK_W / 2.0 + (FLARE_W / 2.0 - TRUNK_W / 2.0) * pow((45.0 - h) / 45.0, 2.4)


## The trunk, row by row: round, lit from the sunset on the west, long furrows down it, moss on the lit side. Only its
## stretch between the limbs and the far hills shows; the ridge's woods hide its foot.
static func _trunk(img: Image, bg: Callable) -> void:
	var y_top := int(TREE_FOOT - TREE_PPT * (UNDER_C + 10.0))
	for y in range(y_top, int(TREE_FOOT) + 2):
		var h := (TREE_FOOT - y - 0.5) / TREE_PPT
		if h < 0.0:
			continue
		var hwp := (trunk_hw(h) + 2.5 * sin(h / 11.0 + TREE_SEED)) * TREE_PPT
		for x in range(int(TREE_AXIS - hwp), int(TREE_AXIS + hwp) + 1):
			if not bg.call(x, y):
				continue
			var u := clampf((x + 0.5 - TREE_AXIS) / hwp, -1.0, 1.0)
			var b := -u * 0.7 + sqrt(maxf(0.0, 1.0 - u * u)) * 0.6
			var k := 4 if b > 0.88 else (3 if b > 0.6 else (2 if b > 0.3 else (1 if b > -0.1 else 0)))
			if fposmod(u * 6.0 + 0.5 * sin(h / 23.0), 1.0) < 0.2 and k > 0:
				k -= 1   # a long furrow
			var c: Color = TREE_BARK[k]
			if -u > 0.25 and vn(x, h * TREE_PPT, 3.0, TREE_SEED + 8) > 0.7:
				c = OLIVE if b > 0.7 else OLIVE_DK   # moss on the sunset side
			img.set_pixel(x, y, c)


## Four limbs from the trunk up into the crown, tapering; the low sun lights them from below.
static func _limbs(img: Image, bg: Callable) -> void:
	for limb in LIMBS:
		var pts: Array = []
		for p: Vector2 in limb[0]:
			pts.append(Vector2(TREE_AXIS + TREE_PPT * p.x, TREE_FOOT - TREE_PPT * p.y))
		var path := catmull(pts, 20)
		var w0: float = limb[1]
		var w1: float = limb[2]
		for i in path.size():
			var cx := path[i].x
			var cy := path[i].y
			var r := maxf(0.7, (w0 + (w1 - w0) * i / path.size()) * TREE_PPT / 2.0)
			for yy in range(int(cy - r) - 1, int(cy + r) + 2):
				for xx in range(int(cx - r) - 1, int(cx + r) + 2):
					if not bg.call(xx, yy) or pow(xx + 0.5 - cx, 2) + pow(yy + 0.5 - cy, 2) > r * r:
						continue
					var q := (yy + 0.5 - cy) / maxf(r, 0.5)
					img.set_pixel(xx, yy, TREE_BARK[0] if q < -0.45 else (TREE_BARK[1] if q < 0.35 else BARK))


## The crown: one even dome (Dome), its leaves in small clusters on a staggered grid, each lower cluster over the one
## above so every cluster shows a lit top arc and a dark lower edge. Lit low from the sunset side, so the lower west
## part is the bright one. The texture fades out toward the wordmark's calm box, where the crown is only its dark body
## and a teal rim along its top.
static func _crown(img: Image, bg: Callable) -> void:
	var dm := Dome.new(func(arc: float) -> float: return vn(arc, 0.0, 30.0, TREE_SEED))
	# The leaf clusters: rows every 6 px, columns every 8 px, odd rows shifted half a step, each nudged by a hash
	# (the mock used Python's random here; any steady jitter reads the same), 4 to 6 px tall and a little wider.
	var leaves: Array = []
	var j := 0
	for gy in range(dm.y0, dm.y1 + 4, 6):
		for gx in range(dm.x0 - 4, dm.x1 + 5, 8):
			var cy := gy + hn(gx, j, 23) * 3.0 - 1.5
			var cx := gx + (4 if j % 2 == 1 else 0) + hn(j, gx, 29) * 4.0 - 2.0
			leaves.append(Vector3(cy, cx, 4.0 + 2.0 * hn(gx + 7, j + 3, 37)))
		j += 1
	leaves.sort_custom(func(a: Vector3, b: Vector3) -> bool: return a.x < b.x or (a.x == b.x and a.y < b.y))
	var own := {}   # pixel -> Vector3(cluster, dx, dy): the lowest cluster over a pixel owns it
	for i in leaves.size():
		var cy: float = leaves[i].x
		var cx: float = leaves[i].y
		var r: float = leaves[i].z
		for yy in range(int(cy - r) - 1, int(cy + r) + 2):
			for xx in range(int(cx - r * 1.15) - 1, int(cx + r * 1.15) + 2):
				var dx := (xx + 0.5 - cx) / (r * 1.15)
				var dy := (yy + 0.5 - cy) / r
				if dx * dx + dy * dy <= 1.0 and dm.has(xx, yy):
					own[Vector2i(xx, yy)] = Vector3(i, dx, dy)
	var none := Vector3(-1, 0, 0)
	for yy in range(maxi(0, dm.y0), mini(img.get_height(), dm.y1)):
		for xx in range(maxi(0, dm.x0), mini(img.get_width(), dm.x1)):
			if not dm.has(xx, yy) or not bg.call(xx, yy):
				continue
			if CALM.has_point(Vector2i(xx, yy)):
				img.set_pixel(xx, yy, LEAF_RIM if not dm.has(xx, yy - 1) else LEAF_BODY)
				continue
			var sun := -dm.gd(xx)                    # 1 at the west rim, where the low sun is
			var gv := dm.gv(yy)                      # 0 at the lowest leaves, 1 at the top
			var l: Vector3 = own.get(Vector2i(xx, yy), none)
			var up: Vector3 = own.get(Vector2i(xx, yy - 1), Vector3(-2, 0, 0))
			var dn: Vector3 = own.get(Vector2i(xx, yy + 1), Vector3(-2, 0, 0))
			var score := sun * 0.55 + (0.22 - gv) * 1.5 + (-l.z * 0.6 - l.y * 0.5) * 0.3
			if up.x != l.x and l.z < -0.2 and l.y < 0.6:
				score += 0.35                        # a cluster's lit top arc
			if dn.x != l.x and l.z > 0.2:
				score -= 0.4                         # its lower edge, in the shadow of the one below
			if not dm.has(xx, yy - 1) or not dm.has(xx - 1, yy):
				score += 0.3                         # the dome's top and west edges catch the light
			score -= 0.8 * maxf(0.0, (CALM.end.y + 16 - yy) / 16.0)   # fade to the calm box's flat body
			var c := LEAF_BODY
			if score >= 0.8:
				c = LEAF_HI
			elif score >= 0.45:
				c = LEAF_LIT
			elif score >= 0.15:
				c = LEAF_MID if sun > 0.1 else LEAF_SH
			elif score >= -0.2:
				c = LEAF_SH
			if not dm.has(xx, yy + 1):
				c = LEAF_MID if sun > 0.2 else LEAF_BODY   # the underside
			img.set_pixel(xx, yy, c)


## The crown's outline on screen (final_mocks.py Dome): 440 tiles across at its widest line, which is BELLY tiles over
## the rim; its top at 400 tiles, its lowest leaves at the rim (140), the underside rising to 165 where the trunk goes
## in. Above the widest line a half ellipse with a small rounded leaf break every leaf_p px all the way round; below it
## a shallow belly with hanging lobes. Drawn level and symmetric, so it reads as one even dome. Worked out once into a
## mask, since each pixel's colour asks about its neighbours too. arc_noise is vn along the outline (an inner class
## cannot call the outer script's static functions), which jitters where the leaf breaks fall.
class Dome:
	var cx: float
	var a: float
	var yw: float                  # the widest line
	var yr: float                  # the lowest leaves
	var b: float                   # widest line to top
	var c: float                   # widest line to the lowest leaves
	var notch: float               # how far the underside rises where the trunk goes in
	var leaf_p: float
	var lobe_p: float
	const LEAF_D := 2.0
	const LOBE_D := 3.0
	var x0: int
	var x1: int
	var y0: int
	var y1: int
	var _mask := PackedByteArray()
	var _arc_noise: Callable

	func _init(arc_noise: Callable) -> void:
		_arc_noise = arc_noise
		var sx := func(across: float) -> float: return TREE_AXIS + TREE_PPT * across
		var sy := func(up: float) -> float: return TREE_FOOT - TREE_PPT * up
		var xl: float = sx.call(CROWN_OFF - CROWN_W / 2.0)
		var xr: float = sx.call(CROWN_OFF + CROWN_W / 2.0)
		cx = (xl + xr) / 2.0
		a = (xr - xl) / 2.0
		yw = sy.call(UNDER_RIM + BELLY)
		yr = sy.call(UNDER_RIM)
		b = yw - float(sy.call(TREE_H))
		c = yr - yw
		notch = yr - float(sy.call(UNDER_C))
		leaf_p = maxf(5.0, a / 9.0)
		lobe_p = maxf(7.0, a / 6.5)
		x0 = int(cx - a) - 1
		x1 = int(cx + a) + 2
		y0 = int(yw - b) - 1
		y1 = int(yr + LOBE_D) + 2
		_mask.resize((x1 - x0 + 1) * (y1 - y0 + 1))
		for y in range(y0, y1 + 1):
			for x in range(x0, x1 + 1):
				_mask[(y - y0) * (x1 - x0 + 1) + (x - x0)] = 1 if _inside(x, y) else 0

	## True when the pixel is leaves.
	func has(x: int, y: int) -> bool:
		if x < x0 or x > x1 or y < y0 or y > y1:
			return false
		return _mask[(y - y0) * (x1 - x0 + 1) + (x - x0)] == 1

	func gd(x: int) -> float:
		return (x + 0.5 - cx) / a          # -1 at the west edge, 1 at the east

	func gv(y: int) -> float:
		return (yr - y - 0.5) / (yr - yw + b)   # 0 at the lowest leaves, 1 at the top

	func _inside(x: int, y: int) -> bool:
		if absf(x + 0.5 - cx) >= a or y + 0.5 > _bottom(x):
			return false
		return y + 0.5 > yw or _upper(x, y)

	## Inside the top half ellipse, less a leaf break: a rounded bump every leaf_p px along the arc.
	func _upper(x: int, y: int) -> bool:
		var nx := (x + 0.5 - cx) / a
		var ny := (yw - y - 0.5) / b
		var rho := sqrt(nx * nx + ny * ny)
		if rho >= 1.0:
			return false
		var arc := atan2(ny, nx) * (a + b) / 2.0
		var u: float = arc / leaf_p + 0.5 + 0.25 * (float(_arc_noise.call(arc)) - 0.5)
		var f := u - floorf(u) - 0.5       # -0.5 to 0.5 across one leaf bump, 0 on its crest
		return rho <= 1.0 - LEAF_D * pow(2.0 * f, 2) / ((a + b) / 2.0)

	## The underside: the belly's half ellipse, raised in the middle where the trunk goes in, with hanging lobes.
	func _bottom(x: int) -> float:
		var d := (x + 0.5 - cx) / a
		if absf(d) >= 1.0:
			return yw
		var lobes := LOBE_D * absf(sin(PI * (x + 0.5 - cx) / lobe_p + 0.6))
		return yw + (c + lobes) * sqrt(1.0 - d * d) - notch * exp(-pow(d / 0.3, 2))


# =====================================================================================================================
# The Wayline Tower

## The pixels the Tower must leave alone: the Rise from row 168 down, and the houses, hedge and street trees in front
## of it (west of x 266 from row 143, west of x 284 from row 146, where the garden tree beside the last house stands).
static func keep(x: int, y: int) -> bool:
	return y >= FOOT or (x < 266 and y >= 143) or (x < 284 and y >= 146)


## Where a wayline ties on at the reel: the reel's sheaves, at the deck's west end, stepped so the lines do not merge.
static func sheave(i: int) -> Vector2:
	return Vector2(DECK_X0 + 1 + 2 * i, DECK_Y - 2 - i)


## The giant Tower's foot in this picture: the Stack and its plinth, brass rails, the doors over the Rise stair at
## door_x, the hall windows, the great tree's root up the west face, the Low Reel, and two sunset wisps across it.
## Pixels at x 312 or more above row 50 are painted bright here; title_highbank.gd's _preshade darkens them after.
static func tower(img: Image, door_x: int) -> void:
	_stack(img)
	var y8 := roundi(_sy(8.0))
	var y16 := roundi(_sy(16.0))
	# A brass rail along each step's ledge, with a post every 6 px.
	for rail in [[y8 - 3, roundi(TOWER_AXIS - 26.0 * TOWER_PPT)], [y16 - 3, roundi(TOWER_AXIS - 21.0 * TOWER_PPT)]]:
		var yr: int = rail[0]
		for x in range(int(rail[1]) + 1, img.get_width()):
			img.set_pixel(x, yr, BRASS if x < TOWER_AXIS else BRASS_MID)
			if (x - int(TOWER_AXIS)) % 6 == 0:
				img.set_pixel(x, yr + 1, BRASS_DK)
				img.set_pixel(x, yr + 2, BRASS_DK)
	var door := _doors(img, door_x, y8, y16)
	var root_ok := func(x: int, y: int) -> bool: return not keep(x, y) and not door.has(Vector2i(x, y))
	# The great tree's root: it runs underground from the tree and comes up out of the Rise at the first step's west
	# corner (its path starts below the ground row, so the ground cuts it level), climbs the corner, up the second
	# step's west side and onto the Stack's west face, off the top. Tied with a brass band at each step's top.
	# (Preston, 2026-10-28: it used to come in from behind the gardens and looked cut off and floating.)
	var root := _root(img, [Vector2(290, 174), Vector2(292, 163), Vector2(295, 152), Vector2(299, 142),
		Vector2(304, 133), Vector2(310, 123), Vector2(315, 108), Vector2(317, 86), Vector2(317, 60), Vector2(315, 34),
		Vector2(317, 10), Vector2(319, -10)], 13.0, 8.0, Vector2(-0.85, -0.5), 12, 0.26, root_ok, 0.08, true)
	# Where it comes out of the ground: short roots gripping the Rise either side of it.
	for pts in [[Vector2(289, 165), Vector2(286, 167), Vector2(283, 169)],
			[Vector2(297, 164), Vector2(303, 166), Vector2(309, 168)]]:
		_root(img, pts, 3.0, 1.2, Vector2(-0.85, -0.5), 31, 0.0, root_ok, 0.0, true)
	for y in [y8, y16]:
		for x in range(284, 330):
			if root.has(Vector2i(x, y)):
				img.set_pixel(x, y, BRASS)
	# Two thin rootlets along cornices.
	for pts in [[Vector2(320, 105), Vector2(330, 105), Vector2(339, 106), Vector2(345, 107)],
			[Vector2(319, 43), Vector2(328, 43), Vector2(336, 44), Vector2(341, 45)]]:
		_root(img, pts, 2.2, 0.8, Vector2(-0.3, -0.95), int(pts[0].y), 0.0, root_ok, 0.0, false)
	_low_reel(img, root_ok)
	_wisps(img)


## The tile height at a row's middle, and a height's row (the camera looks level).
static func _sy(t: float) -> float:
	return FOOT - TOWER_PPT * t


## The plinth's two steps and the Stack, row by row: round, lit from the sunset on the west, a faint line each story,
## a cornice every 3 stories catching the light with moss under it, and porthole windows climbing a spiral stair (the
## drum's motif), some lit. The step tops are mossy lips, as the bands' era lips are on the whole Tower.
static func _stack(img: Image) -> void:
	var s := TOWER_PPT
	for y in range(0, FOOT):
		var t := (FOOT - y - 0.5) / s
		if t < 0.0:
			continue
		var band: Array = []
		for bd in BANDS:
			if t >= bd[0] and t < bd[1]:
				band = bd
		if band.is_empty():
			continue
		var m: String = band[3]
		var hw: float = float(band[2]) * s / 2.0
		var ramp: Array = STONE[m]
		var story := int(t / 4.0)
		var tin := fmod(t, 4.0)
		var xa := roundi(TOWER_AXIS - hw)
		var xb := maxi(xa + 1, roundi(TOWER_AXIS + hw))
		for x in range(xa, mini(xb, img.get_width())):
			if keep(x, y):
				continue
			var u := clampf((x + 0.5 - TOWER_AXIS) / maxf(hw, 0.5), -1.0, 1.0)
			var b := -u * 0.72 + sqrt(maxf(0.0, 1.0 - u * u)) * 0.62
			var k := 0 if b > 0.8 else (1 if b > 0.5 else (2 if b > 0.18 else 3))
			var c: Color = ramp[k]
			if m != "A":
				if fmod(t, 2.0) < 1.0 / s:
					c = ramp[mini(3, k + 1)]                         # the courses of the footing
				if m == "P1" and t < 3.0 and vn(x, y, 3.0, 7) > 0.55:
					c = OLIVE if k < 2 else OLIVE_DK                 # moss at the ground
			else:
				if tin < 1.0 / s and k < 3:
					c = ramp[k + 1]                                  # one faint line a story
				if fmod(t, 12.0) < 1.0:
					c = ramp[maxi(0, k - 1)]                         # a cornice catches the light
				elif fmod(t, 12.0) > 12.0 - 1.0 / s:
					c = ramp[mini(3, k + 1)]
				if tin >= 1.0 and tin <= 2.8 and hn(story, 1, SEED) < 0.8:
					for kk in 7:                                     # porthole windows on a spiral stair
						var ph := story * 0.55 + kk * (TAU / 7.0) + 0.3
						var cph := cos(ph)
						if cph < 0.2:
							continue
						var wx := TOWER_AXIS + sin(ph) * hw
						if absf(x + 0.5 - wx) < maxf(0.5, 0.75 * cph * s):
							var lit := hn(story, kk, SEED + 9) < 0.3
							c = LIGHT_HI if lit else BARK_DK
							if absf(tin - 1.9) < 0.6 / s and absf(x + 0.5 - wx) < 0.6:
								c = LIGHT if lit else FRAME                  # the cross bar
				if fmod(t, 12.0) > 9.5 and vn(x, t, 2.5, 11) > 0.78:
					c = MOSS_LIT if k < 2 else OLIVE                 # moss under a cornice
			img.set_pixel(x, y, c)
		if m == "A" and fmod(t, 12.0) < 1.0 / s:   # the cornice's lip, a pixel wider than the shaft
			for x in [xa - 1, roundi(TOWER_AXIS + hw)]:
				if x >= 0 and x < img.get_width():
					img.set_pixel(x, y, ramp[1])
	# The step tops: a mossy lip a pixel proud of each step's face.
	for bd in BANDS:
		var y := roundi(_sy(bd[1]))
		if y < 0:
			continue
		var hw: float = float(bd[2]) * s / 2.0 + maxf(1.0, s)
		for x in range(roundi(TOWER_AXIS - hw), mini(roundi(TOWER_AXIS + hw) + 1, img.get_width())):
			if x >= 0 and not keep(x, y):
				img.set_pixel(x, y, MOSS_LIT)


## The doors at the top of the Rise stair (open, lit inside, a keystone and a lamp each side) and three hall windows on
## the upper step, one dark. Returns the door's pixels, which the root must not cover.
static func _doors(img: Image, dx: int, y8: int, y16: int) -> Dictionary:
	var door := {}
	for y in range(y8 + 6, FOOT):
		var half := 5 if y > y8 + 7 else (4 if y == y8 + 7 else 2)   # an arched top
		for x in range(dx - half, dx + half + 1):
			door[Vector2i(x, y)] = true
	for p: Vector2i in door:
		if p.x <= dx - 4 or p.x >= dx + 4:
			img.set_pixelv(p, BARK)                   # the open leaves
		else:
			img.set_pixelv(p, LIGHT_HI if p.y < FOOT - 4 else LIGHT)
	for p: Vector2i in door:
		for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1)]:
			if not door.has(p + o):
				img.set_pixelv(p + o, FRAME)
	img.set_pixel(dx, y8 + 4, KEYSTONE)
	for lx in [dx - 9, dx + 9]:                       # a lamp each side of the doors
		img.set_pixel(lx, y8 + 9, BRASS_DK)
		img.set_pixel(lx, y8 + 10, LIGHT_HI)
		img.set_pixel(lx, y8 + 11, LIGHT_DK)
	for i in 3:
		var wx := dx - 13 + 13 * i
		for y in range(y16 + 6, y16 + 11):
			for x in range(wx - 1, wx + 2):
				if y == y16 + 6 and x != wx:
					continue                          # the arched top
				img.set_pixel(x, y, BARK_DK if i == 0 else LIGHT_HI)
		for y in range(y16 + 7, y16 + 12):
			img.set_pixel(wx - 2, y, FRAME)
			img.set_pixel(wx + 2, y, FRAME)
		img.set_pixel(wx, y16 + 5, FRAME)
	return door


## The Low Reel at 34 tiles up: a ring deck round the Stack with a rail and posts, route lanterns under its rim, a
## brace from the face out under the deck's west end, and the reel, a spoked wheel standing on the deck.
static func _low_reel(img: Image, ok: Callable) -> void:
	var w := img.get_width()
	var yd := DECK_Y
	for x in range(DECK_X0, w):
		var west := x < TOWER_AXIS - 20.0
		img.set_pixel(x, yd - 1, BRASS_HI if west else BRASS)
		img.set_pixel(x, yd, BRASS if west else BRASS_MID)
		img.set_pixel(x, yd + 1, BRASS_MID)
		img.set_pixel(x, yd + 2, BRASS_DK)
		img.set_pixel(x, yd - 4, BRASS if x < TOWER_AXIS else BRASS_MID)
		if (x - DECK_X0) % 5 == 0:
			img.set_pixel(x, yd - 3, BRASS_DK)
			img.set_pixel(x, yd - 2, BRASS_DK)
		if (x - DECK_X0) % 9 == 4 and x < w - 2:      # route lanterns under the rim
			img.set_pixel(x, yd + 3, BRASS_DK)
			img.set_pixel(x, yd + 4, LIGHT_HI)
	var face := roundi(TOWER_AXIS - 17.0 * TOWER_PPT)
	for i in 7:
		var x := face - 1 - 2 * i
		var y := yd + 9 - i
		if x > DECK_X0 and ok.call(x, y):
			img.set_pixel(x, y, FRAME)
			img.set_pixel(x - 1, y, FRAME)
	var rc := Vector2(DECK_X0 + 6, yd - 9)
	var rr := 5.5
	for y in range(int(rc.y - rr) - 1, int(rc.y + rr) + 2):
		for x in range(int(rc.x - rr) - 1, int(rc.x + rr) + 2):
			var d := Vector2(x + 0.5, y + 0.5).distance_to(rc)
			if d >= rr - 1.3 and d <= rr:
				img.set_pixel(x, y, BARK if -(x + 0.5 - rc.x) + (rc.y - y - 0.5) > 0.0 else BARK_DK)
			elif d < rr - 1.3:
				if d < 1.2:
					img.set_pixel(x, y, BRASS)            # the hub
				elif absf(sin(3.0 * atan2(y + 0.5 - rc.y, x + 0.5 - rc.x))) < 0.28:
					img.set_pixel(x, y, FRAME)            # a spoke
	for y in range(int(rc.y + rr), yd - 1):            # its post down to the deck
		img.set_pixel(int(rc.x), y, BARK_DK)


## Two thin sunset wisps across the Stack, so it stands in the sky rather than against it.
static func _wisps(img: Image) -> void:
	for wisp in [[22, 3], [41, 5]]:
		var wy: int = wisp[0]
		var sd: int = wisp[1]
		for x in range(300, img.get_width()):
			if vn(x, wy, 9.0, sd) < 0.32:
				continue
			var yy := wy + int(1.5 * sin(x / 31.0 + sd))
			img.set_pixel(x, yy, WISP if vn(x, 0.0, 4.0, sd + 1) > 0.5 else WISP_DK)
			if vn(x, 1.0, 6.0, sd + 2) > 0.55:
				img.set_pixel(x, yy + 1, FRAME)


## One root of the great tree along a path (final_mocks.py draw_root): it tapers from w0 to w1 px, swells and pinches,
## shows long strands of bark along its length with furrows between them, moss on its sunward side and a dark rim.
## ok(x, y) says where it may paint. Returns every pixel it painted (rim included).
static func _root(img: Image, pts: Array, w0: float, w1: float, light: Vector2, seed: int, moss: float, ok: Callable,
		swell: float, outline: bool) -> Dictionary:
	var path := catmull(pts, 40)
	var n := path.size()
	var l := light.normalized()
	var w := img.get_width()
	var h := img.get_height()
	var owner := {}   # pixel -> [lit, across, path index, radius]
	for i in n:
		var cx := path[i].x
		var cy := path[i].y
		var r := (w0 + (w1 - w0) * float(i) / maxi(1, n - 1)) / 2.0 * (1.0 + swell * (2.0 * vn(i, 0.0, 23.0, seed) - 1.0))
		var j := mini(n - 1, i + 1)
		var tg := path[j] - path[maxi(0, j - 1)]
		var tl := tg.length() if tg.length() > 0.0 else 1.0
		var nrm := Vector2(-tg.y / tl, tg.x / tl)
		for yy in range(int(cy - r) - 1, int(cy + r) + 2):
			for xx in range(int(cx - r) - 1, int(cx + r) + 2):
				var dx := xx + 0.5 - cx
				var dy := yy + 0.5 - cy
				if dx * dx + dy * dy > r * r or xx < 0 or yy < 0 or xx >= w or yy >= h or not ok.call(xx, yy):
					continue
				var across := (dx * nrm.x + dy * nrm.y) / maxf(r, 0.5)
				var key := Vector2i(xx, yy)
				if owner.has(key) and absf(across) > absf(owner[key][1]):
					continue
				owner[key] = [(dx * l.x + dy * l.y) / maxf(r, 0.5), across, i, r]
	for key: Vector2i in owner:
		var lit: float = owner[key][0]
		var across: float = owner[key][1]
		var i: int = owner[key][2]
		var r: float = owner[key][3]
		var k := 5 if lit > 0.62 else (4 if lit > 0.2 else (3 if lit > -0.25 else (2 if lit > -0.65 else 1)))
		var nb := maxi(3, int(r / 1.8))
		var sb := (across + 1.0) / 2.0 * nb
		var band := int(sb)
		var strand := 50 + int(r * 5.0)
		if hn(band, (i + band * 17) / strand, seed) > 0.55:
			k = maxi(1, k - 1)                        # a long darker strand of bark
		if r > 3.5 and absf(fposmod(sb, 1.0) - 0.5) > 0.4 and hn(band, (i + band * 29) / (strand / 2), seed + 3) > 0.35:
			k = maxi(1, k - 1)                        # the furrow between strands
		var c: Color = ROOT_RAMP[k]
		if lit > 0.15 and vn(key.x, key.y, 5.0, seed + 11) > 1.0 - moss:
			c = MOSS_RAMP[2 if lit > 0.55 else 1]
		img.set_pixelv(key, c)
	var painted := owner.duplicate()
	if outline:
		for key: Vector2i in owner:
			for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var q: Vector2i = key + o
				if not owner.has(q) and q.x >= 0 and q.y >= 0 and q.x < w and q.y < h and ok.call(q.x, q.y):
					img.set_pixelv(q, ROOT_RAMP[0])
					painted[q] = true
	return painted


# =====================================================================================================================
# Shared sums (final_mocks.py hn, vn and catmull), so the noise matches the mock's

## A hash of whole numbers to 0..1.
static func hn(x: int, y: int, s: int = 0) -> float:
	var n := (x * 374761393 + y * 668265263 + s * 982451653) & 0xffffffff
	n = ((n ^ (n >> 13)) * 1274126177) & 0xffffffff
	return float((n ^ (n >> 16)) & 0xffff) / 65535.0


## Smooth value noise, 0..1, with features about sc px across.
static func vn(x: float, y: float, sc: float, s: int = 0) -> float:
	var gx := x / sc
	var gy := y / sc
	var x0 := floori(gx)
	var y0 := floori(gy)
	var fx := gx - x0
	var fy := gy - y0
	fx = fx * fx * (3.0 - 2.0 * fx)
	fy = fy * fy * (3.0 - 2.0 * fy)
	var a := hn(x0, y0, s)
	var b := hn(x0 + 1, y0, s)
	var c := hn(x0, y0 + 1, s)
	var d := hn(x0 + 1, y0 + 1, s)
	return a + (b - a) * fx + (c - a) * fy + (a - b - c + d) * fx * fy


## A smooth curve through the points (Catmull-Rom), per samples between each pair, ending on the last point.
static func catmull(pts: Array, per: int) -> PackedVector2Array:
	var out := PackedVector2Array()
	var p: Array = [pts[0]] + pts + [pts[-1]]
	for i in range(1, p.size() - 2):
		var p0: Vector2 = p[i - 1]
		var p1: Vector2 = p[i]
		var p2: Vector2 = p[i + 1]
		var p3: Vector2 = p[i + 2]
		for j in per:
			var t := float(j) / per
			var t2 := t * t
			var t3 := t2 * t
			out.append(0.5 * (2.0 * p1 + (p2 - p0) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2
				+ (3.0 * p1 - p0 - 3.0 * p2 + p3) * t3))
	out.append(pts[-1])
	return out
