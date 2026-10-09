extends Node2D
## Hollowtide as a mystery dungeon (Claude, 2026-10-09). Preston: "We're pivoting to more mystery
## dungeon... even the combat turns etc. Take and synthesize what we've made and learned onto a
## newer and improved mystery dungeon like game." The design doc is
## docs/design/mystery-dungeon-pivot-2026-10-09.md; this is its first playable slice.
##
## Turn-based on a grid: every creature takes one action when the leader takes one. Moving,
## attacking, using a move or resting is an action; turning to face is free. Partners follow the
## leader in a chain and fight with their own judgment; wild creatures sleep until something of
## yours comes into sight. The floor comes from the Hollow generator with one-tile hallways;
## the creatures, their kits, art and essence chart come from what the arena built. Every
## number is a draft for Grok.
##
## Structure read from Explorers of Sky (docs/research/pmd-sky-references-2026-10-09.md);
## nothing copied. What is new against it: bumping into an enemy attacks it, a move with nothing
## in reach is refused instead of wasting the turn, a move aims itself at the one enemy it can
## reach, enemy strong moves show a warning the turn before, and the moves keep the arena kits.

const Arena := preload("res://scripts/arena/arena_prototype.gd")
const Gen := preload("res://scripts/hollow/hollow_gen.gd")
const Painter := preload("res://scripts/dungeon/floor_painter.gd")
const MoveBody := preload("res://scripts/moves/move_body.gd")
const FONT := preload("res://assets/fonts/Silkscreen-Bold.ttf")

const T := 24                           # tile size in the low-resolution view
const VIEW := Vector2i(384, 216)
const SCALE := 3.0
const FLOORS := 3
const HP_SCALE := 0.2                   # arena HP to dungeon HP
const DMG_SCALE := 0.6                  # arena damage to dungeon damage
const SIGHT := 6                        # tiles a creature sees
const REGEN_EVERY := 4                  # turns per point of natural recovery
const STEP_TIME := 0.11                 # seconds a step takes on screen
const WILD_HP := 0.8                    # wild creatures on these early floors are weaker than yours,
const WILD_DMG := 0.7                   # as early floors are in Explorers of Sky (drafts for Grok)
const REST_TO := 0.7                    # the autopilot rests back to this share of health between fights
## The run loop (slice 2). The lantern is the run's clock: it drains a point every few turns and
## relights when you down a wild creature; its light is how far you see down a hallway (rooms
## stay lit while it burns). The bag holds ten kinds of item, is kept when a dungeon is cleared
## and lost when the leader faints. Item names are working labels.
const LIGHT_MAX := 100.0
const LIGHT_DRAIN_EVERY := 3
const LIGHT_ON_KO := 12.0
const BAG_KINDS := 10
const ITEMS := {
	"reedberry": {"name": "Reedberry", "what": "heals the leader 15", "col": Color("#c84a5a")},
	"lamp_oil": {"name": "Lamp Oil", "what": "40 light back", "col": Color("#f2c14e")},
	"river_stone": {"name": "River Stone", "what": "thrown down a line, 8 damage", "col": Color("#9aa4ae")},
	"rally_seed": {"name": "Rally Seed", "what": "the leader gets up once when it faints", "col": Color("#7fd16a")},
}
const TRAPS := {
	"snare": {"name": "Snare", "what": "held for 2 turns"},
	"silt": {"name": "Silt Pit", "what": "6 damage round it, 15 light lost"},
	"warp": {"name": "Warp Eddy", "what": "carried to another room"},
}
const MONSTER_HOUSE_WILD := 4
# Move scrolls (Claude, 2026-10-09; working name, Preston names it): a found item that teaches a
# shared signature to a teammate whose body has every part it needs (scripts/moves/move_body.gd,
# Grok's gate). Bag kinds are "scroll:<move>". Drafts for Grok.
const SCROLL_SHARE := 0.25              # share of floor items that are scrolls
const MOVES_MAX := 4
## Enemy warnings (slice 4): the arena's telegraph as a turn rule.
const WARN_KINDS := ["dash", "line", "burst"]
## Recruiting (slice 5): the chance a beaten wild creature asks to join, by its stage, and the team's size.
const RECRUIT_RATE := {0: 0.3, 1: 0.15, 2: 0.06}
# Position is power (Claude, 2026-10-09; structure from Into the Breach's pushes, Hoplite's
# approach and Explorers of Sky's sleeping rooms; the numbers are drafts for Grok).
const AMBUSH := 1.5                     # a hit on a sleeping creature
const PINCER := 1.5                     # a hit on a foe with one of the attacker's team on its far side
const SLAM_SHARE := 0.15                # a shoved creature that hits a wall or a body loses this share of its max HP
const SLAM_STAGGER := 1                 # and loses this many turns (and whatever it was gathering)
# Team tactics (Claude, 2026-10-09; structure from Rescue Team DX's team orders and the arena's
# Kit Sense modes). T cycles them and costs no turn. TACTIC_LEASH is how far from the leader a
# partner will go after a foe; guard also keeps it beside the leader.
const TACTICS := ["follow", "go", "guard"]
const TACTIC_NAMES := {"follow": "FOLLOW ME", "go": "GO AFTER FOES", "guard": "GUARD ME"}
const TACTIC_LEASH := {"follow": 4, "go": 99, "guard": 2}
const FLANK_REACH := 2                  # a partner walks this many tiles round to a foe's far side
const FLANK_WORTH := 0.4                # but only while the foe has more than this share of its health
const TEAM_MAX := 4
## The hybrid (2026-10-09): exploring is turn-based; a fight is played in real time with the
## arena engine on this same floor. An awake wild creature this close and in sight starts one;
## the wild creatures within reach of it join; running this far from every foe for a moment ends it.
const BATTLE_RANGE := 5
const BATTLE_JOIN := 8
const FLEE_TILES := 9
const FLEE_SECONDS := 1.5
const BATTLE_SECONDS_PER_TURN := 1.0    # the lantern and the turn count advance with a battle's length
const BATTLE_SCENE := "res://scenes/hollow_floor.tscn"
const HIT_TIME := 0.2
const RECIPE := {"cols": 4, "rows": 3, "cell_w": 14, "cell_h": 10, "room_density": 0.7, "extra_halls": 0.15,
	"dead_ends": false, "hall_width": 1, "wild": 3, "spawns": [[2, 0], [3, 0], [7, 0], [9, 0]],
	"items": 5, "traps": 4, "monster_house": 0.3}
const DIRS := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1)]

var party: Array = [[0, 0], [1, 0]]     # your team, [line, stage]; the first one leads
var floor_n := 1
var floor_seed := 0
var autopilot := false
var poll_input := true                  # the checks turn this off and call act_* themselves
var turn := 0
var busy := false
var cleared := 0
var faints := 0
var light := LIGHT_MAX
var bag := {"reedberry": 1}
var bag_open := false
var bag_sel := 0
var floor_items: Array[Dictionary] = []   # {pos, kind}
var traps: Array[Dictionary] = []         # {pos, kind, seen}
var monster_room := Rect2i()              # the Monster House this floor (empty when none)
var monster_sprung := false
var visible_tiles := {}                   # tiles the leader can see this turn
var dodged := 0                           # wind-ups that landed on nobody (for the checks)
var recruit_override := -1.0              # the checks force the chance (0..1); below zero uses RECRUIT_RATE
var asking := -1                          # the creature waiting for your answer, or -1
var roster: Array = []                    # creatures waiting at the courier hall, [line, stage]
var tactic := "follow"                    # the partners' order (T cycles it)
var pincers := 0                          # hits your partners landed from a pincer (for the checks)
var taught := {}                          # "line:stage" -> the moves a teammate knows after a scroll
var teach_kind := ""                      # the scroll being read, or "" when the teach panel is shut
var teach_sel := 0
var teach_learner := -1                   # chosen learner (ents index) while choosing a move to forget
var _party_at_start: Array = []           # the team the run began with (a faint returns to it)
var real_time_battles := false            # Preston, 2026-10-09: dungeon fights stay turn-based; the arena is its own mode. On: fights hand over to the arena engine (kept, built that night)
var in_battle := false
var battles := 0
var _battle: Node2D = null
var _battle_ids: Array = []               # ents index of each arena fighter, in the arena's order
var _battle_t := 0.0
var _flee_t := 0.0
var _screen: Sprite2D
var _hud_layer: CanvasLayer
var _roster_at_start: Array = []
var _floor_fx: Node2D                     # warning tiles, drawn on the floor under the creatures
var data: Dictionary = {}
var ents: Array[Dictionary] = []        # every creature on the floor; ents[0] is the leader
var log_lines: Array[String] = []
var explored := PackedByteArray()
var _fields := {}
var _pops: Array[Dictionary] = []       # floating numbers and words
var _shots: Array[Dictionary] = []      # a move's projectile in flight
var _hold := 0.0                        # a first key press waits this long so two keys can make a diagonal
var _was_dir := Vector2i.ZERO
var _keys_was := {}

var _view: SubViewport
var _world: Node2D
var _map: Sprite2D
var _fx: Node2D
var _hud: Node2D
var _fade: ColorRect


func _ready() -> void:
	if floor_seed == 0:
		floor_seed = randi()
	_party_at_start = party.duplicate(true)
	_roster_at_start = roster.duplicate(true)
	_view = SubViewport.new()
	_view.size = VIEW
	_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	add_child(_view)
	var screen := Sprite2D.new()
	screen.texture = _view.get_texture()
	screen.centered = false
	screen.scale = Vector2.ONE * SCALE
	screen.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(screen)
	_screen = screen
	_world = Node2D.new()
	_view.add_child(_world)
	_map = Sprite2D.new()
	_map.centered = false
	_world.add_child(_map)
	_floor_fx = Node2D.new()
	_floor_fx.draw.connect(_draw_floor_fx)
	_world.add_child(_floor_fx)
	_fx = Node2D.new()
	_fx.z_index = 4000
	_fx.draw.connect(_draw_fx)
	_world.add_child(_fx)
	var layer := CanvasLayer.new()
	add_child(layer)
	_hud_layer = layer
	_hud = Node2D.new()
	_hud.draw.connect(_draw_hud)
	layer.add_child(_hud)
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.size = Vector2(1152, 648)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_fade)
	_build_floor(true)


# ---------------------------------------------------------------- the floor

func _build_floor(fresh_team: bool) -> void:
	var keep: Array = []
	if not fresh_team:
		for e in ents:
			if e["team"] == 0:
				keep.append(e["hp"])
	for e in ents:
		e["node"].queue_free()
	ents.clear()
	_fields.clear()
	_pops.clear()
	_shots.clear()
	data = Gen.generate(floor_seed, RECIPE)
	_map.texture = ImageTexture.create_from_image(Painter.paint(data, T, floor_seed))
	explored = PackedByteArray()
	explored.resize(data["w"] * data["h"])
	# Your team round the start, the leader on it.
	var start: Vector2i = data["start"]
	var spots: Array[Vector2i] = [start]
	for d in [Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 1), Vector2i(1, 1)]:
		if _floor_at(start + d):
			spots.append(start + d)
	for k in party.size():
		var e := _make(party[k][0], party[k][1], 0, spots[mini(k, spots.size() - 1)])
		if k < keep.size():
			e["hp"] = mini(keep[k], e["max_hp"])
		ents.append(e)
	# The wild creatures, asleep in their rooms.
	var rng := RandomNumberGenerator.new()
	rng.seed = floor_seed + 7
	for sp in data["spawns"]:
		if _occupant(sp) >= 0:
			continue
		var pick: Array = RECIPE["spawns"][rng.randi_range(0, RECIPE["spawns"].size() - 1)]
		var w := _make(pick[0], pick[1], 1, sp)
		w["max_hp"] = maxi(6, int(round(w["max_hp"] * WILD_HP)))
		w["hp"] = w["max_hp"]
		w["awake"] = false
		w["facing"] = Arena.FACINGS[rng.randi_range(0, 7)]
		ents.append(w)
	for e in ents:
		_place(e)
	_stock_floor(rng)
	_reveal()
	_say("B%dF" % floor_n)


