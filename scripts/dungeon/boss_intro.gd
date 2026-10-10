extends RefCounted
## The Quietwater Warden's entrance on the boss floor (Claude, 2026-10-10), from Preston's storyboard:
## the team walks into a big pond garden at the bottom of the Hollow, the kind of place a tired
## creature would call a beautiful resting spot, not knowing it is the Warden's domain; a voice speaks
## to them from nowhere; a great shadow rises under the water; the Warden bursts out, unseen, in a
## flash that knocks the team flat; as they get up dazed, its shadow appears on the ground (it jumped,
## it is a frog); it lands and slams them back; its Listeners hop out of the pond to its sides; then
## the talk, then the fight.
##
## Everything is drawn in code on the dungeon's own layers, pixel by pixel at the world's 1x: the
## meadow, the pond and its life (fish, lily blossoms, reeds, fireflies), the shadows and the daze
## stars (draw_floor and draw_over below); splashes and dust use the dungeon's particles.
## The lines are Claude's proposals; the voice and temper are Preston's to change (VOICE, AFTER).

const Music := preload("res://scripts/audio/music.gd")

# The Warden's temper, proposed: old, patient, possessive of its garden, scornful of noise. Creatures
# that rest by its water stay (the Hollow is absence: they are never seen again). It is not cruel; it
# keeps what comes to it. "{partner}", "{leader}" and "{boss}" are filled in.
const OPEN := [
	["{partner}", "Look at this place... water, flowers, fireflies. All the way down here?", "joyous"],
	["{partner}", "Let's rest by the pond for a moment. It feels safe.", "happy"],
]
const NOTICE := [["{partner}", "...Huh? Did the water just move?", "surprised"]]
const VOICE := [
	["???", "Safe. Everything that wanders down here says so."],
	["???", "They drink. They sleep by the water. They forget to leave."],
	["{partner}", "Who said that? Show yourself!", "surprised"],
	["???", "You are standing in my garden. Mind your noise."],
]
const AFTER := [
	["{boss}", "This water is mine. Every reed, every ripple, every creature that rests here.", "determined"],
	["{boss}", "Listeners. Hold them where they stand.", "determined"],
	["{partner}", "{leader}... this was never a resting place. Together!", "angry"],
	["{boss}", "Rest, then. The pond will keep you.", "happy"],
]
const WALK_STEPS := 3          # tiles the team walks in before the voice starts (it stops just below the meadow)
const POND := Vector2i(9, 3)   # the pond in tiles, centred one row below the stairs
const LAND_ROW := 7            # the Warden lands this many tiles below the stairs, clear of the shore: its back reaches about three tiles up (Preston: its rear touched the water)
const FIREFLIES := 14


## Lay out the room for the scene: the Warden and its Listeners hidden until they appear.
## Called by _build_floor on the boss floor, after _place_boss.
static func setup(dg) -> void:
	dg.cutscene = true
	dg.intro = {"t0": Time.get_ticks_msec(), "pond_shadow": 0.0, "ground": {}, "dazed": false}
	for e in dg.ents:
		if e.get("boss", false) or e.get("minion", false):
			e["hidden"] = true
			e["node"].visible = false


## The pond: centred under the stairs. Its tiles do not walk (dungeon._floor_at).
static func pond_rect(stairs: Vector2i) -> Rect2i:
	return Rect2i(stairs + Vector2i(-POND.x / 2, 1), POND)


## The meadow round it: decoration only, it walks like any floor.
static func garden_rect(dg) -> Rect2i:
	return Rect2i(dg.pond.position - Vector2i(3, 1), dg.pond.size + Vector2i(6, 3))


static func pond_center(dg) -> Vector2:
	return Vector2(dg.pond.position * dg.T) + Vector2(dg.pond.size * dg.T) * 0.5


## The scene stops quietly if the floor is left or freed while it plays (the checks free it).
static func _alive(dg) -> bool:
	return is_instance_valid(dg) and dg.is_inside_tree()


