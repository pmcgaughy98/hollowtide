extends RefCounted
## The Shortcut Crew's boss floor at the bottom of Rootbank Warren (Claude, 2026-10-10), the Warden
## scene's structure made shorter and comic, after the crew proposal's beats: the team walks in on
## Mirekit and Whinet fighting over the stolen parcel; a "!" when they notice; the talk; the streak
## wipe; the fight. When Mirekit falls it flops over playing dead, Whinet panics, Mirekit springs up,
## swears "the boss'll hear about this", and both run, leaving the parcel behind.
##
## The parcel is drawn in code on the floor layer (draw_floor). The lines are Claude's proposals;
## the crew's voices are Preston's to change (ARGUE, FLOP, FLEE, GOT_IT).

const BossIntro := preload("res://scripts/dungeon/boss_intro.gd")
const Music := preload("res://scripts/audio/music.gd")

const ARGUE := [
	["{boss}", "Hold it still! Whoever tied this knot was showing off.", "determined"],
	["Whinet", "Is it food? Tell me it's food.", "happy"],
	["{boss}", "Couriers don't carry food, Whinet. They carry valuables. Shiny ones.", "mischievous"],
]
const FLOP := [
	["{partner}", "Is it... out cold?", "surprised"],
	["Whinet", "Mirekit? Mirekit! You said this would be easy!", "sad"],
]
const FLEE := [
	["{boss}", "I was resting. Strategically.", "determined"],
	["{boss}", "Keep your soggy parcel, courier. The boss'll hear about this!", "angry"],
	["Whinet", "Yeah! The boss'll hear about this!", "angry"],
]
const GOT_IT := [["{partner}", "Our parcel! A little chewed, but it's all here.", "joyous"]]
const WALK_STEPS := 2
const PARCEL_TILE := Vector2i(-1, 3)   # from the stairs: between the two, where they fight over it


## Called by _build_floor on the crew's floor, after _place_boss: the two have their backs to the
## team, bent over the parcel.
static func setup(dg) -> void:
	dg.cutscene = true
	dg.intro = {"t0": Time.get_ticks_msec(), "parcel": dg._tile_px(dg.data["stairs"] + PARCEL_TILE) + Vector2(0, 4)}
	for e in _crew(dg):
		e["awake"] = true   # no sleep pose, no "z"; no turns run while the scene plays
		e["facing"] = "n"
		dg._set_tex(e, e["art"]["still"]["n"])


static func _crew(dg) -> Array:
	return dg.ents.filter(func(e: Dictionary) -> bool: return e.get("boss", false) or e.get("minion", false))


static func _whinet(dg) -> Dictionary:
	for e in dg.ents:
		if e.get("minion", false):
			return e
	return {}


## Queue lines and wait until they are read. Any crew member speaks with its own portrait.
static func _lines(dg, lines: Array) -> void:
	if not BossIntro._alive(dg):
		return
	var pe: Dictionary = dg.ents[1] if dg.ents.size() > 1 and dg.ents[1]["team"] == 0 else dg.ents[0]
	for l in lines:
		var who: String = String(l[0]).replace("{partner}", String(pe["name"])).replace("{boss}", String(dg.ents[dg.boss]["name"]))
		var form := ""
		for e in dg.ents:
			if String(e["name"]) == who:
				form = String(e["form"])
		if l.size() > 2 and form != "":
			form += ":" + String(l[2])
		dg.talk.append([who, String(l[1]).replace("{leader}", String(dg.ents[0]["name"])), form])
	while BossIntro._alive(dg) and not dg.talk.is_empty():
		await dg.get_tree().process_frame


## The parcel jolts as the two tug at it.
static func _tug(dg, times: int) -> void:
	var b: Dictionary = dg.ents[dg.boss]
	for k in times:
		if not BossIntro._alive(dg) or not dg.intro.has("parcel"):
			return
		dg._play_act(b, "attack")
		dg.intro["jolt"] = Time.get_ticks_msec()
		dg._sfx("shove", -14.0)
		await BossIntro._wait(dg, 0.55)
		if not BossIntro._alive(dg):
			return


