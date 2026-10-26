extends RefCounted
## The Wayline Hall's crew in their rooms, and the morning mail call (Claude, 2026-10-11; Preston approved the crew,
## docs/creatures/guild-crew-2026-10-11.md, and asked for the lower floor). Built on scene_kit.gd.
##
## Outside scenes each crew member stands at their post and says a line when the leader talks to them (E).
## The mail call plays on the Hall's lower floor once before each run, after the Wayline has taken the team on
## (R3 of docs/design/genre-synthesis-2026-10-12.md, 2026-10-12: parcel sorting in our own shape, not a briefing
## with a cheer). Wayling has the morning's mail on the table by the mark; the crew gather round; Wayling calls
## routes, not names, and whoever runs that route claims it. Muskin is late as ever and gets the route nobody
## wants. The runners get no route from the table: theirs comes from the Postmaster, who comes out with the
## morning's note. Then everyone peels off to work. The lines are Claude's drafts for Preston, in the house voice
## (docs/design/dialogue-voice-guide.md). Rinsepaw the cook keeps the kitchen hatch (sprites made 2026-10-11).

const SceneKit := preload("res://scripts/town/scene_kit.gd")
const TeamState := preload("res://scripts/town/team_state.gd")

# Where each one works, by room: [form, tile, facing].
const POSTS := {
	"hall": [["grubbit", Vector2i(17, 11), "w"], ["wayling", Vector2i(14, 5), "s"]],
	"hall_low": [["stillwade", Vector2i(4, 3), "s"], ["wickglow", Vector2i(11, 3), "s"],
		["muskin", Vector2i(6, 11), "s"], ["slipjaw", Vector2i(2, 7), "e"], ["rinsepaw", Vector2i(2, 10), "s"]],
}

## What each says at their post. Slipjaw changes his tune once the team are runners.
static func lines_for(form: String, story: Dictionary) -> Array:
	match form:
		"wayling":
			if story.get("runner", false):
				return [["Wayling", "Runners! Jobs go up on the board outside. Bring me the slip when you're done, and don't fold it."]]
			return [["Wayling", "The Postmaster's downstairs. Mind the third step, it squeaks."]]
		"grubbit":
			return [["Grubbit", "...Oh! You walked right up on me.", "surprised"], ["Grubbit", "Parcel for the bend, parcel for Highbank... I go by feel down here. Never misread one yet.", "happy"]]
		"stillwade":
			return [["Stillwade", "River's up two notches since sunup.", "worried"], ["Stillwade", "Not flood-up. Just... thinking about it.", "determined"]]
		"wickglow":
			return [["Wickglow", "Did you hear? Somebody saw Gruntle's bunch sneaking round the Warren again.", "mischievous"], ["Wickglow", "Don't tell Wayling I told you. Actually, tell everybody.", "happy"]]
		"muskin":
			return [["Muskin", "Am I late? I'm late. I'm always late.", "worried"], ["Muskin", "Wait. Are you guys late too? Oh good.", "surprised"]]
		"rinsepaw":
			return [["Rinsepaw", "Supper's at sundown, hon. Late gets what's left.", "happy"], ["Rinsepaw", "And Muskin's always late, so there's never much left. You two eat.", "sad"]]
		"slipjaw":
			if story.get("runner", false):
				return [["Slipjaw", "Fine. You're runners. Doesn't mean you're faster than me.", "angry"]]
			return [["Slipjaw", "You two? Runners? Ha. We'll see who gets there first.", "determined"]]
	return []


## Who a room may show once the Wayline has taken the team on (Claude, 2026-10-24, pass 6 / L6-15), for
## SceneKit.read_ahead under the door's fade: the crew at their posts, on the lower floor the whole mail call, and
## the Postmaster in the chamber.
static func cast_of(room_id: String) -> Array:
	var out: Array = []
	for p in POSTS.get(room_id, []):
		out.append(p[0])
	if room_id == "hall_low":
		out.append_array(["wayling", "muskin", "starward"])
	elif room_id == "chamber":
		out.append("starward")   # at the dais once the trial is set (town_room.gd)
	return out


