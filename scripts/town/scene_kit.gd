extends RefCounted
## The town scene toolkit (Claude, 2026-10-10; Preston: "build the toolkit", after the Explorers of Sky
## chapter he linked, where townsfolk walk in, take their places, face whoever is talking and react).
## Static helpers any town scene calls on its host (hub_town.gd or town_room.gd), so a new scene is a list
## of beats, not new plumbing:
##   SceneKit.spawn(host, form, tile, facing)      a creature that is not on the team
##   await SceneKit.walk_to(host, e, tile)         walk there along open tiles, round anything in the way
##   await SceneKit.walk_all(host, [[e, tile], ...]) several at once
##   SceneKit.face(host, e, toward)                turn to a tile or to another creature
##   SceneKit.face_all(host, list, toward)
##   SceneKit.emote(host, e, "!")                  a "!" or "?" bubble over it
##   await SceneKit.say(host, lines)               [speaker, line, face] lines with portraits, read with E
##   SceneKit.pan(host, to, seconds)               move the camera; SceneKit.release(host) gives it back
##   SceneKit.rows(center, count, per_row)         line-up marks: rows facing a speaker
##   SceneKit.ring(center, count, radius)          a crowd round a speaker
##   SceneKit.draw(host, canvas)                   the bubbles, from the host's label/world layer
## A host provides: team, npcs, talk, cutscene, cam_focus, scene_fx, _world, _px(tile), _place(e),
## _facing_of(d), and an open-tile test (_open or open_at).

const Arena := preload("res://scripts/arena/arena_prototype.gd")
const Lines := preload("res://scripts/creatures/lines.gd")
const DIRS4 := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const DIRS8 := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1)]


static func _alive(host) -> bool:
	return is_instance_valid(host) and host.is_inside_tree()


static func wait(host, s: float) -> void:
	if _alive(host):
		await host.get_tree().create_timer(s).timeout


static func _open(host, t: Vector2i) -> bool:
	return host._open(t) if host.has_method("_open") else host.open_at(t)


## Who stands where now (team and townsfolk), so walkers go round each other.
static func _taken(host, but: Dictionary) -> Dictionary:
	var out := {}
	var all: Array = []
	all.append_array(host.team)
	all.append_array(host.npcs)
	for e in all:
		if e != but and is_instance_valid(e["node"]) and e["node"].visible:
			out[e["pos"]] = true
	return out


## A creature that is not on the team, by form: its town set (half again its dungeon size), else its dungeon set.
static func spawn(host, form: String, tile: Vector2i, facing := "s") -> Dictionary:
	var node := Node2D.new()
	host._world.add_child(node)
	var sprite := Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.add_child(sprite)
	preload("res://scripts/arena/creature_finish.gd").apply(sprite)
	var dir := "res://assets/sprites/arena/%s/town/" % form
	if not ResourceLoader.exists(dir + "s.png"):
		dir = "res://assets/sprites/arena/%s/dungeon/" % form
	var still := {}
	var walk := {}
	for f in Arena.FACINGS:
		still[f] = load(dir + f + ".png")
		var frames: Array = []
		for k in 8:
			if ResourceLoader.exists(dir + "walk_%s_f%d.png" % [f, k]):
				frames.append(load(dir + "walk_%s_f%d.png" % [f, k]))
		walk[f] = frames
	var e := {"form": form, "pos": tile, "node": node, "sprite": sprite, "still": still, "walk": walk,
		"facing": facing, "walk_t": 0.0, "walk_clock": 0.0, "npc": true}
	host._place(e)
	host.npcs.append(e)
	return e


