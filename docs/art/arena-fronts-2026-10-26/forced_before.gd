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

const SceneKit := preload("res://scripts/town/scene_kit.gd")
const Layout := preload("res://scripts/town/town_layout.gd")
const Lines := preload("res://scripts/creatures/lines.gd")
const Arena := preload("res://scripts/arena/arena_prototype.gd")
const Music := preload("res://scripts/audio/music.gd")
const UI := preload("res://scripts/ui/ui_style.gd")

const TEAR := [
	["Mirekit", "Ooh, this one pays in reedberries, boss!", "mischievous"],
	["Gruntle", "Rip it down. If we aren't running it, nobody is.", "mischievous"],
]
const OBJECT := [["{partner}", "Hey! Those are Wayline jobs. You can't just tear them down!", "angry"]]
const MOCK := [
	["Gruntle", "Well, well. The little runt the Tower keeps turning away.", "mischievous"],
	["Whinet", "No partner, no route! Hee hee!", "mischievous"],
	["{partner}", "I have a partner now. We're seeing the Postmaster today.", "determined"],
]
const AFTER_SHOVE := [
	["Gruntle", "You? On a route? You'd lose a parcel in a puddle.", "angry"],
	["Gruntle", "And you, stray. Never seen you before. Stay out of my way.", "mischievous"],
	["Mirekit", "Come on, boss. The good jobs won't steal themselves.", "mischievous"],
]
# When the partner carries the parcel saved from the flood (story "parcel" = "saved"; Preston, 2026-10-10:
# it is stolen here, and the guild's trial becomes getting it back). Claude's drafts.
const SHOW_OFF := [["{partner}", "I have a partner now. And we saved this from the flood: a sealed Wayline parcel!", "determined"]]
const SNATCH := [
	["Mirekit", "Ooh, a sealed one! Finders keepers!", "mischievous"],
	["Gruntle", "Want it back? Rootbank Warren. If you can find the way in.", "mischievous"],
]
const GET_UP_STOLEN := [
	["{partner}", "...They took it. The one parcel I kept dry through the whole flood.", "sad"],
	["{partner}", "That was Gruntle's crew. They take jobs and never deliver them.", "angry"],
	["{partner}", "The Postmaster has to hear about this. The Tower's right there. Come on!", "determined"],
]
const GET_UP := [
	["{partner}", "...That was Gruntle. His crew takes jobs and never delivers them.", "sad"],
	["{partner}", "Forget them. The Wayline Tower is right there. Let's go!", "determined"],
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
	preload("res://scripts/arena/creature_finish.gd").apply(sprite, false, form)
	var still := {}
	var walk := {}
	var dir := "res://_c22_no_directional_sets/%s/town/" % form
	if not ResourceLoader.exists(dir + "s.png"):
		dir = "res://_c22_no_directional_sets/%s/dungeon/" % form
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
		# The docs/ path stays until Codex's C22 moves the art into assets/ (Claude, 2026-10-24, pass 4 T11). Read
		# through UI.res_image: the imported texture in an exported game, the file on disk here (pass 5 RM10).
		var img := UI.res_image("res://docs/creatures/arena-starters-2026-10-07/forms/%s_arena_front_chosen.png" % form)
		if img == null:
			img = Image.create(66, 66, false, Image.FORMAT_RGBA8)   # no art anywhere: an empty stand-in, not a crash
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
	var pname: String = load(Lines.of(pe["line"])["forms"][pe["stage"]][1]).creature_name
	for l in lines:
		var who: String = String(l[0]).replace("{partner}", pname)
		var form: String = String(pe["form"]) if l[0] == "{partner}" else who.to_lower()
		if l.size() > 2:
			form += ":" + String(l[2])
		town.talk.append([who, String(l[1]), form])
	while _alive(town) and not town.talk.is_empty():
		await town.get_tree().process_frame


## The opening shot (Claude, 2026-10-24, pass 4 T5 / LV-28): the board, the crew and the team in one frame, every
## head at least SHOT_TOP from the top of the screen and every foot above the text box (UI.dialogue's box starts at
## 452 of 648). It was the midpoint of the board and the leader, which put the crew's heads at the top edge when the
## team stood three rows down. When they cannot all fit, the heads win. Three screen pixels to a view pixel.
const SHOT_TOP := 48.0     # screen px: the highest head at least this far down
const SHOT_FOOT := 440.0   # screen px: the lowest foot at most this far down, 12 px above the text box
const BOARD_TOP := 12.0    # screen px: the board's roof at least this far down (pass 5 RM11)


## with_board false frames the actors alone (the get-up lines, once the crew are gone; integrator, 2026-10-24).
## Each actor is framed where it stands at rest, on its tile: a creature mid-step or mid-lunge is framed where it
## lands. An actor can be [entry, tile, facing] for one still walking there, framed in the still it will stand in
## (Claude, 2026-10-24, pass 5 RM11).
static func _shot(town, actors: Array, with_board := true) -> Vector2:
	var box := Rect2()
	var rects: Array[Rect2] = []
	for a in actors:
		var e: Variant = a[0] if a is Array else a
		if not (e is Dictionary) or e.is_empty() or not is_instance_valid(e["node"]):
			continue
		var tile: Vector2i = a[1] if a is Array else e["pos"]
		var still: Texture2D = e["still"].get(a[2]) if a is Array and a.size() > 2 and e.has("still") else null
		var r := _ink(town, e.get("sprite"), still, true)
		if r.has_area():
			r.position += town._px(tile) - (e["node"] as Node2D).position
		rects.append(r)
	for r in rects:
		if r.has_area():
			box = r if not box.has_area() else box.merge(r)
	var heads := box   # the creatures alone
	var stand: Node = town._world.find_child("NoticeStand", true, false)   # job_board_painter.gd's board art
	var board := Rect2()
	if not with_board:
		pass
	elif stand is Sprite2D:
		board = _ink(town, stand)
	else:   # no art: the board's two tiles and the row above them
		var place: Dictionary = Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "board")[0]
		var r: Rect2i = place["rect"]
		board = Rect2(Vector2(r.position * T()) - Vector2(0, T()), Vector2(r.size * T()) + Vector2(0, T()))
	if board.has_area():
		box = board if not box.has_area() else box.merge(board)
	var half: Vector2 = Vector2(town.VIEW) * 0.5
	var px: float = town.SCALE
	# The camera's y at most this: heads on screen, and the board's roof too, though the roof may sit nearer the edge
	# (BOARD_TOP): held to the heads' margin, the tall board pushed the partner's feet 6 px into the text box's margin
	# (Claude, 2026-10-24, pass 5 RM11).
	var hi := (heads.position.y if heads.has_area() else box.position.y) + half.y - SHOT_TOP / px
	if board.has_area():
		hi = minf(hi, board.position.y + half.y - BOARD_TOP / px)
	var lo := box.end.y + half.y - SHOT_FOOT / px       # and at least this: feet above the box
	return Vector2(box.get_center().x, (lo + hi) * 0.5 if lo <= hi else hi).round()