## Items in the rooms, hidden traps on the floor, and sometimes a Monster House.
func _stock_floor(rng: RandomNumberGenerator) -> void:
	floor_items.clear()
	traps.clear()
	monster_room = Rect2i()
	monster_sprung = false
	var taken := {data["start"]: true, data["stairs"]: true}
	for e in ents:
		taken[e["pos"]] = true
	var rooms: Array = data["rooms"]
	var kinds: Array = ITEMS.keys()
	for k in RECIPE["items"]:
		var room: Rect2i = rooms[rng.randi_range(0, rooms.size() - 1)]
		var p := Vector2i(rng.randi_range(room.position.x, room.end.x - 1), rng.randi_range(room.position.y, room.end.y - 1))
		if taken.has(p) or not _floor_at(p):
			continue
		taken[p] = true
		var kind: String = kinds[rng.randi_range(0, kinds.size() - 1)]
		if rng.randf() < SCROLL_SHARE:
			var pool := scroll_pool()
			if not pool.is_empty():
				kind = "scroll:" + pool[rng.randi_range(0, pool.size() - 1)]
		floor_items.append({"pos": p, "kind": kind})
	var trap_kinds: Array = TRAPS.keys()
	var tries := 0
	while traps.size() < RECIPE["traps"] and tries < 400:
		tries += 1
		var p := Vector2i(rng.randi_range(1, data["w"] - 2), rng.randi_range(1, data["h"] - 2))
		if taken.has(p) or not _floor_at(p) or _cheb(p, data["start"]) < 3:
			continue
		taken[p] = true
		traps.append({"pos": p, "kind": trap_kinds[rng.randi_range(0, trap_kinds.size() - 1)], "seen": false})
	if rng.randf() < RECIPE["monster_house"]:
		for room in rooms:
			if not room.grow(1).has_point(data["start"]) and not room.has_point(data["stairs"]):
				monster_room = room
				break