## The shortest walk on open tiles that are not taken (eight ways, no cutting a corner), as a list of steps.
static func path(host, e: Dictionary, goal: Vector2i) -> Array:
	var taken := _taken(host, e)
	taken.erase(goal)
	var start: Vector2i = e["pos"]
	var came := {start: start}
	var q: Array = [start]
	while not q.is_empty():
		var c: Vector2i = q.pop_front()
		if c == goal:
			break
		for d in DIRS8:
			var n: Vector2i = c + d
			if came.has(n) or not _open(host, n) or taken.has(n):
				continue
			if d.x != 0 and d.y != 0 and (not _open(host, c + Vector2i(d.x, 0)) or not _open(host, c + Vector2i(0, d.y))):
				continue
			came[n] = c
			q.append(n)
	if not came.has(goal):
		return []
	var out: Array = []
	var at := goal
	while at != start:
		out.push_front(at)
		at = came[at]
	return out


## Walk a creature to a tile, one step at a time with its walk cycle.
static func walk_to(host, e: Dictionary, goal: Vector2i, step := 0.24) -> void:
	for t in path(host, e, goal):
		if not _alive(host):
			return
		var d: Vector2i = t - e["pos"]
		e["facing"] = host._facing_of(d)
		e["pos"] = t
		e["walk_t"] = step + 0.06
		# Depth follows the feet every frame (Preston, 2026-10-10: Starward "goes through" the desk; its
		# depth stayed at the spot behind the desk until the walk ended).
		var node: Node2D = e["node"]
		var follow := func(p: Vector2) -> void:
			node.position = p
			node.z_index = int(p.y)
		host.create_tween().tween_method(follow, node.position, host._px(t), step)
		await wait(host, step)
	if _alive(host):
		host._place(e)


## Several walkers at once; returns when the last arrives.
static func walk_all(host, moves: Array, step := 0.24) -> void:
	var longest := 0
	for m in moves:
		longest = maxi(longest, path(host, m[0], m[1]).size())
		walk_to(host, m[0], m[1], step)
	await wait(host, longest * step + 0.05)


## Turn toward a tile or another creature.
static func face(host, e: Dictionary, toward) -> void:
	var to: Vector2i = toward["pos"] if toward is Dictionary else toward
	var d: Vector2i = (to - e["pos"]).clamp(Vector2i(-1, -1), Vector2i(1, 1))
	if d != Vector2i.ZERO:
		e["facing"] = host._facing_of(d)
		host._place(e)


static func face_all(host, list: Array, toward) -> void:
	for e in list:
		face(host, e, toward)


## A "!" or "?" bubble over a creature for a moment.
static func emote(host, e: Dictionary, mark := "!") -> void:
	host.scene_fx["emote"] = {"e": e, "mark": mark, "at": Time.get_ticks_msec()}
	if host.has_method("_sfx"):
		host._sfx("emote_alert")


## Lines with portraits: [speaker, line, face]. "{partner}" and "{leader}" are filled in from the team;
## a speaker's portrait is its form (the team's own form for {partner}).
static func say(host, lines: Array) -> void:
	if not _alive(host):
		return
	var pe: Dictionary = host.team[1] if host.team.size() > 1 else host.team[0]
	var pname: String = load(Lines.of(pe["line"])["forms"][pe["stage"]][1]).creature_name
	var lname: String = load(Lines.of(host.team[0]["line"])["forms"][host.team[0]["stage"]][1]).creature_name
	for l in lines:
		var who: String = String(l[0]).replace("{partner}", pname)
		var form: String = String(pe["form"]) if l[0] == "{partner}" else ("" if who == "???" else who.to_lower())
		if l.size() > 2 and form != "":
			form += ":" + String(l[2])
		host.talk.append([who, String(l[1]).replace("{leader}", lname), form])
	while _alive(host) and not host.talk.is_empty():
		await host.get_tree().process_frame


## Move the camera over `s` seconds; release() hands it back to the leader.
static func pan(host, to: Vector2, s := 0.5) -> void:
	var from: Vector2 = host.cam_focus if host.cam_focus != null else host.team[0]["node"].position
	host.create_tween().tween_method(func(v: Vector2) -> void: host.cam_focus = v, from, to, s).set_trans(Tween.TRANS_SINE)