static func _wait(dg, s: float) -> void:
	if _alive(dg):
		await dg.get_tree().create_timer(s).timeout


## Pan the camera from where it looks now to `to` over `s` seconds.
static func _pan(dg, to: Vector2, s: float) -> void:
	if not _alive(dg):
		return
	var from: Vector2 = dg.cam_focus if dg.cam_focus is Vector2 else dg.ents[0]["node"].position
	var tw: Tween = dg.create_tween()
	tw.tween_method(func(v: Vector2) -> void: dg.cam_focus = v, from, to, s).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Show some lines and wait until the player has read them all (J), or the checks' autopilot has.
static func _lines(dg, lines: Array) -> void:
	if not _alive(dg):
		return
	var pe: Dictionary = dg.ents[1] if dg.ents.size() > 1 and dg.ents[1]["team"] == 0 else dg.ents[0]
	var bname: String = dg.ents[dg.boss]["name"]
	for l in lines:
		var who: String = String(l[0])
		var form := ""
		if who == "{partner}":
			form = String(pe["form"])
		elif who == "{boss}":
			form = String(dg.ents[dg.boss]["form"])
		if l.size() > 2 and form != "":
			form += ":" + String(l[2])   # the face for this line (UI.dialogue_portrait)
		var text: String = String(l[1]).replace("{leader}", String(dg.ents[0]["name"]))
		dg.talk.append([who.replace("{partner}", String(pe["name"])).replace("{boss}", bname), text, form])
	while _alive(dg) and not dg.talk.is_empty():
		await dg.get_tree().process_frame


## The pond's sound bed (ElevenLabs, tools/audio/build_dungeon_sfx.py), looping under the garden.
static func _ambience(dg) -> void:
	var stream: AudioStreamWAV = load("res://assets/audio/sfx/dungeon/pond_ambience.wav")
	if stream == null:
		return
	stream = stream.duplicate()
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = int(stream.get_length() * stream.mix_rate)
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = -30.0
	dg.add_child(p)
	p.play()
	dg.intro["ambience"] = p
	dg.create_tween().tween_property(p, "volume_db", -2.0, 1.5)


static func _ambience_fade(dg, to_db: float, s: float) -> void:
	var p: AudioStreamPlayer = dg.intro.get("ambience")
	if p == null or not is_instance_valid(p):
		return
	var tw: Tween = dg.create_tween()
	tw.tween_property(p, "volume_db", to_db, s)
	if to_db <= -60.0:
		tw.tween_callback(p.queue_free)


## A "!" or "?" pops over a creature for a moment, the way Explorers of Sky marks a surprise.
static func _emote(dg, i: int, mark: String) -> void:
	dg.intro["emote"] = {"i": i, "mark": mark, "at": Time.get_ticks_msec()}
	dg._sfx("emote_alert", -4.0)


## While the voice speaks, each teammate turns this way and that, looking for it.
static func _look_around(dg) -> void:
	var looks := ["nw", "ne", "w", "e", "n"]
	var k := 0
	while _alive(dg) and dg.intro.get("looking", false):
		for e in _team(dg):
			var f: String = looks[(k + e["line"]) % looks.size()]
			e["facing"] = f
			dg._set_tex(e, e["art"]["still"][f])
		k += 1
		await _wait(dg, 0.7)


static func _team(dg) -> Array:
	return dg.ents.filter(func(e: Dictionary) -> bool: return e["team"] == 0 and e["hp"] > 0)


## Move every teammate one tile by `d` where it can go, front of the line first.
static func _shift_team(dg, d: Vector2i, walk: bool) -> void:
	var team := _team(dg)
	team.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return (a["pos"].y * d.y) > (b["pos"].y * d.y))
	for e in team:
		var to: Vector2i = e["pos"] + d
		if dg._floor_at(to) and dg._occupant(to) < 0:
			e["pos"] = to
			if walk:
				e["facing"] = dg._facing_of(d)
				e["walk_t"] = dg.STEP_TIME * 2.0
			var tw: Tween = dg._slide(e, dg._tile_px(to))
			if not walk:
				tw.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


