extends RefCounted
## The title screen's Highbank, painted in code (Claude, 2026-10-27; Preston: "the town on the title screen has to be
## a real town in game ... I want Wayline Tower to be prominent in the title screen"). The placeholder for the slot
## title.backdrop.highbank (scripts/art/slots/title.gd), which the title draws at 3x over the whole 1152 x 648 screen.
##
## Highbank seen from across the river at the golden hour, the old title village's time of day. Layout A of the vast
## scale design (Claude, 2026-10-28; Preston picked A, then: "Remove the older tower from Title A too, its covering the
## new tower you made behind it that looks better"): the Wayline Tower at its full 480 tiles is far too tall for the
## frame, so only its foot shows at the right, the round Stack running off the top and the right edge and coming down
## to Tower Rise on its stepped plinth, with the doors at the top of the Rise stair, the Low Reel deck where the town's
## waylines leave, and the great tree's root up its west face. The great tree stands behind the town with its whole
## crown under the wordmark. Both giants are painted by title_giants.gd beside this file; its header has the numbers.
## The Street's own houses sit small along the bluff, west to east in their street order, with waylines strung from
## the reel down to posts on their roofs (one hangs slack, the route that went quiet); the Crossroads and the steps sit
## under the Tower's doors, and the bluff face, the switchbacks and the ferry dock drop to the river in front.
##
## The houses are the game's own pictures shrunk to one scale (K): each house's slot image, so a house Codex installs
## shows up here too. Their places come from the Street's area data (scripts/world/areas/street.gd), lined up so the
## Street's north steps sit on the Rise stair's axis, where the old shrunken tower's door was. Everything is snapped to
## PALETTE (the tower's 36 colours plus 11 for sky, hills and water), inside the slot's 48-colour budget. The sky, hills,
## bluff and river are painted here.
##
## The layout keeps clear of the title's text, measured from creature_opening.gd and the wordmark script: the letters
## (x 90 to 295, y 0 to 52 in this picture's px) sit on calm sky, where the great tree's crown is only its dark body and
## a teal rim; the menu's corner (x 21 to 128, y 108 to 199) and the key hint (y 203) on the dark left. The title's
## canopy shade stops at the slot's "shade_end" anchor (312, 50); past that column the top 50 rows are painted already
## shaded (the sky one band darker, the Stack and its root darkened the same way), so no edge shows on the title.

const TP := preload("res://scripts/town/tower_parts.gd")
const Slots := preload("res://scripts/art/art_slots.gd")
const Street := preload("res://scripts/world/areas/street.gd")
const Giants := preload("res://scripts/art/placeholders/title_giants.gd")

const SIZE := Vector2i(384, 216)
const K := 162.0 / 720.0                   # the one scale for the houses (0.225 of their game size)
## Where the old shrunken tower's frame sat (its top-left). The town is still laid out from it: the Rise stair's axis
## is that frame's door axis (street_x), so the houses, stair and switchbacks keep their places.
const TOWER_AT := Vector2i(284, 6)
const SHADE_END := Vector2i(312, 50)       # the canopy shade's corner when the row has no "shade_end" anchor
const SHADE := Color(0.07, 0.10, 0.10)     # creature_opening.gd's canopy shade, laid over at 38%
const STREET_Y := 181                     # the row the houses stand on (their foot row)
const RISE_Y := 165                        # Tower Rise's grass, a step above the Street (the tower's foot is row 167)
const LANE_Y := 182                        # Market Street's lane, rows 182 to 187
const BLUFF_Y := 188                       # the bluff's mossy lip, then its face down to the river
const RIVER_Y := 202                       # the river, to the bottom edge