## Followers behind the leader come up onto its row as the scene opens (Claude, 2026-10-24, pass 4 T5): walking up
## from the street below, the partner trailed a row under the leader, a row too low for the whole cast to fit above
## the text box. Since pass 5 (RM11 / LO5-22) every follower below the leader's row does it, not only the partner: a
## third and fourth creature trailed two and three rows down, under the text box. Each walks to the free tile on the
## leader's row nearest the leader that it reaches in CATCH_STEPS steps or fewer (not awaited: it walks while the
## crew tear at the board); one with no such tile fades out for the scene and comes back when it ends.
## Returns {"to": team index -> the tile it is walking to, "face": -> the way it will face, "faded": indexes faded}.
const CATCH_STEPS := 3


static func _catch_up(town, lead: Dictionary) -> Dictionary:
	var out := {"to": {}, "face": {}, "faded": []}
	var taken: Array = []
	for e in town.npcs + town.team:
		taken.append(e["pos"])
	for k in range(1, town.team.size()):
		var e: Dictionary = town.team[k]
		if e["pos"].y <= lead["pos"].y:
			continue
		var side := -1 if e["pos"].x <= lead["pos"].x else 1
		var route: Array = []
		for dx in [side, -side, 2 * side, -2 * side, 3 * side, -3 * side]:
			var to: Vector2i = lead["pos"] + Vector2i(dx, 0)
			if taken.has(to) or not town.follower_ok(to):
				continue
			route = SceneKit.path(town, e, to)
			if not route.is_empty() and route.size() <= CATCH_STEPS:
				break
			route = []
		if route.is_empty():
			out["faded"].append(k)
			town.create_tween().tween_property(e["node"], "modulate:a", 0.0, 0.3)
			continue
		taken.erase(e["pos"])
		taken.append(route[route.size() - 1])
		out["to"][k] = route[route.size() - 1]
		var last: Vector2i = route[route.size() - 1] - (route[route.size() - 2] if route.size() > 1 else e["pos"])
		out["face"][k] = town._facing_of(last)   # the way it faces once there: _step turns it to each step
		_walk_route(town, e, route)
	return out


