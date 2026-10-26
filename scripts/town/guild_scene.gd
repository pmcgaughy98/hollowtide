extends RefCounted
## The guild morning in Wayline Hall (Claude, 2026-10-10; Preston: "build the toolkit and guild morning
## scene", after Explorers of Sky's morning line-up). Pilot step 4 (docs/design/pilot-story-2026-10-10.md):
## the partner brings the stray to the Hall. Wayling calls the morning line-up and finds only the two of
## them: every senior runner is out checking the routes the collapse washed out. Starward comes round the
## counter, hears that the partner is not alone any more, and grants one parcel as the entry trial:
## deliver it and you are both runners. Wayling hands over the parcel. The lines are Claude's proposals.
## Plays the first time the team enters the Hall (story "guild_trial" not set). Built on scene_kit.gd.

const SceneKit := preload("res://scripts/town/scene_kit.gd")
const Music := preload("res://scripts/audio/music.gd")

const CALL := [
	["Wayling", "Morning line-up! Runners, fall in!"],
]
const EMPTY := [
	["Wayling", "...Oh. It's only you two. Again."],
	["{partner}", "Wayling, please. We need to see the Postmaster.", "determined"],
	["Wayling", "Every runner is out checking the routes since the bank gave way. The Postmaster is very busy."],
]
const STARWARD_IN := [
	["Starward", "I heard 'please'. Out with it, little one.", "happy"],
	["{partner}", "No one runs a route alone. I know. But I'm not alone anymore.", "determined"],
]
const SIZE_UP := [
	["Starward", "A stray, out of the clay the night the river rose. Hm.", "surprised"],
	["Starward", "The routes are washed out and my Hall is empty. I can spare one parcel. A short run.", "determined"],
	["Starward", "Deliver it, and you are both runners of the Wayline.", "happy"],
]
const HAND_OVER := [
	["Wayling", "To the Old Ferry Landing. Sealed, signed, and don't you dare get it wet."],
	["{partner}", "We won't let you down!", "joyous"],
	["Starward", "Off you go. The river doesn't wait.", "happy"],
]
# When the crew have the parcel the partner saved (story "parcel" = "stolen"; Preston, 2026-10-10).
const EMPTY_STOLEN := [
	["Wayling", "...Oh. It's only you two. Again."],
	["{partner}", "Wayling, please! Gruntle's crew stole a Wayline parcel. We need the Postmaster!", "determined"],
	["Wayling", "Every runner is out checking the routes since the bank gave way. The Postmaster is very busy."],
]
const STARWARD_IN_STOLEN := [
	["Starward", "Gruntle again. I heard. Out with it, little one.", "angry"],
	["{partner}", "I kept one parcel dry through the whole flood, and they took it. And I'm not alone anymore.", "determined"],
]
const SIZE_UP_STOLEN := [
	["Starward", "A stray, out of the clay the night the river rose. Hm.", "surprised"],
	["Starward", "A runner doesn't lose a parcel. A runner gets it back.", "determined"],
	["Starward", "Rootbank Warren. Bring that parcel home, both of you, and you are runners of the Wayline.", "happy"],
]
const SEND_OFF := [
	["Wayling", "The Warren's down through the Mouth, by the Old Ferry Landing. Mind the roots."],   # Claude's proposal, 2026-10-26 (L7-04): the way objective.gd names
	["{partner}", "We'll get it back!", "joyous"],
	["Starward", "Off you go. The river doesn't wait.", "happy"],
]
# Back from Rootbank Warren with the parcel (story "parcel" = "recovered"; Preston, 2026-10-10: Starward
# names them runners). Claude's drafts for Preston.
const BACK_IN := [
	["Wayling", "They're back! And is that... the parcel?"],
	["{partner}", "Rootbank Warren. One parcel, a little chewed, all there.", "joyous"],
]
const NAMED := [
	["Starward", "Gruntle's crew, sent running by a trainee and a stray from the clay.", "surprised"],
	["Starward", "A runner doesn't lose a parcel. A runner gets it back. You did both.", "happy"],
	["Starward", "From today you run for the Wayline. Both of you.", "determined"],
	["Wayling", "Runners! I'll put your names up on the board."],
	["{partner}", "We're runners. We're really runners!", "joyous"],
]
const STARWARD_HOME := Vector2i(11, 2)   # behind the dispatch counter
const STARWARD_MARK := Vector2i(11, 5)   # in front of it, facing the room
const WAYLING_HOME := Vector2i(14, 5)
const WAYLING_MARK := Vector2i(13, 5)
# Where the team stands for the line-up: one open carpet tile each for a team of four, the pair in front and two
# recruits behind them (Claude, 2026-10-26, pass 7 S3 / LF7-08: a fourth member stood on the third's tile). All four
# are open floor in the Hall (checked against town_room's solid tiles); the mini() below is only a guard.
# One row since pass 8 (Claude, 2026-10-26, LH8-03): the recruits a row behind stood under the pair's sprites, so the
# leader and the partner stay in the middle and the recruits stand at the two ends, two tiles out, nobody covered.
const LINE := [Vector2i(10, 8), Vector2i(12, 8), Vector2i(8, 8), Vector2i(14, 8)]
const STEP := 0.2   # seconds a tile for the staged walks (Starward's were 0.3; pass 7 S2 / L7-07)