static func run(dg) -> void:
	if not BossIntro._alive(dg):
		return
	var b: Dictionary = dg.ents[dg.boss]
	Music.play(dg.get_tree(), "boss_scene")
	# 1. Fade in on the two bent over the parcel, arguing, their backs to the stairs' approach.
	dg.cam_focus = dg._tile_px(b["pos"]) + Vector2(-8, 18)
	dg._fade.color.a = 1.0
	dg.create_tween().tween_property(dg._fade, "color:a", 0.0, 0.9)
	await BossIntro._wait(dg, 1.0)
	if not BossIntro._alive(dg):
		return
	await _tug(dg, 2)
	await _lines(dg, ARGUE)
	if not BossIntro._alive(dg):
		return
	_tug(dg, 2)
	# 2. The team walks in from below; the partner sees them.
	BossIntro._pan(dg, (dg._tile_px(b["pos"]) + dg.ents[0]["node"].position) * 0.5 + Vector2(0, -WALK_STEPS * dg.T * 0.5), 1.0)
	for k in WALK_STEPS:
		BossIntro._shift_team(dg, Vector2i(0, -1), true)
		await BossIntro._wait(dg, 0.3)
		if not BossIntro._alive(dg):
			return
	for e in BossIntro._team(dg):
		e["facing"] = "n"
		dg._set_tex(e, e["art"]["still"]["n"])
	await BossIntro._wait(dg, 0.4)
	if not BossIntro._alive(dg):
		return
	BossIntro._emote(dg, 1 if dg.ents.size() > 1 and dg.ents[1]["team"] == 0 else 0, "!")
	await BossIntro._wait(dg, 0.8)
	if not BossIntro._alive(dg):
		return
	var talk: Array = dg.boss_cfg().get("talk", [])
	await _lines(dg, talk.slice(0, 1))
	if not BossIntro._alive(dg):
		return
	# 3. The crew spin round; Mirekit drags the parcel behind it.
	BossIntro._emote(dg, dg.boss, "!")
	for e in _crew(dg):
		e["facing"] = "s"
		dg._set_tex(e, e["art"]["still"]["s"])
		var node: Node2D = e["node"]
		var hop: Tween = dg.create_tween()
		hop.tween_property(node, "position:y", node.position.y - 6.0, 0.08)
		hop.tween_property(node, "position:y", node.position.y, 0.1)
	dg._sfx("swing", -6.0)
	var from: Vector2 = dg.intro["parcel"]
	var behind: Vector2 = dg._tile_px(b["pos"] + Vector2i(0, -1)) + Vector2(0, 4)
	dg.create_tween().tween_method(func(t: float) -> void: dg.intro["parcel"] = from.lerp(behind, t) + Vector2(0, -8.0 * sin(t * PI)), 0.0, 1.0, 0.35)
	await BossIntro._wait(dg, 0.9)
	if not BossIntro._alive(dg):
		return
	await _lines(dg, talk.slice(1))
	if not BossIntro._alive(dg):
		return
	# 4. The streak wipe, a white flash, the fight.
	dg.intro["wipe_at"] = Time.get_ticks_msec()
	dg._sfx("battle_wipe", -2.0)
	await BossIntro._wait(dg, 0.7)
	if not BossIntro._alive(dg):
		return
	dg._flash = 0.45
	dg.intro.erase("wipe_at")
	dg.cutscene = false
	dg.cam_focus = null
	dg._meet_boss()


