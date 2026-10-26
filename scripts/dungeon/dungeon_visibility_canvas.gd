extends Node2D
## Crisp unseen cells render after every world effect and before the HUD. The popups draw over it (dungeon.gd _pop_top,
## z 4096; LV-19, D4, Claude, 2026-10-24).
## A wall tile beside a floor tile in sight is drawn too (Claude, 2026-10-24, pass 6 P2 and P3, L6-24): a hallway was a
## strip of floor in the dark, because only its floor was in sight. Now its walls show what the painters drew there:
## the face on the north side, the lip on the south side, the cap row along a room's sides. A wall diagonal to the
## floor shows only at an outer corner, so a hallway's walls stop where its lit floor stops. Walls only; what stands
## on a floor tile still needs that tile in sight. The unseen is the painters' own black (it was #080b0e), so the
## edge you see is the cap row's stepped back edge, not the tile's.
const Gen := preload("res://scripts/hollow/hollow_gen.gd")
const FOG := Color.BLACK
var dungeon: Node2D
var _walls := {}        # wall tiles beside a floor tile in sight, worked out when the sight changes
var _sight_hash := 0
var _sight_data: Dictionary = {}
func _init(target: Node2D) -> void:
	dungeon=target
	z_index=4095
func _process(_delta: float) -> void: queue_redraw()
func _draw() -> void:
	var seen: Dictionary = dungeon.visible_tiles
	var data: Dictionary = dungeon.data
	var hv := seen.hash()
	if hv != _sight_hash or not is_same(data, _sight_data):
		_sight_hash = hv
		_sight_data = data
		_walls = walls_beside(seen, data)
	var origin: Vector2 = -dungeon._world.position
	var t0 := Vector2i(floori(origin.x/24)-1,floori(origin.y/24)-1)
	for y in range(t0.y,t0.y+12):
		for x in range(t0.x,t0.x+19):
			var p := Vector2i(x,y)
			if not seen.has(p) and not _walls.has(p):
				draw_rect(Rect2(x*24,y*24,24,24),FOG)


## The wall tiles beside each floor tile in sight: the four that share a side with it, and a diagonal one when both
## tiles between them are wall (an outer corner).
static func walls_beside(seen: Dictionary, data: Dictionary) -> Dictionary:
	var out := {}
	if not data.has("tiles"):
		return out
	var tiles: PackedByteArray = data["tiles"]
	var w: int = data["w"]
	var h: int = data["h"]
	var wall := func(x: int, y: int) -> bool:
		return x >= 0 and y >= 0 and x < w and y < h and tiles[y * w + x] == Gen.WALL
	for p: Vector2i in seen:
		if p.x < 0 or p.y < 0 or p.x >= w or p.y >= h or tiles[p.y * w + p.x] == Gen.WALL:
			continue
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				if not wall.call(p.x + dx, p.y + dy):
					continue
				if dx == 0 or dy == 0 or (wall.call(p.x + dx, p.y) and wall.call(p.x, p.y + dy)):
					out[Vector2i(p.x + dx, p.y + dy)] = true
					# The bank's top above a north face too, so a Rootbank Warren face reads two tiles high (Claude, 2026-10-26,
					# pass 7 F1, L7-12). In the Mouth it shows the cap row above its faces. At the face's outer corner the
					# tile above the corner too (Claude, 2026-10-26, pass 8 F1, L12): the painters wrap the top's back
					# course round the corner there, and the fog cut it off along a straight tile edge.
					if dy == -1 and wall.call(p.x + dx, p.y - 2):
						out[Vector2i(p.x + dx, p.y - 2)] = true
	return out
