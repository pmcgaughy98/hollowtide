extends RefCounted
## The Wayline Hall's crew in their rooms, and the morning roll call (Claude, 2026-10-11; Preston approved the crew,
## docs/creatures/guild-crew-2026-10-11.md, and asked for the roll-call floor). Built on scene_kit.gd.
##
## Outside scenes each crew member stands at their post and says a line when the leader talks to them (E).
## The roll call plays on the Hall's lower floor once before each run, after the guild has taken the team on:
## Wayling calls the roll on the mark, the crew lines up, Starward comes out of the chamber with the word of the
## day, and everyone goes back to their post. The lines are Claude's drafts for Preston, in the house voice
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
			return [["Wayling", "The Guildmaster's downstairs. Mind the third step, it squeaks."]]
		"grubbit":
			return [["Grubbit", "...Oh! You walked right up on me."], ["Grubbit", "Parcel for the bend, parcel for Highbank... I go by feel down here. Never misread one yet."]]
		"stillwade":
			return [["Stillwade", "River's up two notches since sunup."], ["Stillwade", "Not flood-up. Just... thinking about it."]]
		"wickglow":
			return [["Wickglow", "Did you hear? Somebody saw Gruntle's bunch sneaking round the Warren again."], ["Wickglow", "Don't tell Wayling I told you. Actually, tell everybody."]]
		"muskin":
			return [["Muskin", "Am I late? I'm late. I'm always late."], ["Muskin", "Wait. Are you guys late too? Oh good."]]
		"rinsepaw":
			return [["Rinsepaw", "Supper's at sundown, hon. Late gets what's left."], ["Rinsepaw", "And Muskin's always late, so there's never much left. You two eat."]]
		"slipjaw":
			if story.get("runner", false):
				return [["Slipjaw", "Fine. You're runners. Doesn't mean you're faster than me."]]
			return [["Slipjaw", "You two? Runners? Ha. We'll see who gets there first."]]
	return []


## The crew at their posts in this room (not during the roll call, not while a guild scene owns the room).
static func place(room) -> void:
	var story: Dictionary = room._record().get("story", {})
	if not story.get("guild_trial", false):
		return   # before the guild takes the team on, the Hall is the guild scenes' stage
	for p in POSTS.get(room.room_id, []):
		var e: Dictionary = SceneKit.spawn(room, p[0], p[1], p[2])
		e["lines"] = lines_for(p[0], story)


# ---------------------------------------------------------------- the roll call

const MARK := Vector2i(14, 9)
const CALLER := Vector2i(14, 6)                 # Wayling, in front of the mark, facing the room
const STAND := {"grubbit": Vector2i(12, 8), "stillwade": Vector2i(17, 8), "wickglow": Vector2i(17, 10),
	"slipjaw": Vector2i(12, 10), "rinsepaw": Vector2i(17, 9)}
const LATE_DOOR := Vector2i(1, 6)                # Muskin comes in late, from the crew room
const TEAM_SPOTS := [Vector2i(14, 11), Vector2i(15, 11), Vector2i(13, 11)]
const STARWARD_AT := Vector2i(15, 5)


## Once before each run, after the guild has taken the team on.
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


static func _word_of_the_day(story: Dictionary) -> Array:
	if story.get("runner", false) and String(story.get("stone", "")) == "":
		return [["Starward", "Word of the day. The river took a lot of mail this week. Every letter you bring home is somebody's whole week.", "determined"],
			["Starward", "Our runners are going deeper into the Hollow. Wish 'em luck, then get to work.", "happy"]]
	if String(story.get("parcel", "")) == "stolen":
		return [["Starward", "Word of the day. A parcel of ours is sitting in Rootbank Warren with the wrong crew.", "determined"],
			["Starward", "These two are bringing it home. The rest of you, keep the Hall running till they do.", "determined"]]
	return [["Starward", "Word of the day. The river doesn't wait, and neither does the mail.", "determined"],
		["Starward", "Go on, then. Get to it.", "happy"]]


static func run(room) -> void:
	room.cutscene = true
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
	await _say_each(room, cast, [["Wayling", "Morning, everybody! Line up, line up! On the mark, please!"]])
	if not SceneKit._alive(room):
		return
	var moves: Array = []
	for k in room.team.size():
		moves.append([room.team[k], TEAM_SPOTS[mini(k, TEAM_SPOTS.size() - 1)]])
	await SceneKit.walk_all(room, moves, 0.2)
	for e in room.team:
		SceneKit.face(room, e, way)
	for form in crew:
		SceneKit.face(room, crew[form], way)
	await _say_each(room, cast, [["Wayling", "Grubbit?"], ["Grubbit", "...here."], ["Wayling", "Stillwade?"], ["Stillwade", "Here."],
		["Wayling", "Wickglow?"], ["Wickglow", "Here! Bright and early!"], ["Wayling", "Rinsepaw?"], ["Rinsepaw", "Here, hon. Soup's on at sundown."],
		["Wayling", "Slipjaw?"], ["Slipjaw", "Obviously."],
		["Wayling", "Muskin? ...Muskin?"]])
	if not SceneKit._alive(room):
		return
	# Muskin, late as ever.
	var mus: Dictionary = SceneKit.spawn(room, "muskin", LATE_DOOR, "e")
	crew["muskin"] = mus
	cast["Muskin"] = mus
	SceneKit.emote(room, way, "!")
	await SceneKit.walk_to(room, mus, Vector2i(13, 10), 0.13)
	SceneKit.face(room, mus, way)
	await _say_each(room, cast, [["Muskin", "Here! Sorry! Here! The door stuck. The door always sticks."], ["Wayling", "...And our runners?"],
		["{partner}", "Here!", "joyous"]])
	if not SceneKit._alive(room):
		return
	# The Guildmaster comes out for the word of the day.
	var star: Dictionary = SceneKit.spawn(room, "starward", Vector2i(14, 2), "s")
	cast["Starward"] = star
	SceneKit.pan(room, room._px(Vector2i(14, 8)), 0.5)
	await SceneKit.walk_to(room, star, STARWARD_AT, 0.26)
	for e in room.team:
		SceneKit.face(room, e, star)
	for form in crew:
		SceneKit.face(room, crew[form], star)
	await _say_each(room, cast, _word_of_the_day(story))
	if not SceneKit._alive(room):
		return
	room._sfx("cheer")   # the whole crew (ElevenLabs, 2026-10-11)
	await _say_each(room, cast, [["Wayling", "You heard the Guildmaster. Wayline!"], ["Muskin", "Wayline!"], ["Wickglow", "Wayline!"]])
	if not SceneKit._alive(room):
		return
	rec["rollcall_runs"] = _runs(rec)
	# Everyone back to work: the crew to their posts, Wayling upstairs, Starward into the chamber.
	var back: Array = []
	for p in POSTS["hall_low"]:
		if crew.has(p[0]):
			back.append([crew[p[0]], p[1]])
	back.append([crew["grubbit"], Vector2i(24, 14)])
	back.append([way, Vector2i(24, 13)])
	back.append([star, Vector2i(14, 2)])
	SceneKit.release(room)
	await SceneKit.walk_all(room, back, 0.22)
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
		if not who.is_empty() and is_instance_valid(who["node"]):
			SceneKit.pan(room, who["node"].position + Vector2(0, -17), 0.35)
		await SceneKit.say(room, [l])


static func _despawn(room, e: Dictionary) -> void:
	room.npcs.erase(e)
	if is_instance_valid(e["node"]):
		e["node"].queue_free()
