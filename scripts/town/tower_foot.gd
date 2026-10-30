extends RefCounted
## The new Wayline Tower's foot on Tower Rise, a coded blockout (Claude, 2026-10-29; docs/design/vast-scale-2026-10-27/
## RISE_CLIMB_SLICE.md slice 1, a proposal in working labels). Preston chose "Climb the stair" for the doors at the
## true scale (VAST_SCALE_DESIGN.md, "Numbers"): plinth step 1 is 8 tiles tall and step 2 another 8, the Stack 34
## tiles across, all wider than the Rise, so every face runs off both sides. It matches the installed title painting
## (assets/slots/title/backdrop/highbank.png): the pale round Stack with brass rings, river-stone plinth faces in
## courses, brass rails on the step edges, the stair, the arched double doors, and the great tree's root coming in from
## the west and climbing the west side ("The root"). Every colour is one of the title's 47
## (scripts/art/placeholders/title_highbank.gd PALETTE), lit low from the west as on the title.
##
## place() stands it for the "hall" building whose entry says "tower": "foot" (scripts/world/areas/hall_rise.gd):
##   "TowerFoot"     the plinth, under everyone (z 0): the door landing, step 2's face with its stair, the terrace,
##                   step 1's face with its stair, and the root from the lane on row 29 up to row 0; with its two
##                   brass rails, each sorted on its edge row so a creature on that row stands behind it.
##   "WaylineTower"  the Stack's foot (returned, the hall's node, sorted at the door row like any building): the Stack's
##                   face from row 0 up STACK_UP px, the arched doorway, the root up its west side, and the door leaves
##                   ("Door", three swing frames in meta "frames", as BuildingTemplate.place gives every building).
## The Tower scene (scripts/story/tower_reveal.gd) hides the Stack's node and stands the old 30-tile tower (TowerParts)
## on the doors for its climb until slice 2 retimes it; the plinth stays.
##
## Slice 2 turns the parts into art slots for Codex (step faces, stair, Stack foot and doors, rails, root).

const Finish := preload("res://scripts/town/exterior_finish.gd")

const T := 24
const STACK_UP := 240        # px of the Stack painted above row 0; the camera shows at most 144 (headroom + the lean)
const STACK_R := 408.0       # the Stack's radius: 34 tiles across
const FOOT_C := 23           # the Stack's foot row at the door axis: row 0's bottom px, the sill under the doors
const FOOT_RY := 40.0        # the half-height of the foot's curve as seen from the south (its sides rise this much at 90 degrees)
const COURSE := 12           # px per stone course, on the Stack and the plinth faces' stair
const FACE_COURSE := 24      # the step faces' ashlar course, two of the Stack's tall
const PIER_EVERY := 7 * T    # a buttress pier along each step face this often (px)
const PIER_W := 14
## The plinth in area px (rows of hall_rise.gd): the landing (rows 1 to 4) and step 2's face (5 to 12), the terrace
## (13 to 17) and step 1's face (18 to 25); the foot of the plinth is y 624 (row 26).
const LANDING := Vector2i(0, 120)
const FACE2 := Vector2i(120, 312)
const TERRACE := Vector2i(312, 432)
const FACE1 := Vector2i(432, 624)
const PLINTH_FOOT := 624
const FLARE := 600                # below this the root bends west toward the lane it lies along
const GROUND := 716               # the ground line along the lane (row 29), where the root goes under
const TREADS := Vector2i(684, 712)   # the rows of the lane's treads cut into the root's back (rows 28 and 29)
const BOTTOM := 720               # the plinth picture's bottom: the lane row 29's foot
const DOOR := Vector2i(48, 64)    # the double door, as the hall class's (BuildingTemplate.CLASSES)
const RAIL_H := 14                # a rail's height over its edge
const SHADE_W := 7                # the root's shadow to its east (the light is low in the west)

# The title's colours (title_highbank.gd PALETTE), by job.
const INK := Color("#0b0e11")
const HI := Color("#fbd490")
const AMB := Color("#f1c177")
const AMB2 := Color("#ecb36b")
const AMB3 := Color("#dca562")
const AMB4 := Color("#c49243")
const CREAM := Color("#f5d9a8")
const PALE := Color("#e6c697")
const LIGHT := Color("#ccb290")
const TAN := Color("#c7a378")
const STONE := Color("#9c8c68")
const MID := Color("#8e7f5e")
const GREY := Color("#5f5e57")
const OIL := Color("#6b6d45")
const UMBER := Color("#5d4b34")
const BRASS := {"hi": Color("#f2d27a"), "lit": Color("#d4a94c"), "mid": Color("#a37a32"), "sh": Color("#6b4f1f")}
const MOSS := {"hi": Color("#c6bb2a"), "lit": Color("#908940"), "mid": Color("#6b6f1d"), "sh": Color("#44421a")}
const ROOT := {"hi": Color("#c49b69"), "lit": Color("#b06b3d"), "body": Color("#8c6545"), "mid": Color("#663f23"),
	"sh": Color("#3f2716"), "dk": Color("#23180e"), "cut": Color("#92724b"), "warm": Color("#7c4a26"), "glow": Color("#b8793e")}
