extends "res://scripts/arena/arena_prototype.gd"
## A Hollow floor (Claude, 2026-10-09; Preston: "do the slice"). The first slice of the
## mystery-dungeon synthesis (docs/research/pmd-sky-references-2026-10-09.md): a generated floor
## of rooms and hallways, fought in real time on the arena engine. You steer your lead creature
## with the arena controls, your partners follow and fight with Kit Sense, wild creatures sleep
## in their rooms until something of yours comes into sight, and the stairs lead down. Three
## floors to a Hollow; fainting sends you back to the top. Every number is a draft for Grok;
## "the Hollows" is a working name.
##
## How it plugs in: the arena draws whatever map it is given and asks _floor() and _blocked()
## where creatures may stand, so this script builds the floor image from the arena's own ground
## art, answers those two questions from the generated tiles, follows the leader with the
## camera, and adds what a dungeon needs: sleeping wild creatures, walking around walls, walls
## that stop shots, and stairs.

const Gen := preload("res://scripts/hollow/hollow_gen.gd")
const FLOORS := 3
const AGGRO := 110.0                   # a sleeping wild creature wakes when something of yours is this close and in sight
const WAKE_ROOM := 70.0                # and wakes the others this close to it
const FOLLOW_GAP := 34.0               # partners keep about this far behind the leader
const STAIRS_REACH := 12.0
const PATH_COMMIT := 0.5               # once walking around a wall, keep at it this long (stops flip-flopping)
const BODY_HALF := 7.0                 # half a creature's width, for the wide line of sight
const STAIRS_HOLD := 0.6               # standing on the stairs this long takes them, so a dodge across them does not
## The first Hollow's floor recipe (drafts for Grok): stage 1 forms from four lines.
const RECIPE := {"wild": 3, "spawns": [[2, 0], [3, 0], [7, 0], [9, 0]]}

var party: Array = [[0, 0], [1, 0]]    # your team, [line, stage]; the first one is the one you steer
var floor_n := 1
var floor_seed := 0
var _data: Dictionary = {}
var _fields: Dictionary = {}            # walking-distance fields toward a tile, cached for path finding
var _changing := false
var _on_stairs := 0.0
var _label_floor: Label
var cleared := 0                        # how many Hollows finished (for the check)
## Battle mode (2026-10-09): the turn-based dungeon hands one fight to this floor. It brings its
## own floor data, painted picture, tile size and creatures; this floor plays the fight in real
## time and reports back through match_over.
var tile: int = Gen.TILE
var battle_mode := false
var given_texture: Texture2D = null
var spec: Array = []                    # [[team 0 creatures], [team 1 creatures]], each {line, stage, px, frac, facing}


func _init() -> void:
	picker_redirect = false
	match_horn = false
	story_mode = true
	rocks_on = false
	team_size = 1                       # no crest, no clock: a Hollow ends at its stairs
	floor_seed = randi()


func _ready() -> void:
	super._ready()
	match_over.connect(_on_over)
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	_label_floor = Label.new()
	_label_floor.position = Vector2(1000, 40)
	_label_floor.add_theme_font_override("font", load("res://assets/fonts/Silkscreen-Bold.ttf"))
	_label_floor.add_theme_font_size_override("font_size", 18)
	_label_floor.add_theme_color_override("font_color", Color("#F0F4F8"))
	_label_floor.add_theme_constant_override("outline_size", 4)
	_label_floor.add_theme_color_override("font_outline_color", Color(0.05, 0.06, 0.08))
	layer.add_child(_label_floor)
	_label_floor.visible = not battle_mode
	_update_floor_label()


# ---------------------------------------------------------------- the floor itself

func _set_arena(_i: int) -> void:
	_arena = 0
	if given_texture != null:
		_fields.clear()
		_crowd_dots.clear()
		_map.texture = given_texture
		return
	if _data.is_empty():
		_data = Gen.generate(floor_seed, RECIPE)
	_fields.clear()
	_crowd_dots.clear()
	_map.texture = ImageTexture.create_from_image(_paint())


func _floor() -> Rect2:
	if _data.is_empty():
		return super._floor()
	return Rect2(tile, tile, (_data["w"] - 2) * tile, (_data["h"] - 2) * tile)


