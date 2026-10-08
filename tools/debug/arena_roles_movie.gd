extends SceneTree
## Records three role matchups, one PNG per frame, and prints every move each side used
## (Claude, 2026-10-07).  Godot --path . --fixed-fps 30 --script res://tools/debug/arena_roles_movie.gd
## 1. You Stormwick (skirmisher) vs a Rampartroot tank.
## 2. You Rampartroot (tank) vs a Scourmaw assassin, which then dives (Undertow).
## 3. You Scourmaw (assassin) vs a darting Stormwick, then your own Undertow.
var OUT := ProjectSettings.globalize_path("user://arena_roles_movie/")
var arena: Node2D
var n := 0
var used := {}
var seg := ""

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	for f in DirAccess.get_files_at(OUT):
		DirAccess.remove_absolute(OUT + f)
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	await process_frame
	seg = "1"
	_matchup(0, 2, 1, 2)
	await _play_for(240, 45.0, true)
	seg = "2"
	_matchup(1, 2, 2, 2)
	await _play_for(180, 25.0, true)
	arena._fighters[1]["meter"] = 100   # the rival's AI fires its own signature
	await _play_for(90, 25.0, false)
	print("rampartroot hp after the dive: ", arena._fighters[0]["hp"], "/", arena._fighters[0]["max_hp"])
	seg = "3"
	_matchup(2, 2, 0, 2)
	await _play_for(180, 120.0, true)
	arena._fighters[0]["meter"] = 100
	arena.signature(0)
	await _play_for(80, 120.0, false)
	print("frames ", n)
	var keys := used.keys()
	keys.sort()
	for k in keys:
		print("  ", k, " x", used[k])
	quit()

func _matchup(you: int, ys: int, rival: int, rs: int) -> void:
	arena._you = you; arena._you_stage = ys; arena._rival = rival; arena._rival_stage = rs
	arena._new_match()

## Your movement: keep about `keep` pixels from the rival while circling it.
func _play_for(frames: int, keep: float, hold_rival_meter: bool) -> void:
	for i in frames:
		var me: Dictionary = arena._fighters[0]
		var to: Vector2 = arena._fighters[1]["body"].position - me["body"].position
		var d := to.length()
		arena.debug_input = to.normalized() * clampf((d - keep) / 30.0, -1.0, 1.0) + to.normalized().orthogonal() * 0.6
		if hold_rival_meter:
			arena._fighters[1]["meter"] = 0
		for l in arena._labels:
			if l["t"] < 0.034:
				var key: String = seg + " " + ("you " if l["who"] == 0 else "rival ") + arena._fighters[l["who"]]["name"] + ": " + l["text"]
				used[key] = used.get(key, 0) + 1
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OUT + "f%04d.png" % n)
		n += 1