static func pending(room) -> bool:
	# Not while the partner still holds the parcel saved from the flood: the board scene (its theft) comes first.
	var story: Dictionary = room._record().get("story", {})
	if room.room_id == "hall" and String(story.get("parcel", "")) == "recovered" and not story.get("runner", false):
		return true   # back with the parcel: Starward names them runners
	return room.room_id == "hall" and not story.get("guild_trial", false) and String(story.get("parcel", "")) != "saved"


## The two in their places before the scene starts (called when the Hall is built).
static func place(room) -> void:
	SceneKit.spawn(room, "starward", STARWARD_HOME, "s")
	SceneKit.spawn(room, "wayling", WAYLING_HOME, "w")


static func _npc(room, form: String) -> Dictionary:
	for e in room.npcs:
		if e["form"] == form:
			return e
	return {}


static func run(room) -> void:
	room.cutscene = true
	var stolen := String(room._record().get("story", {}).get("parcel", "")) == "stolen"
	if String(room._record().get("story", {}).get("parcel", "")) == "recovered":
		await _runners(room)
		return
	Music.play(room.get_tree(), "wayline_hall")
	var star := _npc(room, "starward")
	var way := _npc(room, "wayling")
	var lead: Dictionary = room.team[0]
	var partner: Dictionary = room.team[1] if room.team.size() > 1 else lead
	SceneKit.pan(room, room._px(Vector2i(11, 7)), 0.01)
	await SceneKit.wait(room, 0.6)
	# 1. The team walks up into the hall; Wayling hops to its mark and calls the line-up as they come in (the call
	# no longer waits for the last step: Claude, 2026-10-26, pass 7 S2), and they face it once they stand.
	var moves: Array = []
	for k in room.team.size():
		moves.append([room.team[k], LINE[mini(k, LINE.size() - 1)]])
	SceneKit.walk_to(room, way, WAYLING_MARK, 0.18)
	SceneKit.walk_all(room, moves, STEP)   # not awaited: settle() below
	await SceneKit.wait(room, 0.5)
	if not SceneKit._alive(room):
		return   # the room was left (a check's stairs, a door) while the line walked in
	SceneKit.face(room, way, partner)
	SceneKit.emote(room, way, "!")
	await SceneKit.say(room, CALL)
	await SceneKit.settle(room, room.team)
	SceneKit.face_all(room, room.team, way)
	SceneKit.face(room, way, partner)
	# It looks round the empty hall.
	for f in ["w", "e", "w", "s"]:
		way["facing"] = f
		room._place(way)
		await SceneKit.wait(room, 0.35)
	await SceneKit.say(room, EMPTY_STOLEN if stolen else EMPTY)
	if not SceneKit._alive(room):
		return
	# 2. The Guildmaster heard: it comes round the counter to stand before them, talking as it comes (S2: its first
	# line no longer waits for the walk), and faces the partner once there.
	SceneKit.emote(room, star, "!")
	await SceneKit.wait(room, 0.6)
	SceneKit.pan(room, room._px(Vector2i(11, 6)), 0.6)
	SceneKit.walk_to(room, star, STARWARD_MARK, STEP)   # not awaited: settle() below
	var star_in: Array = STARWARD_IN_STOLEN if stolen else STARWARD_IN
	await SceneKit.say(room, star_in.slice(0, 1))
	await SceneKit.settle(room, [star])
	if not SceneKit._alive(room):
		return
	SceneKit.face_all(room, room.team, star)
	SceneKit.face(room, way, star)
	SceneKit.face(room, star, partner)
	await SceneKit.say(room, star_in.slice(1))
	if not SceneKit._alive(room):
		return
	# 3. It looks the stranger over.
	SceneKit.face(room, star, lead)
	SceneKit.emote(room, lead, "!")
	await SceneKit.wait(room, 0.8)
	await SceneKit.say(room, SIZE_UP_STOLEN if stolen else SIZE_UP)
	if not SceneKit._alive(room):
		return
	if stolen:
		# No parcel to hand over: the trial is the one the crew took.
		SceneKit.face(room, way, partner)
		await SceneKit.say(room, SEND_OFF)
		if not SceneKit._alive(room):
			return
		var r: Dictionary = room._record()
		if not r.has("story") or r["story"] == null:
			r["story"] = {}
		r["story"]["guild_trial"] = true   # the trial: bring the stolen parcel back from Rootbank Warren
		SceneKit.walk_to(room, way, WAYLING_HOME, 0.2)
		var stands := _close_up(room)
		await SceneKit.walk_to(room, star, STARWARD_HOME, STEP)
		await _closed(room, stands)
		SceneKit.release(room)
		room.cutscene = false
		return
	# Retired (Claude, 2026-10-22, FLOW-22): the board scene always takes the parcel first, so steps 4 and 5 play only for a record older than the theft.
	# 4. Wayling fetches a parcel from behind the counter and hands it to the partner.
	await SceneKit.walk_to(room, way, Vector2i(14, 2), 0.16)
	room.scene_fx["parcel"] = room._px(way["pos"]) + Vector2(0, -26)
	await SceneKit.walk_to(room, way, partner["pos"] + Vector2i(1, -1), 0.16)
	var from: Vector2 = room._px(way["pos"]) + Vector2(0, -26)
	var to: Vector2 = partner["node"].position + Vector2(0, -30)
	var hop: Tween = room.create_tween()
	hop.tween_method(func(t: float) -> void: room.scene_fx["parcel"] = from.lerp(to, t) + Vector2(0, -10.0 * sin(t * PI)), 0.0, 1.0, 0.35)
	await hop.finished
	if room.has_method("_sfx"):
		room._sfx("pickup")
	SceneKit.face(room, way, partner)
	await SceneKit.say(room, HAND_OVER)
	if not SceneKit._alive(room):
		return
	room.scene_fx.erase("parcel")
	var rec: Dictionary = room._record()
	if not rec.has("story") or rec["story"] == null:
		rec["story"] = {}
	rec["story"]["guild_trial"] = true      # the entry trial is given: one parcel to the Old Ferry Landing
	rec["story"]["parcel"] = "carried"
	# 5. The two go back to their posts; the team closes up behind the leader and is free.
	SceneKit.walk_to(room, way, WAYLING_HOME, 0.2)
	var stands := _close_up(room)
	await SceneKit.walk_to(room, star, STARWARD_HOME, STEP)
	await _closed(room, stands)
	SceneKit.release(room)
	room.cutscene = false


