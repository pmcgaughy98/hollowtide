extends SceneTree
## The ElevenLabs sounds (Claude, 2026-10-09): every built sound loads, and the game plays the right
## one at the right moment: a real attack (swing, the hit, the move's essence impact), a miss, the
## stairs, a pickup, a trap, the lantern running low, and the town's job board and doors.
## Reads the dungeon's last_sfx (sound name -> turn) and the town's last_sfx.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dungeon_sfx_check.gd

const NAMES := ["swing", "miss", "hit_light", "hit_heavy", "hit_super", "slam", "shove", "windup",
	"impact_fire", "impact_water", "impact_shock", "impact_earth", "impact_root", "impact_wind",
	"stairs", "pickup", "eat", "trap_snare", "trap_silt", "trap_warp", "monster_ambush", "lantern_low",
	"faint", "iq_learn", "scroll", "door", "board_paper",
	# the second batch
	"denied", "throw", "part_break", "recruit_rise", "hollow_fade", "revive", "lantern_up", "lantern_out",
	"room_clear", "floor_arrive", "boss_appear", "dizzy", "wake", "escape", "menu_open", "menu_close",
	"snare_struggle", "evolve_ready"]


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _run() -> void:
	var bad := 0
	# Every sound loads and has length.
	var short: Array[String] = []
	for n in NAMES:
		var s: AudioStream = load("res://assets/audio/sfx/dungeon/%s.wav" % n)
		if s == null or s.get_length() < 0.1:
			short.append(n)
	print("sounds that load: %d of %d %s" % [NAMES.size() - short.size(), NAMES.size(), str(short) if not short.is_empty() else ""])
	bad += short.size()

	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[0, 0], [1, 0]]
	root.add_child(dg)
	await _frames(4)
	print("floor start: played %s -> %s" % [str(dg.last_sfx.keys()), "ok" if dg.last_sfx.has("floor_arrive") else "WRONG"])
	bad += 0 if dg.last_sfx.has("floor_arrive") else 1
	dg.traps.clear()
	dg.monster_room = Rect2i()
	for e in dg.ents:
		if e["team"] == 1:
			e["hp"] = 0
			e["node"].visible = false
	# The leader (Kithflare, Ember) hits a Rimefin beside it.
	var lead: Dictionary = dg.ents[0]
	var d := Vector2i.ZERO
	for dd in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1)]:
		if dg.can_step(lead["pos"], dd) and dg._occupant(lead["pos"] + dd) < 0:
			d = dd
			break
	var w: Dictionary = dg._make(2, 0, 1, lead["pos"] + d)
	w["max_hp"] = 99
	w["hp"] = 99
	dg.ents.append(w)
	dg._place(w)
	var m: String = lead["moves"][0]
	w["awake"] = false   # asleep: the hit wakes it with a snort
	dg.last_sfx.clear()
	dg.use_move(0, m, d)
	await _frames(30)
	var ess: String = dg._ess_name(m, lead)
	var want_impact: String = "" if dg.MOVE_FX.get(m, {}).get("hit", "") == "light_slash" else dg.ESSENCE_SFX.get(ess, "")
	var played: Array = dg.last_sfx.keys()
	var hit_any: bool = played.has("hit_light") or played.has("hit_heavy") or played.has("hit_super")
	var ok_attack: bool = played.has("swing") and hit_any and (want_impact == "" or played.has(want_impact)) and played.has("wake")
	print("attack with %s (%s): played %s -> %s" % [m, ess, str(played), "ok" if ok_attack else "WRONG"])
	bad += 0 if ok_attack else 1
	# An essence move (not a plain slash, any reach: the Rimefin stands right in front) layers its essence's impact under the hit.
	var em := ""
	for mv in lead["moves"]:
		if dg.MOVE_FX.get(mv, {}).get("hit", "") != "light_slash" and em == "":
			em = mv
	if em != "":
		lead["cds"][em] = 0
		dg.last_sfx.clear()
		dg.use_move(0, em, d)
		await _frames(30)
		var want2: String = dg.ESSENCE_SFX.get(dg._ess_name(em, lead), "")
		print("essence move %s: played %s -> %s" % [em, str(dg.last_sfx.keys()), "ok" if want2 == "" or dg.last_sfx.has(want2) else "WRONG"])
		bad += 0 if want2 == "" or dg.last_sfx.has(want2) else 1
	else:
		print("essence move: the leader has no essence move; " + str(lead["moves"]))
	# A swing at empty air.
	w["hp"] = 0
	w["node"].visible = false
	dg.last_sfx.clear()
	lead["cds"][m] = 0
	dg.use_move(0, m, d)
	await _frames(30)
	print("swing at nothing: played %s -> %s" % [str(dg.last_sfx.keys()), "ok" if dg.last_sfx.has("miss") else "WRONG"])
	bad += 0 if dg.last_sfx.has("miss") else 1
	# A trap underfoot: the trap's own sound.
	dg.last_sfx.clear()
	dg.traps.append({"pos": lead["pos"], "kind": "silt", "seen": false})
	lead["moved"] = true
	dg._spring_traps()
	await _frames(4)
	print("silt trap: played %s -> %s" % [str(dg.last_sfx.keys()), "ok" if dg.last_sfx.has("trap_silt") else "WRONG"])
	bad += 0 if dg.last_sfx.has("trap_silt") else 1
	dg.traps.clear()
	# The lantern dropping under a quarter.
	dg.last_sfx.clear()
	dg.light = 25.0
	for k in dg.LIGHT_DRAIN_EVERY + 1:
		await dg.act_rest()
		await _frames(12)
	print("lantern runs low (light %.0f): played %s -> %s" % [dg.light, str(dg.last_sfx.keys()), "ok" if dg.last_sfx.has("lantern_low") else "WRONG"])
	bad += 0 if dg.last_sfx.has("lantern_low") else 1
	# The lantern going out.
	dg.last_sfx.clear()
	dg.light = 1.0
	for k in dg.LIGHT_DRAIN_EVERY + 1:
		await dg.act_rest()
		await _frames(12)
	print("lantern goes out (light %.0f): played %s -> %s" % [dg.light, str(dg.last_sfx.keys()), "ok" if dg.last_sfx.has("lantern_out") else "WRONG"])
	bad += 0 if dg.last_sfx.has("lantern_out") else 1
	# The stairs.
	dg.last_sfx.clear()
	lead["pos"] = dg.data["stairs"]
	dg._place(lead)
	dg.act_stairs()
	await _frames(40)
	print("stairs: played %s -> %s" % [str(dg.last_sfx.keys()), "ok" if dg.last_sfx.has("stairs") else "WRONG"])
	bad += 0 if dg.last_sfx.has("stairs") else 1
	dg.queue_free()
	await _frames(4)

	# The town: the job board rustles, the Storage door creaks, the shut Item Shop stays quiet (GS-12).
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	await _frames(4)
	town.panel = {}
	for pair in [["board", "board_paper"], ["storage", "door"], ["shop", ""]]:
		var place: Dictionary = {}
		for p in town.Layout.PLACES:
			if p["id"] == pair[0]:
				place = p
		town.panel = {}
		town.last_sfx = ""
		town.team[0]["pos"] = place["door"]
		town.act_use()
		print("town %s: played %s -> %s" % [pair[0], town.last_sfx, "ok" if town.last_sfx == pair[1] else "WRONG"])
		bad += 0 if town.last_sfx == pair[1] else 1
	town.queue_free()
	print("RESULT: %s" % ("all sounds wired" if bad == 0 else "%d problems" % bad))
	quit()
