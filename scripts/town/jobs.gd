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
const POSTED := 4          # requests on the board at once
const TAKE_MAX := 4        # jobs the team can carry into a run
const KINDS := {           # proposals
	"rescue": {"title": "Find %s", "reward": "rally_seed", "count": 1, "pts": 30},
	"lost_item": {"title": "Recover %s's %s", "reward": "reedberry", "count": 2, "pts": 20},
}
const FLOOR_PTS := 10      # each floor deeper adds this many rank points (proposal)
const LOST_ITEMS := ["river_stone", "lamp_oil", "reedberry"]
const RANK_STEPS := [0, 60, 150, 300, 500]   # points to reach Courier Rank 1..5 (proposal; rank names are Preston's)


## Fresh requests for a board. The same seed always posts the same four.
static func post(seed: int) -> Array:
	var c: Dictionary = load(DUNGEON).get_script_constant_map()
	var spawns: Dictionary = c["FLOOR_SPAWNS"]
	var rng := RandomNumberGenerator.new()
	rng.seed = seed * 7919 + 13
	var out: Array = []
	for k in POSTED:
		var fl := rng.randi_range(1, int(c["FLOORS"]))
		var pool: Array = spawns.get(fl, spawns[1])
		var who: Array = pool[rng.randi_range(0, pool.size() - 1)]
		var kind: String = KINDS.keys()[rng.randi_range(0, KINDS.size() - 1)]
		var job := {"id": "%d_%d" % [seed, k], "kind": kind, "line": who[0], "stage": who[1], "floor": fl, "done": false,
			"reward": KINDS[kind]["reward"], "count": KINDS[kind]["count"], "pts": KINDS[kind]["pts"] + FLOOR_PTS * (fl - 1)}
		if kind == "lost_item":
			job["item"] = LOST_ITEMS[rng.randi_range(0, LOST_ITEMS.size() - 1)]
		out.append(job)
	return out


static func client_form(job: Dictionary) -> String:
	return Arena.LINES[int(job["line"])]["forms"][int(job["stage"])][0]


static func client_name(job: Dictionary) -> String:
	return load(Arena.LINES[int(job["line"])]["forms"][int(job["stage"])][1]).creature_name


static func item_name(kind: String) -> String:
	return String(load(DUNGEON).get_script_constant_map()["ITEMS"][kind]["name"])


static func title(job: Dictionary) -> String:
	if job["kind"] == "lost_item":
		return KINDS["lost_item"]["title"] % [client_name(job), item_name(job["item"])]
	return KINDS[job["kind"]]["title"] % client_name(job)


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
		return "Put back: %s." % title(job)
	if data["jobs"].size() >= TAKE_MAX:
		return "The satchel holds %d jobs. Put one back first." % TAKE_MAX
	data["jobs"].append(job.duplicate(true))
	return "Taken: %s. B%dF." % [title(job), int(job["floor"])]


## Pay every finished job: its items go in the bag, its points to the rank. Returns one line per job.
static func pay(data: Dictionary) -> Array:
	var said: Array = []
	var keep: Array = []
	for j in data.get("jobs", []):
		if not j.get("done", false):
			keep.append(j)
			continue
		var bag: Dictionary = data.get("bag", {})
		bag[j["reward"]] = int(bag.get(j["reward"], 0)) + int(j["count"])
		data["bag"] = bag
		var before: int = rank_of(int(data.get("rank", 0)))[0]
		data["rank"] = int(data.get("rank", 0)) + int(j["pts"])
		var line := "%s: %s x%d, +%d rank" % [title(j), item_name(j["reward"]), int(j["count"]), int(j["pts"])]
		if rank_of(int(data["rank"]))[0] > before:
			line += ". Courier Rank %d!" % rank_of(int(data["rank"]))[0]
		said.append(line)
		# A finished request leaves the board too.
		data["board"] = data.get("board", []).filter(func(b: Dictionary) -> bool: return b["id"] != j["id"])
	data["jobs"] = keep
	return said
