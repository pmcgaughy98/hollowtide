extends RefCounted
## The dungeon's marks, painted in code (Claude, 2026-10-26, placeholder factory lane D; build plan section 3, row D).
## Three painters the dungeon slot rows name in their "placeholder" field (scripts/art/slots/dungeon.gd):
##   stairs_sealed: Grok's slot. Until Grok's file is installed, a slate slab with a teal seal ring set into it, in
##     place of the red X the sealed stairs wore.
##   sleep_mark: Claude's slot, so this is the finished art. A hand-placed pixel z with an ink shadow, three frames of
##     a breath (dim, mid, bright); the dungeon steps them with the same breath that bobs it, in place of a font letter.
##   shot: Claude's twelve essence shots, also finished art. One 4x4 shape per essence inside its 6x6 cell, three
##     frames of flight each, in the essence's own colour ramp, in place of the round dot.
## Each returns exactly the slot's sheet_size with binary alpha, and keeps clear of the edges its kind forbids (effects
## and HUD pieces touch no edge; the stairs touch only the bottom), so art_slots_check's C1, C3 and C4 hold.

const INK := Color("#0b0e11")
const SLATE := Color("#5b6470")
const SEAL := Color("#3fa79b")
const SHADOW := Color("#2b3326")
const ZZZ := Color(0.85, 0.9, 1.0)   # the colour the sleeping "z" had as a font letter

## The z, hand-placed: 4 wide and 5 tall at (1, 1) in the 7x8 cell; its ink shadow sits one pixel down and right.
## Rows: "t" top bar, "d" the diagonal, "b" bottom bar (each row takes its own tone per frame).
const Z_ROWS := ["tttt", "...d", "..d.", ".d..", "bbbb"]
## Per frame, the tone of the top bar, the diagonal and the bottom bar: W white, L lit, B base, S shade.
const Z_TONES := [["B", "S", "S"], ["L", "B", "S"], ["W", "L", "B"]]

## The twelve shots: three 4x4 frames each, placed at (1, 1) in the 6x6 cell. W is the hot core (the essence colour
## lightened), L lit, B base, S shade, D deep: the four steps of PlaceholderPainter.ramp, light from the upper left.
const SHOTS := {
	"ember": [[".L..", "LWB.", "BWBS", ".SD."], ["..L.", ".WLB", "BWBS", ".SD."], [".LL.", "LWWB", "BBBS", ".SD."]],   # a flame ball, its tip flickering
	"tide": [[".LB.", "LWBB", "BBBS", ".SS."], ["....", "LWLB", "BBBS", "SSSD"], [".LB.", ".WB.", ".BS.", ".SD."]],   # a droplet that squashes and stretches
	"bloom": [["..LB", ".LWB", "LBBS", "BS.."], [".LB.", "LWBB", "BBBS", ".SS."], ["LB..", "BWL.", "SBBL", "..SB"]],   # a seed spinning end over end
	"electric": [["L..B", ".WL.", ".LW.", "B..S"], [".LB.", "LWWB", "BWWS", ".BS."], ["..L.", "LWB.", ".BWS", ".S.."]],   # a spark: cross, flash, zigzag
	"stone": [["LLB.", "LBBS", "BBSD", ".SD."], [".LLB", "LBBS", "BBSD", ".DS."], [".LB.", "LBBB", "BBSS", "SDD."]],   # a chunky pebble tumbling
	"gale": [[".LL.", "...B", "...B", "..S."], ["....", "S...", "B..L", ".BL."], [".BB.", "L..S", "L...", "...."]],   # an open swirl turning clockwise
	"blight": [["B...", ".LB.", ".BS.", "...D"], [".BB.", "BLBS", "BBSS", ".SS."], ["...B", ".LB.", ".BS.", "D..."]],   # spores that puff out and drift
	"hollow": [[".BB.", "B..S", "B..S", ".SS."], [".LB.", "L..S", "B..D", ".SD."], [".BL.", "B..L", "S..B", ".DS."]],   # a ring with nothing inside it
	"ice": [["..LL", ".LWB", "LBS.", "BS.."], ["..LW", ".LBB", "LBS.", "BS.."], ["..LL", ".LBB", "WBS.", "BS.."]],   # a shard, its glint running along it
	"loam": [[".LB.", "LBSB", "BSDS", "...D"], ["LB..", "BBSB", "SBDS", ".D.."], [".LB.", "BLBS", "BSDB", "D..."]],   # a clod shedding a crumb
	"murk": [["LBB.", "BSDB", "BDSB", ".BS."], [".BBL", "BSDB", "BDSB", ".SB."], [".BB.", "BSDB", "BDSB", "LSB."]],   # a dark blob, a wisp circling it
	"sinew": [[".LB.", "LBSB", "BSBS", ".SD."], [".BL.", "BLBS", "SBLB", ".DS."], [".LB.", "BSLB", "LBSB", ".SD."]],   # a taut knot, its striations pulsing
}


