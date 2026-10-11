extends RefCounted
## Meeting the Shortcut Crew at the Job Board (Claude, 2026-10-10; Preston: "meeting by him shoving at
## job board"). On the team's first walk through Highbank, before the parcel, Gruntle (the crew's boss)
## and its two grunts are at the board tearing down Wayline postings. The partner objects; Gruntle mocks
## it as the runt the Hall keeps turning away, shoves it to the ground, sizes up the stranger, and the
## crew strolls off. It sets up the theft and "the boss'll hear about this". Story:
## docs/design/pilot-story-2026-10-10.md. The lines are Claude's proposals.
##
## Gruntle's town sprite is its dungeon set once that is built; until then a stand-in cut from its chosen
## front art (it faces one way). The scene runs inside hub_town.gd (talk, npcs, cam_focus, cutscene).

const Layout := preload("res://scripts/town/town_layout.gd")
const Arena := preload("res://scripts/arena/arena_prototype.gd")

const TEAR := [
	["Mirekit", "Ooh, this one pays in reedberries, boss!", "mischievous"],
	["Gruntle", "Rip it down. If we aren't running it, nobody is.", "mischievous"],
]
const OBJECT := [["{partner}", "Hey! Those are Wayline jobs. You can't just tear them down!", "angry"]]
const MOCK := [
	["Gruntle", "Well, well. The little runt the Hall keeps turning away.", "mischievous"],
	["Whinet", "No partner, no route! Hee hee!", "mischievous"],
	["{partner}", "I have a partner now. We're seeing the Guildmaster today.", "determined"],
]
const AFTER_SHOVE := [
	["Gruntle", "You? On a route? You'd lose a parcel in a puddle.", "angry"],
	["Gruntle", "And you, stray. Never seen you before. Stay out of my way.", "mischievous"],
	["Mirekit", "Come on, boss. The good jobs won't steal themselves.", "mischievous"],
]
const GET_UP := [
	["{partner}", "...That was Gruntle. His crew takes jobs and never delivers them.", "sad"],
	["{partner}", "Forget them. The Wayline Hall is right there. Let's go!", "determined"],
]
# Where the crew loiter, from the board's door: Gruntle at the board, a grunt either side.
const SPOTS := {"gruntle": Vector2i(1, 0), "mirekit": Vector2i(-1, 0), "whinet": Vector2i(3, 0)}
const TRIGGER := 3   # tiles from the board's door at which the scene starts


static func board_door() -> Vector2i:
	return Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "board")[0]["door"]


## Whether the crew are at the board: the first visit, before the first dungeon is beaten.
static func pending(town) -> bool:
	var rec: Dictionary = town._record()
	return not rec.get("story", {}).get("met_crew", false) and not "first" in rec.get("beaten", [])


## Put the three at the board, backs to the street (called from hub_town._ready).
static func place_crew(town) -> void:
	for form in SPOTS:
		var e: Dictionary = make_npc(town, form, board_door() + SPOTS[form])
		e["facing"] = "n"
		town._place(e)
		town.npcs.append(e)


## A creature that is not on the team: its dungeon set if built, or a stand-in from its front art.
static func make_npc(town, form: String, pos: Vector2i) -> Dictionary:
	var node := Node2D.new()
	town._world.add_child(node)
	var sprite := Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.add_child(sprite)
	preload("res://scripts/arena/creature_finish.gd").apply(sprite)
	var still := {}
	var walk := {}
	var dir := "res://assets/sprites/arena/%s/town/" % form
	if not ResourceLoader.exists(dir + "s.png"):
		dir = "res://assets/sprites/arena/%s/dungeon/" % form
	if ResourceLoader.exists(dir + "s.png"):
		for f in ["s", "se", "e", "ne", "n", "nw", "w", "sw"]:
			still[f] = load(dir + f + ".png")
			var frames: Array = []
			for k in 8:
				if ResourceLoader.exists(dir + "walk_%s_f%d.png" % [f, k]):
					frames.append(load(dir + "walk_%s_f%d.png" % [f, k]))
			walk[f] = frames
	else:
		# Stand-in until the rotation is cut: the chosen front art at the crew's boss size, one view.
		var img := Image.load_from_file(ProjectSettings.globalize_path("res://docs/creatures/arena-starters-2026-10-07/forms/%s_arena_front_chosen.png" % form))
		img.resize(66, 66, Image.INTERPOLATE_NEAREST)   # about 1.25x the town set's 51 to 59 px crew (Preston: 78 was "a tad too big")
		var tex := ImageTexture.create_from_image(img)
		for f in ["s", "se", "e", "ne", "n", "nw", "w", "sw"]:
			still[f] = tex
			walk[f] = []
		sprite.flip_h = false
	var e := {"form": form, "pos": pos, "node": node, "sprite": sprite, "still": still, "walk": walk,
		"facing": "s", "walk_t": 0.0, "walk_clock": 0.0, "npc": true}
	town._place(e)
	return e


