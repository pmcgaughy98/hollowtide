extends RefCounted
## What to do next, read from the story so far (Claude, 2026-10-11; Preston: "we need objective tab so players
## know where to go"). One short line for the screen and a longer one, with where the place is in Highbank,
## for the Objective page in the menu. Finished games keep this to one goal at a time (Coromon's and Cassette
## Beasts' current-quest line, Explorers of Sky's partner reminders); structure only.
##   Objective.current(story, beaten) -> {"short": String, "long": String}
## Places in Highbank (town_layout.gd): the Hall and the Job Board at the top middle, the Growth Shrine on the
## west side, the Mouth of the Hollow by the Old Ferry Landing at the south-east edge.
## Directions once (Claude, 2026-10-22, W25): each place's whereabouts are given the first time the story sends
## the team there; after that the line names the place only, so no direction phrase appears twice in this file.


static func current(story: Dictionary, beaten: Array) -> Dictionary:
	var parcel := String(story.get("parcel", ""))
	var stone := String(story.get("stone", ""))
	if not "mouth" in beaten:
		return _goal("Escape the flood through the Hollow Mouth",
			"The road up to Highbank is under water. Follow the stone walkway into the ruin and find the way out the other side.")
	if parcel == "saved":
		return _goal("Show the parcel at the Job Board",
			"Your partner wants Highbank to see the parcel it saved. The Job Board stands beside the Wayline Hall's steps, at the top middle of town.")
	if parcel == "stolen" and not story.get("guild_trial", false):
		return _goal("Tell Starward at the Wayline Hall",
			"The Shortcut Crew took the parcel. Starward, the Postmaster, is at the counter inside the Wayline Hall.")
	if parcel == "stolen":
		return _goal("Get the parcel back in Rootbank Warren",
			"The crew went to ground in Rootbank Warren. The way down is the Mouth of the Hollow, by the Old Ferry Landing at the south-east edge of town.")
	if parcel == "recovered":
		return _goal("Bring the parcel to Starward",
			"The parcel is back. Take it to Starward at the counter in the Wayline Hall.")
	if not "hollow" in beaten:
		return _goal("Go down to The Hollow",
			"You're runners now. The Hollow is the next way down, through the Mouth of the Hollow.")
	if stone == "carried":
		return _goal("Set the Warden's stone in the Growth Shrine",
			"The Warden let you take its stone. The Growth Shrine is on the west side of town; its socket is waiting.")
	if story.get("pilot_end_seen", false):   # set by the end card after the first growth (scripts/town/pilot_end.gd)
		return _goal("That's the first stretch. Run the Hollows again or rest at home.",
			"That's the first stretch. Run the Hollows again or rest at home. The shrine is there for whoever is ready next.")
	return _goal("Grow at the Growth Shrine, or run a Hollow again",
		"The shrine is awake. A creature that is ready grows there. The Mouth of the Hollow takes you back into any Hollow to grow the rest of the team.")


static func _goal(short: String, long: String) -> Dictionary:
	return {"short": short, "long": long}