## The Stack's face across its width, lit from the west: base, mortar and a darker block, by band (west to east).
const STACK_BASE := [HI, AMB, CREAM, PALE, LIGHT, TAN, STONE]
const STACK_MORTAR := [AMB3, AMB3, LIGHT, TAN, STONE, MID, MID]
const STACK_DARK := [AMB, AMB2, PALE, LIGHT, TAN, STONE, MID]
const STACK_EDGES := [0.2, 0.3, 0.42, 0.55, 0.68, 0.8]   # where each band ends, across the whole Stack (0 west, 1 east)
## A 4 x 4 ordered dither, so the Stack's light bands blend instead of striping.
const BAYER := [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5]
## Two steps darker, for the root's shadow on whatever it falls on.
const DARKER := {
	"fbd490": "dca562", "f1c177": "c49243", "ecb36b": "c49243", "dca562": "b8793e", "c49243": "a37a32",
	"f5d9a8": "ccb290", "e6c697": "c7a378", "ccb290": "9c8c68", "c7a378": "9c8c68", "9c8c68": "8e7f5e",
	"8e7f5e": "5f5e57", "5f5e57": "5d4b34", "6b6d45": "44421a", "5d4b34": "3f2716",
	"f2d27a": "d4a94c", "d4a94c": "a37a32", "a37a32": "6b4f1f", "c6bb2a": "908940", "908940": "6b6f1d", "6b6f1d": "44421a",
}

static var _cache := {}   # "<what>|<width>|<axis>" -> Image, painted once a session


# ---------------------------------------------------------------------------------------------------------------------
# Standing it in the area

## Stands the foot under `parent` for the hall entry `entry` (its "door" tiles set the door axis) in an area `width_px`
## wide, and returns the Stack's node. The plinth's node is added first, so the Stack draws over the landing.
static func place(parent: Node, entry: Dictionary, width_px: int) -> Node2D:
	var axis := door_axis(entry)
	var foot := Node2D.new()
	foot.name = "TowerFoot"
	foot.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(foot)
	foot.add_child(_sprite("Plinth", plinth_image(width_px, axis), Vector2.ZERO))
	for edge: int in [LANDING.y, TERRACE.y]:
		var rail := _sprite("Rail%d" % (edge / T), rail_image(width_px, axis), Vector2(0, edge - RAIL_H))
		rail.z_as_relative = false
		rail.z_index = edge - 2   # the edge row's z plus: over a creature on that row (its z is row * 24 + 18)
		foot.add_child(rail)
	var stack := Node2D.new()
	stack.name = "WaylineTower"
	stack.position = Vector2(0, -STACK_UP)
	stack.z_index = 0   # the door row (row 0): behind a creature on the door tiles, as any building sorts
	stack.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(stack)
	var face := _sprite("Exterior", stack_image(width_px, axis), Vector2.ZERO)
	Finish.apply(face, true)   # the shared sel-out finish every building has
	stack.add_child(face)
	var door := door_rect(axis)
	var frames := door_frames()
	var leaves := _sprite("Door", frames[0], Vector2(door.position + Vector2i(0, STACK_UP)))
	Finish.apply(leaves)
	stack.add_child(leaves)
	stack.set_meta("frames", frames)
	stack.set_meta("door_px", Rect2i(door.position + Vector2i(0, STACK_UP), door.size))
	stack.set_meta("class", "hall")
	stack.set_meta("slot", "town.building.hall")
	stack.set_meta("foot", foot)
	return stack


## The door axis in area px: the middle of the hall's door tiles (Tower Rise: x 312).
static func door_axis(entry: Dictionary) -> int:
	var doors: Array = entry.get("door", [])
	if doors.is_empty():
		return 13 * T
	var x0 := 1 << 20
	var x1 := -1
	for d: Vector2i in doors:
		x0 = mini(x0, d.x)
		x1 = maxi(x1, d.x)
	return (x0 + x1 + 1) * T / 2


## The double door's opening in area px: 48 x 64 on the door axis, its foot 2 px above row 0's bottom (the sill).
static func door_rect(axis: int) -> Rect2i:
	return Rect2i(axis - DOOR.x / 2, FOOT_C - 1 - DOOR.y, DOOR.x, DOOR.y)


## The Stack's foot row at column x (area px): FOOT_C under the doors, rising toward the sides as a round foot does.
static func foot_y(x: float, axis: int) -> float:
	var u := clampf((x - axis) / STACK_R, -1.0, 1.0)
	return FOOT_C - FOOT_RY * (1.0 - sqrt(1.0 - u * u))


static func _sprite(name: String, img_or_tex: Variant, at: Vector2) -> Sprite2D:
	var s := Sprite2D.new()
	s.name = name
	s.centered = false
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.texture = img_or_tex if img_or_tex is Texture2D else ImageTexture.create_from_image(img_or_tex)
	s.position = at
	return s


