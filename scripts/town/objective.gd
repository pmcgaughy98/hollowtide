extends RefCounted
## What to do next, read from the story so far (Claude, 2026-10-11; Preston: "we need objective tab so players
## know where to go"). One short line for the screen and a longer one, with where the place is in Highbank,
## for the Objective page in the menu. Finished games keep this to one goal at a time (Coromon's and Cassette
## Beasts' current-quest line, Explorers of Sky's partner reminders); structure only.
##   Objective.current(story, beaten, in_hollow) -> {"short": String, "long": String}
## Places in Highbank (town_layout.gd): the Hall and the Job Board at the top middle, the Growth Shrine on the
## west side, the Mouth of the Hollow by the Old Ferry Landing at the south-east edge.
## Directions once (Claude, 2026-10-22, W25): each place's whereabouts are given the first time the story sends
## the team there; after that the line names the place only, so no direction phrase appears twice in this file.
## In a Hollow (Claude, 2026-10-24, LV-23): `in_hollow` true drops the sentence that says how to get down from
## town, which reads wrong once the team is already below. Town callers keep the default and the whole line.
## Pass 8 (Claude, 2026-10-26, T2 and T3; the new lines are proposals, Preston's to rewrite): the gate's and the
## landing's names come from town_layout.gd, so the street's plaque, the town's run line and these lines say one name;
## inside Hollow Mouth (below, before it is cleared) the line is the Mouth's own, not the riverbank's; and once the end
## card has played (pilot_end_seen) the short line reads the record: who is ready at the shrine, else the requests
## taken, else the board's new requests.

const Layout := preload("res://scripts/town/town_layout.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const AFTER := "That's the first stretch. Run the Hollows again or rest at home."


static func current(story: Dictionary, beaten: Array, in_hollow := false) -> Dictionary:
	var parcel := String(story.get("parcel", ""))
	var stone := String(story.get("stone", ""))
	var gate := Layout.place_name("gate")
	if not "mouth" in beaten and in_hollow:   # below in Hollow Mouth, the flood behind (T3 / L10)
		return _goal("Find the stairs. The way out is below.",
			"The water's up behind you. Take the stairs down on every floor; the way out of the ruin is at the bottom.")
	if not "mouth" in beaten:
		return _goal("Escape the flood through the Hollow Mouth",
			"The road up to Highbank is under water. Follow the stone walkway into the ruin and find the way out the other side.")
	if parcel == "saved":
		return _goal("Show the parcel at the Job Board",
			"Your partner wants Highbank to see the parcel it saved. The Job Board stands beside the Wayline Tower's steps, at the top middle of town.")
	if parcel == "stolen" and not story.get("guild_trial", false):
		return _goal("Tell Starward at the Wayline Tower",
			"The Shortcut Crew took the parcel. Starward, the Postmaster, is at the counter inside the Wayline Tower.")
	if parcel == "stolen":
		return _goal("Get the parcel back in Rootbank Warren",
			"The crew went to ground in Rootbank Warren." + ("" if in_hollow else " The way down is the %s, by the %s at the south-east edge of town." % [gate, Layout.place_name("landing")]))
	if parcel == "recovered":
		return _goal("Bring the parcel to Starward",
			"The parcel is back. Take it to Starward at the counter in the Wayline Tower.")
	if not "hollow" in beaten:
		return _goal("Go down to The Hollow",
			"You're runners now. The Hollow is the next way down, through the %s." % gate)
	if stone == "carried":
		return _goal("Set the Warden's stone in the Growth Shrine",
			"The Warden let you take its stone. The Growth Shrine is on the west side of town; its socket is waiting.")
	if story.get("pilot_end_seen", false):   # set by the end card after the first growth (scripts/town/pilot_end.gd)
		var now := after_pilot(TeamState.data)
		return _goal(now, now + " " + AFTER + ("" if now.contains("ready to grow") else " The shrine is there for whoever is ready next."))
	return _goal("Grow at the Growth Shrine, or run a Hollow again",
		"The shrine is awake. A creature that is ready grows there. The %s takes you back into any Hollow to grow the rest of the team." % gate)


## After the end card (T3 / L-10), read from the record in order: the first creature ready to grow, else the requests
## taken (one paid for and waiting at the board, else the first still to reach), else the board's new requests.
## Proposals, word for word in the pass 8 result.
## The street and the rooms draw the line every frame: the answer is kept for MEMO_FRAMES frames (a sixth of a second
## at 60), since the readiness test reads dungeon.gd's tables for each member.
const MEMO_FRAMES := 10
static var _memo := ""
static var _memo_at := -MEMO_FRAMES


static func after_pilot(rec: Dictionary) -> String:
	var frame := Engine.get_process_frames()
	if frame - _memo_at < MEMO_FRAMES and frame >= _memo_at:
		return _memo
	_memo = _after_pilot(rec)
	_memo_at = frame
	return _memo


static func _after_pilot(rec: Dictionary) -> String:
	if not rec.get("party", []).is_empty():
		var ready: Array = load("res://scripts/town/evolution.gd").ready_list(rec)
		if not ready.is_empty():
			var m: Array = rec["party"][int(ready[0])]
			var lines: GDScript = load("res://scripts/creatures/lines.gd")
			var who: String = load(lines.of(int(m[0]))["forms"][int(m[1])][1]).creature_name
			return "%s is ready to grow at the Growth Shrine." % who
	var jobs: Array = rec.get("jobs", [])
	if jobs.any(func(j: Dictionary) -> bool: return j.get("done", false)):
		return "A request is done. The pay waits at the Job Board."
	var Jobs: GDScript = load("res://scripts/town/jobs.gd")
	for j: Dictionary in jobs:
		var who: String = Jobs.client_name(j)
		var at: String = Jobs.place_text(j)
		match String(j.get("kind", "")):
			"rescue":
				return "%s is lost on %s." % [who, at]
			"lost_item":
				return "%s's %s is down on %s." % [who, Jobs.item_name(String(j.get("item", ""))), at]
			"delivery":
				return "%s waits for a parcel on %s." % [who, at]
	return "New requests on the Job Board."


static func _goal(short: String, long: String) -> Dictionary:
	return {"short": short, "long": long}
