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
# Lines rewritten 2026-10-11 in the house voice (docs/design/dialogue-voice-guide.md). Claude's drafts.
const OPEN := [
	["{partner}", "Would you look at this. Flowers? Clear down here?", "joyous"],
	["{partner}", "C'mon, let's go sit by the water a minute. My feet are killing me.", "happy"],
]
# At the water's edge, looking at their reflections (Preston, 2026-10-11).
const REFLECT := [["{partner}", "Ha. Look at us. We look like we got drug through the creek backwards.", "happy"]]
const NOTICE := [["{partner}", "...Hang on. Did the water just move?", "surprised"]]
const VOICE := [
	["???", "Safe. Everything that wanders down here says so."],
	["???", "They drink. They sleep by the water. They forget to leave."],
	["{partner}", "Okay, who said that? That's not funny.", "surprised"],
	["???", "You are standing in my garden. Mind your noise."],
]
const AFTER := [
	["{boss}", "This water is mine. Every reed, every ripple, every creature that rests here.", "determined"],
	["{boss}", "Listeners. Hold them where they stand.", "determined"],
	["{partner}", "{leader}... yeah, no. We are not resting here. Come on!", "angry"],
	["{boss}", "Rest, then. The pond will keep you.", "happy"],
]
const WALK_STEPS := 3          # tiles the team walks in before the voice starts (it stops just below the meadow)
const POND := Vector2i(13, 4)   # the pond in tiles, centred one row below the stairs (grown 2026-10-11)
const LAND_ROW := 9            # the Warden lands this many tiles below the stairs, clear of the shore: its back reaches about three tiles up (Preston: its rear touched the water; 2026-10-11 the pond grew, and he wants it and its Listeners to land on dry ground)
const KNOCK_ROWS := 6          # the burst throws the team this far back from the shore, past where the Warden lands
const FIREFLIES := 14


## Lay out the room for the scene: the Warden and its Listeners hidden until they appear.
## Called by _build_floor on the boss floor, after _place_boss.
static func setup(dg) -> void:
	dg.cutscene = true
	dg.intro = {"t0": Time.get_ticks_msec(), "pond_shadow": 0.0, "ground": {}, "dazed": false}
	_aim = null
	# The team side by side before the first frame (Claude, 2026-10-26, pass 8 S4, L08): in a file, the partner walked in
	# a tile behind the leader and spoke its first line from behind the text box.
	line_up(dg)
	for e in dg.ents:
		if e.get("boss", false) or e.get("minion", false):
			e["hidden"] = true
			e["node"].visible = false


## The pond: centred under the stairs. Its tiles do not walk (dungeon._floor_at).
static func pond_rect(stairs: Vector2i) -> Rect2i:
	return Rect2i(stairs + Vector2i(-POND.x / 2, 1), POND)


## The garden: the whole room (Preston, 2026-10-11: the Warden calls it a garden, but the meadow was a small
## patch and the scene showed mostly stone). Decoration only, it walks like any floor.
static func garden_rect(dg) -> Rect2i:
	return dg.data["rooms"][0] if dg.data.has("rooms") and not dg.data["rooms"].is_empty() else Rect2i(dg.pond.position - Vector2i(3, 1), dg.pond.size + Vector2i(6, 3))


## The stepping stones from where the team walks in up to the pond's near shore, in garden pixels.
static func _path(dg) -> PackedVector2Array:
	var g := garden_rect(dg)
	var start: Vector2i = dg.data.get("start", Vector2i(g.position.x + g.size.x / 2, g.end.y - 2))
	var x := float((start.x - g.position.x) * dg.T + dg.T / 2)
	var y0 := float((dg.pond.end.y - g.position.y) * dg.T + 6)
	var y1 := float((start.y - g.position.y) * dg.T + dg.T)
	var pts := PackedVector2Array()
	var y := y1
	var k := 0
	while y > y0:
		pts.append(Vector2(x + sin(k * 1.7) * 5.0, y))
		y -= 15.0
		k += 1
	return pts


static func pond_center(dg) -> Vector2:
	return Vector2(dg.pond.position * dg.T) + Vector2(dg.pond.size * dg.T) * 0.5


