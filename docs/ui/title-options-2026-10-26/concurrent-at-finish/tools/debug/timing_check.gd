extends SceneTree
## Timing probe (Claude, 2026-10-22, factory lane 7, CR-01). How long a floor takes to build, how long Highbank and
## two rooms take to arrive, and how much static memory twenty floor builds leave behind. The critic measured 2.3 to
## 5.7 s a floor on 2026-10-21; its probe went with its scratchpad, so this one is written fresh. Judges two things:
## every _build_floor at or under BUILD_MAX seconds, and static memory growth over the twenty builds at or under
## MEM_MAX_MB. The arrival and room times, the mean by look, and one rebuild of a floor already built (what lane 1's
## floor-image cache, keyed by dungeon, floor and seed, can save) are printed for reading. Rerun after that cache lands:
## twenty new floors also show whether the cache lets memory grow without end.
## Normal floors only: a boss floor starts its scene on build (the crew, the Warden), and that scene would play on
## in the background while the next floor is timed.
## Highbank (Claude, 2026-10-23, T1 / LO-03): the first arrival paints the street and is printed with each step of
## hub_town._ready; after two rooms, a warm arrival reuses the session's kept picture and is judged at or under
## WARM_MAX seconds (it took 5.2 to 6.1 s before the picture was kept).
##   Godot --headless --path . --fixed-fps 30 --script res://tools/debug/timing_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const BUILD_MAX := 3.5       # seconds, one _build_floor
const MEM_MAX_MB := 20.0     # static memory growth over BUILDS floors
const BUILDS := 20
const WARM_MAX := 2.5        # seconds, a Highbank arrival once the street is painted this session
# (dungeon, floor): the normal floors of the three dungeons; the plan repeats with a new seed each lap.
const FLOOR_PLAN := [["mouth", 1], ["mouth", 2], ["mouth", 3], ["mouth", 4], ["first", 1], ["first", 2], ["first", 3], ["hollow", 1], ["hollow", 2]]
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _mb(bytes: int) -> float:
	return bytes / (1024.0 * 1024.0)


## Milliseconds since `t0` (a Time.get_ticks_usec() reading).
func _ms(t0: int) -> float:
	return (Time.get_ticks_usec() - t0) / 1000.0


var _reused := false   # the last arrival's street_cached


## One Highbank arrival: hub_town's _ready timed whole, then its own steps (ready_ms) printed in order.
func _arrive(what: String) -> float:
	var town: Node = load("res://scenes/hub_town.tscn").instantiate()
	TeamState.give_to(town)
	town.poll_input = false
	var t := Time.get_ticks_usec()
	root.add_child(town)   # _ready paints the street (or reuses this session's picture) and places the team
	var town_ms := _ms(t)
	await _frames(3)
	_reused = town.street_cached
	print("Highbank arrival, %s (hub_town _ready): %.0f ms%s" % [what, town_ms, ", street picture reused" if _reused else ", street painted"])
	for step in town.ready_ms:
		print("  %-26s %7.1f ms" % [step, town.ready_ms[step]])
	town.queue_free()
	await _frames(2)
	return town_ms