# Colours not in the tower's palette: five sky bands and the one under them, the village painting's olive gold and
# forest green, the hills and a water sparkle. SKY_D, SKY 0 and SKY 1 are each what the canopy shade (black-teal at
# 38%) makes of the band below them, so the sky past the shade's end can be painted already shaded.
const SKY := [Color("#1e302e"), Color("#263d3a"), Color("#33524e"), Color("#43665a"), Color("#61785c")]
const SKY_D := Color("#192726")
const GLOW := Color("#9f946d")             # the old village painting's olive gold, the band above the horizon
const HILL_FAR := Color("#4f6858")
const HILL := Color("#303e37")             # the village painting's forest green
const HILL_DK := Color("#1d2925")
const WATER_HI := Color("#6fb5a6")
## Every colour this picture uses: the tower's 36 (TowerParts.PALETTE) and the 11 above. 47 of the slot's 48.
const PALETTE := [
	"#0b0e11", "#f5d9a8", "#e6c697", "#ccb290", "#9c8c68", "#5f5e57", "#c7a378", "#8e7f5e", "#3f2716", "#c49b69",
	"#b06b3d", "#8c6545", "#663f23", "#92724b", "#5d4b34", "#23180e", "#c6bb2a", "#908940", "#6b6f1d", "#44421a",
	"#f2d27a", "#d4a94c", "#a37a32", "#6b4f1f", "#fbd490", "#f1c177", "#ecb36b", "#dca562", "#c49243", "#b8793e",
	"#7c4a26", "#6b6d45", "#2d9e9f", "#12837f", "#07515c", "#00313a",
	"#1e302e", "#263d3a", "#33524e", "#43665a", "#61785c", "#192726", "#9f946d", "#4f6858", "#303e37", "#1d2925",
	"#6fb5a6",
]
## The sky bands' first rows (SKY 0 to 4, then GLOW, then the amber horizon). The shade's bottom edge (row 50) falls
## on a band edge, so it reads as part of the sky.
const BANDS := [0, 26, 50, 72, 90, 103, 112]

## The waylines: the reel's sheave it leaves from (title_giants.gd sheave), the house slot whose roof post it ends on,
## and its sag. The storage line is the quiet route: slack, with no cradle. (The old tower's fourth line ran off the
## right edge; from the deck's west end it would cross the Stack, so it is gone.)
const LINES := [
	{"sheave": 0, "to": "town.building.shop", "sag": 12.0, "cradle": 0.55},
	{"sheave": 1, "to": "town.building.storage", "sag": 24.0, "cradle": -1.0},
	{"sheave": 2, "to": "town.building.scrolls", "sag": 9.0, "cradle": 0.4},
]

## The slot's placeholder: the whole view, exactly the slot's size (384 x 216). Back to front: sky, far hills, the
## great tree (on sky and far hills only), the cloud streaks in front of it, the ridge's woods, the left tree, Tower
## Rise, the Street, the giant Tower, the shade past the shade's end, the waylines, the bluff and the river.
static func paint(_id: String, spec: Dictionary) -> Image:
	var img := Image.create(SIZE.x, SIZE.y, false, Image.FORMAT_RGBA8)
	_sky(img)
	_far_hills(img)
	Giants.great_tree(img)
	_clouds(img)
	_ridge(img)
	_left_tree(img)
	_rise(img)
	var roofs := _street(img)
	Giants.tower(img, roundi(street_x(_steps_x())))
	var anchors: Dictionary = spec.get("anchors", {})
	_preshade(img, anchors.get("shade_end", SHADE_END))
	_lines(img, roofs)
	_bluff(img)
	_river(img)
	var want: Vector2i = spec.get("size", SIZE)
	if want != SIZE:
		img.resize(want.x, want.y, Image.INTERPOLATE_NEAREST)
	return img


# ---------------------------------------------------------------------------------------------------------------------
# Where things go

## The x in this picture of a Street x (world px). The Street's north steps line up with the Rise stair's axis (the
## old tower frame's door axis, x 332.6), which is where the giant Tower's doors are painted.
static func street_x(world_x: float) -> float:
	var door_x := TOWER_AT.x + TP.BEACON.x * K
	return door_x + (world_x - _steps_x()) * K