# ---------------------------------------------------------------------------------------------------------------------
# The pictures

## The plinth in area px from y 0 to BOTTOM: paving on the landing and the terrace, the two faces with the stair cut
## into them on the door axis, and the root up the west side (transparent below the plinth but for the root's run).
static func plinth_image(w: int, axis: int) -> Image:
	var key := "plinth|%d|%d" % [w, axis]
	if _cache.has(key):
		return _cache[key]
	var c := Cv.new(Vector2i(w, BOTTOM), 0)
	_paving(c, Vector2i(0, LANDING.y), axis, 7)
	_paving(c, TERRACE, axis, 31)
	_face(c, FACE2, axis, 11)
	_face(c, FACE1, axis, 53)
	# Shadows where things meet the ground, so they stand on it rather than end on it (Preston, 2026-10-29: "it cuts
	# off rather than has an edge"): a dark line under the Stack's foot fading out over the landing, step 2's shadow
	# on the terrace. Step 1's on the grass below it is the ground painter's, as under every ledge in the town
	# (highbank_painter.gd _ledges).
	for x in w:
		var fy := int(roundf(foot_y(x + 0.5, axis)))
		c.put(x, fy + 1, INK)   # the contact line, as under every standing thing in the town
		c.put(x, fy + 2, UMBER)
		_shade(c, Rect2i(x, fy + 3, 1, 8), 0.85, 0.0)
	_shade(c, Rect2i(0, FACE2.y, w, 8), 0.9, 0.0)
	_root(c, 0, BOTTOM)
	_cache[key] = c.img
	return c.img


## The Stack's foot from STACK_UP px above row 0 down to its foot: the round face in courses, lit from the west, two
## brass rings a story (4 tiles) apart, the base course and the era lip's brass band, slit and porthole windows, the
## arched doorway (its inside dark with a warm floor, for when the leaves swing open), and the root up its west side.
static func stack_image(w: int, axis: int) -> Image:
	var key := "stack|%d|%d" % [w, axis]
	if _cache.has(key):
		return _cache[key]
	var c := Cv.new(Vector2i(w, STACK_UP + T), -STACK_UP)
	for x in w:
		var u := clampf((x + 0.5 - axis) / STACK_R, -1.0, 1.0)
		var f := (u + 1.0) * 0.5
		var theta := asin(u)
		var theta_w := asin(clampf((x - 0.5 - axis) / STACK_R, -1.0, 1.0))
		var fy := foot_y(x + 0.5, axis)
		for y in range(-STACK_UP, int(roundf(fy)) + 1):
			var d := fy - y   # px above the foot
			var band := _band(f + (BAYER[(y & 3) * 4 + (x & 3)] - 7.5) / 16.0 * 0.03)   # dithered where the light turns
			var course := int(d / COURSE)
			var stagger := 0.5 if course % 2 == 1 else 0.0
			var j := floori(theta / 0.055 + stagger)
			var col: Color = STACK_BASE[band]
			if fmod(d, COURSE) < 1.0 or j != floori(theta_w / 0.055 + stagger):
				col = STACK_MORTAR[band]
			elif _hash(course, j) % 6 == 0:
				col = STACK_DARK[band]
			if d < 9.0:   # the base course, a shade darker, with a lit lip
				col = STACK_DARK[band] if d < 8.0 else STACK_BASE[maxi(0, band - 1)]
			elif d < 13.0:   # the era lip's brass band
				col = _brass(f, d - 9.0, 4.0)
			for ring in [96.0, 192.0]:
				if d >= ring and d < ring + 7.0:
					col = _brass(f, d - ring, 7.0)
					if fposmod(theta, 0.08) < 0.012 and d >= ring + 2.0 and d < ring + 5.0:
						col = BRASS.sh   # a rivet
				elif d >= ring + 7.0 and d < ring + 9.0 and _hash(x, int(ring)) % 3 == 0:
					col = MOSS.mid if d < ring + 8.0 else MOSS.lit   # moss on the ring's lip
			c.put(x, y, col)
	# Slit windows either side of the doors, a porthole over them, and two more on the stair's climb round the Stack.
	for sx in [axis - 84, axis + 80]:
		var top := int(foot_y(sx, axis)) - 60
		c.rect(sx - 1, top - 1, 6, 20, INK)
		c.rect(sx, top, 4, 18, ROOT.dk)
		c.rect(sx + 1, top + 12, 2, 5, ROOT.warm)
	for p in [Vector2i(axis, 150), Vector2i(axis - 150, 176), Vector2i(axis + 128, 226)]:
		_porthole(c, p.x, int(foot_y(p.x, axis)) - p.y, 7)
	_doorway(c, axis)
	_root(c, -STACK_UP, T)
	_cache[key] = c.img
	return c.img