func _floor_at(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < data["w"] and p.y < data["h"] and data["tiles"][p.y * data["w"] + p.x] == Gen.FLOOR


func _occupant(p: Vector2i) -> int:
	for k in ents.size():
		if ents[k]["hp"] > 0 and ents[k]["pos"] == p:
			return k
	return -1


## A step from `from` in `d` is possible: open floor, and a diagonal may not cut a wall corner.
func can_step(from: Vector2i, d: Vector2i) -> bool:
	var to := from + d
	if not _floor_at(to):
		return false
	if d.x != 0 and d.y != 0 and (not _floor_at(from + Vector2i(d.x, 0)) or not _floor_at(from + Vector2i(0, d.y))):
		return false
	return true


func _sees(a: Vector2i, b: Vector2i) -> bool:
	return _sees_r(a, b, SIGHT)


func _sees_r(a: Vector2i, b: Vector2i, reach: int) -> bool:
	if maxi(absi(a.x - b.x), absi(a.y - b.y)) > reach:
		return false
	var n: int = maxi(absi(a.x - b.x), absi(a.y - b.y))
	for k in range(1, n):
		var p := Vector2i(roundi(lerpf(a.x, b.x, float(k) / n)), roundi(lerpf(a.y, b.y, float(k) / n)))
		if not _floor_at(p):
			return false
	return true


func _cheb(a: Vector2i, b: Vector2i) -> int:
	return maxi(absi(a.x - b.x), absi(a.y - b.y))


## One step toward `goal` around the walls, not onto anyone; ZERO when there is none.
## The step for creature i that brings it closest to goal, or ZERO. With through_team, a tile held
## by its own team counts as open (the leader swaps places with a partner in the way, never one
## behind it: swapping with whoever came first made the pair trade tiles forever in a hallway,
## Preston, 2026-10-09).
func _step_toward(i: int, goal: Vector2i, through_team := false) -> Vector2i:
	var from: Vector2i = ents[i]["pos"]
	if not _floor_at(goal) or not _floor_at(from):
		return Vector2i.ZERO   # no path to or from a tile that is not open floor
	var key: int = goal.y * data["w"] + goal.x
	if not _fields.has(key):
		if _fields.size() > 32:
			_fields.clear()
		_fields[key] = Gen.distances(data["tiles"], data["w"], data["h"], goal)
	var field: PackedInt32Array = _fields[key]
	var here: int = field[from.y * data["w"] + from.x]
	if here < 0:
		return Vector2i.ZERO
	var best := Vector2i.ZERO
	var best_d := here
	for d in DIRS:
		if not can_step(from, d):
			continue
		var q: Vector2i = from + d
		var dq: int = field[q.y * data["w"] + q.x]
		var o := _occupant(q)
		if dq < 0 or dq >= best_d or (o >= 0 and not (through_team and ents[o]["team"] == ents[i]["team"])):
			continue
		best = d
		best_d = dq
	return best


# ---------------------------------------------------------------- creatures

func _make(line: int, stage: int, team: int, pos: Vector2i) -> Dictionary:
	var form: Array = Arena.LINES[line]["forms"][stage]
	var cdata: CreatureData = load(form[1])
	var kit: Dictionary = Arena.KITS[form[0]]
	var moves: Array[String] = [kit["moves"][0]]
	for m in kit.get("abilities", []):
		if Arena.MOVES[m]["damage"] > 0 and moves.size() < 4:
			moves.append(m)
	var hp := maxi(10, int(round(Arena.MAX_HP * (1.0 + Arena.STAGE_HP * stage) * kit.get("hp", 1.0) * HP_SCALE)))
	var essences: Array = [cdata.essence]
	if cdata.has_second_essence:
		essences.append(cdata.second_essence)
	var node := Node2D.new()
	_world.add_child(node)
	var shadow := Polygon2D.new()
	var pts := PackedVector2Array()
	for k in 12:
		pts.append(Vector2(cos(k * TAU / 12.0) * 8.0, sin(k * TAU / 12.0) * 3.0))
	shadow.polygon = pts
	shadow.color = Color(0, 0, 0, 0.3)
	node.add_child(shadow)
	var sprite := Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.add_child(sprite)
	# Codex's Hollowtide Sprite finish (2026-10-08): the near-black outline and edge repair every
	# creature wears in the arena, worn in the dungeon too (Preston, 2026-10-09).
	preload("res://scripts/arena/creature_finish.gd").apply(sprite)
	var key := "%d:%d" % [line, stage]
	if team == 0 and taught.has(key):
		moves.clear()
		for m in taught[key]:
			moves.append(m)   # what a scroll taught it stays across floors
	var cds := {}
	for m in moves:
		cds[m] = 0
	return {"line": line, "stage": stage, "form": form[0], "name": cdata.creature_name, "team": team, "pos": pos,
		"facing": "s", "hp": hp, "max_hp": hp, "moves": moves, "cds": cds, "essences": essences, "awake": true,
		"node": node, "sprite": sprite, "art": _load_art(form[0]), "walk_t": 0.0, "flash": 0.0, "warn": ""}


func _load_art(folder: String) -> Dictionary:
	# The dungeon set: one size per stage (tools/arena/build_dungeon_set.py, Preston 2026-10-09);
	# the arena's tuned small set when a creature has none yet.
	var set := "dungeon" if ResourceLoader.exists("res://assets/sprites/arena/%s/dungeon/s.png" % folder) else "small"
	var still := {}
	var walk := {}
	var foot := {}
	for f in Arena.FACINGS:
		still[f] = load("res://assets/sprites/arena/%s/%s/%s.png" % [folder, set, f])
		foot[still[f]] = _foot_row(still[f])
		var frames: Array[Texture2D] = []
		for i in 8:
			var p := "res://assets/sprites/arena/%s/%s/walk_%s_f%d.png" % [folder, set, f, i]
			if ResourceLoader.exists(p):
				frames.append(load(p))
		var rows: Array[float] = []
		for tex in frames:
			rows.append(_foot_row(tex))
		rows.sort()
		var planted := 0.0
		if not rows.is_empty():
			var median: float = rows[rows.size() / 2]
			for r in rows:
				if r <= median + 4.0:
					planted = maxf(planted, r)
		for tex in frames:
			foot[tex] = planted
		walk[f] = frames
	return {"still": still, "walk": walk, "foot": foot}


func _foot_row(tex: Texture2D) -> float:
	var img: Image = tex.get_image()
	for y in range(img.get_height() - 1, -1, -1):
		var n := 0
		for x in img.get_width():
			if img.get_pixel(x, y).a > 0.1:
				n += 1
		if n >= 4:
			return float(y + 1)
	return float(img.get_height())


func _tile_px(p: Vector2i) -> Vector2:
	return Vector2(p) * T + Vector2(T * 0.5, T * 0.78)


func _place(e: Dictionary) -> void:
	# A step still sliding would put the creature back where it was on its last frame (a warp
	# trap sprung on a step did exactly that): stop it first.
	if e.get("tw") is Tween and e["tw"].is_valid():
		e["tw"].kill()
	e["node"].position = _tile_px(e["pos"])
	e["node"].z_index = int(e["node"].position.y)
	_set_tex(e, e["art"]["still"][e["facing"]])


func _set_tex(e: Dictionary, tex: Texture2D) -> void:
	var s: Sprite2D = e["sprite"]
	s.texture = tex
	s.offset = Vector2(0, tex.get_height() * 0.5 - e["art"]["foot"].get(tex, float(tex.get_height())))


func _facing_of(d: Vector2i) -> String:
	return Arena.FACINGS[int(round(fposmod(Vector2(d).angle(), TAU) / (TAU / 8.0))) % 8]


func _dir_of(facing: String) -> Vector2i:
	return DIRS[Arena.FACINGS.find(facing)]


func _foes(i: int, j: int) -> bool:
	return ents[i]["team"] != ents[j]["team"] and ents[j]["hp"] > 0


# ---------------------------------------------------------------- moves

## How a move reaches on the grid, from its arena telegraph: a front tile, a dash along a line,
## a shot down a line, or a burst on a target in sight and the tiles round it.
func move_reach(m: String) -> Dictionary:
	var mv: Dictionary = Arena.MOVES[m]
	var tiles: int = clampi(int(round(mv["range"] / T)), 1, 8)
	var kind: String = Arena.TELEGRAPH[m][0] if Arena.TELEGRAPH.has(m) else ("dash" if mv.get("mobility", false) else ("front" if mv["range"] <= 34.0 else "line"))
	match kind:
		"melee":
			return {"kind": "front", "n": 1}
		"charge":
			return {"kind": "dash", "n": clampi(tiles, 2, 6)}
		"area":
			return {"kind": "burst", "n": clampi(tiles, 2, 6)}
		"line", "rail":
			return {"kind": "line", "n": clampi(tiles, 2, 8)}
	return {"kind": kind, "n": clampi(tiles, 1, 6)}


## Who move m from creature i facing d would hit first ([-1] when nobody), and where i ends up.
func move_hits(i: int, m: String, d: Vector2i) -> Dictionary:
	var e: Dictionary = ents[i]
	var r := move_reach(m)
	var p: Vector2i = e["pos"]
	match r["kind"]:
		"front":
			if can_step(p, d) or _floor_at(p + d):
				var o := _occupant(p + d)
				if o >= 0 and _foes(i, o) and can_step(p, d) == true or (o >= 0 and _foes(i, o) and (d.x == 0 or d.y == 0)):
					return {"hits": [o], "end": p}
			return {"hits": [], "end": p}
		"dash":
			var at := p
			for k in r["n"]:
				if not can_step(at, d):
					break
				var o := _occupant(at + d)
				if o >= 0:
					return {"hits": [o] if _foes(i, o) else [], "end": at}
				at += d
			return {"hits": [], "end": at}
		"line":
			var at := p
			for k in r["n"]:
				if not _floor_at(at + d):
					break
				at += d
				var o := _occupant(at)
				if o >= 0 and _foes(i, o):
					return {"hits": [o], "end": p}
			return {"hits": [], "end": p}
		"burst":
			# The nearest enemy in sight within reach, along this facing's half of the room, and its neighbours.
			var best := -1
			for j in ents.size():
				if _foes(i, j) and _cheb(p, ents[j]["pos"]) <= r["n"] and _sees(p, ents[j]["pos"]) and Vector2(ents[j]["pos"] - p).dot(Vector2(d)) > 0.0:
					if best < 0 or _cheb(p, ents[j]["pos"]) < _cheb(p, ents[best]["pos"]):
						best = j
			if best < 0:
				return {"hits": [], "end": p}
			var hits: Array = [best]
			for j in ents.size():
				if j != best and _foes(i, j) and _cheb(ents[j]["pos"], ents[best]["pos"]) <= 1:
					hits.append(j)
			return {"hits": hits, "end": p}
	return {"hits": [], "end": p}


## The tiles move m from creature i facing d covers: the next tile, the run of a dash or a shot,
## or the burst's target tile and the tiles round it. This is what a warning marks.
func move_tiles(i: int, m: String, d: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var p: Vector2i = ents[i]["pos"]
	var r := move_reach(m)
	match r["kind"]:
		"front":
			out.append(p + d)
		"dash", "line":
			var at := p
			for k in r["n"]:
				if not (can_step(at, d) if r["kind"] == "dash" else _floor_at(at + d)):
					break
				at += d
				out.append(at)
		"burst":
			var hits: Array = move_hits(i, m, d)["hits"]
			if not hits.is_empty():
				var c: Vector2i = ents[hits[0]]["pos"]
				for dy in range(-1, 2):
					for dx in range(-1, 2):
						if _floor_at(c + Vector2i(dx, dy)):
							out.append(c + Vector2i(dx, dy))
	return out


## The best direction for move m from creature i: the first facing that hits someone, preferring
## the current facing (this is the aiming help: a move turns to the one enemy it can reach).
func aim(i: int, m: String) -> Vector2i:
	var cur := _dir_of(ents[i]["facing"])
	if not move_hits(i, m, cur)["hits"].is_empty():
		return cur
	for d in DIRS:
		if not move_hits(i, m, d)["hits"].is_empty():
			return d
	return Vector2i.ZERO


func damage(i: int, j: int, m: String) -> int:
	var e: Dictionary = ents[i]
	var ess: int = Arena.MOVE_ESSENCE.get(m, e["essences"][0])
	var mult := 1.0
	for d in ents[j]["essences"]:
		mult *= Arena.ARENA_CHART.get([ess, d], 1.0)
	var base: float = Arena.MOVES[m]["damage"] * (1.0 + Arena.STAGE_POWER * e["stage"]) * DMG_SCALE * mult * (WILD_DMG if e["team"] == 1 else 1.0)
	return maxi(1, int(round(base * randf_range(0.9, 1.1))))


func _mult(i: int, j: int, m: String) -> float:
	var ess: int = Arena.MOVE_ESSENCE.get(m, ents[i]["essences"][0])
	var mult := 1.0
	for d in ents[j]["essences"]:
		mult *= Arena.ARENA_CHART.get([ess, d], 1.0)
	return mult


func _turns_of(m: String, i: int) -> int:
	if m == ents[i]["moves"][0]:
		return 0
	return maxi(1, int(ceil(Arena.MOVES[m]["cooldown"])))


# ---------------------------------------------------------------- one action

## Creature i takes move m toward d. Plays out on screen; returns false when nothing happened.
func use_move(i: int, m: String, d: Vector2i) -> bool:
	var e: Dictionary = ents[i]
	var res := move_hits(i, m, d)
	e["facing"] = _facing_of(d)
	_set_tex(e, e["art"]["still"][e["facing"]])
	e["cds"][m] = _turns_of(m, i)
	_say("%s used %s!" % [e["name"], Arena.MOVES[m]["name"]])
	_callout(e, m)
	var r := move_reach(m)
	if r["kind"] == "dash" and res["end"] != e["pos"]:
		e["pos"] = res["end"]
		await _slide(e, _tile_px(e["pos"])).finished
		e["node"].z_index = int(e["node"].position.y)
	var origin: Vector2 = _tile_px(e["pos"])
	var lunge: Vector2 = Vector2(d).normalized() * 6.0
	if e.get("tw") is Tween and e["tw"].is_valid():
		e["tw"].kill()
	var tw2 := create_tween()
	e["tw"] = tw2
	tw2.tween_property(e["node"], "position", origin + lunge, HIT_TIME * 0.4)
	tw2.tween_property(e["node"], "position", origin, HIT_TIME * 0.6)
	if r["kind"] in ["line", "burst"] and not res["hits"].is_empty():
		_shots.append({"from": origin + Vector2(0, -10), "to": ents[res["hits"][0]]["node"].position + Vector2(0, -10), "t": 0.0, "burst": r["kind"] == "burst"})
	await get_tree().create_timer(HIT_TIME * 0.5).timeout
	if res["hits"].is_empty():
		_say("It missed.")
		_play("res://assets/audio/sfx/ui/cursor.wav", -12.0)
	for j in res["hits"]:
		_hit(i, j, m)
	await tw2.finished
	if r["kind"] == "dash" and not res["hits"].is_empty():
		await _shove(i, res["hits"][0], d)
	return true


## A wind-up lands on the tiles it marked last turn: a dash runs down them until something is in
## the way, a shot takes the first enemy on them, a burst takes every enemy on them. Whoever
## stepped out is missed.
func _fire_windup(i: int) -> void:
	var e: Dictionary = ents[i]
	var w: Dictionary = e["windup"]
	e.erase("windup")
	var m: String = w["m"]
	var d: Vector2i = w["d"]
	var tiles: Array = w["tiles"]
	var kind: String = move_reach(m)["kind"]
	var hits: Array = []
	_say("%s used %s!" % [e["name"], Arena.MOVES[m]["name"]])
	_callout(e, m)
	if kind == "dash":
		var end: Vector2i = e["pos"]
		for t in tiles:
			var o := _occupant(t)
			if o >= 0:
				if _foes(i, o):
					hits.append(o)
				break
			end = t
		if end != e["pos"]:
			e["pos"] = end
			await _slide(e, _tile_px(end)).finished
	else:
		for t in tiles:
			var o := _occupant(t)
			if o >= 0 and _foes(i, o):
				hits.append(o)
				if kind == "line":
					break
	var origin: Vector2 = _tile_px(e["pos"])
	var tw := _slide(e, origin + Vector2(d).normalized() * 6.0)
	tw.tween_property(e["node"], "position", origin, HIT_TIME * 0.6)
	if kind in ["line", "burst"] and not tiles.is_empty():
		var aim_at: Vector2 = _tile_px(tiles[-1] if kind == "line" else tiles[tiles.size() / 2]) + Vector2(0, -10)
		if not hits.is_empty():
			aim_at = ents[hits[0]]["node"].position + Vector2(0, -10)
		_shots.append({"from": origin + Vector2(0, -10), "to": aim_at, "t": 0.0, "burst": kind == "burst"})
	await get_tree().create_timer(HIT_TIME * 0.5).timeout
	if hits.is_empty():
		dodged += 1
		_say("It missed: nobody was where it struck.")
		_play("res://assets/audio/sfx/ui/cursor.wav", -12.0)
	for j in hits:
		_hit(i, j, m)
	await tw.finished
	if kind == "dash" and not hits.is_empty():
		await _shove(i, hits[0], d)


func _hit(i: int, j: int, m: String) -> void:
	var o: Dictionary = ents[j]
	var tags := position_tags(i, j)
	var bonus := 1.0
	for t in tags:
		bonus *= AMBUSH if t == "AMBUSH" else PINCER
	var dmg := maxi(1, int(round(damage(i, j, m) * bonus)))
	var mult := _mult(i, j, m)
	for k in tags.size():
		_pops.append({"pos": o["node"].position + Vector2(0, -38 - 9 * k), "text": tags[k] + "!", "t": 0.0, "col": Color(1, 0.6, 0.35)})
	if "PINCER" in tags and ents[i]["team"] == 0 and i != 0:
		pincers += 1
	var why := ""
	if "AMBUSH" in tags:
		why += " An ambush!"
	if "PINCER" in tags:
		why += " Caught in a pincer!"
	_say("%s took %d damage.%s%s" % [o["name"], dmg, " It's super effective!" if mult > 1.0 else (" It's not very effective." if mult < 1.0 else ""), why])
	_play("res://assets/audio/sfx/ui/hit_strong.wav" if mult > 1.0 or not tags.is_empty() else "res://assets/audio/sfx/ui/hit_weak.wav", -6.0)
	_wound(i, j, dmg, Color(1, 0.95, 0.6) if mult > 1.0 else (Color(0.7, 0.75, 0.8) if mult < 1.0 else Color(1, 1, 1)))


## The move's name over the creature using it, as Rescue Team DX shows it (structure only), so a
## player reads who did what without the log. The basic attack stays quiet.
func _callout(e: Dictionary, m: String) -> void:
	if m == e["moves"][0]:
		return
	_pops.append({"pos": e["node"].position + Vector2(-float(Arena.MOVES[m]["name"].length()) * 2.5, -44), "text": Arena.MOVES[m]["name"] + "!", "t": 0.0, "col": Color(1, 1, 1) if e["team"] == 0 else Color(1, 0.75, 0.6)})


## Where the attacker stands decides the bonus: AMBUSH on a creature still asleep, PINCER when
## one of the attacker's team stands on the tile right behind the target, seen from the attacker.
## Both work against your team too.
func position_tags(i: int, j: int) -> Array[String]:
	var tags: Array[String] = []
	var o: Dictionary = ents[j]
	if o["team"] == 1 and not o["awake"]:
		tags.append("AMBUSH")
	var away: Vector2i = o["pos"] - ents[i]["pos"]
	var behind: Vector2i = o["pos"] + Vector2i(signi(away.x), signi(away.y))
	var k := _occupant(behind)
	if k >= 0 and k != i and ents[k]["team"] == ents[i]["team"]:
		tags.append("PINCER")
	return tags


## A charge shoves the creature it hits one tile further along. Open floor: it slides there. A wall
## or another creature: it SLAMS, losing a share of its health and its next turn, and anything it
## was gathering is broken; a creature it slams into takes the same knock.
func _shove(i: int, j: int, d: Vector2i) -> void:
	var o: Dictionary = ents[j]
	if o["hp"] <= 0 or j == asking:
		return
	var to: Vector2i = o["pos"] + d
	var into := _occupant(to)
	if can_step(o["pos"], d) and into < 0:
		o["pos"] = to
		_say("%s was knocked back!" % o["name"])
		await _slide(o, _tile_px(to)).finished
		o["node"].z_index = int(o["node"].position.y)
		return
	var at: Vector2 = _tile_px(o["pos"])
	var tw := _slide(o, at + Vector2(d) * 5.0)
	tw.tween_property(o["node"], "position", at, HIT_TIME * 0.5)
	_pops.append({"pos": o["node"].position + Vector2(0, -38), "text": "SLAM!", "t": 0.0, "col": Color(1, 0.45, 0.3)})
	_say("%s slammed into %s!" % [o["name"], ents[into]["name"] if into >= 0 else "the wall"])
	_play("res://assets/audio/sfx/ui/hit_strong.wav", -3.0)
	if o.has("windup"):
		_say("Its %s was broken!" % Arena.MOVES[o["windup"]["m"]]["name"])
		o.erase("windup")
	o["stagger"] = SLAM_STAGGER
	_wound(i, j, maxi(2, int(round(o["max_hp"] * SLAM_SHARE))), Color(1, 0.55, 0.4))
	if into >= 0 and into != i:
		_wound(i, into, maxi(2, int(round(ents[into]["max_hp"] * SLAM_SHARE))), Color(1, 0.55, 0.4))
	await tw.finished


## Creature j loses dmg health to creature i: the number, the flash, waking, fainting and the
## chance a beaten wild creature asks to join.
func _wound(i: int, j: int, dmg: int, col: Color) -> void:
	var o: Dictionary = ents[j]
	o["hp"] = maxi(0, o["hp"] - dmg)
	o["flash"] = 0.25
	o["awake"] = true
	_pops.append({"pos": o["node"].position + Vector2(0, -26), "text": str(dmg), "t": 0.0, "col": col})
	if o["hp"] <= 0:
		o.erase("windup")
		_say("%s fainted!" % o["name"])
		if o["team"] == 1:
			light = minf(LIGHT_MAX, light + LIGHT_ON_KO)   # beating an opponent lights the floor (the Battle Pyramid)
			if ents[i]["team"] == 0 and asking < 0 and randf() < (recruit_override if recruit_override >= 0.0 else RECRUIT_RATE.get(o["stage"], 0.05)):
				# It gets back up and asks to come along.
				asking = j
				o["hp"] = 1
				o["awake"] = false   # it waits for your answer and takes no turns
				o["flash"] = 0.0
				_pops.append({"pos": o["node"].position + Vector2(0, -30), "text": "?", "t": 0.0, "col": Color(1, 0.9, 0.5)})
				_say("%s got back up! It wants to come with you. (Y join / N leave)" % o["name"])
				_play("res://assets/audio/sfx/ui/confirm.wav", -8.0)
				return
		var tw := create_tween()
		tw.tween_property(o["node"], "modulate:a", 0.0, 0.35)


func _step(i: int, d: Vector2i) -> Tween:
	var e: Dictionary = ents[i]
	e["pos"] += d
	e["moved"] = true
	e["facing"] = _facing_of(d)
	e["walk_t"] = STEP_TIME
	return _slide(e, _tile_px(e["pos"]))


## Every movement of a creature's sprite goes through here: a new slide stops the one before it,
## so a held key never lets the last frame of the previous step pull the creature back a tile
## (Preston, 2026-10-09: "the creature is going back and forth").
func _slide(e: Dictionary, to: Vector2) -> Tween:
	if e.get("tw") is Tween and e["tw"].is_valid():
		e["tw"].kill()
	var tw := create_tween()
	tw.tween_property(e["node"], "position", to, STEP_TIME)
	e["tw"] = tw
	return tw


# ---------------------------------------------------------------- the player's actions

## The leader moves one tile in d: into an enemy it attacks (bump), into a partner it swaps places.
func act_move(d: Vector2i) -> void:
	if busy or asking >= 0 or d == Vector2i.ZERO or ents.is_empty() or ents[0]["hp"] <= 0:
		return
	var lead: Dictionary = ents[0]
	if lead.get("stagger", 0) > 0:
		await _player_turn(func() -> bool: return true)   # _player_turn spends the turn reeling
		return
	if lead.get("snared", 0) > 0:
		_say("%s struggles in the snare." % lead["name"])
		await _player_turn(func() -> bool: return true)
		return
	if not can_step(lead["pos"], d):
		lead["facing"] = _facing_of(d)
		_set_tex(lead, lead["art"]["still"][lead["facing"]])
		return
	var o := _occupant(lead["pos"] + d)
	if o >= 0 and _foes(0, o):
		await _player_turn(func() -> bool: return await use_move(0, lead["moves"][0], d))
		return
	busy = true
	var tweens: Array = []
	if o >= 0:
		# Swap places with a partner.
		ents[o]["pos"] = lead["pos"]
		ents[o]["facing"] = _facing_of(-d)
		ents[o]["walk_t"] = STEP_TIME
		tweens.append(_slide(ents[o], _tile_px(ents[o]["pos"])))
	tweens.append(_step(0, d))
	await _world_turn(tweens)
	busy = false


func act_face(d: Vector2i) -> void:
	if busy or d == Vector2i.ZERO:
		return
	ents[0]["facing"] = _facing_of(d)
	_set_tex(ents[0], ents[0]["art"]["still"][ents[0]["facing"]])


## Slot 0 is the basic attack, 1 to 3 the moves. A move with nobody in reach is refused and
## costs nothing; a move that can reach one enemy turns to it.
func act_attack(slot: int) -> void:
	if busy or asking >= 0 or ents.is_empty() or ents[0]["hp"] <= 0 or slot >= ents[0]["moves"].size():
		return
	var lead: Dictionary = ents[0]
	var m: String = lead["moves"][slot]
	if lead["cds"][m] > 0:
		_say("%s needs %d more turn%s." % [Arena.MOVES[m]["name"], lead["cds"][m], "" if lead["cds"][m] == 1 else "s"])
		_play("res://assets/audio/sfx/ui/cancel.wav", -12.0)
		return
	var d := aim(0, m)
	if d == Vector2i.ZERO:
		if slot == 0:
			d = _dir_of(lead["facing"])   # a basic swing into the air still takes the turn, like a swing
		else:
			_say("Nothing in reach for %s." % Arena.MOVES[m]["name"])
			_play("res://assets/audio/sfx/ui/cancel.wav", -12.0)
			return
	await _player_turn(func() -> bool: return await use_move(0, m, d))


func act_rest() -> void:
	if busy or asking >= 0:
		return
	await _player_turn(func() -> bool: return true)


func act_stairs() -> void:
	if busy or ents.is_empty() or ents[0]["pos"] != data["stairs"]:
		return
	busy = true
	_play("res://assets/audio/sfx/ui/confirm.wav", -6.0)
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 1.0, 0.3)
	await tw.finished
	floor_n += 1
	if floor_n > FLOORS:
		cleared += 1
		floor_n = 1
		light = LIGHT_MAX
		_party_at_start = party.duplicate(true)   # the run's recruits are yours now
		_roster_at_start = roster.duplicate(true)
		_say("The Hollow is cleared! The bag and the new partners are kept.")
	floor_seed = randi()
	_build_floor(floor_n != 1)
	tw = create_tween()
	tw.tween_property(_fade, "color:a", 0.0, 0.3)
	await tw.finished
	busy = false


## Hand the fight to the arena engine: your whole team, and every wild creature awake within
## reach of the leader (or asleep in the leader's room), from where they stand with the health
## they have. The arena draws the same floor picture, so nothing jumps.
func _start_battle() -> void:
	if _battle != null or ents.is_empty():
		return
	var lead_pos: Vector2i = ents[0]["pos"]
	var room := Rect2i()
	for r in data["rooms"]:
		if r.grow(1).has_point(lead_pos):
			room = r.grow(1)
	var sides := [[], []]
	var ids := [[], []]
	for k in ents.size():
		var e: Dictionary = ents[k]
		if e["hp"] <= 0:
			continue
		if e["team"] == 1:
			var near: bool = e["awake"] and _cheb(e["pos"], lead_pos) <= BATTLE_JOIN
			var roommate: bool = room.size != Vector2i.ZERO and room.has_point(e["pos"])
			if not (near or roommate):
				continue
			e["awake"] = true
		e.erase("windup")
		sides[e["team"]].append({"line": e["line"], "stage": e["stage"], "px": _tile_px(e["pos"]),
			"frac": float(e["hp"]) / e["max_hp"], "facing": e["facing"]})
		ids[e["team"]].append(k)
	if sides[1].is_empty():
		in_battle = false
		return
	var b: Node2D = load(BATTLE_SCENE).instantiate()
	b.battle_mode = true
	b.tile = T
	b._data = {"w": data["w"], "h": data["h"], "tiles": data["tiles"], "stairs": Vector2i(-99, -99), "start": lead_pos, "spawns": [], "rooms": data["rooms"]}
	b.given_texture = _map.texture
	b.spec = sides
	b.party = []
	b.control_slot = 0
	b.poll_input = poll_input
	b.auto_you = autopilot
	_battle_ids = ids[0] + ids[1]
	_battle = b
	_battle_t = 0.0
	_flee_t = 0.0
	battles += 1
	_say("A battle! %d wild creature%s." % [sides[1].size(), "" if sides[1].size() == 1 else "s"])
	_screen.visible = false
	_hud_layer.visible = false
	add_child(b)
	b.match_over.connect(_end_battle)


## The fight is over (or you ran): everyone goes back on the grid at the tile nearest where they
## stood, with the health they kept. Downed wild creatures may ask to join, as in a turn fight.
func _end_battle(winner: int) -> void:
	if _battle == null:
		return
	var b: Node2D = _battle
	_battle = null
	var taken := {}
	var downed: Array = []
	for n in mini(b._fighters.size(), _battle_ids.size()):
		var f: Dictionary = b._fighters[n]
		var k: int = _battle_ids[n]
		var e: Dictionary = ents[k]
		var frac: float = float(maxi(0, f["hp"])) / maxf(1.0, f["max_hp"])
		e["hp"] = 0 if f["hp"] <= 0 else maxi(1, int(round(e["max_hp"] * frac)))
		e["facing"] = f["facing"]
		if e["hp"] > 0:
			e["pos"] = _snap(f["body"].position, taken)
			taken[e["pos"]] = true
		elif e["team"] == 1:
			downed.append(k)
		for m in e["cds"]:
			e["cds"][m] = 0
	var seconds := _battle_t
	turn += int(seconds / BATTLE_SECONDS_PER_TURN)
	light = maxf(0.0, light - seconds / BATTLE_SECONDS_PER_TURN / LIGHT_DRAIN_EVERY)
	for k in downed:
		light = minf(LIGHT_MAX, light + LIGHT_ON_KO)
		ents[k]["node"].modulate.a = 0.0
	b.queue_free()
	_screen.visible = true
	_hud_layer.visible = true
	in_battle = false
	for e in ents:
		_place(e)
		e["node"].modulate.a = 1.0 if e["hp"] > 0 else 0.0
	_reveal()
	if winner == 0:
		_say("The battle is won! (%d s)" % int(seconds))
	elif winner == 1:
		_say("%s is down." % ents[0]["name"])
	else:
		_say("You got away.")
	# A beaten wild creature may get up and ask to join.
	if winner == 0 and asking < 0:
		for k in downed:
			if randf() < (recruit_override if recruit_override >= 0.0 else RECRUIT_RATE.get(ents[k]["stage"], 0.05)):
				asking = k
				ents[k]["hp"] = 1
				ents[k]["awake"] = false
				ents[k]["node"].modulate.a = 1.0
				_say("%s got back up! It wants to come with you. (Y join / N leave)" % ents[k]["name"])
				break
	if ents[0]["hp"] <= 0:
		_end_turn()   # the faint rules


## The nearest open floor tile to a point, not one already taken.
func _snap(px: Vector2, taken: Dictionary) -> Vector2i:
	var t0 := Vector2i(floori(px.x / T), floori(px.y / T))
	for r in range(0, 6):
		var best := Vector2i(-1, -1)
		var best_d := INF
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				var q := t0 + Vector2i(dx, dy)
				if _floor_at(q) and not taken.has(q) and (Vector2(q) * T + Vector2(T, T) * 0.5).distance_to(px) < best_d:
					best = q
					best_d = (Vector2(q) * T + Vector2(T, T) * 0.5).distance_to(px)
		if best.x >= 0:
			return best
	return data["start"]


## While a battle runs: count its length, and end it if your leader has run far from every foe.
func _watch_battle(delta: float) -> void:
	if _battle == null or _battle._fighters.is_empty() or _battle._winner >= 0:
		return
	_battle_t += delta
	var lead: Dictionary = _battle._fighters[0]
	var far := true
	for f in _battle._fighters:
		if f["team"] == 1 and f["hp"] > 0 and f["body"].position.distance_to(lead["body"].position) < FLEE_TILES * T:
			far = false
	_flee_t = _flee_t + delta if far else 0.0
	if _flee_t >= FLEE_SECONDS:
		_end_battle(-1)


## Your answer to a creature asking to join. Answering costs no turn.
func act_recruit(accept: bool) -> void:
	if asking < 0 or asking >= ents.size():
		asking = -1
		return
	var o: Dictionary = ents[asking]
	asking = -1
	if not accept:
		o["hp"] = 0
		_say("%s goes back into the hollow." % o["name"])
		create_tween().tween_property(o["node"], "modulate:a", 0.0, 0.35)
		return
	var team_now := 0
	for e in ents:
		if e["team"] == 0 and e["hp"] > 0:
			team_now += 1
	if team_now >= TEAM_MAX:
		# No room on this run: it waits at the courier hall once the run is cleared.
		o["hp"] = 0
		o["node"].visible = false
		roster.append([o["line"], o["stage"]])
		_say("The team is full. %s will wait at the courier hall." % o["name"])
	else:
		o["team"] = 0
		o["awake"] = true
		o["hp"] = maxi(1, o["max_hp"] / 2)
		o["node"].modulate.a = 1.0
		for m in o["cds"]:
			o["cds"][m] = 0
		party.append([o["line"], o["stage"]])
		_say("%s joined the team!" % o["name"])
	_play("res://assets/audio/sfx/ui/confirm.wav", -4.0)


func _player_turn(action: Callable) -> void:
	busy = true
	if ents[0].get("stagger", 0) > 0:
		ents[0]["stagger"] -= 1
		_say("%s is still reeling from the slam!" % ents[0]["name"])
		await _world_turn([])
		busy = false
		return
	var ok: bool = await action.call()
	if ok:
		await _world_turn([])
	busy = false


# ---------------------------------------------------------------- everyone else's turn

## After the leader acts, every other creature takes one action: steps all happen together,
## attacks one after another (the order Explorers of Sky shows them in).
func _world_turn(lead_tweens: Array) -> void:
	turn += 1
	var tweens: Array = lead_tweens.duplicate()
	for i in range(1, ents.size()):
		var e: Dictionary = ents[i]
		if e["hp"] <= 0 or (e["team"] == 1 and not e["awake"]):
			continue
		if e.get("snared", 0) > 0:
			e.erase("windup")   # held fast, it loses the move it was gathering
			continue
		if e.get("stagger", 0) > 0:
			e["stagger"] -= 1   # slammed: it spends this turn getting its footing back
			continue
		if e.has("windup"):
			if not tweens.is_empty():
				await get_tree().create_timer(STEP_TIME).timeout
				tweens.clear()
			await _fire_windup(i)
			if ents[0]["hp"] <= 0:
				break
			continue
		var plan := _decide(i)
		if plan["kind"] == "windup":
			e["facing"] = _facing_of(plan["d"])
			_set_tex(e, e["art"]["still"][e["facing"]])
			e["windup"] = {"m": plan["m"], "d": plan["d"], "tiles": move_tiles(i, plan["m"], plan["d"])}
			e["cds"][plan["m"]] = _turns_of(plan["m"], i) + 1
			_say("%s is gathering itself for %s!" % [e["name"], Arena.MOVES[plan["m"]]["name"]])
			_play("res://assets/audio/sfx/arena/telegraph.wav", -10.0)
			continue
		if plan["kind"] == "move":
			tweens.append(_step(i, plan["d"]))
		elif plan["kind"] == "attack":
			if not tweens.is_empty():
				await get_tree().create_timer(STEP_TIME).timeout
				tweens.clear()
			await use_move(i, plan["m"], plan["d"])
			if ents[0]["hp"] <= 0:
				break
	if not tweens.is_empty():
		await get_tree().create_timer(STEP_TIME).timeout
	_end_turn()


func _decide(i: int) -> Dictionary:
	var e: Dictionary = ents[i]
	var t := _target(i)
	if t >= 0:
		var best := {}
		var best_score := 0.0
		for m in e["moves"]:
			if e["cds"][m] > 0:
				continue
			var d := aim(i, m)
			if d == Vector2i.ZERO:
				continue
			var hits: Array = move_hits(i, m, d)["hits"]
			var score := 0.0
			for j in hits:
				var bonus := 1.0
				for tag in position_tags(i, j):
					bonus *= AMBUSH if tag == "AMBUSH" else PINCER
				score += Arena.MOVES[m]["damage"] * _mult(i, j, m) * bonus
			if m != e["moves"][0]:
				score *= 1.15   # a move over the basic when both reach (Kit Sense's lean, kept)
			if score > best_score:
				best_score = score
				best = {"kind": "attack", "m": m, "d": d, "j": hits[0]}
		if not best.is_empty() and e["team"] == 0 and not "PINCER" in position_tags(i, best["j"]):
			# A short walk round to a healthy foe's far side beats ordinary hits: every hit after is a PINCER.
			var q := pincer_tile(i, best["j"])
			var foe: Dictionary = ents[best["j"]]
			if q != Vector2i(-1, -1) and q != e["pos"] and _cheb(e["pos"], q) <= FLANK_REACH and foe["hp"] > foe["max_hp"] * FLANK_WORTH:
				var st := _step_toward(i, q)
				if st != Vector2i.ZERO:
					return {"kind": "move", "d": st}
		if not best.is_empty():
			if e["team"] == 1 and best["m"] != e["moves"][0] and move_reach(best["m"])["kind"] in WARN_KINDS:
				best["kind"] = "windup"   # a wild creature's strong move warns first
			return best
		var step := Vector2i.ZERO
		if e["team"] == 0:
			var flank := pincer_tile(i, t)
			if flank != e["pos"] and flank != Vector2i(-1, -1):
				step = _step_toward(i, flank)   # round to the far side of the foe
		if step == Vector2i.ZERO:
			step = _step_toward(i, ents[t]["pos"])
		if step != Vector2i.ZERO:
			return {"kind": "move", "d": step}
	if e["team"] == 0 and tactic == "guard" and _cheb(e["pos"], ents[0]["pos"]) > 1:
		var back := _step_toward(i, ents[0]["pos"])
		if back != Vector2i.ZERO:
			return {"kind": "move", "d": back}
	if e["team"] == 0:
		# A partner follows the one ahead of it in the chain.
		var ahead: int = 0
		for k in range(i - 1, -1, -1):
			if ents[k]["team"] == 0 and ents[k]["hp"] > 0:
				ahead = k
				break
		if _cheb(e["pos"], ents[ahead]["pos"]) > 1:
			var step := _step_toward(i, ents[ahead]["pos"])
			if step != Vector2i.ZERO:
				return {"kind": "move", "d": step}
	return {"kind": "wait"}


## The tile on the far side of foe t from one of i's teammates already beside it: standing there
## makes every hit a PINCER. (-1, -1) when there is none open; i's own tile when it is already there.
func pincer_tile(i: int, t: int) -> Vector2i:
	var best := Vector2i(-1, -1)
	var tp: Vector2i = ents[t]["pos"]
	for k in ents.size():
		if k == i or ents[k]["hp"] <= 0 or ents[k]["team"] != ents[i]["team"] or _cheb(ents[k]["pos"], tp) != 1:
			continue
		var away: Vector2i = tp - ents[k]["pos"]
		var q: Vector2i = tp + Vector2i(signi(away.x), signi(away.y))
		if q == ents[i]["pos"]:
			return q
		if not _floor_at(q) or _occupant(q) >= 0:
			continue
		if best == Vector2i(-1, -1) or _cheb(ents[i]["pos"], q) < _cheb(ents[i]["pos"], best):
			best = q
	return best


## An item's name, colour and line: the fixed ITEMS, or a scroll made from its move.
func item_info(kind: String) -> Dictionary:
	if kind.begins_with("scroll:"):
		var m := kind.substr(7)
		return {"name": "%s Scroll" % Arena.MOVES[m]["name"], "what": "teaches it to a body with %s" % " and ".join(MoveBody.NEEDS.get(m, [])), "col": Color("#d8c08a")}
	return ITEMS[kind]


## The shared signatures a scroll can hold: moves more than one line's bodies can use, that
## deal damage (the dungeon's moves are attacks for now).
func scroll_pool() -> Array:
	var out: Array = []
	for m in MoveBody.shared(Arena.LINES):
		if Arena.MOVES.has(m) and Arena.MOVES[m]["damage"] > 0:
			out.append(m)
	return out


## The teach panel's rows: first every teammate and whether it can learn the scroll's move,
## then (once one is chosen and its moves are full) the moves it could forget.
func teach_rows() -> Array:
	var m := teach_kind.substr(7)
	var rows: Array = []
	if teach_learner < 0:
		for i in ents.size():
			var e: Dictionary = ents[i]
			if e["team"] != 0 or e["hp"] <= 0:
				continue
			var why := ""
			if m in e["moves"]:
				why = "ALREADY KNOWS IT"
			elif not MoveBody.can_learn(e["form"], m):
				why = "NO %s" % " OR ".join(MoveBody.missing(e["form"], m)).to_upper()
			rows.append({"i": i, "text": "%s   %s" % [String(e["name"]).to_upper(), why if why != "" else "CAN LEARN"], "ok": why == ""})
	else:
		var e: Dictionary = ents[teach_learner]
		for slot in range(1, e["moves"].size()):   # the basic attack is never forgotten
			rows.append({"slot": slot, "text": "FORGET %s" % String(Arena.MOVES[e["moves"][slot]]["name"]).to_upper(), "ok": true})
	return rows


## Teach the open scroll's move to teammate i. With four moves already, it needs the slot to
## forget (1 to 3); without one, the panel asks. Costs no turn. Returns what happened.
func act_teach(i: int, forget := -1) -> String:
	var m := teach_kind.substr(7)
	var e: Dictionary = ents[i]
	if m in e["moves"]:
		_say("%s already knows %s." % [e["name"], Arena.MOVES[m]["name"]])
		return "knows"
	if not MoveBody.can_learn(e["form"], m):
		_say("%s can't learn %s: it has no %s." % [e["name"], Arena.MOVES[m]["name"], " or ".join(MoveBody.missing(e["form"], m))])
		_play("res://assets/audio/sfx/ui/cancel.wav", -12.0)
		return "body"
	if e["moves"].size() >= MOVES_MAX:
		if forget < 1 or forget >= e["moves"].size():
			teach_learner = i
			teach_sel = 0
			_say("%s knows four moves. Which should it forget?" % e["name"])
			return "full"
		var old: String = e["moves"][forget]
		e["cds"].erase(old)
		e["moves"][forget] = m
		_say("%s forgot %s and learned %s!" % [e["name"], Arena.MOVES[old]["name"], Arena.MOVES[m]["name"]])
	else:
		e["moves"].append(m)
		_say("%s learned %s!" % [e["name"], Arena.MOVES[m]["name"]])
	e["cds"][m] = 0
	taught["%d:%d" % [e["line"], e["stage"]]] = e["moves"].duplicate()
	_take(teach_kind)
	teach_kind = ""
	teach_learner = -1
	_pops.append({"pos": e["node"].position + Vector2(0, -38), "text": "NEW MOVE!", "t": 0.0, "col": Color(0.85, 0.95, 0.6)})
	_play("res://assets/audio/sfx/ui/confirm.wav", -6.0)
	return "learned"


## Cycle the partners' order: follow me, go after foes, guard me. Costs no turn.
func act_tactic() -> void:
	tactic = TACTICS[(TACTICS.find(tactic) + 1) % TACTICS.size()]
	_say("Team: %s." % String(TACTIC_NAMES[tactic]).capitalize())
	_play("res://assets/audio/sfx/ui/confirm.wav", -10.0)


## The enemy creature i goes for: the nearest one it can see (a partner only chases what is within
## its order's reach of the leader: 4 tiles following, any distance going after foes, 2 guarding).
func _target(i: int) -> int:
	var e: Dictionary = ents[i]
	var best := -1
	for j in ents.size():
		if not _foes(i, j) or (ents[j]["team"] == 1 and not ents[j]["awake"]):
			continue
		if not _sees(e["pos"], ents[j]["pos"]):
			continue
		if e["team"] == 0 and _cheb(ents[j]["pos"], ents[0]["pos"]) > TACTIC_LEASH[tactic]:
			continue
		if best < 0 or _cheb(e["pos"], ents[j]["pos"]) < _cheb(e["pos"], ents[best]["pos"]):
			best = j
	return best


func _end_turn() -> void:
	for e in ents:
		for m in e["cds"]:
			e["cds"][m] = maxi(0, e["cds"][m] - 1)
		if e["hp"] > 0 and e["team"] == 0 and turn % REGEN_EVERY == 0:
			e["hp"] = mini(e["max_hp"], e["hp"] + 1)
		e["snared"] = maxi(0, e.get("snared", 0) - 1)
	if turn % LIGHT_DRAIN_EVERY == 0:
		light = maxf(0.0, light - 1.0)
		if light == 0.0 and turn % (LIGHT_DRAIN_EVERY * 10) == 0:
			_say("The lantern is out. Only what is close can be seen.")
	_pick_up()
	_spring_traps()
	_monster_house()
	for e in ents:
		e["moved"] = false
	# Wild creatures wake when one of yours comes into sight.
	for w in ents:
		if w["team"] != 1 or w["hp"] <= 0 or w["awake"]:
			continue
		for e in ents:
			if e["team"] == 0 and e["hp"] > 0 and _sees(e["pos"], w["pos"]) and _cheb(e["pos"], w["pos"]) <= SIGHT - 1:
				w["awake"] = true
				_pops.append({"pos": w["node"].position + Vector2(0, -30), "text": "!", "t": 0.0, "col": Color(1, 0.4, 0.3)})
				break
	_reveal()
	if ents[0]["hp"] <= 0 and bag.get("rally_seed", 0) > 0:
		_take("rally_seed")
		ents[0]["hp"] = ents[0]["max_hp"] / 2
		ents[0]["node"].modulate.a = 1.0
		_say("The Rally Seed! %s gets back up." % ents[0]["name"])
	if ents[0]["hp"] <= 0:
		faints += 1
		bag = {"reedberry": 1}   # fainting loses the bag (Explorers of Sky); a fresh run starts with one berry
		party = _party_at_start.duplicate(true)   # and the run's recruits: they never reached the hall
		roster = _roster_at_start.duplicate(true)
		asking = -1
		light = LIGHT_MAX
		_say("%s fainted! The team is carried back to the entrance." % ents[0]["name"])
		floor_n = 1
		floor_seed = randi()
		call_deferred("_build_floor", true)
	elif ents[0]["pos"] == data["stairs"]:
		_say("Stairs. Press E to go down.")
	if real_time_battles and not in_battle and ents[0]["hp"] > 0 and asking < 0:
		for w in ents:
			if w["team"] == 1 and w["hp"] > 0 and w["awake"] and _cheb(w["pos"], ents[0]["pos"]) <= BATTLE_RANGE and _sees(ents[0]["pos"], w["pos"]):
				in_battle = true
				call_deferred("_start_battle")
				break


## How far the lantern lets the leader see down a hallway.
func light_radius() -> int:
	return 1 + int(ceil(light / 20.0))


func _reveal() -> void:
	var lead: Vector2i = ents[0]["pos"]
	var w: int = data["w"]
	visible_tiles.clear()
	var r := light_radius()
	for y in range(lead.y - r, lead.y + r + 1):
		for x in range(lead.x - r, lead.x + r + 1):
			var p := Vector2i(x, y)
			if x >= 0 and y >= 0 and x < w and y < data["h"] and (p == lead or _sees_r(lead, p, r)):
				visible_tiles[p] = true
	if light > 0.0:
		for room in data["rooms"]:
			if room.grow(1).has_point(lead):
				for y in range(room.position.y - 1, room.end.y + 1):
					for x in range(room.position.x - 1, room.end.x + 1):
						visible_tiles[Vector2i(x, y)] = true
	for p in visible_tiles:
		if p.x >= 0 and p.y >= 0 and p.x < w and p.y < data["h"]:
			explored[p.y * w + p.x] = 1
	for e in ents:
		e["node"].visible = e["team"] == 0 or visible_tiles.has(e["pos"])
	for room in data["rooms"]:
		if room.grow(1).has_point(lead):
			for y in range(room.position.y - 1, room.end.y + 1):
				for x in range(room.position.x - 1, room.end.x + 1):
					if x >= 0 and y >= 0 and x < w and y < data["h"]:
						explored[y * w + x] = 1
	for y in range(lead.y - 2, lead.y + 3):
		for x in range(lead.x - 2, lead.x + 3):
			if x >= 0 and y >= 0 and x < w and y < data["h"]:
				explored[y * w + x] = 1


# ---------------------------------------------------------------- the run loop

func _pick_up() -> void:
	var lead: Dictionary = ents[0]
	for k in range(floor_items.size() - 1, -1, -1):
		var it: Dictionary = floor_items[k]
		if it["pos"] != lead["pos"]:
			continue
		if not bag.has(it["kind"]) and bag.size() >= BAG_KINDS:
			_say("The bag is full; the %s stays on the floor." % item_info(it["kind"])["name"])
			continue
		bag[it["kind"]] = bag.get(it["kind"], 0) + 1
		floor_items.remove_at(k)
		_say("Picked up a %s." % item_info(it["kind"])["name"])
		_play("res://assets/audio/sfx/ui/confirm.wav", -12.0)


func _spring_traps() -> void:
	for e in ents:
		if e["team"] != 0 or e["hp"] <= 0 or not e.get("moved", false):
			continue
		for tr in traps:
			if tr["pos"] != e["pos"]:
				continue
			tr["seen"] = true
			_say("%s stepped on a %s!" % [e["name"], TRAPS[tr["kind"]]["name"]])
			_play("res://assets/audio/sfx/ui/cancel.wav", -8.0)
			match tr["kind"]:
				"snare":
					e["snared"] = 3   # this turn's tick takes one, so it holds for 2 turns
				"silt":
					light = maxf(0.0, light - 15.0)
					for o in ents:
						if o["team"] == 0 and o["hp"] > 0 and _cheb(o["pos"], e["pos"]) <= 1:
							o["hp"] = maxi(1, o["hp"] - 6)
							_pops.append({"pos": o["node"].position + Vector2(0, -26), "text": "6", "t": 0.0, "col": Color(0.85, 0.75, 0.55)})
				"warp":
					var rooms: Array = data["rooms"]
					for tries in 30:
						var room: Rect2i = rooms[randi() % rooms.size()]
						var p := room.get_center()
						if not room.grow(1).has_point(e["pos"]) and _occupant(p) < 0 and _floor_at(p):
							e["pos"] = p
							_place(e)
							break


func _monster_house() -> void:
	if monster_sprung or monster_room.size == Vector2i.ZERO or not monster_room.has_point(ents[0]["pos"]):
		return
	monster_sprung = true
	_say("It's a Monster House!")
	_play("res://assets/audio/sfx/ui/hit_strong.wav", -4.0)
	var spawned := 0
	var rng := RandomNumberGenerator.new()
	rng.seed = floor_seed + 99
	for tries in 80:
		if spawned >= MONSTER_HOUSE_WILD:
			break
		var p := Vector2i(rng.randi_range(monster_room.position.x, monster_room.end.x - 1), rng.randi_range(monster_room.position.y, monster_room.end.y - 1))
		if _occupant(p) >= 0 or not _floor_at(p) or _cheb(p, ents[0]["pos"]) < 2:
			continue
		var pick: Array = RECIPE["spawns"][rng.randi_range(0, RECIPE["spawns"].size() - 1)]
		var w := _make(pick[0], pick[1], 1, p)
		w["max_hp"] = maxi(6, int(round(w["max_hp"] * WILD_HP)))
		w["hp"] = w["max_hp"]
		w["awake"] = true
		w["facing"] = _facing_of(ents[0]["pos"] - p)
		ents.append(w)
		_place(w)
		spawned += 1


func _take(kind: String) -> void:
	bag[kind] = bag.get(kind, 0) - 1
	if bag[kind] <= 0:
		bag.erase(kind)


## Use an item from the bag. Using one is the leader's action for the turn; one that cannot do
## anything (a stone with nobody in its line) is refused for free.
func act_use_item(kind: String) -> void:
	if busy or not bag.has(kind) or ents[0]["hp"] <= 0:
		return
	var lead: Dictionary = ents[0]
	if kind.begins_with("scroll:"):
		teach_kind = kind   # reading a scroll costs no turn; the panel chooses who learns
		teach_sel = 0
		teach_learner = -1
		return
	match kind:
		"reedberry":
			_take(kind)
			await _player_turn(func() -> bool:
				var heal: int = mini(15, lead["max_hp"] - lead["hp"])
				lead["hp"] += heal
				_say("%s ate a Reedberry: %d back." % [lead["name"], heal])
				return true)
		"lamp_oil":
			_take(kind)
			await _player_turn(func() -> bool:
				light = minf(LIGHT_MAX, light + 40.0)
				_say("The lantern burns brighter.")
				_reveal()
				return true)
		"river_stone":
			var d := Vector2i.ZERO
			for dd in [_dir_of(lead["facing"])] + DIRS:
				if _stone_target(dd) >= 0:
					d = dd
					break
			if d == Vector2i.ZERO:
				_say("Nothing in a line to throw the stone at.")
				_play("res://assets/audio/sfx/ui/cancel.wav", -12.0)
				return
			_take(kind)
			await _player_turn(func() -> bool:
				var j := _stone_target(d)
				lead["facing"] = _facing_of(d)
				_set_tex(lead, lead["art"]["still"][lead["facing"]])
				_shots.append({"from": lead["node"].position + Vector2(0, -10), "to": ents[j]["node"].position + Vector2(0, -10), "t": 0.0, "burst": false})
				ents[j]["hp"] = maxi(0, ents[j]["hp"] - 8)
				ents[j]["flash"] = 0.25
				ents[j]["awake"] = true
				_pops.append({"pos": ents[j]["node"].position + Vector2(0, -26), "text": "8", "t": 0.0, "col": Color(1, 1, 1)})
				_say("%s threw a River Stone: %s took 8 damage." % [lead["name"], ents[j]["name"]])
				if ents[j]["hp"] <= 0:
					_say("%s fainted!" % ents[j]["name"])
					light = minf(LIGHT_MAX, light + LIGHT_ON_KO)
					create_tween().tween_property(ents[j]["node"], "modulate:a", 0.0, 0.35)
				return true)
		"rally_seed":
			_say("The Rally Seed works by itself when the leader faints.")


## Whether any wild creature's wind-up marks tile p.
func _warned(p: Vector2i) -> bool:
	for e in ents:
		if e["hp"] > 0 and e.has("windup") and p in e["windup"]["tiles"]:
			return true
	return false


func _stone_target(d: Vector2i) -> int:
	var at: Vector2i = ents[0]["pos"]
	for k in 8:
		if not _floor_at(at + d):
			return -1
		at += d
		var o := _occupant(at)
		if o >= 0:
			return o if _foes(0, o) else -1
	return -1


# ---------------------------------------------------------------- per frame

func _process(delta: float) -> void:
	if ents.is_empty():
		return
	if in_battle:
		_watch_battle(delta)
		return
	for e in ents:
		e["flash"] = maxf(0.0, e["flash"] - delta)
		e["sprite"].modulate = Color(3, 3, 3) if e["flash"] > 0.12 else Color(1, 1, 1)
		if e["walk_t"] > 0.0:
			e["walk_t"] = maxf(0.0, e["walk_t"] - delta)
			var frames: Array = e["art"]["walk"][e["facing"]]
			if not frames.is_empty():
				_set_tex(e, frames[int((1.0 - e["walk_t"] / STEP_TIME) * 4.0 + turn * 4) % frames.size()])
			if e["walk_t"] <= 0.0:
				_set_tex(e, e["art"]["still"][e["facing"]])
		e["node"].z_index = int(e["node"].position.y)
	for p in _pops:
		p["t"] += delta
	_pops = _pops.filter(func(p: Dictionary) -> bool: return p["t"] < 0.8)
	for s in _shots:
		s["t"] += delta
	_shots = _shots.filter(func(s: Dictionary) -> bool: return s["t"] < 0.3)
	if poll_input:
		_poll(delta)
	if autopilot and not busy:
		_autopilot()
	var focus: Vector2 = ents[0]["node"].position + Vector2(0, -12)
	var size := Vector2(data["w"], data["h"]) * T
	var half := Vector2(VIEW) * 0.5
	focus = focus.clamp(half, size - half)
	_world.position = (half - focus).round()
	_fx.queue_redraw()
	_floor_fx.queue_redraw()
	_hud.queue_redraw()


func _poll(delta: float) -> void:
	if busy:
		return
	if asking >= 0:
		if _tapped(KEY_Y) or _tapped(KEY_ENTER):
			act_recruit(true)
		elif _tapped(KEY_N) or _tapped(KEY_ESCAPE):
			act_recruit(false)
		return
	if teach_kind != "":
		var rows := teach_rows()
		if _tapped(KEY_W) or _tapped(KEY_UP):
			teach_sel = maxi(0, teach_sel - 1)
		elif _tapped(KEY_S) or _tapped(KEY_DOWN):
			teach_sel = mini(rows.size() - 1, teach_sel + 1)
		elif (_tapped(KEY_J) or _tapped(KEY_ENTER)) and not rows.is_empty():
			if teach_learner < 0:
				act_teach(rows[teach_sel]["i"])
			else:
				act_teach(teach_learner, rows[teach_sel]["slot"])
		elif _tapped(KEY_ESCAPE) or _tapped(KEY_I):
			teach_kind = ""
		return
	if bag_open:
		# The bag: W and S choose, J or Enter uses, I or Escape closes.
		var kinds: Array = bag.keys()
		if _tapped(KEY_W) or _tapped(KEY_UP):
			bag_sel = maxi(0, bag_sel - 1)
		elif _tapped(KEY_S) or _tapped(KEY_DOWN):
			bag_sel = mini(kinds.size() - 1, bag_sel + 1)
		elif (_tapped(KEY_J) or _tapped(KEY_ENTER)) and not kinds.is_empty():
			bag_open = false
			act_use_item(kinds[clampi(bag_sel, 0, kinds.size() - 1)])
		elif _tapped(KEY_I) or _tapped(KEY_ESCAPE):
			bag_open = false
		return
	var d := Vector2i(int(_key(KEY_D) or _key(KEY_RIGHT)) - int(_key(KEY_A) or _key(KEY_LEFT)), int(_key(KEY_S) or _key(KEY_DOWN)) - int(_key(KEY_W) or _key(KEY_UP)))
	if d == Vector2i.ZERO:
		_hold = 0.0
		_was_dir = Vector2i.ZERO
	else:
		if _was_dir == Vector2i.ZERO:
			_hold += delta
			if _hold < 0.07:
				return   # a moment for the second key of a diagonal
		_was_dir = d
		if Input.is_key_pressed(KEY_SHIFT):
			act_face(d)
		else:
			act_move(d)
		return
	for pair in [[KEY_J, 0], [KEY_SPACE, 0], [KEY_1, 1], [KEY_2, 2], [KEY_3, 3]]:
		if _tapped(pair[0]):
			act_attack(pair[1])
			return
	if _tapped(KEY_I):
		bag_open = not bag_open
		bag_sel = 0
		return
	if _tapped(KEY_Z) or _tapped(KEY_PERIOD):
		act_rest()
	elif _tapped(KEY_E):
		act_stairs()
	elif _tapped(KEY_T):
		act_tactic()
	elif _tapped(KEY_TAB):
		autopilot = not autopilot
		_say("Autopilot %s." % ("on" if autopilot else "off"))


func _unhandled_input(event: InputEvent) -> void:
	if in_battle:
		return
	if poll_input and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		act_attack(0)


func _key(k: int) -> bool:
	return Input.is_physical_key_pressed(k)


func _tapped(k: int) -> bool:
	var now := Input.is_physical_key_pressed(k)
	var was: bool = _keys_was.get(k, false)
	_keys_was[k] = now
	return now and not was


## Tab: the leader plays itself: the nearest wild creature it knows of, then the stairs.
func _autopilot() -> void:
	var lead: Dictionary = ents[0]
	if lead["hp"] <= 0:
		return
	if asking >= 0:
		act_recruit(true)
		return
	if lead["pos"] == data["stairs"] and ents.filter(func(e: Dictionary) -> bool: return e["team"] == 1 and e["hp"] > 0).is_empty():
		act_stairs()
		return
	var awake_near := false
	for j in ents.size():
		if ents[j]["team"] == 1 and ents[j]["hp"] > 0 and ents[j]["awake"] and _sees(lead["pos"], ents[j]["pos"]):
			awake_near = true
	if _warned(lead["pos"]):
		# Step out of a marked tile before anything else (what a player should learn to do).
		for dd in DIRS:
			var q: Vector2i = lead["pos"] + dd
			if can_step(lead["pos"], dd) and _occupant(q) < 0 and not _warned(q):
				act_move(dd)
				return
	if float(lead["hp"]) / lead["max_hp"] < 0.4 and bag.has("reedberry"):
		act_use_item("reedberry")
		return
	if light < 25.0 and bag.has("lamp_oil"):
		act_use_item("lamp_oil")
		return
	if not awake_near and float(lead["hp"]) / lead["max_hp"] < REST_TO:
		act_rest()   # catch its breath before the next room
		return
	var t := -1
	for j in ents.size():
		if ents[j]["team"] == 1 and ents[j]["hp"] > 0 and (t < 0 or _cheb(lead["pos"], ents[j]["pos"]) < _cheb(lead["pos"], ents[t]["pos"])):
			t = j
	if t >= 0:
		for slot in range(lead["moves"].size() - 1, -1, -1):
			var m: String = lead["moves"][slot]
			if lead["cds"][m] == 0 and aim(0, m) != Vector2i.ZERO:
				act_attack(slot)
				return
		var d := _step_toward(0, ents[t]["pos"], true)
		if d != Vector2i.ZERO:
			act_move(d)
		else:
			act_rest()
		return
	var goal: Vector2i = data["stairs"]
	for it in floor_items:
		if explored[it["pos"].y * data["w"] + it["pos"].x] == 1 and (goal == data["stairs"] or _cheb(lead["pos"], it["pos"]) < _cheb(lead["pos"], goal)):
			goal = it["pos"]   # pick up what it has seen before the stairs
	var d2 := _step_toward(0, goal, true)
	if d2 != Vector2i.ZERO:
		act_move(d2)
	else:
		act_rest()


# ---------------------------------------------------------------- drawing

## Warning tiles: red, pulsing, on the floor under the creatures, where the leader can see.
func _draw_floor_fx() -> void:
	var k: float = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 130.0)
	for e in ents:
		if e["hp"] <= 0 or not e.has("windup"):
			continue
		for t in e["windup"]["tiles"]:
			if not visible_tiles.has(t):
				continue
			var r := Rect2(Vector2(t) * T + Vector2(1, 1), Vector2(T - 2, T - 2))
			_floor_fx.draw_rect(r, Color(0.9, 0.15, 0.1, 0.18 + 0.17 * k))
			_floor_fx.draw_rect(r, Color(1.0, 0.35, 0.25, 0.75), false, 1.0)