func _run() -> void:
	# 1. The dungeon scene, then twenty floor builds in the same instance, each timed.
	TeamState.start([[0, 0], [1, 0]])
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.poll_input = false
	dg.floor_seed = 1
	TeamState.give_to(dg)
	dg.dungeon = "mouth"
	var t := Time.get_ticks_usec()
	root.add_child(dg)   # _ready builds the Mouth's B1F on seed 1
	var ready_ms := _ms(t)
	await _frames(3)
	print("Dungeon scene ready with its first floor (Hollow Mouth B1F, seed 1): %.0f ms" % ready_ms)
	var mem0 := OS.get_static_memory_usage()
	var worst := 0.0
	var worst_what := ""
	var total := 0.0
	var by_look := {}   # look -> [total ms, floors]
	print("  %-16s %-5s %-6s %-10s %-9s %s" % ["dungeon", "floor", "seed", "look", "size", "build"])
	for k in BUILDS:
		var plan: Array = FLOOR_PLAN[k % FLOOR_PLAN.size()]
		var lap: int = 1 + k / FLOOR_PLAN.size()
		dg.dungeon = plan[0]
		dg.floor_n = plan[1]
		dg.floor_seed = lap * 101 + int(plan[1])
		t = Time.get_ticks_usec()
		dg._build_floor(true)
		var ms := _ms(t)
		await _frames(2)   # the floor before it is freed now (queue_free), so memory reads whole floors
		var look: String = dg.DUNGEONS[dg.dungeon]["looks"].get(dg.floor_n, "bank")
		print("  %-16s %-5s %-6d %-10s %3dx%-5d %6.0f ms%s" % [dg.DUNGEONS[dg.dungeon]["name"], "B%dF" % dg.floor_n, dg.floor_seed, look, dg.data["w"], dg.data["h"], ms, "  (over %.1f s)" % BUILD_MAX if ms > BUILD_MAX * 1000.0 else ""])
		total += ms
		var sum: Array = by_look.get(look, [0.0, 0])
		by_look[look] = [sum[0] + ms, sum[1] + 1]
		if ms > worst:
			worst = ms
			worst_what = "%s B%dF seed %d" % [dg.DUNGEONS[dg.dungeon]["name"], dg.floor_n, dg.floor_seed]
	await _frames(4)
	var mem1 := OS.get_static_memory_usage()
	var growth := _mb(mem1 - mem0)
	_ok("Every floor builds within %.1f s: slowest %.2f s (%s), mean %.2f s over %d floors" % [BUILD_MAX, worst / 1000.0, worst_what, total / 1000.0 / BUILDS, BUILDS], worst <= BUILD_MAX * 1000.0)
	_ok("Static memory grows at most %.0f MB over %d floors: %.1f MB -> %.1f MB (%+.1f MB)" % [MEM_MAX_MB, BUILDS, _mb(mem0), _mb(mem1), growth], growth <= MEM_MAX_MB)
	for look in by_look:
		print("  mean build on a %s floor: %.2f s over %d floors" % [look, by_look[look][0] / 1000.0 / by_look[look][1], by_look[look][1]])
	# The same floor again (dungeon, floor and seed of the last build): what a floor-image cache can save.
	t = Time.get_ticks_usec()
	dg._build_floor(true)
	print("  the last floor built again, same seed: %.0f ms" % _ms(t))
	await _frames(2)
	dg.queue_free()
	await _frames(2)
	# 2. Highbank's first arrival (it paints the street), two rooms, then a warm arrival (the kept picture), each
	# with every step of hub_town._ready. Only the warm one is judged (T1); the first stays printed.
	var first_ms := await _arrive("first")
	# The rooms a player's town makes ahead after its arrival (hub_town.gd _rooms_ahead, on a worker; pass 7 T2), made
	# here on the main thread with TownRoom.prepare, since a headless check runs no warm-up. Printed for reading.
	var TownRoom: GDScript = load("res://scripts/town/town_room.gd")
	for id in ["hall", "hall_low", "home"]:
		t = Time.get_ticks_usec()
		TownRoom.prepare(id)
		print("TownRoom.prepare('%s'): %.0f ms" % [id, _ms(t)])
	for id in ["hall", "hall_low", "home"]:
		var room: Node = load("res://scenes/town_room.tscn").instantiate()
		room.room_id = id
		room.poll_input = false
		t = Time.get_ticks_usec()
		root.add_child(room)
		var room_ms := _ms(t)
		await _frames(3)
		print("Room '%s' (town_room _ready): %.0f ms" % [id, room_ms])
		room.queue_free()
		await _frames(2)
	TeamState.data["arrive_at"] = "home"   # back out of Home's door, as the room does
	var warm_ms := await _arrive("warm")
	_ok("A warm Highbank arrival within %.1f s: %.2f s, the street picture reused %s (the first arrival, which paints it, took %.2f s)" % [WARM_MAX, warm_ms / 1000.0, str(_reused), first_ms / 1000.0], warm_ms <= WARM_MAX * 1000.0 and _reused)
	print("Static memory at the end: %.1f MB" % _mb(OS.get_static_memory_usage()))
	print("TIMING: %s" % ("PASS" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)