## The scene stops quietly if the floor is left or freed while it plays (the checks free it).
static func _alive(dg) -> bool:
	return is_instance_valid(dg) and dg.is_inside_tree()


static func _wait(dg, s: float) -> void:
	if _alive(dg):
		await dg.get_tree().create_timer(s, false).timeout


## Pan the camera from where it looks now to `to` over `s` seconds. A new pan replaces one still under way (pass 8 S4:
## two pans at once pulled the camera between them).
static func _pan(dg, to: Vector2, s: float) -> void:
	if not _alive(dg):
		return
	if _pan_tw != null and _pan_tw.is_valid():
		_pan_tw.kill()
	_aim = to
	var from: Vector2 = dg.cam_focus if dg.cam_focus is Vector2 else dg.ents[0]["node"].position
	var tw: Tween = dg.create_tween()
	tw.tween_method(func(v: Vector2) -> void: dg.cam_focus = v, from, to, s).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_pan_tw = tw


# ---------------------------------------------------------------- framing a line (pass 8 S4)

## Claude, 2026-10-26 (pass 8 S4, L08 and L26): a scene's line showed its speaker behind the text box or a teammate
## cut by the bottom cinema bar (the crew's partner, the team under the Warden). In the view's pixels (384 x 216, at
## 3x): the bars cover 0 to 18 and 198 to 216, a line's text box 149 to 187 and its name plate from 141 (dungeon.gd
## _draw_hud, UI.dialogue).
const SHOT_HEAD := 26.0   # a speaker's head stays under the top bar, with a little air
const SHOT_FOOT := 173.0  # every teammate's feet at least one tile above the bottom bar (174), a pixel spare for rounding
const SHOT_BOX := 140.0   # the leader's and the speakers' feet above the text box and its name plate (141), when there is room
const SHOT_TOP := 18.0    # the top bar's foot
const SHOT_SHOWN := 0.65  # at least this much of a speaker's height shows under the top bar
const SHOT_SIDE := 40.0   # the leader and the speakers no nearer a side than this
static var _aim: Variant = null   # where the last pan was headed, before any line moved it
static var _pan_tw: Tween


## Where the camera looks to show `aim` with the shot kept, as near aim as it can. In order, each rule over the ones
## before it: the speakers' and the leader's feet above the text box when there is room; the speakers' heads under the
## top bar; the leader above the text box whatever happens to a tall speaker's head; SHOT_SHOWN of each speaker's
## height still under the top bar; and before everything, every teammate's feet a tile above the bottom bar. So
## the Warden standing three rows over the team loses the top of its crest to the bar, never the leader to the text
## box or a teammate to the bottom bar. The scenes bring the team close first (line_up, gather, the walk to the
## shore). cam_offset still holds the view inside the map.
static func shot(dg, aim: Vector2, who: Array = []) -> Vector2:
	var half := Vector2(dg.VIEW) * 0.5
	var cast: Array = [dg.ents[0]]
	for e in who:
		if e is Dictionary and e.has("node") and is_instance_valid(e["node"]) and e["node"].visible and not cast.has(e):
			cast.append(e)
	var head := INF
	var feet := -INF
	var high := INF   # the highest a speaker's feet may sit in the view, as a world y less the view's top
	var left := INF
	var right := -INF
	for e in cast:
		var p: Vector2 = e["node"].position
		head = minf(head, p.y + dg._head_y(e))
		feet = maxf(feet, p.y)
		if not is_same(e, cast[0]):
			high = minf(high, p.y - SHOT_TOP + SHOT_SHOWN * dg._head_y(e))
		left = minf(left, p.x)
		right = maxf(right, p.x)
	var lead_y: float = dg.ents[0]["node"].position.y
	var low := lead_y   # the team alone: a speaker who is not in it may stand lower
	for e in _team(dg):
		low = maxf(low, e["node"].position.y)
	var y := maxf(aim.y, feet - SHOT_BOX + half.y)   # the speakers' and the leader's feet above the text box, if room
	y = minf(y, head - SHOT_HEAD + half.y)           # their heads under the top bar
	y = maxf(y, lead_y - SHOT_BOX + half.y)          # the leader above the text box
	if high < INF:
		y = minf(y, high + half.y)                   # most of each speaker still in sight
	y = maxf(y, low - SHOT_FOOT + half.y)            # and before all of it, no teammate under the bottom bar
	var x := (left + right) * 0.5
	if right - left <= dg.VIEW.x - 2.0 * SHOT_SIDE:
		x = clampf(aim.x, right - half.x + SHOT_SIDE, left + half.x - SHOT_SIDE)
	return Vector2(x, y)