## The crew at their posts in this room (not during the mail call, not while a guild scene owns the room).
static func place(room) -> void:
	var story: Dictionary = room._record().get("story", {})
	if not story.get("guild_trial", false):
		return   # before the guild takes the team on, the Hall is the guild scenes' stage
	for p in POSTS.get(room.room_id, []):
		var e: Dictionary = SceneKit.spawn(room, p[0], p[1], p[2])
		e["lines"] = lines_for(p[0], story)


# ---------------------------------------------------------------- the mail call

const MARK := Vector2i(14, 9)
const CALLER := Vector2i(14, 6)                 # Wayling at the sorting table, in front of the mark, facing the room
# The crew stand just off the rug's two long sides, one tile out from where they stood until 2026-10-24 (Claude,
# pass 5 RM7 / LV-16): at the rug's edge the partner's sprite overlapped Wickglow's and Rinsepaw's all through the
# call. Both sides moved, so the line-up stays even about the rug's centre line, where the leader stands.
# The lower row one tile further out again (Claude, 2026-10-24, pass 6 T7 / LO6-02): Wickglow (19, 10), Slipjaw
# (10, 10) and Muskin (11, 10), all open floor of the lower Hall (town_room.gd ROOMS["hall_low"]: inside its walls, off
# its pillars, mess table, hatch and shelves), so the partner on (16, 10) and the leader's nudge have a tile to spare.
const STAND := {"grubbit": Vector2i(11, 8), "stillwade": Vector2i(18, 8), "wickglow": Vector2i(19, 10),
	"slipjaw": Vector2i(10, 10), "rinsepaw": Vector2i(18, 9)}
const LATE_DOOR := Vector2i(1, 6)                # Muskin comes in late, from the crew room
const LATE_SPOT := Vector2i(11, 10)              # and squeezes in beside Slipjaw, clear of the leader (RM7, T7)
# The leader front and centre, the partner beside Wickglow (Preston, 2026-10-11), recruits behind.
# LEADER_NUDGE puts the leader on the rug's centre line where the star points south, facing north (Preston, 2026-10-11).
# The marks are on the rug's open south side, and every one stands clear of the crew's sprites (RM7): the fourth
# stood under Wickglow's feet at (17, 11).
const LEADER_NUDGE := Vector2(12, 4)   # on the rug's centre line, just under the star's south point
const TEAM_SPOTS := [Vector2i(14, 10), Vector2i(16, 10), Vector2i(15, 11), Vector2i(15, 12)]
# The way back to work for those who cross the room (RM7): north of the rug, clear of the team still standing on it.
# Wickglow's starts at its new post (T7): straight up from (19, 10) to (19, 9), then round the rug's north side.
const BACK_VIA := {"rinsepaw": [Vector2i(17, 7), Vector2i(11, 7)], "wickglow": [Vector2i(19, 9), Vector2i(18, 7)],
	"stillwade": [Vector2i(17, 6)], "grubbit": [Vector2i(12, 7), Vector2i(19, 7)], "wayling": [Vector2i(19, 6)]}
const STARWARD_AT := Vector2i(15, 5)


## Once before each run, after the Wayline has taken the team on. (The record's key keeps its old name, rollcall_runs.)
static func pending(room) -> bool:
	if room.room_id != "hall_low":
		return false
	var rec: Dictionary = room._record()
	var story: Dictionary = rec.get("story", {})
	if not story.get("guild_trial", false):
		return false
	return int(rec.get("rollcall_runs", -1)) != _runs(rec)


static func _runs(rec: Dictionary) -> int:
	return int(rec.get("cleared", 0)) + int(rec.get("faints", 0))


## The Postmaster's morning note: the runners' route comes from here, by where the story stands.
static func _postmasters_note(story: Dictionary) -> Array:
	if story.get("runner", false) and String(story.get("stone", "")) == "":
		return [["Starward", "Morning, all. The river took a lot of mail this week. Every letter you bring home is somebody's whole week.", "determined"],
			["Starward", "Our runners go deeper into the Hollow today. Wish 'em luck, then get to work.", "happy"]]
	if String(story.get("parcel", "")) == "stolen":
		return [["Starward", "Morning. A parcel of ours is sitting in Rootbank Warren with the wrong crew.", "determined"],
			["Starward", "These two are bringing it home. The rest of you, keep the mail moving till they do.", "determined"]]
	return [["Starward", "Morning, all. The river doesn't wait, and neither does the mail.", "determined"],
		["Starward", "Go on, then. Get to it.", "happy"]]