func _blocked(p: Vector2) -> bool:
	if super._blocked(p):
		return true
	return _wall_px(p) or _wall_px(p + Vector2(-6, 0)) or _wall_px(p + Vector2(6, 0)) or _wall_px(p + Vector2(0, -3))


func _wall_px(p: Vector2) -> bool:
	if _data.is_empty():
		return false
	var t := Vector2i(floori(p.x / tile), floori(p.y / tile))
	if t.x < 0 or t.y < 0 or t.x >= _data["w"] or t.y >= _data["h"]:
		return true
	return _data["tiles"][t.y * _data["w"] + t.x] == Gen.WALL


func _px(t: Vector2i) -> Vector2:
	return Vector2(t) * tile + Vector2(tile, tile) * 0.5


## Whether the line from a to b crosses no wall.
## A clear line for a whole body: the centre line and two lines a body's half-width to each side.
func _wide_sight(a: Vector2, b: Vector2) -> bool:
	var side: Vector2 = (b - a).normalized().orthogonal() * BODY_HALF
	return _sight(a, b) and _sight(a + side, b + side) and _sight(a - side, b - side)


func _sight(a: Vector2, b: Vector2) -> bool:
	var n: int = int(a.distance_to(b) / 6.0) + 1
	for k in n + 1:
		if _wall_px(a.lerp(b, float(k) / n) + Vector2(0, -4)):
			return false
	return true


## One step toward `to` that walks around walls: down the walking-distance field toward its tile.
func _path_step(from: Vector2, to: Vector2) -> Vector2:
	var w: int = _data["w"]
	var h: int = _data["h"]
	var tt := Vector2i(floori(to.x / tile), floori(to.y / tile))
	var ft := Vector2i(floori(from.x / tile), floori(from.y / tile))
	if tt.x < 0 or tt.y < 0 or tt.x >= w or tt.y >= h or _data["tiles"][tt.y * w + tt.x] == Gen.WALL or ft == tt:
		return (to - from).normalized()
	var key: int = tt.y * w + tt.x
	if not _fields.has(key):
		if _fields.size() > 24:
			_fields.clear()
		_fields[key] = Gen.distances(_data["tiles"], w, h, tt)
	var field: PackedInt32Array = _fields[key]
	if ft.x < 0 or ft.y < 0 or ft.x >= w or ft.y >= h or field[ft.y * w + ft.x] < 0:
		return (to - from).normalized()
	var best := ft
	var best_d: int = field[ft.y * w + ft.x]
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]:
		var q: Vector2i = ft + d
		if q.x < 0 or q.y < 0 or q.x >= w or q.y >= h:
			continue
		var dq: int = field[q.y * w + q.x]
		if dq < 0 or dq >= best_d:
			continue
		if d.x != 0 and d.y != 0 and (field[ft.y * w + q.x] < 0 or field[q.y * w + ft.x] < 0):
			continue   # no cutting a wall corner
		best = q
		best_d = dq
	return (_px(best) - from).normalized()