## The middle of the Street's north steps (world px): the steps up to Tower Rise, under the tower's door.
static func _steps_x() -> float:
	for p in Street.AREA["paths"]:
		var r: Rect2i = p["rect"]
		if String(p["kind"]) == "steps" and r.position.y < 8:
			return (r.position.x + r.size.x * 0.5) * 24.0
	return 1128.0


# ---------------------------------------------------------------------------------------------------------------------
# Sky and land behind the town

static func _sky(img: Image) -> void:
	var cols: Array = SKY + [GLOW, TP.AMBER.sh]
	for y in 132:
		var band := 0
		for i in BANDS.size():
			if y >= int(BANDS[i]):
				band = i
		var next := mini(band + 1, cols.size() - 1)
		var to_next := int(BANDS[next]) - y if next != band else 99
		for x in SIZE.x:
			var c: Color = cols[band]
			# A two-row dither into the next band: a quarter of the pixels, then half.
			if to_next == 2 and (x + 2 * (y % 2)) % 4 == 0:
				c = cols[next]
			elif to_next == 1 and (x + y) % 2 == 0:
				c = cols[next]
			img.set_pixel(x, y, c)


## Long clouds in the open sky between the wordmark and the menu, lit underneath by the low sun. Painted after the
## great tree, so two of them cross its crown as thin streaks in front of it.
static func _clouds(img: Image) -> void:
	_cloud(img, 132, 62, 74)
	_cloud(img, 196, 83, 44)
	_cloud(img, 18, 94, 40)


## Everything right of the shade's end and above its bottom, painted as the shade would leave it. The sky goes one
## band darker (SKY 2 becomes SKY 1, SKY 1 becomes SKY 0, SKY 0 becomes SKY_D), which matches the shaded sky beside
## it; anything else there (the Stack, its root, the wisps) gets the shade's own sum, 62% of the colour plus 38% of
## the shade colour, snapped to PALETTE. So the band runs the full width with no seam at x 312.
static func _preshade(img: Image, corner: Vector2i) -> void:
	var down := {SKY[2]: SKY[1], SKY[1]: SKY[0], SKY[0]: SKY_D}
	var shaded := {}
	for y in mini(corner.y, SIZE.y):
		for x in range(maxi(0, corner.x), SIZE.x):
			var c := img.get_pixel(x, y)
			if down.has(c):
				img.set_pixel(x, y, down[c])
			elif c.a > 0.0:
				if not shaded.has(c):
					shaded[c] = _snap(Color(c.r * 0.62 + SHADE.r * 0.38, c.g * 0.62 + SHADE.g * 0.38,
						c.b * 0.62 + SHADE.b * 0.38))
				img.set_pixel(x, y, shaded[c])


## The PALETTE colour nearest to c (a weighted RGB distance, the same as the mocks' and prepare_slot's snap).
static func _snap(c: Color) -> Color:
	var best := Color(PALETTE[0])
	var best_d := INF
	for h in PALETTE:
		var p := Color(h)
		var rm := (p.r8 + c.r8) / 2.0
		var dr := p.r8 - c.r8
		var dg := p.g8 - c.g8
		var db := p.b8 - c.b8
		var d := (2.0 + rm / 256.0) * dr * dr + 4.0 * dg * dg + (2.0 + (255.0 - rm) / 256.0) * db * db
		if d < best_d:
			best_d = d
			best = p
	return best


static func _cloud(img: Image, x: int, y: int, w: int) -> void:
	for i in w:
		var edge := mini(i, w - 1 - i)
		var top := 1 if edge < 6 else 0
		_px(img, x + i, y + top, GLOW if edge > 2 else SKY[4])
		if edge > 4:
			_px(img, x + i, y + 1, GLOW)
			_px(img, x + i, y + 2, TP.AMBER.sh if (i % 9) != 4 else GLOW)
		if edge > 14 and i < w * 0.6:
			_px(img, x + i, y - 1, SKY[4])


