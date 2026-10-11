extends RefCounted
## The Hollow floor generator (Claude, 2026-10-09; Preston: "do the slice"). Structure read from
## Explorers of Sky's floor parameters (docs/research/pmd-sky-references-2026-10-09.md), written
## from scratch: no code or data from that game. The floor is a grid of cells; each cell holds a
## room or a hallway junction; a random spanning tree joins every cell (connectivity), extra
## links add loops (extra hallway density), junctions left with one link are pruned unless dead
## ends are allowed. The start is a random room, the stairs the room farthest from it by walking
## distance, the wild creatures wait in the other rooms. Pure data, so a check can run it alone.
##
## Recipe keys (all drafts for Grok): cols, rows, cell_w, cell_h (tiles), room_density 0..1,
## extra_halls 0..1, dead_ends bool, hall_width (tiles), wild (how many), spawns [[line, stage], ...].

const TILE := 16
const WALL := 0
const FLOOR := 1

const DEFAULT := {"cols": 4, "rows": 3, "cell_w": 15, "cell_h": 12, "room_density": 0.7, "extra_halls": 0.2,
	"dead_ends": false, "hall_width": 3, "wild": 3, "spawns": []}


## Returns {w, h, tiles (PackedByteArray), rooms [Rect2i], start (Vector2i tile), stairs (Vector2i tile),
## spawns [Vector2i tile], links [[a, b]]}.
static func generate(seed_value: int, recipe: Dictionary = {}) -> Dictionary:
	var r: Dictionary = DEFAULT.duplicate()
	r.merge(recipe, true)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var cols: int = r["cols"]
	var rows: int = r["rows"]
	var cw: int = r["cell_w"]
	var ch: int = r["cell_h"]
	var w: int = cols * cw
	var h: int = rows * ch
	var tiles := PackedByteArray()
	tiles.resize(w * h)
	tiles.fill(WALL)
	var n: int = cols * rows
	# Which cells are rooms (never fewer than two).
	var is_room: Array[bool] = []
	for k in n:
		is_room.append(rng.randf() < r["room_density"])
	while is_room.count(true) < 2:
		is_room[rng.randi_range(0, n - 1)] = true
	# Links: a random spanning tree over neighbouring cells, then extra links.
	var links: Array = []
	var linked := {}
	var seen := {0: true}
	var stack: Array[int] = [rng.randi_range(0, n - 1)]
	seen = {stack[0]: true}
	while not stack.is_empty():
		var c: int = stack[-1]
		var options: Array[int] = []
		for nb in _neighbours(c, cols, rows):
			if not seen.has(nb):
				options.append(nb)
		if options.is_empty():
			stack.pop_back()
			continue
		var nb2: int = options[rng.randi_range(0, options.size() - 1)]
		seen[nb2] = true
		links.append([c, nb2])
		linked[_key(c, nb2)] = true
		stack.append(nb2)
	for c in n:
		for nb in _neighbours(c, cols, rows):
			if nb > c and not linked.has(_key(c, nb)) and rng.randf() < r["extra_halls"]:
				links.append([c, nb])
				linked[_key(c, nb)] = true
	# Prune junction cells left with one link (dead ends), repeatedly, unless dead ends are allowed.
	if not r["dead_ends"]:
		var changed := true
		while changed:
			changed = false
			for c in n:
				if is_room[c]:
					continue
				var deg := 0
				for l in links:
					if l[0] == c or l[1] == c:
						deg += 1
				if deg == 1:
					links = links.filter(func(l: Array) -> bool: return l[0] != c and l[1] != c)
					changed = true
	# Carve rooms, and a point for each junction that still has links.
	var anchors: Array[Vector2i] = []
	var rooms: Array[Rect2i] = []
	var room_of_cell := {}
	for c in n:
		var cx: int = (c % cols) * cw
		var cy: int = (c / cols) * ch
		if is_room[c]:
			var rw: int = rng.randi_range(7, cw - 3)
			var rh: int = rng.randi_range(6, ch - 3)
			var rx: int = cx + rng.randi_range(1, cw - 1 - rw)
			var ry: int = cy + rng.randi_range(1, ch - 1 - rh)
			var room := Rect2i(rx, ry, rw, rh)
			_carve(tiles, w, room)
			room_of_cell[c] = rooms.size()
			rooms.append(room)
			anchors.append(room.get_center())
		else:
			anchors.append(Vector2i(cx + cw / 2, cy + ch / 2))
	var half: int = int(r["hall_width"]) / 2
	for l in links:
		var a: Vector2i = anchors[l[0]]
		var b: Vector2i = anchors[l[1]]
		var corner := Vector2i(b.x, a.y) if rng.randf() < 0.5 else Vector2i(a.x, b.y)
		_carve(tiles, w, _span(a, corner, half))
		_carve(tiles, w, _span(corner, b, half))
	# Start, stairs, spawns.
	var start_room: int = rng.randi_range(0, rooms.size() - 1)
	var start: Vector2i = rooms[start_room].get_center()
	var dist := distances(tiles, w, h, start)
	var stairs_room := start_room
	var far := -1
	for k in rooms.size():
		var d: int = dist[rooms[k].get_center().y * w + rooms[k].get_center().x]
		if d > far:
			far = d
			stairs_room = k
	var stairs: Vector2i = rooms[stairs_room].get_center()
	var others: Array[int] = []
	for k in rooms.size():
		if k != start_room:
			others.append(k)
	var spawns: Array[Vector2i] = []
	for k in int(r["wild"]):
		if others.is_empty():
			break
		var room: Rect2i = rooms[others[k % others.size()]]
		var spot := Vector2i(rng.randi_range(room.position.x + 1, room.end.x - 2), rng.randi_range(room.position.y + 1, room.end.y - 2))
		if spot == stairs:
			spot.x = clampi(spot.x + 2, room.position.x, room.end.x - 1)
		spawns.append(spot)
	return {"w": w, "h": h, "tiles": tiles, "rooms": rooms, "start": start, "stairs": stairs, "spawns": spawns, "links": links}