## One brass rail along a step's edge, RAIL_H px tall with its foot on the edge: posts every tile, a brass top rail
## and a mid rail, from just east of the root to the east edge, open over the stair with a newel each side.
static func rail_image(w: int, axis: int) -> Image:
	var key := "rail|%d|%d" % [w, axis]
	if _cache.has(key):
		return _cache[key]
	var c := Cv.new(Vector2i(w, RAIL_H), 0)
	var x0 := 5 * T + 2
	var gap := Vector2i(axis - T - 8, axis + T + 8)   # the stair's two tiles and its walls
	for x in range(x0, w):
		if x >= gap.x and x < gap.y:
			continue
		c.put(x, 2, INK)
		c.put(x, 3, BRASS.hi if x < axis else BRASS.lit)
		c.put(x, 4, BRASS.mid)
		c.put(x, 5, INK)
		c.put(x, 8, BRASS.mid)
		c.put(x, 9, BRASS.sh)
	for x in range(x0 + 10, w, T):
		if x + 3 >= gap.x and x - 1 < gap.y:
			continue
		_post(c, x, 1)
	for x in [gap.x - 4, gap.y + 1]:
		_post(c, x, 0)
		c.rect(x - 1, 0, 6, 1, INK)
		c.rect(x, 0, 4, 1, BRASS.hi)
	for x in w:   # the contact line: each column's lowest pixel dark, the posts' feet on the coping (as art_slots.gd)
		for y in range(RAIL_H - 1, -1, -1):
			if c.at(x, y).a > 0.0:
				c.put(x, y, INK)
				break
	return _done(key, c.img)


## The door leaves' three swing frames (closed, half open, open), arched at the top as the doorway is: two timber
## leaves meeting in the middle with brass straps and handles, folding back to the jambs.
static func door_frames() -> Array[Texture2D]:
	var out: Array[Texture2D] = []
	var r := DOOR.x / 2
	for f in 3:
		var img := Image.create(DOOR.x, DOOR.y, false, Image.FORMAT_RGBA8)
		var leaf: int = [r, r / 2, 3][f]
		for y in DOOR.y:
			for x in DOOR.x:
				if not _in_arch(x, y, r):
					continue
				var edge := mini(x, DOOR.x - 1 - x)   # px from the leaf's hinge side
				if edge >= leaf:
					continue
				var col: Color = ROOT.body if edge % 6 != 5 else ROOT.mid
				if y in [18, 19, 46, 47] and edge < leaf - 1:
					col = BRASS.mid if y % 2 == 0 else BRASS.sh   # the straps
				if edge == leaf - 1 or edge == 0 or not _in_arch(x, y - 1, r):
					col = INK
				elif edge == leaf - 4 and y in [33, 34]:
					col = BRASS.hi   # the handles
				img.set_pixel(x, y, col)
		out.append(ImageTexture.create_from_image(img))
	return out


static func _in_arch(x: int, y: int, r: int) -> bool:
	if y < 0 or x < 0 or x >= DOOR.x or y >= DOOR.y:
		return false
	if y >= r:
		return true
	return Vector2(x + 0.5 - r, y + 0.5 - r).length() <= r


# ---------------------------------------------------------------------------------------------------------------------
# The parts

## Stone flags on a step's top from top.x to top.y: courses of flags in the cream and tan of the title, joints with moss
## in them, a lighter worn path to the stair on the door axis, a grass strip along the edge and the coping on it.
static func _paving(c: Cv, top: Vector2i, axis: int, seed: int) -> void:
	var w := c.img.get_width()
	var edge := top.y
	for y0 in range(top.x, edge - 12, 12):
		var row := y0 / 12
		var x := -(_hash(row, seed) % 20)
		var k := 0
		while x < w:
			var fw := 18 + _hash(row * 31 + k, seed) % 14
			var tone: Color = [TAN, STONE, LIGHT, TAN, STONE][_hash(k, row + seed) % 5]
			if absi(x + fw / 2 - axis) < T + 6:
				tone = [LIGHT, PALE][_hash(k, row) % 2]   # the worn way to the doors
			c.rect(x + 1, y0 + 1, fw - 1, 11, tone)
			c.rect(x, y0, fw, 1, MID)
			c.rect(x, y0, 1, 12, MID)
			c.rect(x + 1, y0 + 1, fw - 2, 1, _lighter(tone) if tone != PALE else CREAM)   # the flag's lit top
			if _hash(k, row * 7 + seed) % 3 == 0:
				c.rect(x, y0 + 4 + _hash(k, row) % 6, 1, 3, MOSS.mid)   # moss in the joint
			x += fw
			k += 1
	# The grass strip under the rail, then the coping along the edge, its lip lit where the top turns down.
	for x in w:
		var g := _hash(x, seed) % 5
		for y in range(edge - 12, edge - 4):
			var col: Color = MOSS.mid if (y + x) % 3 != 0 else MOSS.lit
			if y < edge - 12 + g:
				continue
			if _hash(x * 3 + y, seed) % 11 == 0:
				col = MOSS.hi
			c.put(x, y, col)
	c.rect(0, edge - 5, w, 1, STONE)
	c.rect(0, edge - 4, w, 3, PALE)
	c.rect(0, edge - 1, w, 1, CREAM)