static func release(host) -> void:
	host.cam_focus = null


## Line-up marks: rows below `center` (the speaker's tile), `per_row` wide, centred.
static func rows(center: Vector2i, count: int, per_row := 4, gap := 2) -> Array:
	var out: Array = []
	for k in count:
		var r := k / per_row
		var n := mini(per_row, count - r * per_row)
		var x := (k % per_row) - (n - 1) / 2
		out.append(center + Vector2i(x, gap + r))
	return out


## A ring of `count` marks round `center` (a crowd round a speaker); the near side left open for the camera.
static func ring(center: Vector2i, count: int, radius := 2.5) -> Array:
	var out: Array = []
	for k in count:
		var a := PI * 1.15 + (PI * 0.7 + TAU * 0.5) * float(k) / maxf(1.0, count - 1)
		out.append(center + Vector2i(roundi(cos(a) * radius * 1.4), roundi(sin(a) * radius)))
	return out


## The bubble (and a parcel being handed over, scene_fx["parcel"]), drawn in world space by the host.
static func draw(host, c: CanvasItem) -> void:
	if host.scene_fx.has("parcel"):
		draw_parcel(c, host.scene_fx["parcel"])
	var em: Dictionary = host.scene_fx.get("emote", {})
	if em.is_empty() or Time.get_ticks_msec() - int(em["at"]) > 1300 or not is_instance_valid(em["e"]["node"]):
		return
	var age: float = (Time.get_ticks_msec() - int(em["at"])) / 1000.0
	var top: float = -float(em["e"]["sprite"].texture.get_height()) + 4.0
	var at: Vector2 = (em["e"]["node"].position + Vector2(6, top - 12 - (2.0 if age < 0.08 else 0.0))).round()
	var ink := Color("#1a1410")
	var red := Color("#d8342c")
	c.draw_rect(Rect2(at + Vector2(-1, -1), Vector2(11, 13)), ink)
	c.draw_rect(Rect2(at, Vector2(9, 11)), Color("#fff4e8"))
	c.draw_rect(Rect2(at + Vector2(1, 11), Vector2(3, 2)), ink)
	c.draw_rect(Rect2(at + Vector2(2, 11), Vector2(1, 1)), Color("#fff4e8"))
	if em["mark"] == "!":
		c.draw_rect(Rect2(at + Vector2(4, 2), Vector2(1, 5)), red)
		c.draw_rect(Rect2(at + Vector2(4, 8), Vector2(1, 1)), red)
	else:
		for p in [Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2), Vector2i(6, 3), Vector2i(6, 4), Vector2i(5, 5), Vector2i(4, 6), Vector2i(4, 8)]:
			c.draw_rect(Rect2(at + Vector2(p), Vector2(1, 1)), red)


## A Wayline parcel at 1x: kraft paper, twine, the teal seal (as the stolen one in crew_scene.gd).
static func draw_parcel(c: CanvasItem, at: Vector2) -> void:
	var o := (at - Vector2(6, 9)).round()
	c.draw_rect(Rect2(o, Vector2(12, 10)), Color("#2a1d14"))
	c.draw_rect(Rect2(o + Vector2(1, 1), Vector2(10, 3)), Color("#c79a62"))
	c.draw_rect(Rect2(o + Vector2(1, 4), Vector2(10, 5)), Color("#a37848"))
	c.draw_rect(Rect2(o + Vector2(1, 4), Vector2(10, 1)), Color("#7c5634"))
	c.draw_rect(Rect2(o + Vector2(5, 1), Vector2(2, 8)), Color("#ead9b0"))
	c.draw_rect(Rect2(o + Vector2(1, 2), Vector2(10, 1)), Color("#ead9b0"))
	c.draw_rect(Rect2(o + Vector2(5, 1), Vector2(2, 2)), Color("#2f8f8a"))
	c.draw_rect(Rect2(o + Vector2(5, 1), Vector2(1, 1)), Color("#7fd4c8"))