## The far hills across the valley, a dip where the river bends away to the west (the Lookout's "next bend").
static func _far_hills(img: Image) -> void:
	for x in SIZE.x:
		var top := 116.0 + 3.0 * sin(x * 0.045) + 2.0 * sin(x * 0.13 + 1.0) - x * 0.012
		if x > 150 and x < 214:
			top += 5.0 * sin((x - 150) / 64.0 * PI)   # the valley the river leaves by
		for y in range(roundi(top), 150):
			img.set_pixel(x, y, HILL_FAR)
		if x > 158 and x < 206:
			var ry := roundi(top) + 2
			_px(img, x, ry, TP.AMBER.sh if (x / 3) % 4 != 0 else GLOW)   # the far river, catching the sunset


## The near ridge behind the town, wooded, rising to the right behind Tower Rise so the tower's cream stone stands
## against dark ground.
static func _ridge(img: Image) -> void:
	for x in SIZE.x:
		var base := 136.0 - x * 0.07 + 2.5 * sin(x * 0.09)
		if x > 230:
			base -= (x - 230) * 0.12   # the high ground behind the Rise
		var bump := absf(sin(x * 0.42)) * 3.0 + absf(sin(x * 0.17 + 2.0)) * 2.0   # treetops
		var top := roundi(base - bump)
		for y in range(top, 182):
			var c := HILL if y < top + 9 else HILL_DK
			if y == top and (x + top) % 3 != 0:
				c = TP.MOSS.sh   # the low sun on the treetops
			img.set_pixel(x, y, c)


## A big dark tree framing the left edge, its canopy behind the wordmark's left end and its trunk down to the bluff.
static func _left_tree(img: Image) -> void:
	var blobs := [[16, 20, 26], [44, 10, 20], [8, 52, 22], [40, 46, 22], [58, 34, 14], [22, 78, 18]]
	for b in blobs:
		_disc(img, b[0], b[1], b[2], HILL_DK)
	for b in blobs:
		_disc(img, b[0] - 3, b[1] - 3, b[2] - 6, HILL)
	for b in blobs:   # light caught on the upper-left of each clump
		_arc(img, b[0] - 3, b[1] - 3, b[2] - 6, TP.MOSS.sh)
	# The trunk leans a little, thickens toward its flared roots, lit on its left and dark on its right.
	for y in range(84, BLUFF_Y + 2):
		var cx := 18.0 - (y - 84) * 0.04
		var hw := 4.0 + (y - 84) / 34.0 + maxf(0.0, y - 172.0) * 0.9
		for x in range(roundi(cx - hw), roundi(cx + hw) + 1):
			var c: Color = TP.ROOTC.sh
			if x <= roundi(cx - hw) + 1:
				c = TP.ROOTC.mid
			elif x >= roundi(cx + hw) - 2:
				c = TP.ROOTC.dk
			elif (y * 3 + x) % 11 == 0:
				c = TP.ROOTC.dk   # bark
			_px(img, x, y, c)
	for b in [[18, 92, 1], [20, 104, -1]]:   # two limbs up into the canopy
		for i in 10:
			_px(img, 18 + (i + 2) * int(b[2]), int(b[1]) - i, TP.ROOTC.sh)
			_px(img, 18 + (i + 2) * int(b[2]), int(b[1]) - i + 1, TP.ROOTC.dk)