## Step along `route` one tile at a time (Claude, 2026-10-24, RM11).
static func _walk_route(town, e: Dictionary, route: Array) -> void:
	for t in route:
		if not _alive(town):
			return
		await _step(town, e, t - e["pos"], 0.22)


## Whether a teammate other than `but`, or a townsfolk, stands on `t` (RM11: the followers now share the leader's
## row, so the partner's march, fall and getting up go round them as they went round the leader).
static func _held(town, t: Vector2i, but: Dictionary) -> bool:
	for e in town.team + town.npcs:
		if not is_same(e, but) and e["pos"] == t:
			return true
	return false


## Where a sprite's drawn pixels are, in the town's world (the camera's space).
## `tex` stands in for the sprite's own picture (a creature framed in the still it will stand in once it has walked
## there), and `rest` leaves out the idle bob's 1 px offset, so a shot does not move with the breath (Claude,
## 2026-10-24, pass 5 RM11).
static func _ink(town, s: Variant, tex: Texture2D = null, rest := false) -> Rect2:
	if not (s is Sprite2D):
		return Rect2()
	var t: Texture2D = tex if tex != null else s.texture
	if t == null:
		return Rect2()
	var r: Rect2 = s.get_rect()
	if tex != null or rest:
		var off: Vector2 = Vector2.ZERO if rest else s.offset
		r = Rect2(off - t.get_size() * 0.5 if s.centered else off, t.get_size())
	var img: Image = t.get_image()
	if img != null and not img.is_empty():
		var used := img.get_used_rect()
		if used.has_area():
			r = Rect2(r.position + Vector2(used.position) * r.size / Vector2(img.get_size()), Vector2(used.size) * r.size / Vector2(img.get_size()))
	var xf: Transform2D = town._world.get_global_transform().affine_inverse() * s.get_global_transform()
	return xf * r


## Pan the camera to `to` over `secs` (not awaited). The pass 4 integrator's re-shoot (2026-10-24) found the opening
## shot was the only framed one: after the shove the partner lay under the text box, and the get-up lines put the
## pair's heads at the top edge (LV-28). The shove and the get-up now re-frame with _shot.
static func _pan(town, to: Vector2, secs: float) -> void:
	var from: Vector2 = town.cam_focus if town.cam_focus != null else to
	town.create_tween().tween_method(func(v: Vector2) -> void: town.cam_focus = v, from, to, secs).set_trans(Tween.TRANS_SINE)


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


## After the crew are gone the partner walks over to stand beside the leader: the same row, one tile of
## ground between them, facing each other (Preston, 2026-10-11: they overlapped after the shove).
## `state` gets "done" once it stands there, for a caller that plays lines while it walks (Claude, 2026-10-26, S2).
static func _beside(town, lead: Dictionary, partner: Dictionary, state := {}) -> void:
	if partner == lead:
		state["done"] = true
		return
	var to := _beside_tile(town, lead, partner)
	var guard := 0
	while _alive(town) and partner["pos"] != to and guard < 8:
		guard += 1
		var d: Vector2i = (to - partner["pos"]).clamp(Vector2i(-1, -1), Vector2i(1, 1))
		if _held(town, partner["pos"] + d, partner):
			d = Vector2i(d.x, 0) if d.y != 0 else Vector2i(0, 1)   # step round the leader or a teammate
		if not town.open_at(partner["pos"] + d):
			d = Vector2i(d.x, 0) if d.x != 0 and town.open_at(partner["pos"] + Vector2i(d.x, 0)) else Vector2i(0, d.y)
			if d == Vector2i.ZERO or not town.open_at(partner["pos"] + d):
				break
		await _step(town, partner, d, 0.22)
	state["done"] = true
	if not _alive(town):
		return
	_face(town, partner, "w" if lead["pos"].x < partner["pos"].x else "e")
	_face(town, lead, "e" if lead["pos"].x < partner["pos"].x else "w")