## The floor image: the arena's grass for the ground (patches without the painted lines), its
## stone darkened for the walls, a lit face where a wall meets the floor below it, a shadow on
## the floor under a wall, and the stairs.
func _paint() -> Image:
	var w: int = _data["w"]
	var h: int = _data["h"]
	var t: int = tile
	var img := Image.create(w * t, h * t, false, Image.FORMAT_RGBA8)
	var rng := RandomNumberGenerator.new()
	rng.seed = floor_seed
	var ground := _patches(load(ARENAS[0]["map"]).get_image(), ARENAS[0]["floor"], rng, 1.0)
	var tiles: PackedByteArray = _data["tiles"]
	# Wall tops: one mass of dark silted bank with quiet grain and a few pebbles, so the walls read
	# as solid ground above the floor rather than a pattern.
	var top := Color(0.2, 0.18, 0.16)
	for y in h * t:
		for x in w * t:
			var tx: int = x / t
			var ty: int = y / t
			if tiles[ty * w + tx] != Gen.WALL:
				continue
			var hsh: int = (((x * 374761393) + (y * 668265263)) ^ ((x * 2654435761) >> 7)) & 0xFFFF
			var n: float = float(hsh) / 65535.0 * 0.05 - 0.025
			var c := Color(top.r + n, top.g + n, top.b + n)
			if ((x * 31 + y * 17) % 97) == 0:
				c = Color(0.32, 0.29, 0.25)
			img.set_pixel(x, y, c)
	for y in h:
		for x in w:
			var wall: bool = tiles[y * w + x] == Gen.WALL
			if not wall:
				img.blit_rect(ground[rng.randi_range(0, ground.size() - 1)], Rect2i(0, 0, t, t), Vector2i(x * t, y * t))
			else:
				# A lighter lip where the bank meets open floor on its sides or above it.
				if x > 0 and tiles[y * w + x - 1] == Gen.FLOOR:
					img.fill_rect(Rect2i(x * t, y * t, 1, t), Color(0.36, 0.32, 0.27))
				if x + 1 < w and tiles[y * w + x + 1] == Gen.FLOOR:
					img.fill_rect(Rect2i(x * t + t - 1, y * t, 1, t), Color(0.36, 0.32, 0.27))
				if y > 0 and tiles[(y - 1) * w + x] == Gen.FLOOR:
					img.fill_rect(Rect2i(x * t, y * t, t, 1), Color(0.36, 0.32, 0.27))
			var below_floor: bool = y + 1 < h and tiles[(y + 1) * w + x] == Gen.FLOOR
			var above_wall: bool = y > 0 and tiles[(y - 1) * w + x] == Gen.WALL
			if wall and below_floor:
				# The cliff face seen from above at an angle: banded silt, dark at the foot.
				for k in 9:
					var shade: float = 0.42 - 0.025 * k
					img.fill_rect(Rect2i(x * t, y * t + 7 + k, t, 1), Color(0.36 * shade / 0.42, 0.29 * shade / 0.42, 0.22 * shade / 0.42) if k < 8 else Color(0.08, 0.06, 0.05))
				img.fill_rect(Rect2i(x * t, y * t + 6, t, 1), Color(0.62, 0.55, 0.44))
			elif not wall and above_wall:
				for k in 3:
					_darken(img, Rect2i(x * t, y * t + k, t, 1), 0.6 + 0.12 * k)
	# The stairs: a dark way down with three lit steps.
	var s: Vector2 = _px(_data["stairs"]) - Vector2(12, 9)
	img.fill_rect(Rect2i(Vector2i(s), Vector2i(24, 18)), Color(0.05, 0.05, 0.07))
	for k in 3:
		img.fill_rect(Rect2i(Vector2i(s) + Vector2i(2 + k * 2, 3 + k * 5), Vector2i(20 - k * 4, 2)), Color(0.55, 0.6, 0.66))
	img.fill_rect(Rect2i(Vector2i(s) - Vector2i(1, 1), Vector2i(26, 1)), Color(0.85, 0.8, 0.6))
	return img


## Sixteen-pixel patches of a map's floor with no painted line in them, brightness scaled.
func _patches(src: Image, area: Rect2, rng: RandomNumberGenerator, bright: float) -> Array[Image]:
	src.convert(Image.FORMAT_RGBA8)
	var out: Array[Image] = []
	var t: int = tile
	for tries in 400:
		if out.size() >= 24:
			break
		var p := Vector2i(rng.randi_range(int(area.position.x), int(area.end.x) - t), rng.randi_range(int(area.position.y), int(area.end.y) - t))
		var patch := src.get_region(Rect2i(p, Vector2i(t, t)))
		var clean := true
		for y in t:
			for x in t:
				var c: Color = patch.get_pixel(x, y)
				if minf(c.r, minf(c.g, c.b)) > 0.7 or c.a < 0.9:
					clean = false
		if not clean:
			continue
		if bright != 1.0:
			for y in t:
				for x in t:
					var c: Color = patch.get_pixel(x, y)
					patch.set_pixel(x, y, Color(c.r * bright, c.g * bright * 0.95, c.b * bright * 0.9))
		out.append(patch)
	if out.is_empty():
		var plain := Image.create(t, t, false, Image.FORMAT_RGBA8)
		plain.fill(Color(0.3, 0.45, 0.2) if bright == 1.0 else Color(0.2, 0.18, 0.16))
		out.append(plain)
	return out


func _darken(img: Image, r: Rect2i, k: float) -> void:
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			var c: Color = img.get_pixel(x, y)
			img.set_pixel(x, y, Color(c.r * k, c.g * k, c.b * k))


