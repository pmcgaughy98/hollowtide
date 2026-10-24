extends RefCounted
## The Job Board (Claude, 2026-10-10; slice 6 of docs/design/mystery-dungeon-pivot-2026-10-09.md).
## Structure from the Mystery Dungeon games' rescue boards: a few requests are posted at a time, each
## naming a client, a floor and a reward; the team takes up to four; on that floor the client (or the
## thing it lost) is waiting; reaching it finishes the job on the spot, so a faint later does not undo
## it; the reward and rank points are paid at the board back home. Nothing of theirs is copied: the
## clients are the wild creatures that live on that floor and the rewards are Hollowtide's own items.
##
## Every number here (rewards, rank points, the rank steps) is Claude's proposal for Grok and Preston.
## The record is TeamState.data: "jobs" (taken), "rank" (points), "board" (posted), "board_for".

const DUNGEON := "res://scripts/dungeon/dungeon.gd"   # loaded, not preloaded: dungeon.gd uses this file
const Arena := preload("res://scripts/arena/arena_prototype.gd")
const Lines := preload("res://scripts/creatures/lines.gd")
const POSTED := 4          # requests on the board at once
const TAKE_MAX := 4        # jobs the team can carry into a run
const KINDS := {           # proposals
	"rescue": {"title": "Find %s", "reward": "rally_seed", "count": 1, "pts": 30},
	"lost_item": {"title": "Recover %s's %s", "reward": "reedberry", "count": 2, "pts": 20},
	"delivery": {"title": "Deliver to %s", "reward": "lamp_oil", "count": 1, "pts": 25},   # R4, 2026-10-12
}
## Deliveries (R4 of docs/design/genre-synthesis-2026-10-12.md, 2026-10-12: deliveries, not explorations). A taken
## delivery puts a parcel in the bag; the client waits on its floor; the condition is judged at the client's
## feet, and the pay follows it: met, the reward is MET_COUNT times and MET_PTS more rank; missed, the plain pay.
## A faint loses the bag, parcels with it, and those deliveries are off the slate. "Dry" waits for the water
## floors (R5). Every number is a proposal for Grok.
const CONDITIONS := {
	"lit": {"ask": "before the lantern goes out", "met": "the lantern still lit", "missed": "the lantern was out"},
	"quick": {"ask": "within %d turns", "met": "in good time", "missed": "late"},
	"careful": {"ask": "without springing a trap", "met": "not a trap sprung", "missed": "a trap went off on the way"},
}
const MET_COUNT := 2
const MET_PTS := 15
const QUICK_TURNS_PER_FLOOR := 70
const PARCEL := "parcel"   # the bag item a taken delivery adds (dungeon.gd ITEMS)
const FLOOR_PTS := 10      # each floor deeper adds this many rank points (proposal)
const LOST_ITEMS := ["river_stone", "lamp_oil", "reedberry"]
const RANK_STEPS := [0, 60, 150, 300, 500]   # points to reach Courier Rank 1..5 (proposal; rank names are Preston's)


## Fresh requests for a board. The same seed always posts the same four.
## Each client posts at most once a board while there are at least as many clients as requests (Claude, 2026-10-24,
## pass 4 T8 / LV-27: the first board was four Canvaswing jobs). A client already on the board is swapped for one
## that is not, from the same floor's creatures when one is left, else from the nearest floor's. The swap draws
## from its own stream, so every floor, kind, item, condition and payment rolled here is the one it was.
static func post(seed: int) -> Array:
	var c: Dictionary = load(DUNGEON).get_script_constant_map()
	var spawns: Dictionary = c["FLOOR_SPAWNS"]
	var floors := int(c["FLOORS"])
	var rng := RandomNumberGenerator.new()
	rng.seed = seed * 7919 + 13
	var swap := RandomNumberGenerator.new()
	swap.seed = seed * 104729 + 7
	var once := clients(spawns, floors).size() >= POSTED
	var posted := {}
	var out: Array = []
	for k in POSTED:
		var fl := rng.randi_range(1, floors)
		var pool: Array = spawns.get(fl, spawns[1])
		var who: Array = pool[rng.randi_range(0, pool.size() - 1)]
		if once and posted.has(_client_key(who)):
			who = _fresh_client(spawns, floors, fl, posted, swap)
		posted[_client_key(who)] = true
		var kind: String = KINDS.keys()[rng.randi_range(0, KINDS.size() - 1)]
		var job := {"id": "%d_%d" % [seed, k], "kind": kind, "line": who[0], "stage": who[1], "floor": fl, "done": false,
			"reward": KINDS[kind]["reward"], "count": KINDS[kind]["count"], "pts": KINDS[kind]["pts"] + FLOOR_PTS * (fl - 1)}
		if kind == "lost_item":
			job["item"] = LOST_ITEMS[rng.randi_range(0, LOST_ITEMS.size() - 1)]
		elif kind == "delivery":
			job["cond"] = CONDITIONS.keys()[rng.randi_range(0, CONDITIONS.size() - 1)]
			if job["cond"] == "quick":
				job["turns"] = QUICK_TURNS_PER_FLOOR * fl
		out.append(job)
	return out