## Mirekit has fallen (dungeon._hit hands over here instead of the plain finish).
static func after(dg) -> void:
	if not BossIntro._alive(dg):
		return
	var b: Dictionary = dg.ents[dg.boss]
	var w := _whinet(dg)
	dg.cutscene = true
	dg.talk.clear()
	if not w.is_empty():
		w["awake"] = false   # it takes no more turns; the scene shows no "z" while cutscene is on
	# 1. It flops over belly up, legs in the air, and gives off a stink: an opossum playing dead.
	b["node"].modulate.a = 1.0
	b["facing"] = "s"
	dg._set_tex(b, b["art"]["still"]["s"])
	b["sprite"].flip_v = true
	dg.intro["stink"] = b["node"].position
	dg._burst(b["node"].position + Vector2(0, -2), Color(0.75, 0.72, 0.66), 10, 30.0, 0.5, -10.0, 1.0)
	dg._sfx("slam", -10.0)
	dg.cam_focus = b["node"].position.lerp(dg.ents[0]["node"].position, 0.35)
	await BossIntro._wait(dg, 1.6)
	if not BossIntro._alive(dg):
		return
	Music.play(dg.get_tree(), "")
	# 2. Whinet, back up if it was down, buzzes over to it in a panic.
	if not w.is_empty():
		w["down"] = false
		w["hp"] = maxi(1, int(w["hp"]))
		w["facing"] = "s"
		dg._set_tex(w, w["art"]["still"]["s"])
		var to: Vector2 = b["node"].position + Vector2(-20, -6)
		var start: Vector2 = w["node"].position
		w["node"].modulate.a = 1.0
		dg.create_tween().tween_method(func(t: float) -> void: w["node"].position = start.lerp(to, t) + Vector2(0, -10.0 * sin(t * PI)), 0.0, 1.0, 0.5)
		dg._sfx("swing", -10.0)
		await BossIntro._wait(dg, 0.6)
		if not BossIntro._alive(dg):
			return
	await _lines(dg, FLOP)
	if not BossIntro._alive(dg):
		return
	# 3. One eye opens: it was faking. It springs up.
	BossIntro._emote(dg, dg.boss, "!")
	await BossIntro._wait(dg, 0.7)
	if not BossIntro._alive(dg):
		return
	b["sprite"].flip_v = false
	dg.intro.erase("stink")
	b["facing"] = "s"
	dg._set_tex(b, b["art"]["still"]["s"])
	var nb: Node2D = b["node"]
	var y0: float = nb.position.y
	var up: Tween = dg.create_tween()
	up.tween_property(nb, "position:y", y0 - 14.0, 0.12).set_ease(Tween.EASE_OUT)
	up.tween_property(nb, "position:y", y0, 0.14).set_ease(Tween.EASE_IN)
	dg._sfx("wake", -4.0)
	await BossIntro._wait(dg, 0.5)
	if not BossIntro._alive(dg):
		return
	await _lines(dg, FLEE)
	if not BossIntro._alive(dg):
		return
	# 4. Both run for it, Mirekit off the side of the room, Whinet up and away; the parcel stays.
	dg._sfx("escape", -2.0)
	b["facing"] = "e"
	dg._set_tex(b, b["art"]["still"]["e"])
	var run: Tween = dg.create_tween().set_parallel(true)
	run.tween_property(nb, "position", nb.position + Vector2(150, -10), 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	run.tween_property(nb, "modulate:a", 0.0, 0.3).set_delay(0.5)
	if not w.is_empty():
		var nw: Node2D = w["node"]
		w["facing"] = "ne"
		dg._set_tex(w, w["art"]["still"].get("ne", w["art"]["still"]["s"]))
		run.tween_property(nw, "position", nw.position + Vector2(120, -140), 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN).set_delay(0.15)
		run.tween_property(nw, "modulate:a", 0.0, 0.3).set_delay(0.75)
	for k in 6:   # dust kicked up as it bolts
		dg._burst(nb.position + Vector2(k * 18, 0), Color(0.75, 0.72, 0.66), 4, 20.0, 0.4, -10.0, 1.0)
	await BossIntro._wait(dg, 1.2)
	if not BossIntro._alive(dg):
		return
	for e in _crew(dg):
		e["hp"] = 0
		e["node"].visible = false
	# 5. The parcel hops to the leader.
	dg.cam_focus = dg.ents[0]["node"].position + Vector2(0, -10)
	await BossIntro._wait(dg, 0.5)
	if not BossIntro._alive(dg):
		return
	var p0: Vector2 = dg.intro.get("parcel", nb.position)
	var p1: Vector2 = dg.ents[0]["node"].position + Vector2(0, -20)
	dg.intro["parcel_up"] = true
	var fly: Tween = dg.create_tween()
	fly.tween_method(func(t: float) -> void: dg.intro["parcel"] = p0.lerp(p1, t) + Vector2(0, -26.0 * sin(t * PI)), 0.0, 1.0, 0.5)
	await fly.finished
	if not BossIntro._alive(dg):
		return
	dg._sfx("pickup", -2.0)
	dg._burst(p1, Color("#ffe9a8"), 14, 50.0, 0.6, -20.0, 1.0)
	Music.jingle(dg.get_tree(), "victory")
	await _lines(dg, GOT_IT)   # held up over the leader's head while the partner speaks
	if not BossIntro._alive(dg):
		return
	dg.intro.erase("parcel")
	dg.cutscene = false
	dg._finish_after_boss()


# ---------------------------------------------------------------- drawing

## The stolen parcel: a kraft-paper box tied with twine, the Wayline's teal seal on top, drawn at the
## world's 1x. On the floor layer while it sits (the crew stand in front of it), over everything while
## it hops to the leader. It jolts when the two tug at it.
static func draw(dg, c: CanvasItem, over: bool) -> void:
	if over and dg.intro.has("stink"):
		_draw_stink(c, dg.intro["stink"])
	if not dg.intro.has("parcel") or dg.intro.get("parcel_up", false) != over:
		return
	var at: Vector2 = dg.intro["parcel"]
	var age: float = (Time.get_ticks_msec() - int(dg.intro.get("jolt", 0))) / 1000.0
	if age < 0.15:
		at += Vector2(signf(sin(age * 90.0)), 0)
	var o := (at - Vector2(6, 9)).round()
	var ink := Color("#2a1d14")
	c.draw_rect(Rect2(o + Vector2(1, 9), Vector2(11, 2)), Color(0, 0, 0, 0.28))   # its shadow
	c.draw_rect(Rect2(o, Vector2(12, 10)), ink)
	c.draw_rect(Rect2(o + Vector2(1, 1), Vector2(10, 3)), Color("#c79a62"))          # the lit lid
	c.draw_rect(Rect2(o + Vector2(1, 4), Vector2(10, 5)), Color("#a37848"))          # the shaded side
	c.draw_rect(Rect2(o + Vector2(1, 4), Vector2(10, 1)), Color("#7c5634"))          # the lid's edge
	c.draw_rect(Rect2(o + Vector2(5, 1), Vector2(2, 8)), Color("#ead9b0"))           # twine, both ways
	c.draw_rect(Rect2(o + Vector2(1, 2), Vector2(10, 1)), Color("#ead9b0"))
	c.draw_rect(Rect2(o + Vector2(5, 1), Vector2(2, 2)), Color("#2f8f8a"))           # the teal seal
	c.draw_rect(Rect2(o + Vector2(5, 1), Vector2(1, 1)), Color("#7fd4c8"))
	c.draw_rect(Rect2(o + Vector2(2, 6), Vector2(2, 1)), Color("#5a3d24"))           # a chewed corner
	c.draw_rect(Rect2(o + Vector2(10, 7), Vector2(1, 2)), Color("#5a3d24"))


## Three green wisps curling up off Mirekit while it plays dead (an opossum's trick; it is Blight).
static func _draw_stink(c: CanvasItem, at: Vector2) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	for k in 3:
		var phase := fmod(t * 0.7 + k / 3.0, 1.0)   # each wisp rises, then starts again
		var base := at + Vector2(-9 + k * 9, -14)
		for n in 6:
			var y := -phase * 22.0 - n * 2.0
			var p := (base + Vector2(sin(t * 3.0 + k * 2.0 + n * 0.9) * 2.0, y)).round()
			var a := (1.0 - phase) * (1.0 - n / 6.0)
			c.draw_rect(Rect2(p - Vector2(1, 0), Vector2(3, 2)), Color("#3d4a1c", a * 0.5))   # a dark edge so it reads on the dirt
			c.draw_rect(Rect2(p, Vector2(1, 2)), Color("#c4e070", a))