func _draw_fx() -> void:
	for it in floor_items:
		var c: Vector2 = (Vector2(it["pos"]) * T + Vector2(T, T) * 0.5).round()
		_fx.draw_circle(c + Vector2(0, 2), 5.0, Color(0, 0, 0, 0.3))
		_fx.draw_circle(c, 4.0, item_info(it["kind"])["col"])
		_fx.draw_circle(c + Vector2(-1, -1), 1.5, Color(1, 1, 1, 0.6))
	for tr in traps:
		if tr["seen"]:
			var c2: Vector2 = (Vector2(tr["pos"]) * T + Vector2(T, T) * 0.5).round()
			_fx.draw_line(c2 + Vector2(-5, -5), c2 + Vector2(5, 5), Color(0.75, 0.2, 0.2), 2.0)
			_fx.draw_line(c2 + Vector2(-5, 5), c2 + Vector2(5, -5), Color(0.75, 0.2, 0.2), 2.0)
	# The dark: every tile in view the lantern does not reach.
	var origin: Vector2 = -_world.position
	var t0 := Vector2i(floori(origin.x / T) - 1, floori(origin.y / T) - 1)
	for ty in range(t0.y, t0.y + VIEW.y / T + 3):
		for tx in range(t0.x, t0.x + VIEW.x / T + 3):
			if not visible_tiles.has(Vector2i(tx, ty)):
				_fx.draw_rect(Rect2(Vector2(tx, ty) * T, Vector2(T, T)), Color(0.02, 0.02, 0.04, 0.82))
	# Sleeping wild creatures breathe a "z".
	for e in ents:
		if e["team"] == 1 and e["hp"] > 0 and not e["awake"] and visible_tiles.has(e["pos"]):
			var p: Vector2 = e["node"].position + Vector2(8, -30 - 2.0 * sin(Time.get_ticks_msec() / 300.0))
			_fx.draw_string(FONT, p.round(), "z", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.85, 0.9, 1.0, 0.85))
	# The leader's facing: a small chevron on the tile ahead.
	if not ents.is_empty() and ents[0]["hp"] > 0:
		var ahead: Vector2 = _tile_px(ents[0]["pos"] + _dir_of(ents[0]["facing"])) + Vector2(0, -T * 0.28)
		_fx.draw_arc(ahead.round(), 4.0, 0, TAU, 12, Color(1, 0.85, 0.4, 0.55), 1.0)
	for s in _shots:
		var k: float = clampf(s["t"] / 0.15, 0.0, 1.0)
		var at: Vector2 = s["from"].lerp(s["to"], k)
		_fx.draw_circle(at.round(), 3.0 if not s["burst"] else 2.0 + 8.0 * k, Color(1, 0.95, 0.7, 1.0 - k * 0.5))
	for p in _pops:
		var a: float = clampf(1.0 - p["t"] / 0.8, 0.0, 1.0)
		_fx.draw_string(FONT, (p["pos"] + Vector2(-6, -14.0 * p["t"])).round(), p["text"], HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(p["col"], a))