## The tile _beside walks the partner to (split out 2026-10-26, S2, so the shot can frame it before it gets there).
static func _beside_tile(town, lead: Dictionary, partner: Dictionary) -> Vector2i:
	if partner == lead:
		return partner["pos"]
	var side := 1 if partner["pos"].x >= lead["pos"].x else -1
	var to: Vector2i = lead["pos"]
	for c in [Vector2i(2 * side, 0), Vector2i(-2 * side, 0), Vector2i(side, 0), Vector2i(-side, 0)]:
		if town.open_at(lead["pos"] + c) and not _held(town, lead["pos"] + c, partner):   # not on a teammate (RM11)
			to = lead["pos"] + c
			break
	return to


const RUN_STEP := 0.12   # seconds a tile: a run, about twice the team's walk


## The crew's exit: Gruntle's path through the streets to the Mouth of the Hollow, the other two on his heels,
## Mirekit holding the parcel up. The camera follows them down; at the gate they drop out of sight. `state` gets
## "done" at the end, for a caller that plays a line while they run (Claude, 2026-10-26, S2).
static func _run_for_the_way_down(town, crew: Array, carrier: Dictionary, state := {}) -> void:
	# Highbank v2 (lane A, Claude, 2026-10-26): the Mouth may be in another area; TownLayout.way_to gives the exit
	# toward it, and in today's map the Mouth's door as before.
	var route: Array = SceneKit.path(town, crew[0], Layout.way_to("gate"))
	if route.is_empty():   # no way through: the old stroll off the screen
		route = [crew[0]["pos"] + Vector2i(-7, 2)]
	var lag := 0
	for e in crew:
		_run_along(town, e, route, lag * 0.18)
		lag += 1
	var total: float = route.size() * RUN_STEP + 0.18 * crew.size() + 0.3
	var t := 0.0
	while t < total and _alive(town):
		await town.get_tree().process_frame
		var dt: float = town.get_process_delta_time()
		t += dt
		if not carrier.is_empty() and is_instance_valid(carrier["node"]):
			town.scene_fx["parcel"] = carrier["node"].position + Vector2(0, -34)
		var lead_node: Node2D = crew[0]["node"]
		if is_instance_valid(lead_node):
			var from: Vector2 = town.cam_focus if town.cam_focus != null else lead_node.position
			town.cam_focus = from.lerp(lead_node.position + Vector2(0, -10), minf(1.0, dt * 4.0))
	if _alive(town):
		await _wait(town, 0.5)   # a beat on the empty gate
	state["done"] = true


## One crew member along the route, a tile at a time with its walk frames, fading out on the last tiles.
static func _run_along(town, e: Dictionary, route: Array, delay: float) -> void:
	if delay > 0.0:
		await _wait(town, delay)
	var prev: Vector2i = e["pos"]
	for k in route.size():
		if not _alive(town) or not is_instance_valid(e["node"]):
			return
		var to: Vector2i = route[k]
		e["facing"] = town._facing_of((to - prev).clamp(Vector2i(-1, -1), Vector2i(1, 1)))
		e["walk_t"] = RUN_STEP + 0.06
		var tw: Tween = town.create_tween()
		tw.tween_property(e["node"], "position", town._px(to), RUN_STEP)
		if k >= route.size() - 3:
			town.create_tween().tween_property(e["node"], "modulate:a", 0.0, RUN_STEP * 3.0)
		prev = to
		await _wait(town, RUN_STEP)
	e["pos"] = prev