static func _npc(town, form: String) -> Dictionary:
	for e in town.npcs:
		if e["form"] == form:
			return e
	return {}


static func _alive(town) -> bool:
	return is_instance_valid(town) and town.is_inside_tree()


static func _wait(town, s: float) -> void:
	if _alive(town):
		await town.get_tree().create_timer(s).timeout


## Queue lines and wait until they are read; each speaker shows its own portrait.
static func _lines(town, lines: Array) -> void:
	if not _alive(town):
		return
	var pe: Dictionary = town.team[1] if town.team.size() > 1 else town.team[0]
	var pname: String = load(Arena.LINES[pe["line"]]["forms"][pe["stage"]][1]).creature_name
	for l in lines:
		var who: String = String(l[0]).replace("{partner}", pname)
		var form: String = String(pe["form"]) if l[0] == "{partner}" else who.to_lower()
		if l.size() > 2:
			form += ":" + String(l[2])
		town.talk.append([who, String(l[1]), form])
	while _alive(town) and not town.talk.is_empty():
		await town.get_tree().process_frame


## Frame two places together, held above the text box (it covers the bottom third of the view).
static func _frame(town, a: Vector2, b: Vector2) -> void:
	var to := (a + b) * 0.5 + Vector2(0, 30)
	var from: Vector2 = town.cam_focus if town.cam_focus != null else to
	town.create_tween().tween_method(func(v: Vector2) -> void: town.cam_focus = v, from, to, 0.5).set_trans(Tween.TRANS_SINE)


static func _face(town, e: Dictionary, f: String) -> void:
	e["facing"] = f
	town._place(e)


## Step a creature one tile, walking.
static func _step(town, e: Dictionary, d: Vector2i, time := 0.22) -> void:
	e["facing"] = town._facing_of(d)
	e["pos"] += d
	e["walk_t"] = time + 0.06
	town.create_tween().tween_property(e["node"], "position", town._px(e["pos"]), time)
	await _wait(town, time)
	if _alive(town):
		town._place(e)


static func run(town) -> void:
	if not _alive(town):
		return
	town.cutscene = true
	var lead: Dictionary = town.team[0]
	var partner: Dictionary = town.team[1] if town.team.size() > 1 else lead
	var g := _npc(town, "gruntle")
	var mk := _npc(town, "mirekit")
	var wh := _npc(town, "whinet")
	var door := board_door()
	town.cam_focus = (town._px(door) + lead["node"].position) * 0.5 + Vector2(0, 10)   # the board, the crew and the team in one frame
	# 1. The crew, backs turned, tearing postings off the board.
	for k in 2:
		town.board_fx["torn_at"] = Time.get_ticks_msec()
		town._sfx("board_paper")
		await _wait(town, 0.6)
	await _lines(town, TEAR)
	# 2. The partner marches up past the leader to the board and calls out; the crew turn round.
	var to: Vector2i = g["pos"] + Vector2i(0, 1)
	for d in [Vector2i(0, 1), Vector2i(-1, 1), Vector2i(1, 1)]:
		if town.open_at(g["pos"] + d):
			to = g["pos"] + d
			break
	var guard := 0
	while _alive(town) and partner["pos"] != to and guard < 8:
		guard += 1
		var d: Vector2i = (to - partner["pos"]).clamp(Vector2i(-1, -1), Vector2i(1, 1))
		if partner["pos"] + d == lead["pos"]:
			d = Vector2i(d.x if d.x != 0 else 1, d.y)   # step round the leader
		if not town.open_at(partner["pos"] + d):
			break
		await _step(town, partner, d, 0.2)
	_face(town, partner, "n")
	_face(town, lead, "n")
	await _lines(town, OBJECT)
	if not _alive(town):
		return
	town.board_fx["emote"] = {"e": g, "at": Time.get_ticks_msec()}
	town._sfx("emote_alert")
	for e in [g, mk, wh]:
		_face(town, e, "s")
	await _wait(town, 0.7)
	await _lines(town, MOCK)
	if not _alive(town):
		return
	# 3. The shove: Gruntle lunges, the partner is thrown back two tiles and falls.
	var back := Vector2i(0, 1)
	if partner["pos"] + back == lead["pos"] or partner["pos"] + back * 2 == lead["pos"]:
		back = Vector2i(-1, 1) if town.open_at(partner["pos"] + Vector2i(-1, 1)) else Vector2i(1, 1)
	var g0: Vector2 = g["node"].position
	var lunge: Tween = town.create_tween()
	lunge.tween_property(g["node"], "position", g0 + Vector2(back) * 8.0, 0.08)
	lunge.tween_property(g["node"], "position", g0, 0.18)
	town._sfx("shove")
	town._sfx("slam")
	town.shake = 4.0
	var land: Vector2i = partner["pos"]
	for k in 2:
		if town.open_at(land + back) and land + back != lead["pos"]:
			land += back
	partner["pos"] = land
	partner["down"] = true
	var fly: Tween = town.create_tween()
	var p0: Vector2 = partner["node"].position
	var p1: Vector2 = town._px(land)
	fly.tween_method(func(t: float) -> void: partner["node"].position = p0.lerp(p1, t) + Vector2(0, -10.0 * sin(t * PI)), 0.0, 1.0, 0.32)
	await fly.finished
	if not _alive(town):
		return
	town.board_fx["dust"] = {"at": p1, "t0": Time.get_ticks_msec()}
	await _wait(town, 0.6)
	# The leader turns to face Gruntle.
	_face(town, lead, town._facing_of((g["pos"] - lead["pos"]).clamp(Vector2i(-1, -1), Vector2i(1, 1))))
	town.board_fx["emote"] = {"e": lead, "at": Time.get_ticks_msec()}
	town._sfx("emote_alert")
	await _wait(town, 0.6)
	await _lines(town, AFTER_SHOVE)
	if not _alive(town):
		return
	# 4. The crew stroll off down the street and out of sight.
	for e in [g, mk, wh]:
		var go: Tween = town.create_tween().set_parallel(true)
		go.tween_property(e["node"], "position", e["node"].position + Vector2(-T() * 7, T() * 2), 1.6)
		go.tween_property(e["node"], "modulate:a", 0.0, 0.5).set_delay(1.1)
		e["facing"] = "sw"
		e["walk_t"] = 1.6
	await _wait(town, 1.7)
	if not _alive(town):
		return
	for e in [g, mk, wh]:
		e["node"].queue_free()
	town.npcs.clear()
	# 5. The partner gets up.
	_frame(town, partner["node"].position, lead["node"].position)
	partner["down"] = false
	town._place(partner)
	town._sfx("dizzy")
	_face(town, partner, town._facing_of((lead["pos"] - partner["pos"]).clamp(Vector2i(-1, -1), Vector2i(1, 1))))
	await _wait(town, 0.5)
	await _lines(town, GET_UP)
	if not _alive(town):
		return
	var rec: Dictionary = town._record()
	if not rec.has("story") or rec["story"] == null:
		rec["story"] = {}
	rec["story"]["met_crew"] = true
	town.board_fx.clear()
	town.cam_focus = null
	town.cutscene = false


