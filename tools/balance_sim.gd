extends SceneTree
## Balance simulator. Plays every creature against every other creature with the
## game's own rules (scripts/battle_rules.gd, the same file the battle screen
## uses) and no animation, then writes a report of who wins and how fast.
##
## Run it from the project folder:
##   Summer.exe --headless --path . --script res://tools/balance_sim.gd
## Options, after a lone "--":
##   --runs 1000        battles per wild matchup (the wild side picks at random)
##   --overrides FILE   a JSON file of test numbers (see below)
##   --out FILE         where the report goes (default docs/battle/balance/sim-report.md)
##
## Overrides let Grok's (or anyone's) proposed numbers be tested without
## touching the game's data. Names are the in-game names:
##   {"creatures": {"Cinderhide": {"base_hp": 70, "base_speed": 55}},
##    "moves": {"Kingstone Rail": {"power": 80, "max_uses": 2}}}
##
## The turn below mirrors battle_screen.gd's _on_move_pressed. If the battle's
## turn order changes there, change it here too.

const CREATURE_DIR := "res://data/creatures/"
const FAINTED := 0
const TURN_LIMIT := 60  # a battle this long is reported as a stalemate

var _runs := 1000
var _out := "res://docs/battle/balance/sim-report.md"
var _overrides := {}


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	for i in args.size():
		if args[i] == "--runs" and i + 1 < args.size():
			_runs = int(args[i + 1])
		elif args[i] == "--out" and i + 1 < args.size():
			_out = args[i + 1]
		elif args[i] == "--overrides" and i + 1 < args.size():
			_overrides = JSON.parse_string(FileAccess.get_file_as_string(args[i + 1]))
			if _overrides == null:
				push_error("Could not read overrides file " + args[i + 1])
				_overrides = {}
	seed(20260930)  # the same report every run, until the numbers change
	var roster := _load_roster()
	var report := _report(roster)
	DirAccess.make_dir_recursive_absolute(_out.get_base_dir())
	var f := FileAccess.open(_out, FileAccess.WRITE)
	f.store_string(report)
	f.close()
	print(report)
	print("Wrote ", ProjectSettings.globalize_path(_out))
	quit()


# ------------------------------------------------------------------ the roster

## Every creature file, copied so overrides never touch the real data.
func _load_roster() -> Array[CreatureData]:
	var roster: Array[CreatureData] = []
	var files := DirAccess.get_files_at(CREATURE_DIR)
	files.sort()
	for file in files:
		if not file.ends_with(".tres"):
			continue
		var original: CreatureData = load(CREATURE_DIR + file)
		var c: CreatureData = original.duplicate()
		var known: Array[MoveData] = []
		for m in _moves_of(original):
			var copy: MoveData = m.duplicate()
			_apply(copy, _overrides.get("moves", {}).get(copy.move_name, {}))
			known.append(copy)
		c.moves = known
		c.move = null
		_apply(c, _overrides.get("creatures", {}).get(c.creature_name, {}))
		roster.append(c)
	return roster


func _moves_of(c: CreatureData) -> Array[MoveData]:
	if not c.moves.is_empty():
		return c.moves
	var result: Array[MoveData] = []
	if c.move != null:
		result.append(c.move)
	return result


func _apply(target: Resource, values: Dictionary) -> void:
	for key in values:
		if key in target:
			target.set(key, values[key])
		else:
			push_warning("Override '%s' is not a field of %s" % [key, target])


# ------------------------------------------------------------------ one battle

## One side of a battle: who it is, its HP, its moves' uses left, its guard.
class Fighter:
	var creature: CreatureData
	var hp: int
	var uses := {}
	var guard := 1.0
	var intent: MoveData
	var pending := false
	var canceled := false

	func _init(c: CreatureData) -> void:
		creature = c
		hp = c.base_hp

	func uses_left(m: MoveData) -> int:
		if m == null or m.max_uses == 0:
			return -1
		return uses.get(m, m.max_uses)

	func available() -> Array[MoveData]:
		var result: Array[MoveData] = []
		for m in creature.moves:
			if uses_left(m) != 0:
				result.append(m)
		return result  # empty means Strike


## How the side picks. "random" is how wild creatures choose in the game.
## "strongest" is a player who always uses the hardest-hitting move left.
func _choose(me: Fighter, them: Fighter, policy: String) -> MoveData:
	var options := me.available()
	if options.is_empty():
		return null
	if policy == "random":
		return options.pick_random()
	var best: MoveData = null
	var best_hit := -1
	for m in options:
		if m.kind == MoveData.Kind.GUARD:
			continue
		var hit := BattleRules.damage(me.creature, them.creature, m.power,
			EssenceChart.against(m.essence, them.creature))
		if hit > best_hit:
			best_hit = hit
			best = m
	return best if best != null else options[0]


## Plays one battle. Returns [player_won (bool, false on a stalemate), turns].
func _battle(player_c: CreatureData, foe_c: CreatureData, player_policy: String, foe_policy: String) -> Array:
	var p := Fighter.new(player_c)
	var f := Fighter.new(foe_c)
	var player_first := BattleRules.player_acts_first(player_c, foe_c)
	for turn in range(1, TURN_LIMIT + 1):
		for s in [p, f]:
			s.guard = 1.0
			s.canceled = false
			s.pending = true
		f.intent = _choose(f, p, foe_policy)
		p.intent = _choose(p, f, player_policy)
		# Guards brace before ordinary speed order. They use up the action.
		for s in [p, f]:
			if s.intent != null and s.intent.kind == MoveData.Kind.GUARD:
				_act(s, p if s == f else f)
		var order: Array = [p, f] if player_first else [f, p]
		for s in order:
			if s.pending and not s.canceled:
				_act(s, p if s == f else f)
			if p.hp == FAINTED or f.hp == FAINTED:
				return [f.hp == FAINTED, turn]
	return [false, TURN_LIMIT]