static func run(dg) -> void:
	if not _alive(dg):
		return
	var pc := pond_center(dg)
	var b: Dictionary = dg.ents[dg.boss]
	var land: Vector2 = dg._tile_px(b["pos"])
	# The garden's own theme (ElevenLabs, 2026-10-10; Preston found the rest-floor song "too medieval"
	# here): it sounds like a safe place, until it does not.
	Music.play(dg.get_tree(), "pond_garden")
	# 1. Fade in on the empty garden and hold (Explorers of Sky opens a boss room empty), then the
	# camera comes down and the team walks in from below.
	dg.cam_focus = pc + Vector2(0, 10)
	dg._fade.color.a = 1.0
	dg.create_tween().tween_property(dg._fade, "color:a", 0.0, 1.2)
	_ambience(dg)
	await _wait(dg, 2.6)
	if not _alive(dg):
		return
	# Frame the pond and where the team will stop, together.
	var stop: Vector2 = dg.ents[0]["node"].position + Vector2(0, -WALK_STEPS * dg.T)
	_pan(dg, stop + Vector2(0, -32), 1.6)   # the team sits above the text box, the pond at the top of the frame
	for k in WALK_STEPS:
		_shift_team(dg, Vector2i(0, -1), true)
		await _wait(dg, 0.3)
		if not _alive(dg):
			return
	for e in _team(dg):
		e["facing"] = "n"
		dg._set_tex(e, e["art"]["still"]["n"])
	await _wait(dg, 0.7)
	await _lines(dg, OPEN)
	if not _alive(dg):
		return
	# 2. A ripple spreads over the still water; a "!" over the partner, who noticed.
	dg.intro["ripple_at"] = Time.get_ticks_msec()
	dg._sfx("ripple", -4.0)
	await _wait(dg, 0.5)
	_emote(dg, 1 if dg.ents.size() > 1 and dg.ents[1]["team"] == 0 else 0, "!")
	await _wait(dg, 0.7)
	await _lines(dg, NOTICE)
	if not _alive(dg):
		return
	# 3. The voice from nowhere: the room dims, the music turns, the team looks round for it.
	Music.play(dg.get_tree(), "boss_scene")
	dg._sfx("presence_swell", -3.0)
	_ambience_fade(dg, -26.0, 1.5)   # the pond goes quiet under the voice
	dg.intro["dim"] = 0.0
	dg.create_tween().tween_method(func(v: float) -> void: dg.intro["dim"] = v, 0.0, 0.42, 0.8)
	dg.intro["looking"] = true
	_look_around(dg)
	await _wait(dg, 0.6)
	await _lines(dg, VOICE)
	if not _alive(dg):
		return
	dg.intro["looking"] = false
	for e in _team(dg):
		e["facing"] = "n"
		dg._set_tex(e, e["art"]["still"]["n"])
	# 3. A great shadow rises under the pond; the fish scatter, the ground trembles.
	_pan(dg, (pc + dg.ents[0]["node"].position) * 0.5, 0.6)
	dg._sfx("pond_rumble", -2.0)
	dg._sfx("monster_ambush", -12.0)
	var steps := 28
	for k in steps:
		dg.intro["pond_shadow"] = float(k + 1) / steps
		dg._shake = maxf(dg._shake, 0.4 + 1.6 * float(k) / steps)
		if k % 4 == 0:
			dg._burst(pc + Vector2(randf_range(-50, 50), randf_range(-16, 16)), Color("#9cc7da"), 3, 18.0, 0.5, 30.0, 1.0)
		await _wait(dg, 0.05)
		if not _alive(dg):
			return
	# 4. It bursts out, unseen: a flash, a pillar of water, the team knocked flat, the fireflies gone.
	dg.intro["pond_shadow"] = 0.0
	dg.intro["dim"] = 0.0
	dg.intro["burst_at"] = Time.get_ticks_msec()
	dg._flash = 0.55
	dg._shake = 7.0
	dg._sfx("pond_burst", 0.0)
	dg._play("res://assets/audio/sfx/ui/hit_strong.wav", -6.0)
	_ambience_fade(dg, -80.0, 0.3)
	for k in 3:
		dg._burst(pc, Color("#cfe9f5"), 26, 150.0, 1.1, 260.0, 2.0)
	for k in 70:   # a column of water thrown straight up where it left the pond
		dg._parts.append({"pos": pc + Vector2(randf_range(-16, 16), randf_range(-4, 4)), "vel": Vector2(randf_range(-38, 38), -randf_range(220, 420)),
			"t": -randf() * 0.12, "life": randf_range(0.9, 1.4), "col": Color("#e6f4fb").lerp(Color("#7fb3cc"), randf() * 0.6), "size": randf_range(1.5, 3.0), "grav": 420.0})
	dg._ring(pc, Color("#cfe9f5"), 90.0, 0.6)
	for e in _team(dg):
		e["down"] = true
	dg.intro["dazed"] = true
	await _wait(dg, 0.5)
	if not _alive(dg):
		return
	dg._sfx("water_rain", -4.0)
	for k in 18:   # water rains back down on the room
		var at := Vector2(randf_range(pc.x - 170, pc.x + 170), pc.y - randf_range(80, 140))
		dg._parts.append({"pos": at, "vel": Vector2(randf_range(-5, 5), randf_range(40, 70)), "t": -randf() * 0.6, "life": 1.1, "col": Color("#9cc7da"), "size": 1.0, "grav": 160.0})
	await _wait(dg, 1.1)
	if not _alive(dg):
		return
	# 5. They get up, still dazed.
	dg._sfx("dizzy", -6.0)
	for e in _team(dg):
		e["down"] = false
		dg._set_tex(e, e["art"]["still"][e["facing"]])
	await _wait(dg, 0.9)
	if not _alive(dg):
		return
	# 6. Its shadow on the ground in front of them: it is coming down.
	_pan(dg, (land + dg.ents[0]["node"].position) * 0.5, 0.4)
	dg._sfx("fall_whoosh", -2.0)
	dg.intro["ground"] = {"pos": land, "k": 0.0}
	for k in 20:
		dg.intro["ground"]["k"] = float(k + 1) / 20.0
		await _wait(dg, 0.045)
		if not _alive(dg):
			return
	dg.intro["dazed"] = false
	# 7. It lands and slams the team back.
	var node: Node2D = b["node"]
	node.position = land + Vector2(0, -230)
	b.erase("hidden")
	b["awake"] = true   # awake for the scene (no sleep pose, no "z"); no turns run until the fight
	node.visible = true
	var fall: Tween = dg.create_tween()
	fall.tween_property(node, "position", land, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await fall.finished
	if not _alive(dg):
		return
	dg.intro["ground"] = {}
	dg._place(b)
	dg._shake = 8.0
	dg._flash = 0.25
	dg._sfx("heavy_land", 0.0)
	dg._sfx("slam", -5.0)
	dg._ring(land, Color("#b49a72"), 60.0, 0.5)
	dg._burst(land, Color("#8a7458"), 30, 110.0, 0.7, 180.0, 2.0)
	_shift_team(dg, Vector2i(0, 1), false)
	for e in _team(dg):
		dg._play_act(e, "hurt")
	await _wait(dg, 0.8)
	if not _alive(dg):
		return
	# 8. Its Listeners hop out of the pond to its sides.
	for e in dg.ents:
		if not e.get("minion", false):
			continue
		var to: Vector2 = dg._tile_px(e["pos"])
		var from := pc + Vector2(signf(to.x - pc.x) * 40.0, 10.0)
		e["node"].position = from
		e.erase("hidden")
		e["awake"] = true
		e["node"].visible = true
		dg._burst(from, Color("#cfe9f5"), 12, 70.0, 0.6, 200.0, 1.0)
		dg._sfx("hop_splash", -3.0)
		var hop: Tween = dg.create_tween()
		hop.tween_method(func(t: float) -> void: e["node"].position = from.lerp(to, t) + Vector2(0, -38.0 * sin(t * PI)), 0.0, 1.0, 0.42)
		await hop.finished
		if not _alive(dg):
			return
		dg._place(e)
		await _wait(dg, 0.15)
	await _wait(dg, 0.4)
	if not _alive(dg):
		return
	# 9. The talk, then the fight. The camera holds on the Warden; the team stands under the box.
	_pan(dg, land + Vector2(0, -14), 0.5)
	dg._sfx("warden_croak", -1.0)   # its cry before it speaks, as a boss cries on screen in Explorers of Sky
	dg._shake = 2.5
	await _wait(dg, 1.1)
	await _lines(dg, AFTER)
	if not _alive(dg):
		return
	# 10. Streaks of light wipe across the screen into a white flash, and the fight begins (the
	# transition Explorers of Sky plays into every boss fight).
	dg.intro["wipe_at"] = Time.get_ticks_msec()
	dg._sfx("battle_wipe", -2.0)
	await _wait(dg, 0.7)
	if not _alive(dg):
		return
	dg._flash = 0.45
	dg.intro.erase("wipe_at")
	dg.cutscene = false
	dg.cam_focus = null
	dg.intro["done"] = true
	dg._meet_boss()


# ---------------------------------------------------------------- drawing

static var _tex := {}


## Deterministic noise for the art, so the garden is the same every time.
static func _h(x: int, y: int, k: int = 0) -> float:
	var n := (x * 374761393 + y * 668265263 + k * 1442695041) & 0x7fffffff
	n = ((n ^ (n >> 13)) * 1274126177) & 0x7fffffff
	return float(n % 1000) / 1000.0


## Inside a soft blob filling `size`: 0 at the centre, 1 at the edge, above 1 outside.
static func _blob(x: int, y: int, size: Vector2i, wob: float) -> float:
	var dx := (x + 0.5 - size.x * 0.5) / (size.x * 0.5 - 1.0)
	var dy := (y + 0.5 - size.y * 0.5) / (size.y * 0.5 - 1.0)
	var w := wob * (sin(x * 0.21 + y * 0.05) + 0.7 * sin(y * 0.33 + x * 0.09) + 0.5 * sin(x * 0.53))
	return pow(absf(dx), 2.2) + pow(absf(dy), 2.2) + w


## The meadow round the pond: soft grass with darker tufts, flowers in four colours, mossy stones.
static func _meadow(size: Vector2i) -> Texture2D:
	var key := "meadow%s" % size
	if _tex.has(key):
		return _tex[key]
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	var greens := [Color("#4d6b34"), Color("#57783a"), Color("#628543"), Color("#3f5a2c")]
	var flowers := [Color("#f2a7c3"), Color("#fff4e8"), Color("#f2d16b"), Color("#b9a3e8")]
	for y in size.y:
		for x in size.x:
			var d := _blob(x, y, size, 0.05)
			if d > 1.0:
				continue
			var n := _h(x / 2, y / 2)
			var c: Color = greens[int(n * 3.0)]
			if _h(x, y, 1) > 0.93:
				c = greens[3]   # a dark tuft
			var a := 1.0 if d < 0.8 else clampf((1.0 - d) / 0.2, 0.0, 1.0)
			if a < 1.0 and _h(x, y, 2) > a:
				continue   # the edge breaks up into the floor instead of fading
			img.set_pixel(x, y, c)
	# Flowers: a centre pixel and four petals, scattered.
	for k in int(size.x * size.y / 260):
		var x := int(_h(k, 3, 3) * (size.x - 6)) + 3
		var y := int(_h(k, 7, 4) * (size.y - 6)) + 3
		if _blob(x, y, size, 0.05) > 0.85:
			continue
		var col: Color = flowers[k % flowers.size()]
		for o in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			img.set_pixel(x + o.x, y + o.y, col)
		img.set_pixel(x, y, Color("#e8b84a") if col != flowers[2] else Color("#c9772e"))
		img.set_pixel(x, y + 2, Color("#2f4a24"))   # its stem
	# Mossy stones.
	for k in 7:
		var x := int(_h(k, 11, 5) * (size.x - 12)) + 6
		var y := int(_h(k, 13, 6) * (size.y - 10)) + 5
		if _blob(x, y, size, 0.05) > 0.8:
			continue
		for yy in range(-2, 3):
			for xx in range(-3, 4):
				if xx * xx + yy * yy * 2 <= 8:
					img.set_pixel(x + xx, y + yy, Color("#7d7a6c") if yy < 0 else Color("#5d5b50"))
		img.set_pixel(x - 1, y - 2, Color("#6f8f4e"))
		img.set_pixel(x, y - 2, Color("#6f8f4e"))
	_tex[key] = ImageTexture.create_from_image(img)
	return _tex[key]


## The pond: deep middle, clear shallows, a muddy bank with stones, reeds and cattails, lily pads
## with pink blossoms.
static func _pond(size: Vector2i) -> Texture2D:
	var key := "pond%s" % size
	if _tex.has(key):
		return _tex[key]
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	var bank := Color("#3f3426")
	var bank_hi := Color("#6b5a3e")
	var deep := Color("#16303f")
	var mid := Color("#1f4457")
	var shallow := Color("#2f6178")
	var clear := Color("#3f7a8c")
	for y in size.y:
		for x in size.x:
			var d := _blob(x, y, size, 0.035)
			if d > 1.0:
				continue
			var c: Color
			if d > 0.88:
				c = bank_hi if (y < size.y * 0.5 or _h(x, y, 8) > 0.7) else bank
			elif d > 0.78:
				c = clear
			elif d > 0.6:
				c = shallow
			elif d > 0.3:
				c = mid
			else:
				c = deep
			if d <= 0.88 and _h(x, y, 9) > 0.985:
				c = c.lightened(0.18)   # a glint
			img.set_pixel(x, y, c)
	# Stones in the shallows and on the bank.
	for k in 9:
		var x := int(_h(k, 21, 10) * size.x)
		var y := int(_h(k, 23, 11) * size.y)
		var d := _blob(x, y, size, 0.035)
		if d < 0.72 or d > 0.98:
			continue
		for yy in range(-1, 2):
			for xx in range(-2, 3):
				if absi(xx) + absi(yy) <= 2:
					img.set_pixel(clampi(x + xx, 0, size.x - 1), clampi(y + yy, 0, size.y - 1), Color("#8a8574") if yy < 0 else Color("#66624f"))
	# Lily pads, some with a blossom.
	for k in 9:
		var x := int(_h(k, 31, 12) * (size.x - 14)) + 7
		var y := int(_h(k, 33, 13) * (size.y - 10)) + 5
		if _blob(x, y, size, 0.035) > 0.7:
			continue
		for yy in range(-2, 3):
			for xx in range(-4, 5):
				if xx * xx + yy * yy * 4 <= 16 and not (xx > 0 and yy == 0):
					img.set_pixel(x + xx, y + yy, Color("#5a8c3e") if yy < 1 else Color("#447032"))
		if k % 3 == 0:
			for o in [Vector2i(0, -2), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(0, -1)]:
				img.set_pixel(x + o.x, y + o.y, Color("#f5b8d0"))
			img.set_pixel(x, y - 3, Color("#ffe3ee"))
	# Reeds and cattails round the shore.
	for k in 16:
		var a := _h(k, 41, 14) * TAU
		var x := int(size.x * 0.5 + cos(a) * (size.x * 0.5 - 4))
		var y := int(size.y * 0.5 + sin(a) * (size.y * 0.5 - 4))
		for s in 3:
			var hgt := 5 + int(_h(k, s, 15) * 5)
			for t in hgt:
				var px := clampi(x + s - 1 + (1 if t > hgt - 3 and s == 0 else 0), 0, size.x - 1)
				var py := clampi(y - t, 0, size.y - 1)
				img.set_pixel(px, py, Color("#6f8f4e") if t < hgt - 2 else Color("#89a85a"))
			if k % 2 == 0 and s == 1:
				img.set_pixel(clampi(x, 0, size.x - 1), clampi(y - hgt, 0, size.y - 1), Color("#7a4f2e"))
				img.set_pixel(clampi(x, 0, size.x - 1), clampi(y - hgt - 1, 0, size.y - 1), Color("#7a4f2e"))
	_tex[key] = ImageTexture.create_from_image(img)
	return _tex[key]


## Under the creatures: the meadow, the pond, its fish and ripples, the shadow rising in it, the
## shadow on the ground.
static func draw_floor(dg, c: CanvasItem) -> void:
	var g := garden_rect(dg)
	var gr := Rect2(Vector2(g.position * dg.T), Vector2(g.size * dg.T))
	c.draw_texture(_meadow(Vector2i(gr.size)), gr.position)
	var r := Rect2(Vector2(dg.pond.position * dg.T), Vector2(dg.pond.size * dg.T))
	c.draw_texture(_pond(Vector2i(r.size)), r.position)
	var now := Time.get_ticks_msec() / 1000.0
	var pc := r.get_center()
	var fled: bool = dg.intro.get("pond_shadow", 0.0) > 0.2 or dg.intro.has("burst_at")
	# Fish: three dark shapes on slow loops, until something bigger moves below them.
	if not fled:
		for k in 3:
			var t := now * (0.25 + 0.07 * k) + k * 2.1
			var p := pc + Vector2(cos(t) * (40.0 + 18.0 * k), sin(t * 1.3) * (14.0 + 3.0 * k))
			var dir := Vector2(-sin(t), cos(t * 1.3) * 0.4).normalized()
			for i in 5:
				var q := (p - dir * float(i)).round()
				c.draw_rect(Rect2(q, Vector2(2 if i < 3 else 1, 1)), Color(0.04, 0.12, 0.16, 0.55))
	# Slow rings from the lily pads, faint; a strong one when something stirs.
	for k in 3:
		var idle := fmod(now + k * 1.1, 3.3) / 3.3
		var at := pc + Vector2(-60 + k * 55, -8 + 9 * k)
		_ellipse(c, at, 3.0 + idle * 18.0, Color(0.75, 0.88, 0.95, 0.3 * (1.0 - idle)))
	var since: float = (Time.get_ticks_msec() - int(dg.intro.get("ripple_at", -100000))) / 1000.0
	if since < 1.6:
		for k in 2:
			var t := clampf(since / 1.6 - k * 0.25, 0.0, 1.0)
			_ellipse(c, pc, 6.0 + t * 70.0, Color(0.85, 0.95, 1.0, 0.7 * (1.0 - t)))
	var s: float = dg.intro.get("pond_shadow", 0.0)
	if s > 0.0:
		var w := 16.0 + 54.0 * s
		c.draw_set_transform(pc + Vector2(0, 2), 0.0, Vector2(1.0, 0.45))
		c.draw_circle(Vector2.ZERO, w, Color(0.02, 0.05, 0.08, 0.35 + 0.4 * s))
		c.draw_circle(Vector2.ZERO, w * 0.6, Color(0.0, 0.02, 0.04, 0.35 * s))
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var gd: Dictionary = dg.intro.get("ground", {})
	if not gd.is_empty():
		var k: float = gd["k"]
		c.draw_set_transform(gd["pos"] + Vector2(0, -4), 0.0, Vector2(1.0, 0.42))
		c.draw_circle(Vector2.ZERO, 10.0 + 40.0 * k, Color(0, 0, 0, 0.15 + 0.4 * k))
		c.draw_circle(Vector2.ZERO, 6.0 + 24.0 * k, Color(0, 0, 0, 0.2 * k))
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func _ellipse(c: CanvasItem, at: Vector2, rx: float, col: Color) -> void:
	c.draw_set_transform(at, 0.0, Vector2(1.0, 0.42))
	c.draw_arc(Vector2.ZERO, rx, 0.0, TAU, 32, col, 1.0)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Over the creatures: fireflies drifting over the garden (gone once the Warden bursts out), and stars
## circling the dazed team.
static func draw_over(dg, c: CanvasItem) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	if dg.pond.size != Vector2i.ZERO and not dg.intro.has("burst_at"):
		var g := garden_rect(dg)
		var gr := Rect2(Vector2(g.position * dg.T), Vector2(g.size * dg.T))
		for k in FIREFLIES:
			var base := gr.position + Vector2(_h(k, 51, 16), _h(k, 53, 17)) * gr.size
			var p := (base + Vector2(sin(t * 0.6 + k) * 10.0, cos(t * 0.45 + k * 1.7) * 6.0 - 6.0)).round()
			var glow := 0.5 + 0.5 * sin(t * 2.2 + k * 0.9)
			c.draw_rect(Rect2(p - Vector2(1, 1), Vector2(3, 3)), Color(0.85, 1.0, 0.45, 0.18 * glow))
			c.draw_rect(Rect2(p, Vector2(1, 1)), Color(0.95, 1.0, 0.6, 0.5 + 0.5 * glow))
	var em: Dictionary = dg.intro.get("emote", {})
	if not em.is_empty() and (Time.get_ticks_msec() - int(em["at"])) < 1300 and int(em["i"]) < dg.ents.size():
		# A small white bubble with an ink rim and a tail, the mark in red, popping up a pixel at first.
		var age: float = (Time.get_ticks_msec() - int(em["at"])) / 1000.0
		var at: Vector2 = (dg.ents[int(em["i"])]["node"].position + Vector2(6, -44 - (2.0 if age < 0.08 else 0.0))).round()
		c.draw_rect(Rect2(at + Vector2(-1, -1), Vector2(11, 13)), Color("#1a1410"))
		c.draw_rect(Rect2(at, Vector2(9, 11)), Color("#fff4e8"))
		c.draw_rect(Rect2(at + Vector2(1, 11), Vector2(3, 2)), Color("#1a1410"))
		c.draw_rect(Rect2(at + Vector2(2, 11), Vector2(1, 1)), Color("#fff4e8"))
		var red := Color("#d8342c")
		if em["mark"] == "!":
			c.draw_rect(Rect2(at + Vector2(4, 2), Vector2(1, 5)), red)
			c.draw_rect(Rect2(at + Vector2(4, 8), Vector2(1, 1)), red)
		else:
			for p in [Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2), Vector2i(6, 3), Vector2i(6, 4), Vector2i(5, 5), Vector2i(4, 6), Vector2i(4, 8)]:
				c.draw_rect(Rect2(at + Vector2(p), Vector2(1, 1)), red)
	if not dg.intro.get("dazed", false):
		return
	for e in dg.ents:
		if e["team"] != 0 or e["hp"] <= 0:
			continue
		var top: Vector2 = e["node"].position + Vector2(0, -30 if not e.get("down", false) else -16)
		for k in 3:
			var a := t * 4.0 + k * TAU / 3.0
			var p := (top + Vector2(cos(a) * 9.0, sin(a) * 3.0)).round()
			var col := Color("#ffe27a") if sin(a) > 0.0 else Color("#c9a640")
			c.draw_rect(Rect2(p + Vector2(-1, 0), Vector2(3, 1)), col)
			c.draw_rect(Rect2(p + Vector2(0, -1), Vector2(1, 3)), col)
