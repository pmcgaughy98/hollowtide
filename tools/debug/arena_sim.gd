extends SceneTree
## Arena balance simulator (Claude, 2026-10-07). AI against AI, no keyboard, headless:
##   Godot --headless --path . --fixed-fps 30 --script res://tools/debug/arena_sim.gd -- [matches_per_side] [team_size]
## team_size 1 (default): for each pairing of the three stage 3 forms, plays N matches with
## each form on each side (so the starting spot cancels out) and prints wins, average length
## and average HP left. A match that runs past 90 seconds counts as a draw.
## team_size 2: every two-form team against every other. team_size 3: the three forms
## against the same three (a mirror, so the win split only shows side bias); here the useful
## numbers are per creature: damage dealt, how often it is still standing at the end, and how
## often it is the first to fall. Team matches get 30 more seconds per extra creature.

const FORMS := [[0, 2, "Stormwick"], [1, 2, "Rampartroot"], [2, 2, "Scourmaw"]]
var arena: Node2D

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var per_side := int(args[0]) if args.size() > 0 else 10
	var size := int(args[1]) if args.size() > 1 else 1
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	await process_frame
	arena.auto_you = true
	if size <= 1:
		await _duels(per_side, size)
	else:
		await _team_fights(per_side, size)
	quit()


func _duels(per_side: int, size: int) -> void:
	for a in range(FORMS.size()):
		for b in range(a + 1, FORMS.size()):
			var wins := {FORMS[a][2]: 0, FORMS[b][2]: 0, "draw": 0}
			var seconds := 0.0
			var left := {FORMS[a][2]: 0.0, FORMS[b][2]: 0.0}
			for side in 2:
				for k in per_side:
					seed(hash([a, b, side, k, size]))   # distinct for every match (the old formula repeated seeds past 10 a side)
					var first: Array = FORMS[a] if side == 0 else FORMS[b]
					var second: Array = FORMS[b] if side == 0 else FORMS[a]
					arena._you = first[0]; arena._you_stage = first[1]
					arena._rival = second[0]; arena._rival_stage = second[1]
					arena._new_match()
					var frames := 0
					while arena._winner < 0 and frames < 2700:
						await process_frame
						frames += 1
					seconds += frames / 30.0
					for j in 2:
						var f: Dictionary = arena._fighters[j]
						left[f["name"]] += float(f["hp"]) / f["max_hp"]
					if arena._winner < 0:
						wins["draw"] += 1
					else:
						wins[arena._fighters[arena._winner]["name"]] += 1
			var n := per_side * 2
			print("%s vs %s: %s %d - %d %s (draws %d), avg %.0f s, HP left %d%% / %d%%" % [FORMS[a][2], FORMS[b][2],
				FORMS[a][2], wins[FORMS[a][2]], wins[FORMS[b][2]], FORMS[b][2], wins["draw"], seconds / n,
				100.0 * left[FORMS[a][2]] / n, 100.0 * left[FORMS[b][2]] / n])


func _team_fights(per_side: int, size: int) -> void:
	var teams: Array = []   # each team is a list of FORMS indexes
	if size == 2:
		for a in FORMS.size():
			for b in range(a + 1, FORMS.size()):
				teams.append([a, b])
	else:
		teams = [[0, 1, 2], [0, 1, 2]]
	var stats := {}   # per form: fights, dealt, standing, first_down
	for f in FORMS:
		stats[f[2]] = {"fights": 0, "matches": 0, "dealt": 0, "standing": 0, "first": 0}
	var cap := 2700 + 900 * (size - 1)
	for a in teams.size():
		for b in range(a + 1, teams.size()):
			var wins := [0, 0, 0]   # team a, team b, draws
			var seconds := 0.0
			for side in 2:
				for k in per_side:
					seed(hash([a, b, side, k, size]))   # distinct for every match (the old formula repeated seeds past 10 a side)
					var first: Array = teams[a] if side == 0 else teams[b]
					var second: Array = teams[b] if side == 0 else teams[a]
					arena.teams_override = [first.map(func(x): return [FORMS[x][0], FORMS[x][1]]),
						second.map(func(x): return [FORMS[x][0], FORMS[x][1]])]
					arena._new_match()
					var frames := 0
					while arena._winner < 0 and frames < cap:
						await process_frame
						frames += 1
					seconds += frames / 30.0
					var first_down := -1
					var seen := {}
					for j in arena._fighters.size():
						var f: Dictionary = arena._fighters[j]
						var s: Dictionary = stats[f["name"]]
						s["fights"] += 1
						if not seen.has(f["name"]):
							seen[f["name"]] = true
							s["matches"] += 1
						s["dealt"] += f["dealt"]
						if f["hp"] > 0:
							s["standing"] += 1
						if f["down_at"] >= 0.0 and (first_down < 0 or f["down_at"] < arena._fighters[first_down]["down_at"]):
							first_down = j
					if first_down >= 0:
						stats[arena._fighters[first_down]["name"]]["first"] += 1
					if arena._winner < 0:
						wins[2] += 1
					else:
						# Team a played as side 0 on the first half and side 1 on the second.
						wins[0 if (arena._winner == 0) == (side == 0) else 1] += 1
			print("%s vs %s: %d - %d (draws %d), avg %.0f s" % [_team_name(teams[a]), _team_name(teams[b]),
				wins[0], wins[1], wins[2], seconds / (per_side * 2)])
	for name in stats:
		var s: Dictionary = stats[name]
		if s["fights"] == 0:
			continue
		print("  %s: avg damage dealt %d, still standing %d%%, first to fall %d%% of matches" % [name,
			s["dealt"] / s["fights"], 100 * s["standing"] / s["fights"], 100 * s["first"] / s["matches"]])
	arena.teams_override = []


func _team_name(team: Array) -> String:
	return " + ".join(team.map(func(x): return FORMS[x][2]))
