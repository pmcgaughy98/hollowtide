extends RefCounted
## The pilot's payoff, part one (Claude, 2026-10-10; Preston: "the artifact or item that comes out of
## the pond being what allows you to evolve. It gets installed into the evolution shrine"). When the
## Warden falls, its Listeners slip back into the water, the pond lights from below, and a stone rises
## out of it. The presence that spoke to the soul speaks once. The stone comes to the leader; the team
## carries it home, where the Growth Shrine takes it (scripts/town/hub_town.gd, install_stone).
## Story: docs/design/pilot-story-2026-10-10.md.
##
## The stone's name and look are Preston's to set. Until then it is "the pond stone" (STONE_NAME), drawn
## in code below: a smooth dark river stone with a glowing seam. The lines are Claude's proposals.

const BossIntro := preload("res://scripts/dungeon/boss_intro.gd")
const Music := preload("res://scripts/audio/music.gd")

const STONE_NAME := "pond stone"   # working label; Preston names it
const GLOW := [
	["{partner}", "The pond... it's glowing. Something's down there.", "surprised"],
]
const PRESENCE := [
	["???", "...There you are."],
	["{partner}", "Did you hear that? It sounded like it knew us.", "worried"],
]
const TAKE := [
	["{partner}", "It's warm. Like it's been waiting for us.", "happy"],
	["Starward", "Bring that home. The Shrine in Highbank has had an empty socket for longer than I've run the Hall.", "determined"],
]
# The stand-off (Preston, 2026-10-10: the Warden is one of those early bosses that turns out to have been far
# stronger; when it is beaten the team and the Warden face off, both spent, the Warden clearly stronger; as it
# goes to finish them the Guildmaster appears, Wigglytuff-style, and punches it into its pond).
const SPENT := [
	["{partner}", "Huff... huff... Did we... get it?", "worried"],
]
const RISES := [
	["{boss}", "...Hm. You fight well, for strays.", "determined"],
	["{boss}", "I have kept this water since before your Hall had a name. Did you think that was all of me?", "determined"],
]
const PINNED := [
	["{partner}", "C-can't... move...", "sad"],
	["{boss}", "Rest, then. The pond will keep you.", "happy"],
]
const HEY := [["???", "Hey."]]
const ARRIVES := [
	["Starward", "Let go of my runners.", "determined"],
	["{boss}", "The Hall's old champion. You came all this way for two strays?", "surprised"],
	["Starward", "For every one of them.", "angry"],
]
const AFTER_PUNCH := [
	["{partner}", "P-Postmaster?! You followed us?", "surprised"],
	["Starward", "I follow every first run. Quietly.", "happy"],
	["Starward", "That thing has kept this pond a long, long time. It was only playing with you.", "worried"],
]