## A step's face from span.x to span.y, built as a retaining wall so it reads as a drop and not as more paving
## (Preston, 2026-10-29: the faces shared the floors' pattern): a coping course standing out over a dark shadow line,
## ashlar blocks two courses tall with drafted margins (lit top and west, dark bottom and east) round a rough pitched
## face, buttress piers casting their shadow east, a footing of small damp rubble, moss hanging from the coping, the
## face darkening toward its foot, and the stair built out on the door axis. Lit from the west: the west third lighter.
static func _face(c: Cv, span: Vector2i, axis: int, seed: int) -> void:
	var w := c.img.get_width()
	c.rect(0, span.x, w, span.y - span.x, UMBER)   # mortar, in shadow
	c.rect(0, span.x, w, 3, LIGHT)                 # the coping's front
	c.rect(0, span.x + 3, w, 1, STONE)
	c.rect(0, span.x + 4, w, 1, INK)               # its shadow on the face under it
	c.rect(0, span.x + 5, w, 2, GREY)
	var top := span.x + 7
	var courses := (span.y - top) / FACE_COURSE
	for k in courses:
		var x := -(_hash(k, seed) % 30)
		var b := 0
		while x < w:
			var bw := 34 + _hash(k * 17 + b, seed) % 26
			_ashlar(c, Rect2i(x, top + k * FACE_COURSE, bw, FACE_COURSE), _face_tone(x + bw / 2, w, _hash(b, k + seed)))
			x += bw
			b += 1
	var foot := top + courses * FACE_COURSE   # the footing under the last course: small rounded rubble, damp
	var fx := -(_hash(courses, seed) % 12)
	var fb := 0
	while fx < w:
		var fw := 12 + _hash(fb, seed + 3) % 10
		var tone: Color = [OIL, MOSS.mid, GREY, OIL][_hash(fb, seed) % 4]
		c.rect(fx + 1, foot + 2, fw - 2, span.y - foot - 4, tone)
		c.rect(fx + 2, foot + 1, fw - 4, 1, _lighter(tone))
		fx += fw
		fb += 1
	for px in range(PIER_EVERY / 2 + _hash(seed, 1) % T, w - PIER_W, PIER_EVERY):
		if absi(px + PIER_W / 2 - axis) >= 2 * T + PIER_W:   # clear of the stair and its walls
			_pier(c, Rect2i(px, span.x + 5, PIER_W, span.y - span.x - 5), top)
	for mx in w:   # moss hanging from the coping
		var hang := _hash(mx, seed + 5) % 9
		if hang > 5:
			for y in range(top, top + hang - 3):
				c.put(mx, y, MOSS.mid if y % 2 == 0 else MOSS.sh)
	c.rect(0, span.y - 1, w, 1, UMBER)
	_shade(c, Rect2i(0, top, w, 10), 0.6, 0.0)               # under the coping
	_shade(c, Rect2i(0, span.y - 36, w, 36), 0.0, 0.9)      # toward the foot, where the light does not reach
	_stair(c, span, axis)


## A face block's tone by where it stands, lit from the west: the west third lighter, the east third darker.
static func _face_tone(xc: int, w: int, h: int) -> Color:
	var west := clampf(float(xc) / w, 0.0, 1.0)
	var tones: Array[Color] = [STONE, MID, STONE, MID]
	if west >= 0.67:
		tones = [OIL, GREY, MID, OIL]
	elif west >= 0.34:
		tones = [MID, OIL, MID, GREY]
	return tones[h % 4]


## One ashlar block over `r`, its last row and column left as the joint: drafted margins, lit along its top and west
## and dark along its bottom and east, round a rough pitched face.
static func _ashlar(c: Cv, r: Rect2i, tone: Color) -> void:
	var x1 := r.end.x - 2   # the block's own last column and row
	var y1 := r.end.y - 2
	var hex := tone.to_html(false)
	var dark := Color(DARKER.get(hex, hex))
	var lit := _lighter(tone)
	c.rect(r.position.x, r.position.y, r.size.x - 1, r.size.y - 1, tone)
	for y in range(r.position.y + 3, y1 - 2):
		for x in range(maxi(0, r.position.x + 3), mini(c.img.get_width(), x1 - 2)):
			if _hash(x * 7 + y, y * 13 + x) % 9 == 0:
				c.put(x, y, dark)   # the pitched face: scattered grain, not a dither grid
	c.rect(r.position.x, r.position.y, r.size.x - 1, 1, lit)
	c.rect(r.position.x, r.position.y, 1, r.size.y - 1, lit)
	c.rect(r.position.x, y1, r.size.x - 1, 1, dark)
	c.rect(x1, r.position.y + 1, 1, r.size.y - 2, dark)