## Tower Rise: a grassy step above the Street with a stone-and-root bank, and the worn stair down from the doors.
static func _rise(img: Image) -> void:
	var left := 246
	for y in range(RISE_Y, STREET_Y + 1):
		var x0 := left + maxi(0, 22 - (y - RISE_Y) * 2)   # the Rise's west end slopes down to the Street
		for x in range(x0, SIZE.x):
			var c: Color = TP.BOULD.mid
			if y < RISE_Y + 3:
				c = TP.MOSS.lit if (x + y) % 5 != 0 else TP.MOSS.mid
			elif y < RISE_Y + 5:
				c = TP.MOSS.mid
			elif y > STREET_Y - 3:
				c = TP.BOULD.sh
			elif (y - RISE_Y) % 4 == 0 or (x + (y / 4) * 5) % 11 == 0:
				c = TP.BOULD.lit if x < 300 else TP.BOULD.sh   # stone courses, lit toward the sun
			img.set_pixel(x, y, c)
		_px(img, x0, y, TP.INK)
	# The Rise stair, on the door axis, down to the Crossroads.
	var cx := roundi(street_x(_steps_x()))
	for y in range(RISE_Y + 1, STREET_Y + 1):
		var step := (y - RISE_Y - 1) % 3
		var c: Color = TP.STONE.lit if step == 0 else (TP.STONE.sh if step == 1 else TP.STONE.dk)
		for x in range(cx - 6, cx + 6):
			img.set_pixel(x, y, c)
		_px(img, cx - 7, y, TP.INK)
		_px(img, cx + 6, y, TP.INK)


# ---------------------------------------------------------------------------------------------------------------------
# The town

## The Street: the hedge and a few trees behind it, the houses in their street order, the lane, its lamps and the
## waymark. Returns each house slot's roof post (where its wayline ties on), keyed by slot id.
static func _street(img: Image) -> Dictionary:
	# The hedge along the backs of the lots (the Street's row 0).
	for x in range(84, 266):
		for y in range(158, STREET_Y):
			img.set_pixel(x, y, TP.MOSS.sh if y > 160 else TP.MOSS.mid)
	for t in [[182, 152, 8], [224, 150, 9], [140, 154, 7], [268, 156, 8]]:
		_tree(img, t[0], t[1], t[2])
	var roofs := {}
	for b in Street.AREA["buildings"]:
		var slot := "town.building.%s" % String(b["id"])
		var s := Slots.spec(slot)
		if s.is_empty() or not (b.get("base") is Rect2i):
			continue
		var base: Rect2i = b["base"]
		var size: Vector2i = s["size"]
		var anchor: Vector2i = s.get("anchor", Vector2i(size.x / 2, size.y - 1))
		var world_left := (base.position.x + base.size.x * 0.5) * 24.0 - anchor.x
		var small := _shrink(Slots.image(slot).get_region(Rect2i(Vector2i.ZERO, size)), roundi(size.x * K), roundi(size.y * K))
		var at := Vector2i(roundi(street_x(world_left)), STREET_Y - small.get_height() + 1)
		img.blend_rect(small, Rect2i(Vector2i.ZERO, small.get_size()), at)
		# A wayline post on the roof's ridge: a timber stub with a brass pulley on top.
		var post := Vector2i(at.x + small.get_width() / 2 + 3, at.y + 2)
		for y in range(post.y - 4, post.y + 1):
			_px(img, post.x, y, TP.TIMB.dk)
		_px(img, post.x, post.y - 5, TP.BRASS.lit)
		roofs[slot] = Vector2(post.x, post.y - 5)
	# Market Street's lane: sunlit sand with ruts, a shadow under the house fronts.
	for x in SIZE.x:
		for y in range(LANE_Y, BLUFF_Y):
			var c: Color = TP.BOULD.hi
			if y == LANE_Y:
				c = TP.BOULD.mid
			elif (x * 7 + y * 3) % 13 == 0:
				c = TP.AMBER.sh   # low sun on the sand
			elif y == LANE_Y + 3 and x % 9 < 4:
				c = TP.STONE.sh   # a rut
			img.set_pixel(x, y, c)
	# The Street's lamp posts, lit for the evening, and the waymark at the Crossroads.
	for p in Street.AREA["props"]:
		if not (p.get("tile") is Vector2i):
			continue   # only single-tile props are drawn here (lamps and the waymark)
		var tile: Vector2i = p["tile"]
		var x := roundi(street_x((tile.x + 0.5) * 24.0))
		if String(p["slot"]) == "town.lamp.post":
			for y in range(STREET_Y - 6, STREET_Y + 1):
				_px(img, x, y, TP.TIMB.dk)
			_px(img, x, STREET_Y - 7, TP.AMBER.hi)
			_px(img, x - 1, STREET_Y - 7, TP.AMBER.sh)
		elif String(p["slot"]) == "town.prop.waymark":
			for y in range(STREET_Y - 3, LANE_Y + 4):
				_px(img, x, y, TP.TIMB.mid)
			for d in 3:
				_px(img, x - 1 - d, STREET_Y - 3 + d, TP.BRASS.mid)
				_px(img, x + 1 + d, STREET_Y - 2 + d, TP.BRASS.mid)
	return roofs