## Called by dungeon._wound when the Warden falls, instead of the plain finish.
static func after(dg) -> void:
	if not BossIntro._alive(dg):
		return
	var pc: Vector2 = BossIntro.pond_center(dg)
	dg.cutscene = true
	dg.talk.clear()
	# The leader is in the scene from its first frame (L7-02, Claude, 2026-10-26): whole and in sight, never a ring
	# with no one on it, and lying in the team's down pose when it was the one that fell.
	var lead: Dictionary = dg.ents[0]
	dg._stop_ko_fade(lead)
	if lead["hp"] <= 0:
		lead["hp"] = 1
		lead["down"] = true
	await _standoff(dg)   # the twist: the Warden was holding back, and the Guildmaster ends it
	if not BossIntro._alive(dg):
		return
	Music.play(dg.get_tree(), "")
	# 1. The Listeners still standing slip back into the pond.
	for e in dg.ents:
		if not e.get("minion", false) or e["hp"] <= 0:
			continue
		e["awake"] = false
		var from: Vector2 = e["node"].position
		var to := pc + Vector2(signf(from.x - pc.x) * 30.0, 6.0)
		var hop: Tween = dg.create_tween()
		hop.tween_method(func(t: float) -> void: e["node"].position = from.lerp(to, t) + Vector2(0, -30.0 * sin(t * PI)), 0.0, 1.0, 0.45)
		hop.tween_property(e["node"], "modulate:a", 0.0, 0.15)
		dg._sfx("hop_splash", -4.0)
		await BossIntro._wait(dg, 0.5)
		if not BossIntro._alive(dg):
			return
		dg._burst(to, Color("#cfe9f5"), 10, 60.0, 0.5, 180.0, 1.0)
		e["hp"] = 0
	# 2. The team turns to the pond; it lights from below.
	BossIntro._pan(dg, pc + Vector2(0, 26), 0.8)   # the pond in the upper half, clear of the text box, room for the stone to rise
	for e in BossIntro._team(dg):
		e["facing"] = "n"
		dg._set_tex(e, e["art"]["still"]["n"])
	dg._sfx("ripple", -4.0)
	dg.intro["ripple_at"] = Time.get_ticks_msec()
	dg.create_tween().tween_method(func(v: float) -> void: dg.intro["stone_glow"] = v, 0.0, 1.0, 1.6)
	await BossIntro._wait(dg, 1.0)
	if not BossIntro._alive(dg):
		return
	BossIntro._emote(dg, 1 if dg.ents.size() > 1 and dg.ents[1]["team"] == 0 else 0, "!")
	await BossIntro._wait(dg, 0.7)
	if not BossIntro._alive(dg):
		return
	await BossIntro._lines(dg, GLOW)
	if not BossIntro._alive(dg):
		return
	# 3. The stone rises out of the water.
	dg._sfx("presence_swell", -3.0)
	dg._sfx("pond_rumble", -12.0)
	dg.intro["stone"] = pc
	var rise: Tween = dg.create_tween()
	rise.tween_method(func(t: float) -> void: dg.intro["stone"] = pc + Vector2(0, -34.0 * t), 0.0, 1.0, 1.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	for k in 4:
		dg._burst(pc + Vector2(randf_range(-10, 10), 0), Color("#bff4ee"), 6, 30.0, 0.8, -30.0, 1.0)
		await BossIntro._wait(dg, 0.45)
		if not BossIntro._alive(dg):
			return
	# 4. The presence, once: the room dims while it speaks.
	dg.create_tween().tween_method(func(v: float) -> void: dg.intro["dim"] = v, 0.0, 0.35, 0.6)
	await BossIntro._wait(dg, 0.6)
	if not BossIntro._alive(dg):
		return
	await BossIntro._lines(dg, PRESENCE)
	if not BossIntro._alive(dg):
		return
	dg.create_tween().tween_method(func(v: float) -> void: dg.intro["dim"] = v, 0.35, 0.0, 0.6)
	# 5. It drifts to the leader and hangs over its head.
	var s0: Vector2 = dg.intro["stone"]
	var s1: Vector2 = dg.ents[0]["node"].position + Vector2(0, -38)
	var drift: Tween = dg.create_tween()
	drift.tween_method(func(t: float) -> void: dg.intro["stone"] = s0.lerp(s1, t) + Vector2(0, -14.0 * sin(t * PI)), 0.0, 1.0, 1.1).set_trans(Tween.TRANS_SINE)
	BossIntro._pan(dg, dg.ents[0]["node"].position + Vector2(0, -20), 1.1)
	await drift.finished
	if not BossIntro._alive(dg):
		return
	dg._sfx("pickup", -2.0)
	dg._burst(s1, Color("#bff4ee"), 18, 60.0, 0.7, -20.0, 1.0)
	dg._ring(s1, Color("#bff4ee"), 40.0, 0.5)
	Music.jingle(dg.get_tree(), "victory")
	await _say(dg, TAKE)   # held up over the leader's head; the Guildmaster speaks too
	if not BossIntro._alive(dg):
		return
	dg.intro.erase("stone")
	dg.cutscene = false
	dg._finish_after_boss()


# ---------------------------------------------------------------- drawing

## Over the creatures: the pond's light from below, and the stone wherever it is.
static func draw_over(dg, c: CanvasItem) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	var g: float = dg.intro.get("stone_glow", 0.0)
	if g > 0.0 and dg.intro.has("stone_glow") and dg.pond.size != Vector2i.ZERO:
		var pc: Vector2 = BossIntro.pond_center(dg)
		var pulse := 0.8 + 0.2 * sin(t * 2.4)
		for k in 4:   # light welling up through the water, in soft rings
			var rx := (14.0 + k * 14.0) * g
			c.draw_set_transform(pc, 0.0, Vector2(1.0, 0.4))
			c.draw_circle(Vector2.ZERO, rx, Color(0.75, 0.97, 0.94, 0.16 * g * pulse * (1.0 - k * 0.2)))
			c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if dg.intro.has("stone"):
		draw_stone(c, dg.intro["stone"] + Vector2(0, sin(t * 2.0) * 1.5), t, 1.0)


## The pond stone at 1x: an egg of dark river slate lit from the top left, a seam of pale teal light
## across its middle that pulses, and a soft halo. `at` is its centre. Also drawn in the shrine's
## socket in town (hub_town.gd).
static func draw_stone(c: CanvasItem, at: Vector2, t: float, halo: float) -> void:
	var o := (at - Vector2(5, 6)).round()
	var pulse := 0.6 + 0.4 * sin(t * 3.0)
	if halo > 0.0:
		for k in 3:
			c.draw_circle(at, 9.0 + k * 4.0, Color(0.75, 0.97, 0.94, (0.12 - k * 0.035) * halo * (0.7 + 0.3 * pulse)))
	# Its rows, outline included: each [first column, width] in a 10 x 12 box.
	var rows := [[3, 4], [2, 6], [1, 8], [1, 8], [0, 10], [0, 10], [0, 10], [0, 10], [1, 8], [1, 8], [2, 6], [3, 4]]
	var ink := Color("#1b2229")
	for y in rows.size():
		var x0: int = rows[y][0]
		var w: int = rows[y][1]
		c.draw_rect(Rect2(o + Vector2(x0, y), Vector2(w, 1)), ink)
		if y > 0 and y < rows.size() - 1:
			c.draw_rect(Rect2(o + Vector2(x0 + 1, y), Vector2(w - 2, 1)), Color("#475663") if y > 5 else Color("#5d6e7c"))
	c.draw_rect(Rect2(o + Vector2(3, 2), Vector2(2, 1)), Color("#8597a4"))   # the lit top-left
	c.draw_rect(Rect2(o + Vector2(2, 3), Vector2(1, 2)), Color("#8597a4"))
	c.draw_rect(Rect2(o + Vector2(6, 9), Vector2(2, 1)), Color("#36424d"))   # the shaded bottom-right
	# The seam: a band of light dipping across the middle, brightest at its heart.
	var seam := Color(0.75, 0.97, 0.94).lerp(Color(1, 1, 1), pulse * 0.4)
	for p in [Vector2i(1, 6), Vector2i(2, 6), Vector2i(3, 7), Vector2i(4, 7), Vector2i(5, 7), Vector2i(6, 6), Vector2i(7, 6), Vector2i(8, 5)]:
		c.draw_rect(Rect2(o + Vector2(p), Vector2(1, 1)), seam)
	c.draw_rect(Rect2(o + Vector2(4, 7), Vector2(2, 1)), Color(1, 1, 1, 0.6 + 0.4 * pulse))



# ---------------------------------------------------------------- the stand-off and the Guildmaster

## Lines where anyone may speak with a portrait: {partner}, {boss}, or a creature by name (its form).
static func _say(dg, lines: Array) -> void:
	if not BossIntro._alive(dg):
		return
	var pe: Dictionary = dg.ents[1] if dg.ents.size() > 1 and dg.ents[1]["team"] == 0 else dg.ents[0]
	var b: Dictionary = dg.ents[dg.boss]
	for l in lines:
		var who: String = String(l[0])
		var form := ""
		if who == "{partner}":
			form = String(pe["form"])
		elif who == "{boss}":
			form = String(b["form"])
		elif who != "???":
			form = who.to_lower()
		if l.size() > 2 and form != "":
			form += ":" + String(l[2])
		dg.talk.append([who.replace("{partner}", String(pe["name"])).replace("{boss}", String(b["name"])), String(l[1]).replace("{leader}", String(dg.ents[0]["name"])), form])
	while BossIntro._alive(dg) and not dg.talk.is_empty():
		await dg.get_tree().process_frame


static func _team(dg) -> Array:
	return dg.ents.filter(func(e: Dictionary) -> bool: return e["team"] == 0 and e["hp"] > 0)


## The Warden falls to zero and does not faint: a flash, both sides spent, then it rises, knocks the team
## flat and goes for the leader; a voice from behind; the Guildmaster walks in and punches it into its pond.
static func _standoff(dg) -> void:
	var w: Dictionary = dg.ents[dg.boss]
	var wn: Node2D = w["node"]
	var lead: Dictionary = dg.ents[0]
	Music.play(dg.get_tree(), "")
	w["hp"] = 1   # it is not beaten; the fight was
	wn.modulate.a = 1.0
	# 1. Spent: both sides heaving, breath puffs over everyone.
	dg.intro["spent"] = true
	dg._sfx("spent_pant", -2.0)
	BossIntro._pan(dg, (wn.position + lead["node"].position) * 0.5 + Vector2(0, 10), 0.6)
	await BossIntro._wait(dg, 1.6)
	if not BossIntro._alive(dg):
		return
	await _say(dg, SPENT)
	if not BossIntro._alive(dg):
		return
	# 2. It draws itself up: it was holding back.
	dg.intro["spent"] = false
	wn.scale = Vector2.ONE
	w["sprite"].position.y = 0.0   # the breath (draw_standoff) ends on its ground pixel
	var grow: Tween = dg.create_tween()
	grow.tween_property(wn, "scale", Vector2(1.12, 1.12), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	dg._sfx("warden_rise", 0.0)
	dg._sfx("presence_swell", -4.0)
	dg._shake = 3.0
	await grow.finished
	if not BossIntro._alive(dg):
		return
	await _say(dg, RISES)
	if not BossIntro._alive(dg):
		return
	# A croak that knocks the team flat.
	dg._sfx("warden_croak", 2.0)
	dg._ring(wn.position, Color("#cfe9f5"), 80.0, 0.5)
	dg._shake = 6.0
	dg._flash = 0.2
	for e in _team(dg):
		e["down"] = true
	dg.intro["dazed"] = true
	await BossIntro._wait(dg, 0.9)
	if not BossIntro._alive(dg):
		return
	await _say(dg, PINNED)
	if not BossIntro._alive(dg):
		return
	# 3. It comes for the leader the way Groudon closes on the heroes in Mystery Dungeon (structure only):
	# one heavy step at a time, each a lift, a slam, the screen shaking and dust at its feet, a beat of
	# dread between, the downed team flinching. Then its strike gathers under the leader's feet.
	var start: Vector2 = wn.position
	var toward: Vector2 = lead["node"].position + Vector2(0, -34)
	dg._sfx("warden_rise", -10.0)
	await BossIntro._wait(dg, 0.6)
	for k in 3:
		if not BossIntro._alive(dg):
			return
		var a: Vector2 = wn.position
		var b: Vector2 = start.lerp(toward, 0.28 * (k + 1))   # three steps close most of the gap
		var stomp: Tween = dg.create_tween()
		stomp.tween_method(func(t: float) -> void: wn.position = a.lerp(b, t) + Vector2(0, -7.0 * sin(t * PI)), 0.0, 1.0, 0.3).set_trans(Tween.TRANS_QUAD)
		await stomp.finished
		if not BossIntro._alive(dg):
			return
		dg._sfx("heavy_land", -1.0 + k)
		dg._shake = 4.0 + 1.5 * k
		dg._burst(wn.position + Vector2(-14, 2), Color(0.66, 0.6, 0.5), 8, 40.0, 0.5, -10.0, 1.0)
		dg._burst(wn.position + Vector2(14, 2), Color(0.66, 0.6, 0.5), 8, 40.0, 0.5, -10.0, 1.0)
		for e in _team(dg):   # the downed team flinches at each footfall
			var n: Node2D = e["node"]
			var y0: float = n.position.y
			var flinch: Tween = dg.create_tween()
			flinch.tween_property(n, "position:y", y0 - 2.0, 0.05)
			flinch.tween_property(n, "position:y", y0, 0.08)
		await BossIntro._wait(dg, 0.75)
	dg.intro["doom"] = lead["node"].position
	dg._sfx("windup", -2.0)
	await BossIntro._wait(dg, 1.0)
	if not BossIntro._alive(dg):
		return
	# 4. "Hey." A voice from behind; the Warden stops.
	await _say(dg, HEY)
	if not BossIntro._alive(dg):
		return
	BossIntro._emote(dg, dg.boss, "?")
	var gate: Vector2i = lead["pos"] + Vector2i(0, 1)
	for k in range(5, 2, -1):   # well behind the team, so it walks in past them
		if dg._floor_at(lead["pos"] + Vector2i(0, k)):
			gate = lead["pos"] + Vector2i(0, k)
			break
	var star: Dictionary = dg._make(6, 2, 0, gate)   # Starward, the Guildmaster: shown, not part of the fight
	var sn: Node2D = star["node"]
	star["facing"] = "n"
	dg._set_tex(star, star["art"]["still"]["n"])
	sn.position = dg._tile_px(gate) + Vector2(0, 40)
	BossIntro._pan(dg, (dg._tile_px(gate) + wn.position) * 0.5, 0.8)
	# It walks in, unhurried.
	var frames: Array = star["art"]["walk"].get("n", [])
	var t0 := Time.get_ticks_msec()
	var stroll: Tween = dg.create_tween()
	stroll.tween_property(sn, "position", dg._tile_px(gate), 1.4)
	while stroll.is_running() and BossIntro._alive(dg):
		if not frames.is_empty():
			dg._set_tex(star, frames[int((Time.get_ticks_msec() - t0) / 90) % frames.size()])
		sn.z_index = int(sn.position.y)
		await dg.get_tree().process_frame
	if not BossIntro._alive(dg):
		return
	dg._set_tex(star, star["art"]["still"]["n"])
	dg.intro.erase("doom")
	await _say(dg, ARRIVES)
	if not BossIntro._alive(dg):
		return
	# 5. The punch: a streak of light to the Warden's flank, a frozen white beat, one blow.
	var at: Vector2 = wn.position + Vector2(0, 26)
	dg.intro["streak"] = {"from": sn.position + Vector2(0, -16), "to": at + Vector2(0, -16), "at": Time.get_ticks_msec()}
	dg._sfx("dash_zip", -1.0)
	BossIntro._pan(dg, at + Vector2(0, -6), 0.12)   # the camera snaps to the blow
	sn.position = at
	sn.z_index = int(at.y) + 1
	await BossIntro._wait(dg, 0.12)
	var punch: Array = star["art"]["acts"].get("attack", {}).get("n", [])
	for i in punch.size():
		dg._set_tex(star, punch[i])
		await BossIntro._wait(dg, 0.05)
	if punch.is_empty():   # no punch frames yet: a lunge
		var jab: Tween = dg.create_tween()
		jab.tween_property(sn, "position", at + Vector2(0, -8), 0.05)
		jab.tween_property(sn, "position", at, 0.12)
	dg._flash = 0.9
	dg._sfx("mega_punch", 2.0)
	dg._sfx("hit_super", -6.0)
	await BossIntro._wait(dg, 0.28)
	if not BossIntro._alive(dg):
		return
	dg._shake = 11.0
	dg._ring(at + Vector2(0, -20), Color("#ffe9a8"), 110.0, 0.5)
	dg._burst(at + Vector2(0, -20), Color("#ffe9a8"), 30, 160.0, 0.7, 60.0, 2.0)
	# 6. The Warden flies in an arc into its own pond.
	var pc: Vector2 = BossIntro.pond_center(dg)
	var w0: Vector2 = wn.position
	var fly: Tween = dg.create_tween().set_parallel(true)
	fly.tween_method(func(t: float) -> void: wn.position = w0.lerp(pc, t) + Vector2(0, -90.0 * sin(t * PI)), 0.0, 1.0, 0.75)
	fly.tween_property(wn, "rotation", -TAU * 1.25, 0.75)
	await fly.finished
	if not BossIntro._alive(dg):
		return
	wn.visible = false
	w["hp"] = 0
	dg._sfx("body_splash", 0.0)
	dg._sfx("pond_burst", -6.0)
	dg._shake = 7.0
	for k in 70:
		dg._parts.append({"pos": pc + Vector2(randf_range(-18, 18), randf_range(-4, 4)), "vel": Vector2(randf_range(-40, 40), -randf_range(200, 380)),
			"t": -randf() * 0.1, "life": randf_range(0.9, 1.3), "col": Color("#e6f4fb").lerp(Color("#7fb3cc"), randf() * 0.6), "size": randf_range(1.5, 3.0), "grav": 420.0})
	dg._ring(pc, Color("#cfe9f5"), 90.0, 0.6)
	await BossIntro._wait(dg, 0.9)
	if not BossIntro._alive(dg):
		return
	dg._sfx("water_rain", -6.0)
	dg.intro.erase("streak")
	# 7. Quiet. It turns to the team; they get up.
	await BossIntro._wait(dg, 0.8)
	if not BossIntro._alive(dg):
		return
	star["facing"] = "s"
	dg._set_tex(star, star["art"]["still"]["s"])
	for e in _team(dg):
		e["down"] = false
		dg._set_tex(e, e["art"]["still"][e["facing"]])
	dg.intro["dazed"] = false
	dg._sfx("dizzy", -8.0)
	BossIntro._pan(dg, (sn.position + lead["node"].position) * 0.5 + Vector2(0, 10), 0.6)
	await _say(dg, AFTER_PUNCH)
	if not BossIntro._alive(dg):
		return
	dg.intro["starward"] = star


## Over the creatures: breath puffs while the two sides are spent, the strike gathering under the leader,
## and the streak of light the Guildmaster leaves.
static func draw_standoff(dg, c: CanvasItem) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	if dg.intro.get("spent", false):
		var who: Array = _team(dg)
		who.append(dg.ents[dg.boss])
		for k in who.size():
			var e: Dictionary = who[k]
			var ph := fmod(t * 1.3 + k * 0.37, 1.0)
			var top: float = -float(e["sprite"].texture.get_height()) * 0.55 * e["node"].scale.y
			var p: Vector2 = (e["node"].position + Vector2(8 + ph * 6.0, top + 10 - ph * 10.0)).round()
			c.draw_rect(Rect2(p, Vector2(3, 2)), Color(1, 1, 1, 0.55 * (1.0 - ph)))
			c.draw_rect(Rect2(p + Vector2(-2, -2), Vector2(2, 2)), Color(1, 1, 1, 0.35 * (1.0 - ph)))
		# Claude, 2026-10-22 (UI-07): the Warden breathes by whole pixels, its sprite lifted 1 px for half of
		# a 0.6 s cycle; its scale stays Vector2.ONE so the pixels never swim.
		var wsp: Sprite2D = dg.ents[dg.boss]["sprite"]
		wsp.position.y = -1.0 if fmod(t, 0.6) < 0.3 else 0.0
	if dg.intro.has("doom"):
		var p: Vector2 = dg.intro["doom"]
		var k := 0.5 + 0.5 * sin(t * 14.0)
		c.draw_set_transform(p, 0.0, Vector2(1.0, 0.45))
		c.draw_circle(Vector2.ZERO, 14.0, Color(0.9, 0.15, 0.1, 0.18 + 0.2 * k))
		c.draw_arc(Vector2.ZERO, 14.0, 0, TAU, 24, Color(1, 0.35, 0.25, 0.8), 1.0)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if dg.intro.has("streak"):
		var st: Dictionary = dg.intro["streak"]
		var a: float = (Time.get_ticks_msec() - int(st["at"])) / 500.0
		if a < 1.0:
			var from: Vector2 = st["from"]
			var to: Vector2 = st["to"]
			for k in 3:
				var off := Vector2(0, (k - 1) * 3)
				c.draw_line(from + off, to + off, Color(1, 0.95, 0.7, (1.0 - a) * (0.9 - k * 0.25)), 3.0 - k)