## Every creature that can be a client: each floor's wild creatures, [line, stage], once each.
static func clients(spawns: Dictionary, floors: int) -> Array:
	var out: Array = []
	var seen := {}
	for f in range(1, floors + 1):
		for who in spawns.get(f, spawns[1]):
			if not seen.has(_client_key(who)):
				seen[_client_key(who)] = true
				out.append(who)
	return out


static func _client_key(who: Array) -> String:
	return "%d_%d" % [int(who[0]), int(who[1])]


## A client not on the board yet: from floor `fl`'s creatures if one is left, else the nearest floor's (the lower
## first on a tie). The board keeps the floor it rolled, so the pay is the same.
static func _fresh_client(spawns: Dictionary, floors: int, fl: int, posted: Dictionary, swap: RandomNumberGenerator) -> Array:
	for dist in floors:
		for f in [fl - dist, fl + dist]:
			if f < 1 or f > floors:
				continue
			var left: Array = spawns.get(f, spawns[1]).filter(func(w: Array) -> bool: return not posted.has(_client_key(w)))
			if not left.is_empty():
				return left[swap.randi_range(0, left.size() - 1)]
	return spawns.get(fl, spawns[1])[0]   # every client is on the board already (the caller checks there are enough)


## The condition as the board asks it: "before the lantern goes out".
static func cond_text(job: Dictionary) -> String:
	var c: Dictionary = CONDITIONS.get(String(job.get("cond", "")), {})
	if c.is_empty():
		return ""
	var ask := String(c["ask"])
	return ask % int(job.get("turns", 0)) if ask.contains("%d") else ask


## Judged at the client's feet, from the run as it stands.
static func judge(job: Dictionary, run: Node) -> bool:
	match String(job.get("cond", "")):
		"lit":
			return float(run.get("light")) > 0.0
		"quick":
			return int(run.get("turn")) <= int(job.get("turns", 0))
		"careful":
			return int(run.get("traps_sprung")) == 0
	return true


## How it went, once judged: "the lantern still lit" or "the lantern was out".
static func result_text(job: Dictionary) -> String:
	var c: Dictionary = CONDITIONS.get(String(job.get("cond", "")), {})
	if c.is_empty():
		return ""
	return String(c["met"] if job.get("met", false) else c["missed"])


## A faint loses the bag and the parcels in it: the deliveries not yet made come off the slate.
## Returns [the jobs that stay, the names of the clients whose parcels were lost].
static func drop_parcels(jobs: Array) -> Array:
	var keep: Array = []
	var lost: Array = []
	for j in jobs:
		if j["kind"] == "delivery" and not j.get("done", false):
			lost.append(client_name(j))
		else:
			keep.append(j)
	return [keep, lost]


static func _add_parcel(data: Dictionary, n: int) -> void:
	var bag: Dictionary = data.get("bag", {"reedberry": 1})   # a team that has not run yet starts with the dungeon's one berry
	var c: int = int(bag.get(PARCEL, 0)) + n
	if c > 0:
		bag[PARCEL] = c
	else:
		bag.erase(PARCEL)
	data["bag"] = bag


static func client_form(job: Dictionary) -> String:
	return Lines.of(int(job["line"]))["forms"][int(job["stage"])][0]


static func client_name(job: Dictionary) -> String:
	return load(Lines.of(int(job["line"]))["forms"][int(job["stage"])][1]).creature_name


static func item_name(kind: String) -> String:
	return String(load(DUNGEON).get_script_constant_map()["ITEMS"][kind]["name"])


static func title(job: Dictionary) -> String:
	if job["kind"] == "lost_item":
		return KINDS["lost_item"]["title"] % [client_name(job), item_name(job["item"])]
	return KINDS[job["kind"]]["title"] % client_name(job)


