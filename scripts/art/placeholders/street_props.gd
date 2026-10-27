extends RefCounted
## Highbank's street lamp and street props, painted in code (Claude, 2026-10-26, placeholder factory lane C; build plan
## section 2.3). The placeholders the rows of scripts/art/slots/town_street.gd name ("res://scripts/art/placeholders/
## street_props.gd:<method>"): Grok's slots, shown until Grok's file is installed. Today's map has no props, so nothing
## here is on screen until an area lists props (TownProps draws them).
##
## The house rules for a prop (03-spec-format.md 2.2): exactly the slot's sheet, binary alpha, a 1 px clear margin on
## every side but the ground (the fences touch the sides they tile across), a drawn 1 px outline in ink, lit from the
## upper left and shaded to the lower right, the lowest opaque row on the slot's foot row, at most 24 colours. House
## colours only (building_exteriors.gd and ui_style.gd, through PlaceholderPainter's ramps). The ground shadow is not
## in the picture: TownProps lays it under the prop, so an installed file drops onto the same foot.
##
## The lamp's glow and flicker stay in code (TownProps); its two stills differ only in the glass. The waymark keeps the
## Crossroads' coded look: its three arrow boards wear the three tints of the carved three-route glyph
## (crossroads_painter.gd _marker) on a timber post with a limestone foot from the plaza's stones.

const INK := Color("#0b0e11")
const TIMBER := Color("#80694a")      # building_exteriors.gd WOOD
const POST := Color("#5e4129")        # the dark timber of the Landing's old mooring posts (highbank_painter.gd)
const STONE := Color("#8f805e")       # building_exteriors.gd STONE
const LIMESTONE := Color("#ac9874")   # the Crossroads' stones (crossroads_painter.gd STONES)
const IRON := Color("#5b6470")        # PlaceholderPainter SLATE
const LANTERN := Color("#f2c14e")     # ui_style.gd LIGHT
const FLAME := Color("#fff4e8")       # ui_style.gd TEXT: the lantern's hot core
const GLASS := Color("#3a4652")       # an unlit pane
const GLINT := Color("#a9d4d6")       # highbank_painter.gd GLINT: light on dark glass
const ROPE := Color("#c9a77a")        # PlaceholderPainter's dawn family
const WATER := Color("#3b6f7c")       # highbank_painter.gd MID
const LEAF := Color("#5b8a3c")        # valley_painter.gd MEADOW[1], the one grass
const ROUTES := [Color("#a99870"), Color("#ceb386"), Color("#eee0bf")]   # crossroads_painter.gd _marker's three tints


# ---------------------------------------------------------------- one method per slot (the rows' "placeholder" hooks)

## town.lamp.post: a dark timber post on a stone plinth, an iron arm and a glass lantern box at the light anchor. The
## "unlit" row has dark panes with a glint; the "lit" row a lantern-gold pane with a hot core.
static func lamp_post(_id: String, spec: Dictionary) -> Image:
	return _sheet(spec, func(img: Image, state: String, _f: int) -> void:
		var la: Vector2i = spec.get("light_anchor", Vector2i(12, 8))
		var h := img.get_height()
		PlaceholderPainter.block(img, Rect2i(la.x - 2, la.y + 6, 4, h - la.y - 10), POST)   # the post
		PlaceholderPainter.block(img, Rect2i(la.x - 5, h - 5, 10, 5), STONE)                # the plinth
		_rect(img, Rect2i(la.x - 4, la.y + 5, 8, 2), _ramp(IRON)[2])                        # the iron arm under the box
		_px(img, la.x - 4, la.y + 7, INK)
		_px(img, la.x + 3, la.y + 7, INK)
		PlaceholderPainter.block(img, Rect2i(la.x - 5, la.y - 6, 10, 12), IRON)             # the lantern box
		PlaceholderPainter.block(img, Rect2i(la.x - 4, la.y - 7, 8, 2), _ramp(IRON)[2])     # its cap
		var pane := Rect2i(la.x - 3, la.y - 4, 6, 8)
		if state == "lit":
			_rect(img, pane, LANTERN)
			_rect(img, Rect2i(la.x - 1, la.y - 2, 2, 4), FLAME)
			_rect(img, Rect2i(la.x - 3, la.y + 3, 6, 1), _ramp(LANTERN)[2])
		else:
			_rect(img, pane, GLASS)
			_px(img, la.x - 2, la.y - 3, GLINT)
			_px(img, la.x - 2, la.y - 2, GLINT)
			_rect(img, Rect2i(la.x, la.y - 4, 1, 8), _ramp(IRON)[3]))                       # the dark box's mullion