static func run(room) -> void:
	room.cutscene = true
	SceneKit.read_ahead(["muskin", "starward"])   # the two who walk in later, read while the call starts (pass 6)
	var rec: Dictionary = room._record()
	var story: Dictionary = rec.get("story", {})
	var way: Dictionary = SceneKit.spawn(room, "wayling", Vector2i(14, 3), "s")
	var crew := {}
	var cast := {"Wayling": way}   # who says each line, so the camera can find them
	for form in STAND:
		crew[form] = SceneKit.spawn(room, form, STAND[form], "s")
		cast[String(form).capitalize()] = crew[form]
	cast["{partner}"] = room.team[1] if room.team.size() > 1 else room.team[0]
	SceneKit.pan(room, room._px(MARK + Vector2i(0, 1)), 0.01)   # the team (row 11) stays above the text box
	await SceneKit.wait(room, 0.4)
	await SceneKit.walk_to(room, way, CALLER, 0.2)
	SceneKit.face(room, way, MARK + Vector2i(0, 3))
	await _say_each(room, cast, [["Wayling", "Mail's in! Gather up, routes are going out. Grab what's yours."]])
	if not SceneKit._alive(room):
		return
	# The team comes up from below the rug (RM7): each steps down to that row first if it stands higher, crosses to the
	# tile two rows under its mark, then walks up onto it, so nobody brushes past Wickglow and Rinsepaw on the way in.
	var moves: Array = []
	for k in room.team.size():
		var spot: Vector2i = TEAM_SPOTS[mini(k, TEAM_SPOTS.size() - 1)]
		var at: Vector2i = room.team[k]["pos"]
		moves.append([room.team[k], [Vector2i(at.x, maxi(at.y, spot.y + 2)), spot + Vector2i(0, 2), spot]])
	await _walk_routes(room, moves, 0.2)
	for e in room.team:
		SceneKit.face(room, e, way)
	await _settle_leader(room)
	for form in crew:
		SceneKit.face(room, crew[form], way)
	# Routes, not names: Wayling reads the table, and whoever runs that route claims it.
	await _say_each(room, cast, [["Wayling", "The bend. Two parcels, and one's heavy."], ["Grubbit", "...mine. I know that one by the weight.", "happy"],
		["Wayling", "Levee row, letters. Wet feet."], ["Stillwade", "Mine. River's up two notches, mind.", "worried"],
		["Wayling", "Highbank windows, the thin ones."], ["Wickglow", "Mine! Gossip's free with every letter.", "mischievous"],
		["Wayling", "The grocer's slip."], ["Rinsepaw", "That's supper, hon. Mine.", "happy"],
		["Wayling", "The ford."], ["Slipjaw", "Fastest route. Obviously mine.", "determined"],
		["Wayling", "Which leaves the Warren road... Muskin? ...Muskin?"]])
	if not SceneKit._alive(room):
		return
	# Muskin, late as ever, gets the route nobody wants.
	var mus: Dictionary = SceneKit.spawn(room, "muskin", LATE_DOOR, "e")
	crew["muskin"] = mus
	cast["Muskin"] = mus
	SceneKit.emote(room, way, "!")
	await SceneKit.walk_to(room, mus, LATE_SPOT, 0.13)
	SceneKit.face(room, mus, way)
	await _say_each(room, cast, [["Muskin", "Here! Sorry! Here! The door stuck. The door always sticks.", "worried"], ["Wayling", "The Warren road's yours, then. The door too."],
		["Muskin", "...everything's always mine.", "worried"], ["Wayling", "And our runners?"], ["{partner}", "Here!", "joyous"],
		["Wayling", "No route from this table for you two. Yours comes from the Postmaster."]])
	if not SceneKit._alive(room):
		return
	# The Postmaster comes out with the morning's note.
	var star: Dictionary = SceneKit.spawn(room, "starward", Vector2i(14, 2), "s")
	cast["Starward"] = star
	SceneKit.pan(room, room._px(Vector2i(14, 8)), 0.5)
	await SceneKit.walk_to(room, star, STARWARD_AT, 0.26)
	for e in room.team.slice(1):   # the leader keeps facing north
		SceneKit.face(room, e, star)
	for form in crew:
		SceneKit.face(room, crew[form], star)
	await _say_each(room, cast, _postmasters_note(story))
	if not SceneKit._alive(room):
		return
	# No cheer: the crew peel off to their routes, and Muskin is already lost.
	await _say_each(room, cast, [["Wayling", "Routes are routes. The mail's not getting any drier standing here."], ["Muskin", "Wait, which way's the Warren road?", "worried"],
		["Slipjaw", "Left. It's always left.", "angry"]])
	if not SceneKit._alive(room):
		return
	rec["rollcall_runs"] = _runs(rec)
	# Everyone back to work: the crew to their posts, Wayling upstairs, Starward into the chamber.
	# Those crossing the room go round the rug's far (north) side, through BACK_VIA, behind the team, not through it.
	var back: Array = []
	for p in POSTS["hall_low"]:
		if crew.has(p[0]):
			back.append([crew[p[0]], BACK_VIA.get(p[0], []) + [p[1]]])
	back.append([crew["grubbit"], BACK_VIA["grubbit"] + [Vector2i(24, 14)]])
	back.append([way, BACK_VIA["wayling"] + [Vector2i(24, 13)]])
	back.append([star, [Vector2i(14, 2)]])
	SceneKit.release(room)
	await _walk_routes(room, back, 0.22)
	if not SceneKit._alive(room):
		return
	for e in [crew["grubbit"], way, star]:
		_despawn(room, e)
	for p in POSTS["hall_low"]:
		if crew.has(p[0]):
			crew[p[0]]["facing"] = p[2]
			room._place(crew[p[0]])
			crew[p[0]]["lines"] = lines_for(p[0], story)
	room.cutscene = false