func _act(me: Fighter, them: Fighter) -> void:
	me.pending = false
	var m: MoveData = me.intent
	if m != null and m.max_uses > 0:
		me.uses[m] = me.uses_left(m) - 1
	if m != null and m.kind == MoveData.Kind.GUARD:
		me.guard = clampf(m.guard_damage_fraction, 0.0, 1.0)
		return
	var power: int = m.power if m else BattleRules.STRIKE_POWER
	var essence: CreatureData.Essence = m.essence if m else me.creature.essence
	var multiplier := EssenceChart.against(essence, them.creature)
	var dealt := BattleRules.after_guard(BattleRules.damage(me.creature, them.creature, power, multiplier), them.guard)
	them.hp = maxi(FAINTED, them.hp - dealt)
	them.guard = 1.0
	if m != null and m.kind == MoveData.Kind.INTERRUPT and them.pending \
			and them.intent != null and them.intent.interruptible:
		them.canceled = true


# ------------------------------------------------------------------ the report

func _report(roster: Array[CreatureData]) -> String:
	var names: Array[String] = []
	for c in roster:
		names.append(c.creature_name)
	var lines: Array[String] = []
	lines.append("# Balance simulator report")
	lines.append("")
	lines.append("Generated by `tools/balance_sim.gd` with the game's own rules (`scripts/battle_rules.gd`).")
	lines.append("Overrides: %s. Wild runs per matchup: %d. A battle past %d turns counts as a stalemate." %
		["none" if _overrides.is_empty() else JSON.stringify(_overrides), _runs, TURN_LIMIT])
	lines.append("")
	lines.append("## The numbers tested")
	lines.append("")
	lines.append("| Creature | Essence | HP | Atk | Def | Spd | Moves (power / uses, 0 = unlimited) |")
	lines.append("|---|---|---|---|---|---|---|")
	for c in roster:
		var kit: Array[String] = []
		for m in c.moves:
			kit.append("%s %d/%d%s" % [m.move_name, m.power, m.max_uses, " sig" if m.signature else ""])
		lines.append("| %s | %s | %d | %d | %d | %d | %s |" % [c.creature_name, c.essence_name(),
			c.base_hp, c.base_attack, c.base_defense, c.base_speed, ", ".join(kit) if not kit.is_empty() else "Strike only"])
	lines.append("")

	# Duel: both sides always use their hardest-hitting move. No dice, one run.
	lines.append("## Duel: both sides play their strongest move")
	lines.append("")
	lines.append("Row is your creature, column is the opponent. Each cell: W or L, then turns taken. No randomness, so one battle each.")
	lines.append("")
	lines.append("| You \\ Foe | " + " | ".join(names) + " |")
	lines.append("|---|" + "---|".repeat(names.size()))
	var duel_wins := {}
	for a in roster:
		var row: Array[String] = []
		var wins := 0
		for b in roster:
			var r := _battle(a, b, "strongest", "strongest")
			row.append(("W" if r[0] else "L") + " " + str(r[1]))
			wins += 1 if r[0] else 0
		duel_wins[a.creature_name] = wins
		lines.append("| **%s** | %s |" % [a.creature_name, " | ".join(row)])
	lines.append("")

	# Wild: you play your strongest move, the wild side picks at random (as in the game).
	lines.append("## Wild encounter: you play strongest, the wild side picks at random")
	lines.append("")
	lines.append("Each cell: your win rate over %d battles, then average turns." % _runs)
	lines.append("")
	lines.append("| You \\ Wild | " + " | ".join(names) + " |")
	lines.append("|---|" + "---|".repeat(names.size()))
	var wild_rate := {}
	for a in roster:
		var row: Array[String] = []
		var total := 0.0
		for b in roster:
			var won := 0
			var turns := 0
			for i in _runs:
				var r := _battle(a, b, "strongest", "random")
				won += 1 if r[0] else 0
				turns += r[1]
			var rate := float(won) / _runs
			total += rate
			row.append("%d%% %.1f" % [roundi(rate * 100.0), float(turns) / _runs])
		wild_rate[a.creature_name] = total / roster.size()
		lines.append("| **%s** | %s |" % [a.creature_name, " | ".join(row)])
	lines.append("")

	lines.append("## Summary")
	lines.append("")
	lines.append("| Creature | Duel wins (of %d) | Average wild win rate | Turns to beat an identical 60/60/60/60 Strike-only dummy |" % roster.size())
	lines.append("|---|---|---|---|")
	var dummy := CreatureData.new()
	dummy.creature_name = "Dummy"
	dummy.essence = CreatureData.Essence.GALE  # neutral to everything but Hollow
	for c in roster:
		var r := _battle(c, dummy, "strongest", "strongest")
		lines.append("| %s | %d | %d%% | %s |" % [c.creature_name, duel_wins[c.creature_name],
			roundi(wild_rate[c.creature_name] * 100.0), str(r[1]) if r[0] else "lost"])
	lines.append("")
	return "\n".join(lines) + "\n"