## The team closes up behind the leader as a scene ends (Claude, 2026-10-26, pass 8 R1 / L01): the line-up stood the
## recruits two tiles from the pair, so the first step after the scene pulled them across the carpet in one jump.
## Members 1 to 3 start walking to the tiles a team arriving on the leader's tile would stand on (town_room.gd
## trail_tiles); the tiles are returned for _closed, which waits for the walks and sets anyone held up on its tile.
static func _close_up(room) -> Array:
	var stands: Array = room.trail_tiles(String(room.team[0]["facing"]))
	for k in range(1, mini(room.team.size(), stands.size())):
		if room.team[k]["pos"] != stands[k]:
			SceneKit.walk_to(room, room.team[k], stands[k], STEP)
	return stands


static func _closed(room, stands: Array) -> void:
	await SceneKit.settle(room, room.team)
	if SceneKit._alive(room):
		room.respace(String(room.team[0]["facing"]), stands)


## Back from Rootbank Warren: the team walks up, the Guildmaster comes round the desk, the partner hands the
## parcel over, and the two are named runners of the Wayline (story "runner" = true, "parcel" = "delivered").
static func _runners(room) -> void:
	Music.play(room.get_tree(), "wayline_hall")
	var star := _npc(room, "starward")
	var way := _npc(room, "wayling")
	var lead: Dictionary = room.team[0]
	var partner: Dictionary = room.team[1] if room.team.size() > 1 else lead
	SceneKit.pan(room, room._px(Vector2i(11, 7)), 0.01)
	await SceneKit.wait(room, 0.6)
	var moves: Array = []
	for k in room.team.size():
		moves.append([room.team[k], LINE[mini(k, LINE.size() - 1)]])
	SceneKit.walk_to(room, way, WAYLING_MARK, 0.18)
	await SceneKit.walk_all(room, moves, STEP)   # awaited: the parcel is held up where the partner stands
	SceneKit.face_all(room, room.team, way)
	SceneKit.face(room, way, partner)
	SceneKit.emote(room, way, "!")
	room.scene_fx["parcel"] = partner["node"].position + Vector2(0, -30)   # held up for the Hall to see
	await SceneKit.wait(room, 0.5)
	await SceneKit.say(room, BACK_IN)
	if not SceneKit._alive(room):
		return
	SceneKit.emote(room, star, "!")
	SceneKit.pan(room, room._px(Vector2i(11, 6)), 0.6)
	await SceneKit.walk_to(room, star, STARWARD_MARK, STEP)
	SceneKit.face_all(room, room.team, star)
	SceneKit.face(room, way, star)
	SceneKit.face(room, star, partner)
	# The parcel goes to the Guildmaster.
	var from: Vector2 = room.scene_fx["parcel"]
	var to: Vector2 = star["node"].position + Vector2(0, -40)
	var hop: Tween = room.create_tween()
	hop.tween_method(func(t: float) -> void: room.scene_fx["parcel"] = from.lerp(to, t) + Vector2(0, -12.0 * sin(t * PI)), 0.0, 1.0, 0.4)
	await hop.finished
	if room.has_method("_sfx"):
		room._sfx("pickup")
	Music.jingle(room.get_tree(), "runners_named")   # the runners' fanfare (ElevenLabs, 2026-10-11)
	await SceneKit.say(room, NAMED)
	if not SceneKit._alive(room):
		return
	room.scene_fx.erase("parcel")
	var rec: Dictionary = room._record()
	if not rec.has("story") or rec["story"] == null:
		rec["story"] = {}
	rec["story"]["guild_trial"] = true
	rec["story"]["runner"] = true          # runners of the Wayline
	rec["story"]["parcel"] = "delivered"
	SceneKit.walk_to(room, way, WAYLING_HOME, 0.2)
	var stands := _close_up(room)
	await SceneKit.walk_to(room, star, STARWARD_HOME, STEP)
	await _closed(room, stands)
	SceneKit.release(room)
	room.cutscene = false
