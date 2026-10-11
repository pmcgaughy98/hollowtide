extends RefCounted
## Every creature line in one lookup (Claude, 2026-10-10). The arena's LINES hold the full three-stage
## lines; the lines made for the dungeon and the story (the Shortcut Crew, the Hollow's new wilds) sit here
## in EXTRA, numbered from 100, so the arena's loops never meet them. Anything that turns a party entry
## [line, stage] into a form or a name asks Lines.of(line), so a recruited Hollow creature works in town,
## on the Team page and at the shrine.

const Arena := preload("res://scripts/arena/arena_prototype.gd")

const EXTRA := {
	100: {"forms": [["mirekit", "res://data/creatures/2201_mirekit.tres"]]},
	101: {"forms": [["whinet", "res://data/creatures/2301_whinet.tres"]]},
	102: {"forms": [["gruntle", "res://data/creatures/2401_gruntle.tres"]]},   # the crew's boss (Preston, 2026-10-10)
	# The Hollow's new wilds (Preston picked the takes, 2026-10-10); stage 1s of lines whose later forms
	# are not made yet. docs/creatures/hollow-wilds-2026-10-10.md.
	103: {"forms": [["skimlet", "res://data/creatures/2501_skimlet.tres"]]},
	104: {"forms": [["ozbender", "res://data/creatures/2601_ozbender.tres"]]},
	105: {"forms": [["valvekin", "res://data/creatures/2701_valvekin.tres"]]},
}


static func of(line: int) -> Dictionary:
	return EXTRA[line] if EXTRA.has(line) else Arena.LINES[line]