static func _tree(img: Image, cx: int, top: int, r: int) -> void:
	for x in range(cx - 1, cx + 1):
		for y in range(top + r, STREET_Y - 6):
			_px(img, x, y, TP.ROOTC.sh)
	_disc(img, cx, top + r, r, TP.MOSS.sh)
	_disc(img, cx - 1, top + r - 1, r - 2, TP.MOSS.mid)
	_arc(img, cx - 1, top + r - 1, r - 2, TP.MOSS.lit)


## The waylines: 1 px of ink with a 1 px lit top, sagging from the Low Reel's sheaves at the deck's west end down to
## the roof posts, a teal tag every 12 px and a parcel cradle partway along the strung ones.
static func _lines(img: Image, roofs: Dictionary) -> void:
	for l in LINES:
		var from := Giants.sheave(int(l["sheave"]))
		if not roofs.has(l["to"]):
			continue
		var to: Vector2 = roofs[l["to"]]
		var sag := float(l["sag"])
		var pts: Array[Vector2i] = []
		var n := int(absf(to.x - from.x)) * 2 + 2
		for j in n + 1:
			var p := Vector2i(TP.curve_at(from, to, sag, float(j) / n).round())
			if pts.is_empty() or pts[-1] != p:
				pts.append(p)
		for j in pts.size():
			var p := pts[j]
			if j % 12 == 6:
				_px(img, p.x, p.y, TP.TEAL.hi)
			else:
				_px(img, p.x, p.y, TP.INK)
			if not pts.has(p + Vector2i(0, -1)):
				_px(img, p.x, p.y - 1, TP.STONE.sh)
		if float(l["cradle"]) > 0.0:
			var c := Vector2i(TP.curve_at(from, to, sag, float(l["cradle"])).round())
			_px(img, c.x, c.y + 1, TP.INK)
			for x in range(c.x - 1, c.x + 2):
				_px(img, x, c.y + 2, TP.TWINE)
				_px(img, x, c.y + 3, TP.OIL)


# ---------------------------------------------------------------------------------------------------------------------
# The bluff and the river

## The bluff under the Street: a mossy lip, a face of stone and earth with hanging roots, and the switchbacks down to
## the Old Ferry Ward's dock.
static func _bluff(img: Image) -> void:
	for x in SIZE.x:
		var drip := 3 + (x * 13) % 7 / 3   # the moss lip hangs a little lower in places
		for y in range(BLUFF_Y, RIVER_Y):
			var k := y - BLUFF_Y
			var course := k / 4
			var c: Color = TP.BOULD.mid
			if k < 2:
				c = TP.MOSS.mid if (x + k) % 4 != 0 else TP.MOSS.lit
			elif k < drip:
				c = TP.MOSS.sh
			elif k > 11:
				c = TP.BOULD.dk
			elif (k % 4 == 1 and (x + course * 5) % 9 != 0) or (x + course * 7) % 13 == 0:
				c = TP.BOULD.sh   # the joints between stones, broken here and there
			elif k % 4 == 2 and (x + course * 3) % 6 < 3:
				c = TP.BOULD.lit   # a stone's sunlit top
			img.set_pixel(x, y, c)
	for x in range(6, SIZE.x, 17):   # roots hanging over the face
		var len := 4 + (x * 7) % 6
		for i in len:
			_px(img, x + (i / 3) % 2, BLUFF_Y + 3 + i, TP.ROOTC.mid)
	# The switchbacks from the Crossroads down to the ferry dock.
	var cx := roundi(street_x(_steps_x()))
	var legs := [[cx - 2, BLUFF_Y + 1, 1], [cx + 9, BLUFF_Y + 5, -1], [cx - 1, BLUFF_Y + 9, 1]]
	for leg in legs:
		for i in 12:
			var x := int(leg[0]) + i * int(leg[2])
			var y := int(leg[1]) + i / 3
			_px(img, x, y, TP.BOULD.hi)
			_px(img, x, y + 1, TP.STONE.sh)
	# The dock: planks on posts over the water.
	for x in range(344, SIZE.x):
		_px(img, x, RIVER_Y - 1, TP.TIMB.lit)
		_px(img, x, RIVER_Y, TP.TIMB.mid)
		_px(img, x, RIVER_Y + 1, TP.TIMB.dk)
	for x in [348, 362, 376]:
		for y in range(RIVER_Y + 2, RIVER_Y + 7):
			_px(img, x, y, TP.TIMB.dk)