func _draw_hud() -> void:
	if ents.is_empty():
		return
	var h := _hud
	h.draw_string(FONT, Vector2(16, 24), "WASD MOVE (TWO KEYS FOR DIAGONALS)   SHIFT TURN   J / CLICK ATTACK   1 2 3 MOVES   I BAG   T TEAM   Z REST   E STAIRS   TAB AUTO", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1, 1, 1, 0.75))
	# The team: floor, names and health.
	h.draw_string(FONT, Vector2(16, 56), "B%dF" % floor_n, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#F0F4F8"))
	var y := 70.0
	for e in ents:
		if e["team"] != 0:
			continue
		var k: float = float(e["hp"]) / e["max_hp"]
		h.draw_string(FONT, Vector2(16, y + 12), "%s  %d/%d" % [e["name"].to_upper(), e["hp"], e["max_hp"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#F0F4F8") if e["hp"] > 0 else Color(1, 0.4, 0.3))
		h.draw_rect(Rect2(16, y + 16, 160, 6), Color(0.1, 0.1, 0.12, 0.8))
		h.draw_rect(Rect2(16, y + 16, 160 * k, 6), Color("#5fd17a") if k > 0.5 else (Color("#e8c547") if k > 0.25 else Color("#e8574a")))
		y += 28.0
	if asking >= 0 and asking < ents.size():
		var ask_box := Rect2(360, 200, 432, 70)
		h.draw_rect(ask_box, Color(0.05, 0.07, 0.1, 0.92))
		h.draw_rect(ask_box, Color(1, 0.85, 0.4), false, 2.0)
		h.draw_string(FONT, ask_box.position + Vector2(14, 28), "%s WANTS TO JOIN YOUR TEAM" % String(ents[asking]["name"]).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, 404, 12, Color(1, 0.85, 0.4))
		h.draw_string(FONT, ask_box.position + Vector2(14, 52), "Y  WELCOME IT       N  LET IT GO", HORIZONTAL_ALIGNMENT_LEFT, 404, 11, Color(1, 1, 1, 0.9))
	# The lantern.
	h.draw_string(FONT, Vector2(16, y + 12), "LANTERN  %d" % int(light), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#f2c14e"))
	h.draw_rect(Rect2(16, y + 16, 160, 6), Color(0.1, 0.1, 0.12, 0.8))
	h.draw_rect(Rect2(16, y + 16, 160 * light / LIGHT_MAX, 6), Color("#f2c14e"))
	var bag_n := 0
	for k in bag:
		bag_n += bag[k]
	h.draw_string(FONT, Vector2(16, y + 44), "BAG  %d ITEMS (I)" % bag_n, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1, 1, 1, 0.8))
	h.draw_string(FONT, Vector2(16, y + 60), "TEAM  %s (T)" % TACTIC_NAMES[tactic], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.6, 0.9, 1.0, 0.9))
	if bag_open:
		var kinds: Array = bag.keys()
		var box := Rect2(360, 140, 432, 40 + 26 * maxi(1, kinds.size()))
		h.draw_rect(box, Color(0.05, 0.07, 0.1, 0.92))
		h.draw_rect(box, Color(1, 0.85, 0.4), false, 2.0)
		h.draw_string(FONT, box.position + Vector2(14, 24), "BAG   W/S CHOOSE   J USE   I CLOSE", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1, 0.85, 0.4))
		if kinds.is_empty():
			h.draw_string(FONT, box.position + Vector2(14, 52), "EMPTY", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1, 1, 1, 0.6))
		for k in kinds.size():
			var it: Dictionary = item_info(kinds[k])
			var yy: float = box.position.y + 52 + k * 26
			if k == bag_sel:
				h.draw_rect(Rect2(box.position.x + 6, yy - 16, box.size.x - 12, 22), Color(1, 1, 1, 0.12))
			h.draw_circle(Vector2(box.position.x + 22, yy - 5), 6.0, it["col"])
			h.draw_string(FONT, Vector2(box.position.x + 36, yy), "%s  x%d   %s" % [String(it["name"]).to_upper(), bag[kinds[k]], String(it["what"]).to_upper()], HORIZONTAL_ALIGNMENT_LEFT, box.size.x - 44, 10, Color(1, 1, 1, 0.9))
	if teach_kind != "":
		var rows := teach_rows()
		var tbox := Rect2(360, 140, 432, 64 + 26 * maxi(1, rows.size()))
		h.draw_rect(tbox, Color(0.05, 0.07, 0.1, 0.94))
		h.draw_rect(tbox, Color("#d8c08a"), false, 2.0)
		var title: String = item_info(teach_kind)["name"]
		h.draw_string(FONT, tbox.position + Vector2(14, 24), title.to_upper() + ("   WHO LEARNS IT?" if teach_learner < 0 else "   FORGET WHICH?"), HORIZONTAL_ALIGNMENT_LEFT, 404, 11, Color("#d8c08a"))
		h.draw_string(FONT, tbox.position + Vector2(14, 42), "W/S CHOOSE   J TEACH   ESC CLOSE", HORIZONTAL_ALIGNMENT_LEFT, 404, 9, Color(1, 1, 1, 0.6))
		for k in rows.size():
			var yy: float = tbox.position.y + 70 + k * 26
			if k == teach_sel:
				h.draw_rect(Rect2(tbox.position.x + 6, yy - 16, tbox.size.x - 12, 22), Color(1, 1, 1, 0.12))
			h.draw_string(FONT, Vector2(tbox.position.x + 18, yy), rows[k]["text"], HORIZONTAL_ALIGNMENT_LEFT, 396, 10, Color(1, 1, 1, 0.95) if rows[k]["ok"] else Color(1, 0.55, 0.45, 0.85))
	# The leader's moves.
	var lead: Dictionary = ents[0]
	for s in lead["moves"].size():
		var m: String = lead["moves"][s]
		var box := Rect2(16 + s * 136, 560, 128, 40)
		var ready: bool = lead["cds"][m] == 0
		h.draw_rect(box, Color(0.07, 0.09, 0.11, 0.85))
		h.draw_rect(box, Color(1, 0.85, 0.4) if ready else Color("#75604D"), false, 2.0)
		h.draw_string(FONT, box.position + Vector2(6, 16), ("J" if s == 0 else str(s)) + "  " + String(Arena.MOVES[m]["name"]).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, 120, 9, Color(1, 1, 1, 0.95 if ready else 0.5))
		var r := move_reach(m)
		h.draw_string(FONT, box.position + Vector2(6, 32), ("%s %d" % [r["kind"].to_upper(), r["n"]]) + ("" if ready else "   %d TURNS" % lead["cds"][m]), HORIZONTAL_ALIGNMENT_LEFT, 120, 8, Color(1, 1, 1, 0.6))
	# The message log, Explorers of Sky style.
	var ly := 470.0
	h.draw_rect(Rect2(600, ly - 16, 536, 92), Color(0.05, 0.07, 0.1, 0.75))
	var shown: Array = log_lines.slice(maxi(0, log_lines.size() - 5))
	for k in shown.size():
		h.draw_string(FONT, Vector2(612, ly + k * 17), shown[k], HORIZONTAL_ALIGNMENT_LEFT, 516, 10, Color(1, 1, 1, 0.55 + 0.45 * float(k + 1) / shown.size()))
	# The minimap: explored floor, the stairs once seen, your team, the wild creatures in sight.
	var mm := Vector2(1136 - data["w"] * 3, 44)
	for ty in data["h"]:
		for tx in data["w"]:
			var k2: int = ty * data["w"] + tx
			if explored[k2] == 1 and data["tiles"][k2] == Gen.FLOOR:
				h.draw_rect(Rect2(mm + Vector2(tx, ty) * 3, Vector2(3, 3)), Color(0.55, 0.7, 0.85, 0.55))
	for it in floor_items:
		if explored[it["pos"].y * data["w"] + it["pos"].x] == 1:
			h.draw_rect(Rect2(mm + Vector2(it["pos"]) * 3, Vector2(3, 3)), item_info(it["kind"])["col"])
	var st: Vector2i = data["stairs"]
	if explored[st.y * data["w"] + st.x] == 1:
		h.draw_rect(Rect2(mm + Vector2(st) * 3 - Vector2(1, 1), Vector2(5, 5)), Color(1, 0.85, 0.3))
	for e in ents:
		if e["hp"] <= 0:
			continue
		if e["team"] == 1 and not _sees(ents[0]["pos"], e["pos"]):
			continue
		h.draw_rect(Rect2(mm + Vector2(e["pos"]) * 3 - Vector2(1, 1), Vector2(4, 4)), Color("#ffb347") if e == ents[0] else (Color("#7fd0ff") if e["team"] == 0 else Color("#ff5a4a")))


func _say(text: String) -> void:
	log_lines.append(text)
	if log_lines.size() > 40:
		log_lines.pop_front()


func _play(path: String, db: float) -> void:
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	p.volume_db = db
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)