static func run(town) -> void:
	if not _alive(town):
		return
	town.cutscene = true
	Music.play(town.get_tree(), "crew_theme")   # the Shortcut Crew's own theme while they are on screen
	var lead: Dictionary = town.team[0]
	var partner: Dictionary = town.team[1] if town.team.size() > 1 else lead
	var g := _npc(town, "gruntle")
	var mk := _npc(town, "mirekit")
	var wh := _npc(town, "whinet")
	# The board, the crew and the team in one frame (T5). Followers below the leader walk up onto its row while the
	# crew tear at the board, and are framed on the tiles they are walking to (RM11).
	var caught := _catch_up(town, lead)
	var cast: Array = [g, mk, wh]
	for k in town.team.size():
		if caught["to"].has(k):
			cast.append([town.team[k], caught["to"][k], caught["face"][k]])
		elif not caught["faded"].has(k):
			cast.append(town.team[k])
	town.cam_focus = _shot(town, cast)
	# Every await below is followed by a look at the town: Return to title frees it mid-scene, and the next line
	# would call into a freed town (Claude, 2026-10-24, pass 4 T6 / LV-29).
	# 1. The crew, backs turned, tearing postings off the board.
	for k in 2:
		town.board_fx["torn_at"] = Time.get_ticks_msec()
		town._sfx("paper_tear")   # ElevenLabs takes, tools/audio/build_dungeon_sfx.py
		await _wait(town, 0.6)
		if not _alive(town):
			return
	await _lines(town, TEAR)
	if not _alive(town):
		return
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
		if _held(town, partner["pos"] + d, partner):
			d = Vector2i(d.x if d.x != 0 else 1, d.y)   # step round the leader (or a teammate, RM11)
		if not town.open_at(partner["pos"] + d) or _held(town, partner["pos"] + d, partner):
			break
		await _step(town, partner, d, 0.2)
	if not _alive(town):
		return
	_face(town, partner, "n")
	_face(town, lead, "n")
	await _lines(town, OBJECT)
	if not _alive(town):
		return
	town.board_fx["emote"] = {"e": g, "at": Time.get_ticks_msec()}
	town._sfx("emote_alert")
	town._sfx("hog_grunt")
	for e in [g, mk, wh]:
		_face(town, e, "s")
	await _wait(town, 0.7)
	if not _alive(town):
		return
	var saved := String(town._record().get("story", {}).get("parcel", "")) == "saved"
	await _lines(town, MOCK.slice(0, MOCK.size() - 1) + (SHOW_OFF if saved else MOCK.slice(MOCK.size() - 1)))
	if not _alive(town):
		return
	if saved:
		town.scene_fx["parcel"] = partner["node"].position + Vector2(0, -30)   # held up for them to see
	# 3. The shove: Gruntle lunges, the partner is thrown back two tiles and falls.
	var back := Vector2i(0, 1)
	if _held(town, partner["pos"] + back, partner) or _held(town, partner["pos"] + back * 2, partner):
		var left: Vector2i = partner["pos"] + Vector2i(-1, 1)
		back = Vector2i(-1, 1) if town.open_at(left) and not _held(town, left, partner) else Vector2i(1, 1)
	var g0: Vector2 = g["node"].position
	var lunge: Tween = town.create_tween()
	lunge.tween_property(g["node"], "position", g0 + Vector2(back) * 8.0, 0.08)
	lunge.tween_property(g["node"], "position", g0, 0.18)
	town._sfx("hog_grunt")
	town._sfx("body_shove")
	town.shake = 4.0
	var land: Vector2i = partner["pos"]
	for k in 2:
		if town.open_at(land + back) and not _held(town, land + back, partner):
			land += back
		else:
			break   # never past a teammate it would land on
	partner["pos"] = land
	partner["down"] = true
	var fly: Tween = town.create_tween()
	var p0: Vector2 = partner["node"].position
	var p1: Vector2 = town._px(land)
	fly.tween_method(func(t: float) -> void: partner["node"].position = p0.lerp(p1, t) + Vector2(0, -10.0 * sin(t * PI)), 0.0, 1.0, 0.32)
	await fly.finished
	if not _alive(town):
		return
	_pan(town, _shot(town, [g, mk, wh, lead, partner]), 0.4)   # the fallen partner stays above the text box
	town.board_fx["dust"] = {"at": p1, "t0": Time.get_ticks_msec()}
	if saved:   # the parcel flies loose and lands beside the partner
		var c0: Vector2 = town.scene_fx.get("parcel", p1)
		var c1: Vector2 = p1 + Vector2(T() * 0.8, -6)
		var drop: Tween = town.create_tween()
		drop.tween_method(func(t: float) -> void: town.scene_fx["parcel"] = c0.lerp(c1, t) + Vector2(0, -14.0 * sin(t * PI)), 0.0, 1.0, 0.4)
	await _wait(town, 0.6)
	if not _alive(town):
		return
	# The leader turns to face Gruntle.
	_face(town, lead, town._facing_of((g["pos"] - lead["pos"]).clamp(Vector2i(-1, -1), Vector2i(1, 1))))
	town.board_fx["emote"] = {"e": lead, "at": Time.get_ticks_msec()}
	town._sfx("emote_alert")
	await _wait(town, 0.6)
	if not _alive(town):
		return
	await _lines(town, AFTER_SHOVE)
	if not _alive(town):
		return
	if saved:
		# Mirekit darts over, snatches it, and holds it up.
		var m0: Vector2 = mk["node"].position
		var at: Vector2 = town.scene_fx.get("parcel", m0)
		var dart: Tween = town.create_tween()
		dart.tween_property(mk["node"], "position", at + Vector2(-6, 26), 0.25)
		await dart.finished
		if not _alive(town):
			return
		town._sfx("pickup")
		town.scene_fx["parcel"] = mk["node"].position + Vector2(0, -34)
		var hop_back: Tween = town.create_tween()
		hop_back.tween_property(mk["node"], "position", m0, 0.3)
		hop_back.parallel().tween_method(func(p: Vector2) -> void: town.scene_fx["parcel"] = p + Vector2(0, -34), mk["node"].position, m0, 0.3)
		await hop_back.finished
		if not _alive(town):
			return
		await _lines(town, SNATCH)
		if not _alive(town):
			return
	# 4. The crew run for the way down, the Mouth of the Hollow, and the camera follows them so the player sees
	# where they went (Preston, 2026-10-11: "make the rival crew run towards it after stealing parcel"). The partner's
	# first words come from the ground as they go (Claude, 2026-10-26, pass 7 S2 / L7-07: the run and the getting up
	# were 7.5 s with nothing to read).
	town._sfx("hog_trot")
	var run_state := {"done": false}
	_run_for_the_way_down(town, [g, mk, wh], mk if saved else {}, run_state)   # not awaited: waited on below
	var get_up: Array = GET_UP_STOLEN if saved else GET_UP
	await _wait(town, 0.8)
	if not _alive(town):
		return
	await _lines(town, get_up.slice(0, 1))
	while _alive(town) and not run_state["done"]:
		await town.get_tree().process_frame
	if not _alive(town):
		return
	town.scene_fx.erase("parcel")
	for e in [g, mk, wh]:
		e["node"].queue_free()
	town.npcs.clear()
	# 5. The partner gets up and comes over to the leader, talking as it comes (S2). The camera goes straight to the
	# pair alone, heads clear of the top edge, framed where the partner will stand.
	partner["down"] = false
	town._place(partner)
	town._sfx("dizzy")
	var spot := _beside_tile(town, lead, partner)
	_pan(town, _shot(town, [lead, [partner, spot, "w" if lead["pos"].x < spot.x else "e"]], false), 0.4)
	await _wait(town, 0.4)
	if not _alive(town):
		return
	var walk_state := {"done": false}
	_beside(town, lead, partner, walk_state)   # not awaited: waited on below
	await _lines(town, get_up.slice(1))
	while _alive(town) and not walk_state["done"]:
		await town.get_tree().process_frame
	if not _alive(town):
		return
	for k in caught["faded"]:   # whoever sat the scene out comes back (RM11)
		if k < town.team.size() and is_instance_valid(town.team[k]["node"]):
			town.create_tween().tween_property(town.team[k]["node"], "modulate:a", 1.0, 0.3)
	var rec: Dictionary = town._record()
	if not rec.has("story") or rec["story"] == null:
		rec["story"] = {}
	rec["story"]["met_crew"] = true
	if saved:
		rec["story"]["parcel"] = "stolen"   # the guild's trial: get it back from Rootbank Warren
	town.board_fx.clear()
	town.cam_focus = null
	town.cutscene = false
	town._music_update()   # back to the town's own music


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