## A buttress pier standing out of a step face over `r`: a capstone over the coping's shadow line, lit on its west side
## and in shade on its east, coursed level with the face, and its shadow on the face to its east.
static func _pier(c: Cv, r: Rect2i, top: int) -> void:
	var x1 := r.end.x - 1
	c.rect(r.position.x, r.position.y, r.size.x, r.size.y, STONE)
	c.rect(r.position.x + 1, r.position.y, 2, r.size.y, PALE)   # its west side, catching the light
	c.rect(x1 - 2, r.position.y, 2, r.size.y, GREY)             # its east side, in shade
	c.rect(r.position.x, r.position.y, 1, r.size.y, INK)
	c.rect(x1, r.position.y, 1, r.size.y, INK)
	for y in range(top + FACE_COURSE - 1, r.end.y - 2, FACE_COURSE):
		c.rect(r.position.x + 1, y, r.size.x - 2, 1, UMBER)     # its joints, level with the face's
		c.rect(r.position.x + 1, y + 1, r.size.x - 2, 1, LIGHT)
	c.rect(r.position.x - 1, r.position.y - 2, r.size.x + 2, 2, CREAM)   # the capstone
	c.rect(r.position.x - 1, r.position.y, r.size.x + 2, 1, INK)
	_shade(c, Rect2i(r.end.x, r.position.y + 1, 8, r.size.y - 1), 0.9, 0.0, true)


## The stair up a face on the door axis, two tiles wide and built out from it: a step every course, each a lit tread,
## its bright nose, a riser in half shade and a dark crease where it meets the tread below. A low wall each side, 8 px
## (its coping lit on the west wall, in shade on the east, its end showing at the foot); the west wall's shadow lies
## across the treads beside it and the whole stair's shadow on the face to its east (the light is low in the west).
static func _stair(c: Cv, span: Vector2i, axis: int) -> void:
	var x0 := axis - T
	var x1 := axis + T
	for y in range(span.x, span.y):
		var p := (y - span.x) % COURSE
		for x in range(x0, x1):
			var west := x < axis
			var col: Color
			if p < 7:
				col = (LIGHT if west else TAN) if absi(x - axis) <= 8 else (PALE if west else LIGHT)   # the tread, worn in the middle
			elif p == 7:
				col = CREAM if west else PALE   # its nose
			elif p < 11:
				col = STONE if west else MID    # the riser
			else:
				col = GREY                      # the crease
			c.put(x, y, col)
	_shade(c, Rect2i(x0, span.x, 7, span.y - span.x), 0.9, 0.0, true)   # the west wall's shadow on the treads
	_shade(c, Rect2i(x1 + 8, span.x + 5, 10, span.y - span.x - 5), 0.9, 0.0, true)   # the stair's on the face
	var cols_w: Array[Color] = [INK, CREAM, PALE, PALE, LIGHT, LIGHT, STONE, INK]   # the west wall, west to east
	var cols_e: Array[Color] = [INK, MID, STONE, STONE, MID, MID, GREY, INK]        # the east wall
	for y in range(span.x, span.y):
		var joint := (y - span.x) % (2 * COURSE) == 0 and y > span.x
		for k in 8:
			c.put(x0 - 8 + k, y, MID if joint and k > 0 and k < 7 else cols_w[k])
			c.put(x1 + k, y, GREY if joint and k > 0 and k < 7 else cols_e[k])
	for x in [x0 - 8, x1]:   # each wall's end at the foot: a lit edge, its face in shade, a dark line on the ground
		c.rect(x + 1, span.y - 7, 6, 1, CREAM if x < axis else STONE)
		c.rect(x + 1, span.y - 6, 6, 5, MID if x < axis else GREY)
		c.rect(x, span.y - 1, 8, 1, INK)


## Darkens what is painted in `r` one step (DARKER) through an ordered dither: `from` of its pixels at r's top (its
## west side when `across`), fading to `to` at the far side. Shadows that keep to the palette.
static func _shade(c: Cv, r: Rect2i, from: float, to: float, across := false) -> void:
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			var t := float(x - r.position.x) / maxf(1.0, r.size.x - 1) if across else float(y - r.position.y) / maxf(1.0, r.size.y - 1)
			if _dither(x, y) >= lerpf(from, to, t):
				continue
			var under := c.at(x, y)
			if under.a > 0.0:
				var hex := under.to_html(false)
				c.put(x, y, Color(DARKER.get(hex, hex)))


## The 4 x 4 ordered dither's threshold at (x, y), from 0 to 1.
static func _dither(x: int, y: int) -> float:
	return (BAYER[(y & 3) * 4 + (x & 3)] + 0.5) / 16.0