## town.prop.well: a round river-stone well with a small timber roof on two posts, a crossbar, rope and bucket.
static func well(_id: String, spec: Dictionary) -> Image:
	return _sheet(spec, func(img: Image, _state: String, _f: int) -> void:
		var w := img.get_width()
		var h := img.get_height()
		var sr := _ramp(STONE)
		PlaceholderPainter.block(img, Rect2i(6, 10, 4, 20), POST)                 # the posts
		PlaceholderPainter.block(img, Rect2i(w - 10, 10, 4, 20), POST)
		PlaceholderPainter.block(img, Rect2i(9, 12, w - 18, 3), TIMBER)          # the crossbar
		_rect(img, Rect2i(w / 2 - 1, 15, 1, 6), ROPE)                             # rope and bucket
		PlaceholderPainter.block(img, Rect2i(w / 2 - 4, 20, 8, 6), TIMBER)
		_rect(img, Rect2i(w / 2 - 3, 22, 6, 1), _ramp(IRON)[1])
		# The roof: a small timber gable over the posts (the brief's), its ridge at the top, eaves past the posts.
		var mr := _ramp(_ramp(TIMBER)[2])
		for y in range(1, 11):
			var half := mini(w / 2 - 2, 4 + (y - 1) * 2)
			_rect(img, Rect2i(w / 2 - half, y, half * 2, 1), mr[1] if y > 2 else mr[0])
			_px(img, w / 2 - half, y, INK)
			_px(img, w / 2 + half - 1, y, INK)
			if y % 3 == 0:
				_rect(img, Rect2i(w / 2 - half + 2, y, half * 2 - 4, 1), mr[2])   # shingle courses
		_rect(img, Rect2i(2, 10, w - 4, 1), INK)                                   # the drip line
		_rect(img, Rect2i(w / 2 - 4, 1, 8, 1), INK)
		# The drum: stone courses, staggered joints, a lit rim round a dark opening.
		PlaceholderPainter.block(img, Rect2i(4, 31, w - 8, h - 31), STONE)
		for y in range(37, h - 2, 6):
			_rect(img, Rect2i(5, y, w - 10, 1), sr[2])
			var off := 0 if (y / 6) % 2 == 0 else 4
			for x in range(8 + off, w - 6, 8):
				_rect(img, Rect2i(x, y + 1, 1, 5), sr[2])
		PlaceholderPainter.block(img, Rect2i(2, 26, w - 4, 7), _ramp(STONE)[0])
		_rect(img, Rect2i(6, 28, w - 12, 3), WATER)
		_rect(img, Rect2i(6, 28, w - 12, 1), INK))


## town.prop.bench: a plank street bench on two stone feet, with a back rail.
static func bench(_id: String, spec: Dictionary) -> Image:
	return _sheet(spec, func(img: Image, _state: String, _f: int) -> void:
		var w := img.get_width()
		var h := img.get_height()
		var tr := _ramp(TIMBER)
		PlaceholderPainter.block(img, Rect2i(8, 9, 3, 10), POST)                  # the back rail's posts
		PlaceholderPainter.block(img, Rect2i(w - 11, 9, 3, 10), POST)
		PlaceholderPainter.block(img, Rect2i(4, 5, w - 8, 5), TIMBER)             # the back rail
		PlaceholderPainter.block(img, Rect2i(6, h - 10, 6, 10), STONE)            # the feet
		PlaceholderPainter.block(img, Rect2i(w - 12, h - 10, 6, 10), STONE)
		PlaceholderPainter.block(img, Rect2i(2, h - 15, w - 4, 6), TIMBER)        # the seat, two planks
		_rect(img, Rect2i(3, h - 12, w - 6, 1), tr[2])
		for x in [14, 30]:
			_px(img, x, h - 13, INK)                                               # nails
			_px(img, x, h - 11, INK))


## town.prop.crates: two courier crates, the smaller on top, a rope band round both.
static func crates(_id: String, spec: Dictionary) -> Image:
	return _sheet(spec, func(img: Image, _state: String, _f: int) -> void:
		var w := img.get_width()
		var h := img.get_height()
		var tr := _ramp(TIMBER)
		PlaceholderPainter.block(img, Rect2i(1, h - 12, w - 2, 12), TIMBER)
		_rect(img, Rect2i(2, h - 7, w - 4, 1), tr[2])
		for i in 8:   # a brace across the lower crate's face
			_px(img, 3 + i * 2, h - 3 - i, tr[3])
			_px(img, 4 + i * 2, h - 3 - i, tr[3])
		PlaceholderPainter.block(img, Rect2i(5, 3, w - 10, 10), tr[0])
		_rect(img, Rect2i(6, 8, w - 12, 1), tr[2])
		_rect(img, Rect2i(w / 2 - 1, 3, 2, h - 3), ROPE)
		_rect(img, Rect2i(w / 2, 4, 1, h - 5), _ramp(ROPE)[2])
		_px(img, w / 2 - 1, 3, INK)
		_px(img, w / 2, 3, INK))