# ---------------------------------------------------------------- creatures on the floor

func _new_match() -> void:
	if battle_mode:
		# The dungeon's creatures, where they stand, with the health they have.
		teams_override = [[], []]
		var flat: Array = []
		for side in 2:
			for c in spec[side]:
				teams_override[side].append([c["line"], c["stage"]])
				flat.append(c)
		super._new_match()
		for k in mini(flat.size(), _fighters.size()):
			var f: Dictionary = _fighters[k]
			f["body"].position = flat[k]["px"]
			f["facing"] = flat[k]["facing"]
			f["hp"] = maxi(1, int(round(f["max_hp"] * flat[k]["frac"])))
		_cam_zoom = 1.0
		_cam_focus = flat[0]["px"]
		_changing = false
		_show_banner("BATTLE!", 1.2)
		return
	if _data.is_empty():
		_data = Gen.generate(floor_seed, RECIPE)
	var rng := RandomNumberGenerator.new()
	rng.seed = floor_seed + 7
	var wild: Array = []
	for k in _data["spawns"].size():
		var pick: Array = RECIPE["spawns"][rng.randi_range(0, RECIPE["spawns"].size() - 1)]
		wild.append(pick)
	teams_override = [party.duplicate(), wild]
	super._new_match()
	var start: Vector2 = _px(_data["start"])
	var k0 := 0
	var k1 := 0
	for f in _fighters:
		if f["team"] == 0:
			f["body"].position = start + [Vector2.ZERO, Vector2(-20, 6), Vector2(20, 6)][mini(k0, 2)]
			f["facing"] = "s"
			k0 += 1
		else:
			f["body"].position = _px(_data["spawns"][mini(k1, _data["spawns"].size() - 1)])
			f["facing"] = ["s", "sw", "w", "se"][k1 % 4]
			f["awake"] = false
			k1 += 1
	_cam_zoom = 1.0
	_cam_focus = start
	_changing = false
	_update_floor_label()


## Sleeping wild creatures are not anyone's target, and do not look for one, until they wake.
func _foe_of(i: int) -> int:
	var f: Dictionary = _fighters[i]
	if f["team"] == 1 and not f.get("awake", true):
		f["target"] = -1
		return -1
	var t: int = super._foe_of(i)
	if t >= 0 and _fighters[t]["team"] == 1 and not _fighters[t].get("awake", true) and not (i == controlled and player_target == t):
		var best := -1
		for j in _fighters.size():
			var o: Dictionary = _fighters[j]
			if _enemies(i, j) and o["hp"] > 0 and o.get("awake", true) and (best < 0 or o["body"].position.distance_to(f["body"].position) < _fighters[best]["body"].position.distance_to(f["body"].position)):
				best = j
		f["target"] = best
		return best
	return t


func _nearest_foe(i: int) -> int:
	var f: Dictionary = _fighters[i]
	var best := -1
	for j in _fighters.size():
		var o: Dictionary = _fighters[j]
		if _enemies(i, j) and o["hp"] > 0 and o.get("awake", true) and f.get("awake", true) and (best < 0 or o["body"].position.distance_to(f["body"].position) < _fighters[best]["body"].position.distance_to(f["body"].position)):
			best = j
	return best