## The arched doorway over the doors: a ring of stone voussoirs (lit on the west), a brass keystone, the opening dark
## inside with lamplight on its floor, and the sill.
static func _doorway(c: Cv, axis: int) -> void:
	var door := door_rect(axis)
	var r := DOOR.x / 2
	var ring := 6
	for y in range(door.position.y - ring, door.end.y):
		for x in range(door.position.x - ring, door.end.x + ring):
			var lx := x - door.position.x
			var ly := y - door.position.y
			var dist := 0.0   # px outside the opening (0 inside)
			if ly >= r:
				dist = maxf(maxf(-lx, lx - (DOOR.x - 1)), 0.0)
			else:
				dist = maxf(0.0, Vector2(lx + 0.5 - r, ly + 0.5 - r).length() - r)
			if dist <= 0.0:   # inside: dark, a warm glow on the floor
				var low := door.end.y - y
				c.put(x, y, ROOT.glow if low <= 3 else (ROOT.warm if low <= 9 else (ROOT.sh if low <= 22 else ROOT.dk)))
			elif dist < 1.0 or (dist >= ring - 1 and dist < ring):
				c.put(x, y, INK)
			elif dist < ring - 1:
				var west := x < axis
				var col := CREAM if west else TAN
				if ly < r and fmod(atan2(ly + 0.5 - r, lx + 0.5 - r) + PI, 0.4) < 0.07:
					col = STONE   # the joints between voussoirs
				c.put(x, y, col)
	c.rect(axis - 3, door.position.y - ring, 6, ring + 1, INK)   # the brass keystone
	c.rect(axis - 2, door.position.y - ring + 1, 4, ring - 1, BRASS.lit)
	c.rect(axis - 2, door.position.y - ring + 1, 2, 1, BRASS.hi)
	c.rect(door.position.x - 2, door.end.y, DOOR.x + 4, 1, PALE)   # the sill
	c.rect(door.position.x - 2, door.end.y + 1, DOOR.x + 4, 1, STONE)


static func _porthole(c: Cv, cx: int, cy: int, r: int) -> void:
	for y in range(cy - r - 1, cy + r + 2):
		for x in range(cx - r - 1, cx + r + 2):
			var d := Vector2(x - cx, y - cy).length()
			if d > r + 1.0:
				continue
			var col: Color = INK
			if d <= r - 3.0:
				col = AMB if (x - cx) + (y - cy) < 0 else AMB3   # lamplight inside
				if x == cx or y == cy:
					col = ROOT.sh   # the mullion
			elif d <= r - 2.0:
				col = INK
			elif d <= r:
				col = BRASS.hi if x < cx else BRASS.mid
			c.put(x, y, col)


static func _post(c: Cv, x: int, top: int) -> void:
	c.rect(x - 1, top, 4, RAIL_H - top, INK)
	c.rect(x, top + 1, 2, RAIL_H - top - 2, ROOT.sh)
	c.rect(x, top + 1, 1, RAIL_H - top - 2, BRASS.sh)
	c.rect(x, top, 2, 1, BRASS.hi)


## The great tree's root (VAST_SCALE_DESIGN.md, "The root"), painted into whichever picture `c` is, from y0 to y1 in
## area px: about 4 tiles thick, it comes in from the west half buried along the lane on row 29 (the lane's treads cut
## into its back), turns up at the plinth's foot and climbs step 1, the terrace, step 2 and the Stack's west side,
## swelling where it bends over each step's edge, bark streaked along it, lit from the west, its shadow to the east.
## A brass band ties it at the Stack's foot (the era lip), and rootlets grip the courses.
static func _root(c: Cv, y0: int, y1: int) -> void:
	var w := c.img.get_width()
	var top := maxi(y0, -STACK_UP)
	var bottom := mini(y1, GROUND + 1)
	# Its shadow first, on whatever is under it.
	for y in range(top, mini(bottom, FLARE)):
		var r := _root_edges(y).y
		for x in range(int(r) + 1, int(r) + 1 + SHADE_W):
			var under := c.at(x, y)
			if under.a > 0.0:
				c.put(x, y, Color(DARKER.get(under.to_html(false), under.to_html(false))))
	var l0 := _root_edges(FLARE).x
	for y in range(top, bottom):
		var e := _root_edges(y)
		var band := maxf(e.x, e.y - 2.0 * _root_half(y))   # the climbing part, anchored on its east side
		for x in range(maxi(0, int(e.x)), mini(w, int(e.y) + 1)):
			var col: Color
			if x >= band:   # across the climbing part: lit west, shaded east
				var t := (x - band) / maxf(1.0, e.y - band)
				col = _root_col(t, x == int(e.x) and band <= e.x)
				if t > 0.15 and t < 0.85 and fmod(t * 9.0 + 0.35 * sin(y / 21.0), 1.0) < 0.12:
					col = ROOT.mid if t < 0.6 else ROOT.sh   # bark streaks along it
			else:   # the run coming in from the west: lit on its back, buried below
				var lip := FLARE + sqrt(maxf(0.0, (l0 - x) * 40.0))
				var v := (y - lip) / maxf(1.0, GROUND - lip)
				col = _root_col(0.06 + v * 0.88, y - lip < 1.0)
				if fmod(y * 0.37 + x * 0.05, 3.1) < 0.3 and v > 0.2:
					col = ROOT.mid   # its bark runs along it
			if y >= TREADS.x and y < TREADS.y:   # the lane's treads cut into its back
				col = ROOT.cut if (x + 3) % 12 > 1 else ROOT.dk
				if (x + 3) % 12 == 2 or y == TREADS.x:
					col = ROOT.hi
			c.put(x, y, col)
	for x in range(0, int(_root_edges(GROUND).y) + 2):   # grass over its buried side
		if _hash(x, 77) % 3 == 0:
			c.put(x, GROUND, MOSS.mid)
			c.put(x, GROUND - 1, MOSS.lit if _hash(x, 5) % 2 == 0 else MOSS.mid)
	# The brass band at the Stack's foot.
	for y in range(maxi(y0, 2), mini(y1, 9)):
		var e := _root_edges(y)
		for x in range(maxi(0, int(e.x) - 1), int(e.y) + 2):
			var f := (x - e.x) / maxf(1.0, e.y - e.x)
			var col := INK if y == 2 or y == 8 else _brass(f * 0.8, y - 3.0, 5.0)
			if y in [4, 6] and int(x) % 11 == 0:
				col = BRASS.sh
			c.put(x, y, col)
	# Rootlets gripping the courses east of it, and along the Stack's rings.
	for y: int in [150, 238, 475, 566, -73, -169]:
		if y < y0 or y >= y1:
			continue
		var x := int(_root_edges(y).y) - 2
		for k in 26 + _hash(y, 3) % 18:
			var yy := y + int(roundf(2.0 * sin(k / 4.0)))
			c.put(x + k, yy, ROOT.mid)
			c.put(x + k, yy + 1, ROOT.sh)


