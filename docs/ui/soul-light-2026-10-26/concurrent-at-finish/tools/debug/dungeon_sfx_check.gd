extends SceneTree
## The ElevenLabs sounds (Claude, 2026-10-09): every built sound loads, and the game plays the right
## one at the right moment: a real attack (swing, the hit, the move's essence impact), a miss, the
## stairs, a pickup, a trap, the lantern running low, and the town's job board and doors.
## Reads the dungeon's last_sfx (sound name -> turn) and the town's last_sfx.
## Two markers from the dungeon's sfx_log (Claude, 2026-10-24, factory pass 6): a rest by key is heard once a streak,
## the autopilot's never (D8); I, Escape, L, L open and shut the bag and the log to menu_open and menu_close (D5).
## A third (pass 8 D8, 2026-10-26): a full bag's "denied" is on the UI bus.
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


## A key pressed and let go, three frames each way, as a player taps it (the dungeon reads it once a frame).
func _key(code: Key) -> void:
	for down in [true, false]:
		var ev := InputEventKey.new()
		ev.keycode = code
		ev.physical_keycode = code
		ev.pressed = down
		Input.parse_input_event(ev)
		await _frames(3)


## The sounds of `take` ("dungeon/<name>.wav") in the dungeon's sound log, each [frame, take, bus].
func _started(dg: Node, take: String) -> Array:
	return dg.sfx_log.filter(func(s: Array) -> bool: return String(s[1]) == take)


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
	# Resting by key (LO6-05, D8): one soft breath, REST_TAKE, at the start of a streak of five; another after a step
	# breaks the streak; none for five of the autopilot's rests (act_rest with by_key off, as the checks rest too).
	var take: String = "dungeon/%s.wav" % dg.REST_TAKE
	dg.sfx_log.clear()
	for k in 5:
		await dg.act_rest(true)
		await _frames(2)
	await _frames(6)
	var streak: Array = _started(dg, take)
	var step := Vector2i.ZERO
	for dd in dg.DIRS:
		if step == Vector2i.ZERO and dg.can_step(lead["pos"], dd) and dg._occupant(lead["pos"] + dd) < 0:
			step = dd
	await dg.act_move(step)
	await _frames(4)
	dg.sfx_log.clear()
	await dg.act_rest(true)
	await _frames(6)
	var after_step: int = _started(dg, take).size()
	dg.sfx_log.clear()
	for k in 5:
		await dg.act_rest()
		await _frames(2)
	await _frames(6)
	var auto_n: int = _started(dg, take).size()
	var ok_rest: bool = streak.size() == 1 and String(streak[0][2]) == "SFX" and after_step == 1 and auto_n == 0
	print("rest by key: a streak of 5 started %s %d time(s)%s, after a step %d, the autopilot's 5 rests %d -> %s" % [take, streak.size(), (" on " + String(streak[0][2])) if streak.size() > 0 else "", after_step, auto_n, "ok" if ok_rest else "WRONG"])
	bad += 0 if ok_rest else 1
	# The bag and the message log by key (L6-31, D5): I opens the bag and Escape shuts it, L opens the log and L shuts
	# it, each to the menu's own open and close on the UI bus (closing the bag played cancel.wav, kept for backing out
	# of a choice). The floor's first lessons are marked as said, so no line comes up between the keys.
	for flag in ["taught_wild", "taught_item", "taught_lantern"]:
		dg.story[flag] = true
	dg.talk.clear()
	dg.poll_input = true
	dg.sfx_log.clear()
	for key in [KEY_I, KEY_ESCAPE, KEY_L, KEY_L]:
		await _key(key)
	dg.poll_input = false
	var ui_heard: Array = dg.sfx_log.filter(func(s: Array) -> bool: return String(s[2]) == "UI").map(func(s: Array) -> String: return String(s[1]).get_file().get_basename())
	var ok_menu: bool = ui_heard == ["menu_open", "menu_close", "menu_open", "menu_close"] and not dg.bag_open and not paused
	print("I, Escape, L, L: UI bus %s, bag open %s, paused %s -> %s" % [str(ui_heard), str(dg.bag_open), str(paused), "ok" if ok_menu else "WRONG"])
	bad += 0 if ok_menu else 1
	# "denied" answers the player, so it plays on the UI bus as the town's does (L33, D8, Claude, 2026-10-26): a full
	# bag turning down a Lamp Oil on the leader's tile.
	var bag_was: Dictionary = dg.bag.duplicate()
	dg.bag = {}
	for k in dg.BAG_KINDS:
		dg.bag["full_%d" % k] = 1
	dg.floor_items.append({"pos": lead["pos"], "kind": "lamp_oil"})
	dg.sfx_log.clear()
	dg._pick_up()
	await _frames(6)
	var denied: Array = _started(dg, "dungeon/denied.wav")
	var ok_denied: bool = denied.size() == 1 and String(denied[0][2]) == "UI"
	print("full bag: denied started %d time(s)%s -> %s" % [denied.size(), (" on " + String(denied[0][2])) if denied.size() > 0 else "", "ok" if ok_denied else "WRONG"])
	bad += 0 if ok_denied else 1
	dg.floor_items = dg.floor_items.filter(func(it: Dictionary) -> bool: return it["pos"] != lead["pos"])
	dg.bag = bag_was
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
		town.enter_area(town.Layout.area_of(pair[0]), pair[0])   # Highbank v2: the place's area first (lane A, 2026-10-26)
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