## Walking distance in tiles from `from` to every tile (-1 where it cannot be reached).
static func distances(tiles: PackedByteArray, w: int, h: int, from: Vector2i) -> PackedInt32Array:
	var dist := PackedInt32Array()
	dist.resize(w * h)
	dist.fill(-1)
	if tiles[from.y * w + from.x] == WALL:
		return dist
	dist[from.y * w + from.x] = 0
	var queue: Array[Vector2i] = [from]
	var head := 0
	while head < queue.size():
		var p: Vector2i = queue[head]
		head += 1
		for d in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]:
			var q: Vector2i = p + d
			if q.x < 0 or q.y < 0 or q.x >= w or q.y >= h:
				continue
			var k: int = q.y * w + q.x
			if tiles[k] == WALL or dist[k] >= 0:
				continue
			dist[k] = dist[p.y * w + p.x] + 1
			queue.append(q)
	return dist


static func _neighbours(c: int, cols: int, rows: int) -> Array[int]:
	var out: Array[int] = []
	var x: int = c % cols
	var y: int = c / cols
	if x > 0: out.append(c - 1)
	if x < cols - 1: out.append(c + 1)
	if y > 0: out.append(c - cols)
	if y < rows - 1: out.append(c + cols)
	return out


static func _key(a: int, b: int) -> String:
	return "%d-%d" % [mini(a, b), maxi(a, b)]


static func _span(a: Vector2i, b: Vector2i, half: int) -> Rect2i:
	var lo := Vector2i(mini(a.x, b.x) - half, mini(a.y, b.y) - half)
	var hi := Vector2i(maxi(a.x, b.x) + half, maxi(a.y, b.y) + half)
	return Rect2i(lo, hi - lo + Vector2i.ONE)


static func _carve(tiles: PackedByteArray, w: int, rect: Rect2i) -> void:
	var h: int = tiles.size() / w
	for y in range(maxi(1, rect.position.y), mini(h - 1, rect.end.y)):
		for x in range(maxi(1, rect.position.x), mini(w - 1, rect.end.x)):
			tiles[y * w + x] = FLOOR