## Footwork on a floor with walls: a sleeping wild creature stays put; with a target in sight the
## arena's own footwork runs; with one out of sight it walks around the walls toward it; with
## none, a partner follows the leader and a leader on autopilot heads for the next wild creature,
## then the stairs.
func _move_ai(i: int, delta: float) -> void:
	var me: Dictionary = _fighters[i]
	if me["hp"] <= 0 or _data.is_empty():
		return
	if me["team"] == 1 and not me.get("awake", true):
		_walk(i, Vector2.ZERO, delta)
		return
	var here: Vector2 = me["body"].position
	var t := _foe_of(i)
	if t >= 0:
		var there: Vector2 = _fighters[t]["body"].position
		# The back-and-forth bug (Preston, 2026-10-09): at a wall corner the centre line of sight
		# flickered on and off every frame, so a creature switched between the arena's footwork
		# (a kiter backs away) and walking the path toward its target, and vibrated in place. It
		# now needs a clear line for its whole body width, and once it starts walking around a
		# wall it keeps at it for PATH_COMMIT seconds before trusting its eyes again.
		me["path_t"] = maxf(0.0, me.get("path_t", 0.0) - delta)
		if me["path_t"] <= 0.0 and _wide_sight(here, there):
			super._move_ai(i, delta)
		else:
			if me["path_t"] <= 0.0:
				me["path_t"] = PATH_COMMIT
			_walk(i, _path_step(here, there), delta * 0.85)
		return
	if me["team"] == 1:
		_walk(i, Vector2.ZERO, delta)
		return
	if i == controlled:
		# Autopilot (Tab, and the checks): the nearest wild creature still standing, then the stairs.
		var goal: Vector2 = _px(_data["stairs"])
		var best := INF
		for o in _fighters:
			if o["team"] == 1 and o["hp"] > 0 and o["body"].position.distance_to(here) < best:
				best = o["body"].position.distance_to(here)
				goal = o["body"].position
		if here.distance_to(goal) > 4.0:
			_walk(i, _path_step(here, goal), delta * 0.85)
		else:
			_walk(i, Vector2.ZERO, delta)
		return
	var lead: Vector2 = _fighters[controlled]["body"].position
	if here.distance_to(lead) > FOLLOW_GAP or not _sight(here, lead):
		# Further behind, it hurries: full pace past twice the gap.
		_walk(i, _path_step(here, lead), delta * (1.0 if here.distance_to(lead) > FOLLOW_GAP * 2.0 else 0.85))
	else:
		_walk(i, Vector2.ZERO, delta)


## Nobody fires at what it cannot see.
func _use_moves(i: int, delta: float) -> void:
	var f: Dictionary = _fighters[i]
	if not (i == controlled and not auto_you):
		var t := _foe_of(i)
		if t < 0 or not _sight(f["body"].position, _fighters[t]["body"].position):
			return
	super._use_moves(i, delta)


## Walls stop shots: a projectile that reaches a wall is spent there, a beam is cut at it.
func _update_effects(delta: float) -> void:
	super._update_effects(delta)
	if _data.is_empty():
		return
	for e in _effects:
		match e["kind"]:
			"fireball":
				if _wall_px(e["pos"]):
					e["life"] = 0.0
			"beam":
				var step := 4.0
				var d := 0.0
				while d < e["len"]:
					if _wall_px(e["from"] + e["dir"] * d):
						e["len"] = d
						break
					d += step


## A team loses when all of its creatures are down; the wild side never "wins" a floor by losing
## creatures, it simply has fewer of them. The floor is left by the stairs.
func _check_winner(_fallback: int) -> void:
	if battle_mode:
		# Your leader down ends it (a mystery dungeon rule); every wild creature down wins it.
		if _fighters[controlled]["hp"] <= 0:
			_winner = 1
			return
		for f in _fighters:
			if f["team"] == 1 and f["hp"] > 0:
				return
		_winner = 0
		return
	for f in _fighters:
		if f["team"] == 0 and f["hp"] > 0:
			return
	_winner = 1


func _update_crest(_delta: float) -> void:
	pass   # no crest in a Hollow


func _draw_crowd() -> void:
	pass   # no stands in a Hollow


func _process(delta: float) -> void:
	super._process(delta)
	if _fighters.is_empty() or _data.is_empty() or _winner >= 0:
		return
	_wake()
	_unstick()
	if battle_mode:
		return   # no stairs in a battle
	var lead: Dictionary = _fighters[controlled]
	if lead["hp"] > 0 and lead["body"].position.distance_to(_px(_data["stairs"])) < STAIRS_REACH:
		_on_stairs += delta
		if _on_stairs < delta * 1.5:
			_label(controlled, "Stairs")
	else:
		_on_stairs = 0.0
	if not _changing and _on_stairs >= STAIRS_HOLD:
		_changing = true
		_on_stairs = 0.0
		_play("res://assets/audio/sfx/ui/confirm.wav", -6.0)
		call_deferred("_next_floor")