## The Hollow a request is in (Claude, 2026-10-24, pass 5 T8 / LV-33). post() draws every client from Rootbank Warren's
## creatures (dungeon.gd FLOOR_SPAWNS, its "first" dungeon), so its requests are there; a job that names its own
## "hollow" keeps it. (dungeon.gd still places a client on its floor of whichever Hollow the team runs.)
const HOLLOW := "first"


static func hollow_of(job: Dictionary) -> String:
	return String(job.get("hollow", HOLLOW))


## "Rootbank Warren B3F": the Hollow's name and the floor, as the board and its messages print where a request is.
static func place_text(job: Dictionary) -> String:
	var dungeons: Dictionary = load(DUNGEON).get_script_constant_map()["DUNGEONS"]
	var name := String(dungeons.get(hollow_of(job), {}).get("name", ""))
	return ("%s B%dF" % [name, int(job["floor"])]).strip_edges()


## The taken requests not yet done whose clients wait in Hollow `hollow_id` (the way down marks those Hollows).
static func waiting_in(data: Dictionary, hollow_id: String) -> Array:
	return data.get("jobs", []).filter(func(j: Dictionary) -> bool: return not j.get("done", false) and hollow_of(j) == hollow_id)


## [rank, points needed for the next rank or -1 at the top].
static func rank_of(pts: int) -> Array:
	var r := 1
	for k in RANK_STEPS.size():
		if pts >= RANK_STEPS[k]:
			r = k + 1
	return [r, RANK_STEPS[r] if r < RANK_STEPS.size() else -1]


## A new board after every run (cleared or fainted), the way the games repost each day. Requests
## already taken stay with the team.
static func refresh(data: Dictionary) -> void:
	var runs: int = int(data.get("cleared", 0)) + int(data.get("faints", 0))
	if data.get("board_for", -1) == runs and data.has("board"):
		return
	data["board_for"] = runs
	data["board"] = post(runs + 1)


## What the board shows, in order: the jobs the team carries, then the open requests.
static func rows(data: Dictionary) -> Array:
	var out: Array = []
	var held := {}
	for j in data.get("jobs", []):
		out.append(j)
		held[j["id"]] = true
	for j in data.get("board", []):
		if not held.has(j["id"]):
			out.append(j)
	return out


static func is_taken(data: Dictionary, job: Dictionary) -> bool:
	for j in data.get("jobs", []):
		if j["id"] == job["id"]:
			return true
	return false


## Take a request, or put a taken one back. Returns what to say.
static func toggle(data: Dictionary, job: Dictionary) -> String:
	if not data.has("jobs"):
		data["jobs"] = []
	if is_taken(data, job):
		data["jobs"] = data["jobs"].filter(func(j: Dictionary) -> bool: return j["id"] != job["id"])
		if job["kind"] == "delivery":
			_add_parcel(data, -1)
		return "Put back: %s." % title(job)
	if data["jobs"].size() >= TAKE_MAX:
		return "The satchel holds %d jobs. Put one back first." % TAKE_MAX
	data["jobs"].append(job.duplicate(true))
	if job["kind"] == "delivery":
		_add_parcel(data, 1)
		return "Taken: %s. %s, %s. The parcel is in the bag." % [title(job), place_text(job), cond_text(job)]
	return "Taken: %s. %s." % [title(job), place_text(job)]


## Pay every finished job: its items go in the bag, its points to the rank. Returns one line per job.
static func pay(data: Dictionary) -> Array:
	var said: Array = []
	var keep: Array = []
	for j in data.get("jobs", []):
		if not j.get("done", false):
			keep.append(j)
			continue
		var count: int = int(j["count"])
		var pts: int = int(j["pts"])
		var note := ""
		if j["kind"] == "delivery":   # pay by the condition at arrival (R4)
			if j.get("met", false):
				count *= MET_COUNT
				pts += MET_PTS
			note = " (%s)" % result_text(j)
		var bag: Dictionary = data.get("bag", {})
		bag[j["reward"]] = int(bag.get(j["reward"], 0)) + count
		data["bag"] = bag
		var before: int = rank_of(int(data.get("rank", 0)))[0]
		data["rank"] = int(data.get("rank", 0)) + pts
		var line := "%s%s: %s x%d, +%d rank" % [title(j), note, item_name(j["reward"]), count, pts]
		if rank_of(int(data["rank"]))[0] > before:
			line += ". Courier Rank %d!" % rank_of(int(data["rank"]))[0]
		said.append(line)
		# A finished request leaves the board too.
		data["board"] = data.get("board", []).filter(func(b: Dictionary) -> bool: return b["id"] != j["id"])
	data["jobs"] = keep
	return said