## The camera to `aim` with the shot kept (`who` speaks next), over `s` seconds; at once when `s` is 0.
static func frame(dg, aim: Vector2, s: float, who: Array = []) -> void:
	if not _alive(dg):
		return
	var to := shot(dg, aim, who)
	if s <= 0.0:
		if _pan_tw != null and _pan_tw.is_valid():
			_pan_tw.kill()
		dg.cam_focus = to
	else:
		_pan(dg, to, s)
	_aim = aim


## Before a beat of lines: keep the camera where the scene aimed it, moved only as far as the shot needs for these
## speakers and the team where they stand now.
static func reframe(dg, who: Array, s := 0.45) -> void:
	if not _alive(dg) or dg.ents.is_empty():
		return
	var aim: Vector2 = _aim if _aim is Vector2 else (dg.cam_focus if dg.cam_focus is Vector2 else dg.ents[0]["node"].position + Vector2(0, -12))
	var to := shot(dg, aim, who)
	var now: Vector2 = dg.cam_focus if dg.cam_focus is Vector2 else to + Vector2(0, 99)
	if now.distance_to(to) > 1.0:
		_pan(dg, to, s)
	_aim = aim


## Wait until the queued lines are read (J, or the checks' autopilot), framing each line's speaker with the leader as
## the line comes up (pass 8 S4): a beat's speakers can stand further apart than one frame holds, as Starward behind
## the team and the Warden over it do, so the camera turns to whoever is talking. `extra` names a speaker who is not in
## the dungeon's list, by the name its lines carry.
static func read_lines(dg, extra := {}) -> void:
	var cur: Variant = null
	while _alive(dg) and not dg.talk.is_empty():
		if not is_same(dg.talk[0], cur):
			cur = dg.talk[0]
			reframe(dg, [_named(dg, String(cur[0]), extra)])
		await dg.get_tree().process_frame


## The creature in the room called `who` (or in `extra`); empty for an unseen voice.
static func _named(dg, who: String, extra := {}) -> Dictionary:
	if extra.has(who):
		return extra[who]
	for e in dg.ents:
		if String(e["name"]) == who and e["hp"] > 0:
			return e
	return {}


## The team in a row across the leader's tile (`up` rows further up where the floor is open): the partner on its
## right, then its left, then two out. Placed, not walked: a scene calls it before its first frame shows.
static func line_up(dg, up := 0) -> void:
	var lead: Dictionary = dg.ents[0]
	for k in up:
		var to: Vector2i = lead["pos"] + Vector2i(0, -1)
		if not dg._floor_at(to) or dg._occupant(to) >= 0:
			break
		lead["pos"] = to
	lead["node"].position = dg._tile_px(lead["pos"])
	var sides := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(2, 0), Vector2i(-2, 0), Vector2i(1, 1), Vector2i(-1, 1)]
	var n := 0
	for e in _team(dg):
		if is_same(e, lead):
			continue
		for k in range(n, sides.size()):
			var to: Vector2i = lead["pos"] + sides[k]
			var who: int = dg._occupant(to)
			if dg._floor_at(to) and (who < 0 or is_same(dg.ents[who], e)):
				e["pos"] = to
				e["node"].position = dg._tile_px(to)
				n = k + 1
				break