## Across the root at t (0 its west edge, 1 its east), lit from the west; `rim` is its outline.
static func _root_col(t: float, rim: bool) -> Color:
	if rim or t < 0.05 or t > 0.95:
		return ROOT.dk
	if t < 0.17:
		return ROOT.hi
	if t < 0.34:
		return ROOT.lit
	if t < 0.62:
		return ROOT.body
	if t < 0.82:
		return ROOT.mid
	return ROOT.sh


## The root's west and east edges at row y (area px). It wanders and swells; near the ground its west side opens out
## toward the west edge (it comes from there) and its east side rounds into the earth.
static func _root_edges(y: float) -> Vector2:
	var m := 52.0 + 8.0 * sin(y / 97.0) + 4.0 * sin(y / 37.0 + 1.3)
	var h := _root_half(y)
	var l := m - h + 2.0 * sin(y / 11.0)
	var r := m + h + 2.0 * sin(y / 13.0 + 2.0)
	if y > FLARE:
		l -= (y - FLARE) * (y - FLARE) / 40.0
	if y > GROUND - 46:
		r -= pow(y - (GROUND - 46), 2.0) / 60.0
	return Vector2(l, r)


static func _root_half(y: float) -> float:
	var h := 40.0 + 3.0 * sin(y / 53.0 + 0.7) + 2.0 * sin(y / 19.0)
	if y < 0.0:
		h += y / 60.0   # it thins as it climbs the Stack
	for e in [FACE2.x, FACE1.x]:
		h += 6.0 * exp(-pow((y - e - 6.0) / 16.0, 2.0))   # it swells where it bends over a step's edge
	return h


## Brass across a band `size` px tall at row `d` of it, its shade by f (0 west, 1 east): a lit top, a dark foot.
static func _brass(f: float, d: float, size: float) -> Color:
	if d < 1.0:
		return BRASS.hi if f < 0.5 else BRASS.lit
	if d >= size - 1.0:
		return BRASS.sh
	return BRASS.lit if f < 0.4 else (BRASS.mid if f < 0.75 else BRASS.sh)


## The Stack's light band at f across it (0 west, 1 east): 0 to 6, STACK_BASE's index.
static func _band(f: float) -> int:
	for k in STACK_EDGES.size():
		if f < STACK_EDGES[k]:
			return k
	return STACK_EDGES.size()


static func _lighter(c: Color) -> Color:
	match c.to_html(false):
		"9c8c68": return TAN
		"8e7f5e": return STONE
		"6b6d45": return MID
		"5f5e57": return MID
		"c7a378": return LIGHT
		"ccb290": return PALE
		"6b6f1d": return MOSS.lit
	return c


static func _hash(a: int, b: int) -> int:
	var h := (a * 73856093) ^ (b * 19349663)
	return absi(h) % 1000003


static func _done(key: String, img: Image) -> Image:
	_cache[key] = img
	return img


## A picture addressed in area px: `oy` is its top row's y, so every part paints with the numbers of the map.
class Cv:
	var img: Image
	var oy := 0
	var w := 0
	var h := 0

	func _init(size: Vector2i, top: int) -> void:
		img = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
		oy = top
		w = size.x
		h = size.y

	func put(x: int, y: int, c: Color) -> void:
		var yy := y - oy
		if x >= 0 and x < w and yy >= 0 and yy < h:
			img.set_pixel(x, yy, c)

	func at(x: int, y: int) -> Color:
		var yy := y - oy
		if x >= 0 and x < w and yy >= 0 and yy < h:
			return img.get_pixel(x, yy)
		return Color(0, 0, 0, 0)

	func rect(x: int, y: int, rw: int, rh: int, c: Color) -> void:
		var r := Rect2i(x, y - oy, rw, rh).intersection(Rect2i(0, 0, w, h))
		if r.size.x > 0 and r.size.y > 0:
			img.fill_rect(r, c)