func _wake() -> void:
	for j in _fighters.size():
		var o: Dictionary = _fighters[j]
		if o["team"] != 1 or o["hp"] <= 0 or o.get("awake", true):
			continue
		var stir: bool = o["hp"] < o["max_hp"]
		if not stir:
			for f in _fighters:
				if f["team"] == 0 and f["hp"] > 0 and f["body"].position.distance_to(o["body"].position) < AGGRO and _sight(f["body"].position, o["body"].position):
					stir = true
					break
		if stir:
			o["awake"] = true
			_label(j, "!")
			for k in _fighters.size():
				var p: Dictionary = _fighters[k]
				if p["team"] == 1 and p["hp"] > 0 and not p.get("awake", true) and p["body"].position.distance_to(o["body"].position) < WAKE_ROOM:
					p["awake"] = true
					_label(k, "!")


## Knockback and carries can push a creature into a wall; it is set back on the nearest floor.
func _unstick() -> void:
	for f in _fighters:
		if f["hp"] <= 0 or not _wall_px(f["body"].position):
			continue
		var t := Vector2i(floori(f["body"].position.x / tile), floori(f["body"].position.y / tile))
		var best := Vector2.INF
		for r in range(1, 4):
			for dy in range(-r, r + 1):
				for dx in range(-r, r + 1):
					var q := t + Vector2i(dx, dy)
					var p := _px(q)
					if not _wall_px(p) and p.distance_to(f["body"].position) < best.distance_to(f["body"].position):
						best = p
			if best != Vector2.INF:
				break
		if best != Vector2.INF:
			f["body"].position = best


func _next_floor() -> void:
	var keep := []
	for f in _fighters:
		if f["team"] == 0:
			keep.append(float(f["hp"]) / f["max_hp"])
	floor_n += 1
	if floor_n > FLOORS:
		cleared += 1
		floor_n = 1
		_show_banner("HOLLOW CLEARED", 2.5)
	floor_seed = randi()
	_data = Gen.generate(floor_seed, RECIPE)
	_set_arena(0)
	_new_match()
	var k := 0
	for f in _fighters:
		if f["team"] == 0 and k < keep.size():
			f["hp"] = maxi(1, int(round(f["max_hp"] * keep[k])))
			k += 1
	if floor_n > 1:
		_show_banner("B%dF" % floor_n, 1.5)


func _on_over(winner: int) -> void:
	if battle_mode or winner != 1:
		return   # in a battle the dungeon takes the result
	# Fainted: back to the top of the Hollow on a fresh floor, full health (the cost of fainting is a draft).
	floor_n = 1
	floor_seed = randi()
	_data = Gen.generate(floor_seed, RECIPE)
	_set_arena(0)
	_new_match()
	_show_banner("BACK TO THE TOP", 2.0)


func _update_floor_label() -> void:
	if _label_floor:
		_label_floor.text = "HOLLOW  B%dF" % floor_n


func _update_camera(delta: float) -> void:
	if _data.is_empty() or _fighters.is_empty():
		super._update_camera(delta)
		return
	var view := Vector2(_view.size)
	var lead: Dictionary = _fighters[controlled]
	var focus_to: Vector2 = lead["body"].position + Vector2(0, -10)
	var zoom_to := 1.0
	if _cam_punch_t > 0.0:
		_cam_punch_t = maxf(0.0, _cam_punch_t - delta)
		zoom_to = _cam_punch_zoom
		focus_to = _cam_punch_at
	else:
		for o in _fighters:
			if o["team"] == 1 and o["hp"] > 0 and o.get("awake", true) and o["body"].position.distance_to(lead["body"].position) < AGGRO:
				zoom_to = 1.1
				focus_to = (lead["body"].position + o["body"].position) * 0.5 + Vector2(0, -10)
				break
	var ease := 1.0 - exp(-delta * 5.0)
	_cam_zoom = lerpf(_cam_zoom, zoom_to, ease)
	_cam_focus = _cam_focus.lerp(focus_to, ease)
	var z: float = _cam_zoom
	var half: Vector2 = view * 0.5 / z
	var size := Vector2(_data["w"], _data["h"]) * tile
	var focus: Vector2 = _cam_focus.clamp(half, size - half)
	var s3 := (_shake if shake_on else 0.0) / SCALE
	_world.scale = Vector2.ONE * z
	_world.position = (view * 0.5 - focus * z).round() + Vector2(randf_range(-s3, s3), randf_range(-s3, s3)).round()