## Say the lines one at a time, and before each, ease the camera to whoever says it so they stand just above
## the text box (Preston, 2026-10-11: the team, Wayling and Starward fell out of frame in the roll call).
static func _say_each(room, cast: Dictionary, lines: Array) -> void:
	for l in lines:
		if not SceneKit._alive(room):
			return
		var who: Dictionary = cast.get(String(l[0]), {})
		if String(l[0]) == "Starward" and not who.is_empty() and is_instance_valid(who["node"]):
			SceneKit.pan(room, who["node"].position + Vector2(0, -17), 0.35)   # the tall Guildmaster gets the frame to itself
		else:
			# Everyone else: the whole roll in one frame, Wayling at the top, the team just above the text box.
			SceneKit.pan(room, room._px(Vector2i(14, 10)) + Vector2(12, -32), 0.35)
		await SceneKit.say(room, [l])


## Walk several at once, each through its own tiles in order (the last is its goal), and wait for the last to
## arrive. Claude, 2026-10-24 (RM7): SceneKit.walk_all takes the shortest way, which ran the crew past the team.
static func _walk_routes(room, routes: Array, step: float) -> void:
	var walking := {"n": routes.size()}
	for r in routes:
		var go := func(e: Dictionary, legs: Array) -> void:
			for t in legs:
				if not SceneKit._alive(room):
					break
				await SceneKit.walk_to(room, e, t, step)
			walking["n"] -= 1
		go.call(r[0], r[1])
	var guard := 0
	while SceneKit._alive(room) and int(walking["n"]) > 0 and guard < 30 * 30:
		await room.get_tree().process_frame
		guard += 1


static func _despawn(room, e: Dictionary) -> void:
	room.npcs.erase(e)
	if is_instance_valid(e["node"]):
		e["node"].queue_free()


## The leader's place in the line: facing north, eased off the tile into the gap (LEADER_NUDGE).
static func _settle_leader(room) -> void:
	await SceneKit.wait(room, 0.15)   # let the leader's own walk finish first; its last step snaps it to the tile
	if not SceneKit._alive(room):
		return
	var lead: Dictionary = room.team[0]
	lead["facing"] = "n"
	room._place(lead)
	room.create_tween().tween_property(lead["node"], "position", room._px(lead["pos"]) + LEADER_NUDGE, 0.15)