## Each teammate walks to a free tile beside the leader (pass 8 S4): a scene that starts mid-fight gathers its team
## so no one is left off the frame or under the bottom bar. Returns once they have all arrived.
static func gather(dg) -> void:
	var lead: Dictionary = dg.ents[0]
	var sides := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(1, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(2, 0), Vector2i(-2, 0)]
	var taken := {lead["pos"]: true}
	var going: Array = []
	for e in _team(dg):
		if is_same(e, lead):
			continue
		if dg._cheb(e["pos"], lead["pos"]) <= 1 and not taken.has(e["pos"]):
			taken[e["pos"]] = true
			continue
		for d in sides:
			var to: Vector2i = lead["pos"] + d
			var who: int = dg._occupant(to)
			if not taken.has(to) and dg._floor_at(to) and (who < 0 or is_same(dg.ents[who], e)):
				taken[to] = true
				going.append(e)
				_walk_to(dg, e, to)
				break
	var guard := 0
	while _alive(dg) and going.any(func(e: Dictionary) -> bool: return e.get("walking", false)) and guard < 60:
		await _wait(dg, 0.1)
		guard += 1


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
	await read_lines(dg)   # each speaker and the leader in the shot, the team above the bottom bar (S4)


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
	p.bus = &"SFX"   # Claude, 2026-10-22 (FEEL-08): the pond bed rides the SFX slider, never Master
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


## Walk one teammate tile by tile to `to` (across, then up), facing the way it goes.
static func _walk_to(dg, e: Dictionary, to: Vector2i) -> void:
	e["walking"] = true
	var guard := 0
	while _alive(dg) and is_instance_valid(e["node"]) and e["pos"] != to and guard < 40:
		guard += 1
		# A blow's lunge finishes first (integrator, 2026-10-26, pass 8): _slide kills the creature's tween, and
		# use_move waits on that lunge. The crew's den gathers the team in the frame its boss falls, often to the
		# partner whose blow felled it, and a killed tween never finishes: the turn hung with busy set
		# (dungeon_evolve_check's autopilot stalled in the den, 0 runs in 900 s).
		var settle := 0
		while _alive(dg) and is_instance_valid(e["node"]) and e.get("tw") is Tween and e["tw"].is_valid() and e["tw"].is_running() and settle < 30:
			await dg.get_tree().process_frame
			settle += 1
		if not (_alive(dg) and is_instance_valid(e["node"])):
			break   # the floor was left or rebuilt while it walked
		var d: Vector2i = Vector2i(signi(to.x - e["pos"].x), 0) if e["pos"].x != to.x else Vector2i(0, signi(to.y - e["pos"].y))
		var nxt: Vector2i = e["pos"] + d
		var who: int = dg._occupant(nxt)
		# The Warden and its Listeners wait hidden on their landing tiles; the team walks through them.
		if dg._floor_at(nxt) and (who < 0 or dg.ents[who].get("hidden", false)):
			e["pos"] = nxt
			e["facing"] = dg._facing_of(d)
			e["walk_t"] = dg.STEP_TIME * 2.0
			dg._slide(e, dg._tile_px(nxt))
		await _wait(dg, 0.3)
	e["walking"] = false