## dungeon.prop.stairs_sealed: a slate slab over the stair opening with a teal seal ring set into it (24x24, foot
## anchor (12, 23)). Grok paints the real one; this stands in until Preston says yes to it.
static func stairs_sealed(_id: String, spec: Dictionary) -> Image:
	var want: Vector2i = spec.get("sheet_size", Vector2i(24, 24))
	var img := Image.create(want.x, want.y, false, Image.FORMAT_RGBA8)
	var w := want.x
	var h := want.y
	# The slab, one pixel in from the top and the sides (only the bottom edge may be touched), and a contact shadow
	# along the bottom row under it.
	PlaceholderPainter.block(img, Rect2i(1, 1, w - 2, h - 2), SLATE)
	img.fill_rect(Rect2i(2, h - 1, w - 3, 1), SHADOW)
	var rp := PlaceholderPainter.ramp(SLATE)
	# Two chisel marks in the stone, upper left and lower right.
	img.fill_rect(Rect2i(4, 4, 3, 1), rp[2])
	img.fill_rect(Rect2i(w - 7, h - 6, 3, 1), rp[2])
	# The seal: an ink groove round a 2 px teal ring, lit on its upper left, shaded on its lower right, and a stud.
	var sr := PlaceholderPainter.ramp(SEAL)
	var c := Vector2(w, h - 1) * 0.5
	for y in range(2, h - 2):
		for x in range(2, w - 2):
			var d := Vector2(x + 0.5, y + 0.5) - c
			var r := d.length()
			if r >= 6.0 and r < 7.0:
				img.set_pixel(x, y, INK)
			elif r >= 4.0 and r < 6.0:
				var side := d.x + d.y
				img.set_pixel(x, y, sr[0] if side < -2.0 else (sr[2] if side > 2.0 else sr[1]))
	var stud := Vector2i(int(c.x) - 1, int(c.y) - 1)
	img.fill_rect(Rect2i(stud, Vector2i(2, 2)), sr[1])
	img.set_pixelv(stud, sr[0])
	return img


## dungeon.hud_piece.sleep_mark: the z, three frames of a breath in one 21x8 sheet (frame 0 dim, 2 bright).
static func sleep_mark(_id: String, spec: Dictionary) -> Image:
	var size: Vector2i = spec.get("size", Vector2i(7, 8))
	var want: Vector2i = spec.get("sheet_size", Vector2i(size.x * 3, size.y))
	var img := Image.create(want.x, want.y, false, Image.FORMAT_RGBA8)
	var tone := {"W": _q(Color(0.97, 0.98, 1.0)), "L": _q(ZZZ), "B": _q(ZZZ.darkened(0.15)), "S": _q(ZZZ.darkened(0.3))}
	for f in mini(3, want.x / size.x):
		var o := Vector2i(f * size.x + 1, 1)
		# The shadow first, so the z covers the shadow's overlap with itself.
		for y in Z_ROWS.size():
			for x in String(Z_ROWS[y]).length():
				if String(Z_ROWS[y])[x] != ".":
					img.set_pixelv(o + Vector2i(x + 1, y + 1), INK)
		for y in Z_ROWS.size():
			for x in String(Z_ROWS[y]).length():
				var part := String(Z_ROWS[y])[x]
				if part != ".":
					var t: String = Z_TONES[f]["tdb".find(part)]
					img.set_pixelv(o + Vector2i(x, y), tone[t])
	return img


## dungeon.effect.shot_<essence>: the essence's three flight frames in one 18x6 sheet, in its tint's ramp.
static func shot(id: String, spec: Dictionary) -> Image:
	var size: Vector2i = spec.get("size", Vector2i(6, 6))
	var want: Vector2i = spec.get("sheet_size", Vector2i(size.x * 3, size.y))
	var img := Image.create(want.x, want.y, false, Image.FORMAT_RGBA8)
	var ess := id.get_slice(".", 2).trim_prefix("shot_")
	if not SHOTS.has(ess):
		return img
	var base := _q(Color(String(spec.get("tint", "#fff2b3"))))
	var rp := PlaceholderPainter.ramp(base)
	var tone := {"W": _q(base.lightened(0.6)), "L": rp[0], "B": rp[1], "S": rp[2], "D": rp[3]}
	var frames: Array = SHOTS[ess]
	for f in mini(frames.size(), want.x / size.x):
		var rows: Array = frames[f]
		for y in rows.size():
			for x in String(rows[y]).length():
				var t := String(rows[y])[x]
				if tone.has(t):
					img.set_pixel(f * size.x + 1 + x, 1 + y, tone[t])
	return img


static func _q(c: Color) -> Color:
	return Color(roundf(c.r * 255.0) / 255.0, roundf(c.g * 255.0) / 255.0, roundf(c.b * 255.0) / 255.0, 1.0)