static func T() -> int:
	return Layout.T


## Over the town: a "!" over whoever noticed, paper scraps when a posting is torn, dust where the
## partner lands. `c` draws in world space (hub_town's label layer).
static func draw(town, c: CanvasItem) -> void:
	var fx: Dictionary = town.board_fx
	var now := Time.get_ticks_msec()
	if fx.has("torn_at") and now - int(fx["torn_at"]) < 600:
		var a: float = (now - int(fx["torn_at"])) / 600.0
		var at: Vector2 = town._px(board_door()) + Vector2(10, -26)
		for k in 4:
			var p := (at + Vector2(k * 5 - 8 + sin(a * 6.0 + k) * 4.0, a * 26.0 + k * 2)).round()
			c.draw_rect(Rect2(p, Vector2(3, 2)), Color(0.93, 0.88, 0.75, 1.0 - a))
	if fx.has("emote") and now - int(fx["emote"]["at"]) < 1300:
		var e: Dictionary = fx["emote"]["e"]
		if is_instance_valid(e["node"]):
			var at: Vector2 = (e["node"].position + Vector2(6, -46)).round()
			c.draw_rect(Rect2(at + Vector2(-1, -1), Vector2(11, 13)), Color("#1a1410"))
			c.draw_rect(Rect2(at, Vector2(9, 11)), Color("#fff4e8"))
			c.draw_rect(Rect2(at + Vector2(1, 11), Vector2(3, 2)), Color("#1a1410"))
			c.draw_rect(Rect2(at + Vector2(4, 2), Vector2(1, 5)), Color("#d8342c"))
			c.draw_rect(Rect2(at + Vector2(4, 8), Vector2(1, 1)), Color("#d8342c"))
	for e in town.team:   # stars circling a creature knocked flat
		if e.get("down", false):
			var top: Vector2 = e["node"].position + Vector2(0, -22)
			for k in 3:
				var a := now / 250.0 + k * TAU / 3.0
				var p := (top + Vector2(cos(a) * 9.0, sin(a) * 3.0)).round()
				var col := Color("#ffe27a") if sin(a) > 0.0 else Color("#c9a640")
				c.draw_rect(Rect2(p + Vector2(-1, 0), Vector2(3, 1)), col)
				c.draw_rect(Rect2(p + Vector2(0, -1), Vector2(1, 3)), col)
	if fx.has("dust") and now - int(fx["dust"]["t0"]) < 700:
		var a: float = (now - int(fx["dust"]["t0"])) / 700.0
		var at: Vector2 = fx["dust"]["at"]
		for k in 6:
			var ang := k * TAU / 6.0
			var p := (at + Vector2(cos(ang) * (4.0 + a * 14.0), sin(ang) * (2.0 + a * 5.0) - a * 4.0)).round()
			c.draw_rect(Rect2(p, Vector2(2, 2)), Color(0.78, 0.72, 0.6, (1.0 - a) * 0.9))