## The burst throws the whole team back from the water, `rows` tiles, skidding to a stop.
static func _knock_back(dg, rows: int) -> void:
	for e in _team(dg):
		var to: Vector2i = e["pos"]
		for k in rows:
			var nxt: Vector2i = to + Vector2i(0, 1)
			var who: int = dg._occupant(nxt)
			if not dg._floor_at(nxt) or (who >= 0 and not dg.ents[who].get("hidden", false)):
				break
			to = nxt
		e["pos"] = to
		if e.get("tw") is Tween and e["tw"].is_valid():
			e["tw"].kill()
		var tw: Tween = dg.create_tween()
		tw.tween_property(e["node"], "position", dg._tile_px(to), 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		e["tw"] = tw


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
	# 2. Down to the water's edge, side by side, and a look at themselves in it (their reflections are
	# drawn in the pond, draw_floor).
	var shore: int = dg.pond.end.y
	var cx: int = dg.pond.position.x + dg.pond.size.x / 2
	var team := _team(dg)
	var spots := [Vector2i(cx, shore), Vector2i(cx + 1, shore), Vector2i(cx - 1, shore)]
	_pan(dg, Vector2((cx + 0.5) * dg.T, shore * dg.T + 2), 2.2)   # the team just above the text box, the pond filling the frame above them
	for k in team.size():
		_walk_to(dg, team[k], spots[mini(k, spots.size() - 1)])
	var guard := 0
	while _alive(dg) and team.any(func(e: Dictionary) -> bool: return e.get("walking", false)) and guard < 80:
		await _wait(dg, 0.1)
		guard += 1
	if not _alive(dg):
		return
	for e in team:
		e["facing"] = "n"
		dg._set_tex(e, e["art"]["still"]["n"])
	await _wait(dg, 1.0)
	await _lines(dg, REFLECT)
	if not _alive(dg):
		return
	await _wait(dg, 0.6)
	# 3. A ripple breaks the reflections; a "!" over the partner, who noticed.
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
	dg._play("res://assets/audio/sfx/ui/hit_strong.wav", -6.0, &"SFX")
	_ambience_fade(dg, -80.0, 0.3)
	for k in 3:
		dg._burst(pc, Color("#cfe9f5"), 26, 150.0, 1.1, 260.0, 2.0)
	for k in 70:   # a column of water thrown straight up where it left the pond
		dg._parts.append({"pos": pc + Vector2(randf_range(-16, 16), randf_range(-4, 4)), "vel": Vector2(randf_range(-38, 38), -randf_range(220, 420)),
			"t": -randf() * 0.12, "life": randf_range(0.9, 1.4), "col": Color("#e6f4fb").lerp(Color("#7fb3cc"), randf() * 0.6), "size": randf_range(1.5, 3.0), "grav": 420.0})
	dg._ring(pc, Color("#cfe9f5"), 90.0, 0.6)
	for e in _team(dg):
		e["down"] = true
	_knock_back(dg, KNOCK_ROWS)
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
		# Each faces the way it hops, so the two mirror each other (Preston, 2026-10-11).
		e["facing"] = "sw" if to.x < pc.x else "se"
		dg._set_tex(e, e["art"]["still"][e["facing"]])
		e["node"].visible = true
		dg._burst(from, Color("#cfe9f5"), 12, 70.0, 0.6, 200.0, 1.0)
		dg._sfx("hop_splash", -3.0)
		var hop: Tween = dg.create_tween()
		hop.tween_method(func(t: float) -> void: e["node"].position = from.lerp(to, t) + Vector2(0, -38.0 * sin(t * PI)), 0.0, 1.0, 0.42)
		await hop.finished
		if not _alive(dg):
			return
		dg._place(e)
		# Landed: it turns to face the team, ready to fight (Preston: not looking away from the enemy).
		var lead: Vector2i = _team(dg)[0]["pos"] if not _team(dg).is_empty() else e["pos"] + Vector2i(0, 1)
		e["facing"] = dg._facing_of((lead - e["pos"]).clamp(Vector2i(-1, -1), Vector2i(1, 1)))
		dg._set_tex(e, e["art"]["still"][e["facing"]])
		await _wait(dg, 0.15)
	await _wait(dg, 0.4)
	if not _alive(dg):
		return
	# 9. The talk, then the fight. The camera holds on the Warden; the team stands under the box.
	frame(dg, land + Vector2(0, -2), 0.5, [b])   # the Listeners at its flanks stay above the text box; the team above the bar (S4)
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
	_aim = null
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
static func _blob(x: int, y: int, size: Vector2i, wob: float, power := 2.2) -> float:
	var dx := (x + 0.5 - size.x * 0.5) / (size.x * 0.5 - 1.0)
	var dy := (y + 0.5 - size.y * 0.5) / (size.y * 0.5 - 1.0)
	var w := wob * (sin(x * 0.21 + y * 0.05) + 0.7 * sin(y * 0.33 + x * 0.09) + 0.5 * sin(x * 0.53))
	return pow(absf(dx), power) + pow(absf(dy), power) + w


## The garden floor: grass in broad light and dark patches, tall grass clumps, flower beds, round bushes
## along the walls, a few mossy stones, and stepping stones up to the pond. Its edge breaks up into the
## room's stone only at the walls.
static func _meadow(size: Vector2i, path: PackedVector2Array = PackedVector2Array()) -> Texture2D:
	var key := "meadow%s%d" % [size, path.size()]
	if _tex.has(key):
		return _tex[key]
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	var greens := [Color("#4d6b34"), Color("#57783a"), Color("#628543"), Color("#3f5a2c")]
	var flowers := [Color("#f2a7c3"), Color("#fff4e8"), Color("#f2d16b"), Color("#b9a3e8"), Color("#e8735a")]
	for y in size.y:
		for x in size.x:
			var d := _blob(x, y, size, 0.02, 5.0)
			if d > 1.0:
				continue
			var n := _h(x / 2, y / 2)
			var c: Color = greens[int(n * 3.0)]
			var patch := sin(x * 0.045 + y * 0.02) + sin(y * 0.06 - x * 0.015) * 0.8   # broad light and shade
			if patch > 1.1:
				c = c.lightened(0.07)
			elif patch < -1.1:
				c = c.darkened(0.1)
			if _h(x, y, 1) > 0.93:
				c = greens[3]   # a dark tuft
			var a := 1.0 if d < 0.9 else clampf((1.0 - d) / 0.1, 0.0, 1.0)
			if a < 1.0 and _h(x, y, 2) > a:
				continue   # the edge breaks up into the floor instead of fading
			img.set_pixel(x, y, c)
	var inside := func(x: int, y: int, lim: float) -> bool:
		return x >= 2 and y >= 2 and x < size.x - 2 and y < size.y - 2 and _blob(x, y, size, 0.02, 5.0) < lim
	# Stepping stones up to the pond.
	for q in path:
		var cx := int(q.x)
		var cy := int(q.y)
		for yy in range(-3, 4):
			for xx in range(-6, 7):
				if xx * xx + yy * yy * 4 <= 36 and inside.call(cx + xx, cy + yy, 1.0):
					var edge := xx * xx + yy * yy * 4 > 24
					img.set_pixel(cx + xx, cy + yy, Color("#4a473e") if edge else (Color("#9a968a") if yy < 0 else Color("#7d7a6c")))
		img.set_pixel(cx - 3, cy - 2, Color("#6f8f4e"))
		img.set_pixel(cx + 2, cy + 2, Color("#6f8f4e"))
	var on_path := func(x: int, y: int) -> bool:
		for q in path:
			if absf(q.x - x) < 12 and absf(q.y - y) < 9:
				return true
		return false
	# Tall grass clumps: a fan of blades, dark at the root, light at the tips.
	for k in int(size.x * size.y / 900):
		var x := int(_h(k, 21, 7) * (size.x - 10)) + 5
		var y := int(_h(k, 23, 8) * (size.y - 12)) + 8
		if not inside.call(x, y, 0.9) or on_path.call(x, y):
			continue
		for b in 5:
			var bx := x - 4 + b * 2
			var tall := 5 + int(_h(k, b, 9) * 4)
			for t in tall:
				var lean := int(float(t) / tall * (b - 2) * 0.8)
				img.set_pixel(bx + lean, y - t, Color("#3f5a2c") if t < tall / 2 else Color("#7da04f"))
	# Flower beds: clusters of one or two colours.
	for k in int(size.x * size.y / 6000) + 4:
		var cx := int(_h(k, 31, 10) * (size.x - 40)) + 20
		var cy := int(_h(k, 37, 11) * (size.y - 40)) + 20
		if not inside.call(cx, cy, 0.8) or on_path.call(cx, cy):
			continue
		var c1: Color = flowers[k % flowers.size()]
		var c2: Color = flowers[(k + 2) % flowers.size()]
		for f in 14:
			var x := cx + int((_h(k, f, 12) - 0.5) * 22)
			var y := cy + int((_h(f, k, 13) - 0.5) * 14)
			if not inside.call(x, y, 0.9):
				continue
			var col := c1 if f % 3 != 0 else c2
			img.set_pixel(x, y + 2, Color("#2f4a24"))   # its stem
			for o in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				img.set_pixel(x + o.x, y + o.y, col)
			img.set_pixel(x, y, Color("#e8b84a") if col != flowers[2] else Color("#c9772e"))
	# Single flowers scattered between the beds.
	for k in int(size.x * size.y / 500):
		var x := int(_h(k, 3, 3) * (size.x - 6)) + 3
		var y := int(_h(k, 7, 4) * (size.y - 6)) + 3
		if not inside.call(x, y, 0.85) or on_path.call(x, y):
			continue
		var col: Color = flowers[k % flowers.size()]
		for o in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			img.set_pixel(x + o.x, y + o.y, col)
		img.set_pixel(x, y, Color("#e8b84a"))
	# Round bushes along the walls, some in blossom.
	for k in 14:
		var ang := _h(k, 41, 14) * TAU
		var cx := int(size.x * 0.5 + cos(ang) * size.x * 0.42)
		var cy := int(size.y * 0.5 + sin(ang) * size.y * 0.40)
		if not inside.call(cx, cy, 0.97) or on_path.call(cx, cy):
			continue
		var r := 7 + int(_h(k, 43, 15) * 4)
		for yy in range(-r, r + 1):
			for xx in range(-r - 2, r + 3):
				var dd := float(xx * xx) / float((r + 2) * (r + 2)) + float(yy * yy) / float(r * r)
				if dd > 1.0 or not inside.call(cx + xx, cy + yy, 1.0):
					continue
				var col := Color("#2c4220") if dd > 0.78 else (Color("#6f9a45") if xx + yy < -r * 0.6 else Color("#4e7332"))
				if dd <= 0.78 and _h(cx + xx, cy + yy, 16) > 0.9:
					col = Color("#3f5a2c")
				img.set_pixel(cx + xx, cy + yy, col)
		if k % 3 == 0:
			for f in 5:
				img.set_pixel(cx + int((_h(k, f, 17) - 0.5) * r * 1.6), cy + int((_h(f, k, 18) - 0.6) * r * 1.2), Color("#f2a7c3"))
	# Mossy stones.
	for k in 4:
		var x := int(_h(k, 11, 5) * (size.x - 12)) + 6
		var y := int(_h(k, 13, 6) * (size.y - 10)) + 5
		if not inside.call(x, y, 0.8) or on_path.call(x, y):
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
	c.draw_texture(_meadow(Vector2i(gr.size), _path(dg)), gr.position)
	var r := Rect2(Vector2(dg.pond.position * dg.T), Vector2(dg.pond.size * dg.T))
	c.draw_texture(_pond(Vector2i(r.size)), r.position)
	var now := Time.get_ticks_msec() / 1000.0
	var pc := r.get_center()
	var fled: bool = dg.intro.get("pond_shadow", 0.0) > 0.2 or dg.intro.has("burst_at")
	# Reflections: a teammate standing at the water's edge shows in it upside down, faces toward you
	# (Preston, 2026-10-11: they walk up and look at their reflection). A ripple breaks them up.
	if not fled:
		var stir: float = clampf(1.0 - (Time.get_ticks_msec() - int(dg.intro.get("ripple_at", -100000))) / 1600.0, 0.0, 1.0)
		for e in _team(dg):
			if e["pos"].y != dg.pond.end.y or e["pos"].x < dg.pond.position.x + 1 or e["pos"].x >= dg.pond.end.x - 1:
				continue
			var spr: Sprite2D = e["sprite"]
			var tex: Texture2D = e["art"]["still"].get("s", spr.texture) if e["facing"] == "n" else spr.texture
			var foot: float = e["art"]["foot"].get(tex, float(tex.get_height()))
			var at := Vector2(e["node"].position.x + sin(now * 2.0 + e["pos"].x) * (0.6 + 4.0 * stir), r.end.y - 3)
			c.draw_set_transform(at, 0.0, Vector2(-spr.scale.x, spr.scale.y * (0.85 - 0.15 * stir)))   # looking down into it: the face, mirrored, rising from the near shore
			c.draw_texture(tex, Vector2(-tex.get_width() * 0.5, -foot), Color(0.62, 0.8, 0.95, 0.42 * (1.0 - 0.6 * stir)))
			c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
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