## The river: the bank's shadow, teal water with long light streaks, sunset glints on the left and the light of the
## Tower's open doors broken on the water under them.
static func _river(img: Image) -> void:
	for y in range(RIVER_Y, SIZE.y):
		for x in SIZE.x:
			if x >= 344 and y < RIVER_Y + 2:
				continue   # the dock planks
			var c: Color = TP.TEAL.lit
			if y < RIVER_Y + 1:
				c = TP.TEAL.sh
			elif y < RIVER_Y + 3:
				c = TP.TEAL.mid
			elif (x * 3 + y * 11) % 29 < 5 and (y % 3) == 1:
				c = TP.TEAL.hi
			elif (x * 5 + y * 7) % 61 == 0:
				c = WATER_HI
			img.set_pixel(x, y, c)
	for g in [[150, 206, 5], [196, 209, 4], [232, 212, 3], [120, 211, 4]]:   # the sunset on the water
		for i in int(g[2]):
			_px(img, int(g[0]) + i, int(g[1]), TP.AMBER.sh)
	var lx := roundi(street_x(_steps_x()))   # the doors' axis
	for r in [[205, 3, TP.AMBER.lit], [208, 2, TP.AMBER.mid], [211, 3, TP.AMBER.sh], [214, 1, TP.AMBER.sh]]:
		for i in int(r[1]):
			_px(img, lx - int(r[1]) / 2 + i, int(r[0]), r[2])


# ---------------------------------------------------------------------------------------------------------------------
# Pixel helpers

static func _px(img: Image, x: int, y: int, c: Color) -> void:
	if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
		img.set_pixel(x, y, c)


## A round clump of leaves: a disc whose outer two rings are ragged, so it does not read as a flat circle.
static func _disc(img: Image, cx: int, cy: int, r: int, c: Color) -> void:
	for y in range(cy - r, cy + r + 1):
		for x in range(cx - r, cx + r + 1):
			var d2 := (x - cx) * (x - cx) + (y - cy) * (y - cy)
			if d2 > r * r or (d2 > (r - 2) * (r - 2) and (x * 7 + y * 13) % 5 < 2):
				continue
			_px(img, x, y, c)


## The light on a clump: a dithered crescent on its upper left, where the low sun catches it.
static func _arc(img: Image, cx: int, cy: int, r: int, c: Color) -> void:
	for y in range(cy - r, cy + r + 1):
		for x in range(cx - r, cx + r + 1):
			var dx := x - cx
			var dy := y - cy
			if dx * dx + dy * dy <= (r - 1) * (r - 1) and dx + dy < -r * 0.8 and (x + y) % 2 == 0:
				_px(img, x, y, c)


## A picture shrunk to w x h by averaging each output pixel's block of source pixels, then snapped to the nearest
## tower palette colour, with on-or-off alpha (TowerParts.shrink, which the road's vista uses too).
static func _shrink(src: Image, w: int, h: int) -> Image:
	return TP.shrink(src, w, h)