## town.prop.barrel: a banded timber water barrel, staves bulging at the middle, water under the rim.
static func barrel(_id: String, spec: Dictionary) -> Image:
	return _sheet(spec, func(img: Image, _state: String, _f: int) -> void:
		var w := img.get_width()
		var h := img.get_height()
		var tr := _ramp(TIMBER)
		var ir := _ramp(IRON)
		var cx := w / 2
		for y in range(2, h):
			var half := 7 + (1 if y >= 6 and y <= h - 6 else 0)
			for x in range(cx - half, cx + half):
				var k := x - (cx - half)
				var c: Color = tr[1]
				if k <= 1:
					c = tr[0]
				elif k >= half * 2 - 3:
					c = tr[2]
				if (x - cx) % 4 == 0 and k > 1 and k < half * 2 - 2:
					c = tr[2]   # stave joints
				if y == h - 1 or k == 0 or k == half * 2 - 1:
					c = INK
				_px(img, x, y, c)
		for band in [6, h - 7]:
			for y in [band, band + 1]:
				_rect(img, Rect2i(cx - 7, y, 14, 1), ir[1] if y == band else ir[2])
				_px(img, cx - 8, y, INK)
				_px(img, cx + 7, y, INK)
		PlaceholderPainter.block(img, Rect2i(cx - 7, 1, 14, 5), tr[0])   # the rim
		_rect(img, Rect2i(cx - 5, 2, 10, 2), WATER)
		_rect(img, Rect2i(cx - 5, 2, 4, 1), GLINT))


## town.prop.planter: a stone planter box with a low green shrub in round clumps.
static func planter(_id: String, spec: Dictionary) -> Image:
	return _sheet(spec, func(img: Image, _state: String, _f: int) -> void:
		var w := img.get_width()
		var h := img.get_height()
		_clumps(img, [Vector3i(8, 9, 5), Vector3i(15, 8, 5), Vector3i(12, 5, 4)], LEAF)
		PlaceholderPainter.block(img, Rect2i(2, h - 10, w - 4, 10), STONE)
		PlaceholderPainter.block(img, Rect2i(1, h - 12, w - 2, 3), _ramp(STONE)[0])
		_rect(img, Rect2i(4, h - 5, w - 8, 1), _ramp(STONE)[2]))


## town.prop.fence_h: one span of low timber fence, its rails running left to right through the cell so it tiles with
## itself; the post in the middle.
static func fence_h(_id: String, spec: Dictionary) -> Image:
	return _sheet(spec, func(img: Image, _state: String, _f: int) -> void:
		var w := img.get_width()
		var h := img.get_height()
		for top in [9, 15]:
			_rail_h(img, 0, w, top)
		PlaceholderPainter.block(img, Rect2i(w / 2 - 3, 5, 6, h - 5), POST)
		_rect(img, Rect2i(w / 2 - 2, 6, 4, 1), _ramp(POST)[0]))


## town.prop.fence_v: one span of fence running away from the camera: the rail seen from above runs top to bottom
## through the cell so it tiles with itself; a post in the middle.
static func fence_v(_id: String, spec: Dictionary) -> Image:
	return _sheet(spec, func(img: Image, _state: String, _f: int) -> void:
		var w := img.get_width()
		var h := img.get_height()
		_rail_v(img, 0, h, w / 2 - 2)
		PlaceholderPainter.block(img, Rect2i(w / 2 - 4, 6, 8, 13), POST)
		_rect(img, Rect2i(w / 2 - 3, 7, 6, 2), _ramp(POST)[0]))


## town.prop.fence_corner: the corner post where a left-right span (to the right) meets a front-back span (down).
static func fence_corner(_id: String, spec: Dictionary) -> Image:
	return _sheet(spec, func(img: Image, _state: String, _f: int) -> void:
		var w := img.get_width()
		var h := img.get_height()
		for top in [9, 15]:
			_rail_h(img, w / 2 + 3, w, top)
		_rail_v(img, 18, h, w / 2 - 2)
		PlaceholderPainter.block(img, Rect2i(w / 2 - 4, 5, 8, 14), POST)
		_rect(img, Rect2i(w / 2 - 3, 6, 6, 2), _ramp(POST)[0]))


## town.prop.mooring_post: a thick timber post with a rounded top and a coil of rope, its foot dark with the wet.
static func mooring_post(_id: String, spec: Dictionary) -> Image:
	return _sheet(spec, func(img: Image, _state: String, _f: int) -> void:
		var w := img.get_width()
		var h := img.get_height()
		var pr := _ramp(POST)
		PlaceholderPainter.block(img, Rect2i(7, 4, w - 14, h - 4), POST)
		PlaceholderPainter.block(img, Rect2i(8, 2, w - 16, 4), pr[0])          # the worn round top
		for x in [10, 13]:
			_rect(img, Rect2i(x, 7, 1, h - 16), pr[2])                         # grain
		_rect(img, Rect2i(8, h - 6, w - 16, 5), pr[3])                        # the wet foot
		var rr := _ramp(ROPE)
		for i in 3:
			var y := 15 + i * 3
			_rect(img, Rect2i(5, y, w - 10, 2), rr[1] if i % 2 == 0 else rr[0])
			_rect(img, Rect2i(5, y + 2, w - 10, 1), rr[3])
			_px(img, 5, y, INK)
			_px(img, w - 6, y + 1, INK))


## town.prop.road_barrier: two timber posts, a top rail, a foot rail and crossed planks between: the way is shut,
## with no words.
static func road_barrier(_id: String, spec: Dictionary) -> Image:
	return _sheet(spec, func(img: Image, _state: String, _f: int) -> void:
		var w := img.get_width()
		var h := img.get_height()
		var tr := _ramp(TIMBER)
		PlaceholderPainter.block(img, Rect2i(2, 12, 4, h - 12), POST)
		PlaceholderPainter.block(img, Rect2i(w - 6, 12, 4, h - 12), POST)
		for i in 26:   # the two crossed planks, three px thick, lit on top
			for dir in [1, -1]:
				var x: int = (5 + i * 11 / 25) if dir == 1 else (w - 8 - i * 11 / 25)
				var y := 20 + i
				_rect(img, Rect2i(x, y, 3, 1), tr[1])
				_px(img, x, y - 1, tr[0])
				_px(img, x + (2 if dir == 1 else 0), y + 1, INK)
		PlaceholderPainter.block(img, Rect2i(1, 14, w - 2, 5), TIMBER)          # the top rail
		PlaceholderPainter.block(img, Rect2i(1, h - 14, w - 2, 4), TIMBER)      # the foot rail
		for x in [3, w - 5]:
			_px(img, x, 16, INK)                                                # nails
			_px(img, x, h - 12, INK))


## town.prop.waymark: the Crossroads waymark, a timber post on a limestone foot with three arrow boards in the three
## tints of the carved three-route glyph (no letters).
static func waymark(_id: String, spec: Dictionary) -> Image:
	return _sheet(spec, func(img: Image, _state: String, _f: int) -> void:
		var w := img.get_width()
		var h := img.get_height()
		PlaceholderPainter.block(img, Rect2i(w / 2 - 2, 4, 4, h - 9), TIMBER)    # the post
		PlaceholderPainter.block(img, Rect2i(w / 2 - 3, 2, 6, 3), POST)          # its cap
		PlaceholderPainter.block(img, Rect2i(w / 2 - 6, h - 7, 12, 7), LIMESTONE)   # the foot
		_rect(img, Rect2i(w / 2 - 5, h - 4, 10, 1), _ramp(LIMESTONE)[2])
		_board(img, 7, 6, 19, 1, ROUTES[0])
		_board(img, 15, 3, 17, -1, ROUTES[1])
		_board(img, 23, 7, 19, 1, ROUTES[2]))


# ---------------------------------------------------------------- shared drawing

## The slot's whole sheet: `paint` draws each cell (its state's name and frame index), then the edges its rule keeps
## clear are cleared, so a stray pixel can never fail C4.
static func _sheet(spec: Dictionary, paint: Callable) -> Image:
	var want: Vector2i = spec.get("sheet_size", spec.get("size", Vector2i(24, 24)))
	var size: Vector2i = spec.get("size", want)
	var sheet := Image.create(want.x, want.y, false, Image.FORMAT_RGBA8)
	var states: Dictionary = spec.get("states", {"static": [1, 0]})
	var allowed := PlaceholderPainter.allowed_sides(spec.get("edges", "bottom"))
	var row := 0
	for st in states:
		for f in maxi(1, int(states[st][0])):
			var cell := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
			paint.call(cell, String(st), f)
			var clear := Color(0, 0, 0, 0)
			if not allowed.has("top"):
				cell.fill_rect(Rect2i(0, 0, size.x, 1), clear)
			if not allowed.has("bottom"):
				cell.fill_rect(Rect2i(0, size.y - 1, size.x, 1), clear)
			if not allowed.has("left"):
				cell.fill_rect(Rect2i(0, 0, 1, size.y), clear)
			if not allowed.has("right"):
				cell.fill_rect(Rect2i(size.x - 1, 0, 1, size.y), clear)
			sheet.blit_rect(cell, Rect2i(Vector2i.ZERO, size), Vector2i(f * size.x, row * size.y))
		row += 1
	return sheet


static func _ramp(base: Color) -> Array[Color]:
	return PlaceholderPainter.ramp(base)


static func _px(img: Image, x: int, y: int, c: Color) -> void:
	if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
		img.set_pixel(x, y, c)


static func _rect(img: Image, r: Rect2i, c: Color) -> void:
	var cut := r.intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	if cut.has_area():
		img.fill_rect(cut, c)


## A rail running left to right from x0 to x1 (exclusive) at row `top`: a lit top, its face, an ink underside. No end
## caps, so a span meets the next one without a seam.
static func _rail_h(img: Image, x0: int, x1: int, top: int) -> void:
	var tr := _ramp(TIMBER)
	_rect(img, Rect2i(x0, top, x1 - x0, 1), tr[0])
	_rect(img, Rect2i(x0, top + 1, x1 - x0, 1), tr[1])
	_rect(img, Rect2i(x0, top + 2, x1 - x0, 1), INK)


## A rail seen from above, running top to bottom from y0 to y1 (exclusive) at column `left`: lit left, its top face,
## shaded right, ink either side.
static func _rail_v(img: Image, y0: int, y1: int, left: int) -> void:
	var tr := _ramp(TIMBER)
	_rect(img, Rect2i(left - 1, y0, 1, y1 - y0), INK)
	_rect(img, Rect2i(left, y0, 1, y1 - y0), tr[0])
	_rect(img, Rect2i(left + 1, y0, 2, y1 - y0), tr[1])
	_rect(img, Rect2i(left + 3, y0, 1, y1 - y0), tr[2])
	_rect(img, Rect2i(left + 4, y0, 1, y1 - y0), INK)


## An arrow board on the waymark: rows top..top+4, from x0 to x1 (inclusive), its point 2 px past x1 (dir 1, right) or
## x0 (dir -1, left), in one tint lit on top and shaded below, ink round it.
static func _board(img: Image, top: int, x0: int, x1: int, dir: int, tint: Color) -> void:
	var r := _ramp(tint)
	for y in range(top, top + 5):
		var c: Color = r[0] if y == top + 1 else (r[2] if y == top + 3 else r[1])
		if y == top or y == top + 4:
			c = INK
		_rect(img, Rect2i(x0, y, x1 - x0 + 1, 1), c)
		var reach := 2 - absi(y - (top + 2))   # the point: 2 px at the middle row, 0 at the edges
		for k in reach:
			_px(img, x1 + 1 + k if dir == 1 else x0 - 1 - k, y, INK if k == reach - 1 else c)
	_rect(img, Rect2i(x0, top, 1, 5) if dir == 1 else Rect2i(x1, top, 1, 5), INK)   # the square end


## Round leaf clumps (Vector3i: centre x, centre y, radius): the union's edge in the leaf's deepest tone, each pixel lit
## where the clump rises toward the upper left and shaded where it falls away to the lower right.
static func _clumps(img: Image, clumps: Array, base: Color) -> void:
	var r := _ramp(base)
	var inside := func(x: int, y: int) -> bool:
		for c: Vector3i in clumps:
			if Vector2(x - c.x, y - c.y).length() <= c.z:
				return true
		return false
	for y in img.get_height():
		for x in img.get_width():
			if not inside.call(x, y):
				continue
			var c: Color = r[1]
			if not inside.call(x - 1, y - 1):
				c = r[0]
			elif not inside.call(x + 1, y + 1):
				c = r[2]
			if not inside.call(x - 1, y) or not inside.call(x + 1, y) or not inside.call(x, y - 1) or not inside.call(x, y + 1):
				c = r[3]
			_px(img, x, y, c)
