extends SceneTree
## The Vitrecrag line in the arena (Claude, 2026-10-07): the three forms walking, Molten
## Glass in a 3v3, Kiln Heat filling while it stands, and an AI 1v1 against Rampartroot.
## Verdicts (Claude, 2026-10-24, factory pass 4): every step ends "-> ok" or "-> WRONG". Kiln Heat
## now holds Vitrecrag still (its own AI used to walk it, which cools the kiln, so the heat read
## 0), and Molten Glass is staged with the rivals held inside the ring.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_vitrecrag_check.gd
## Stills to docs/creatures/arena-vitrecrag-2026-10-07/.

const OUT := "res://docs/creatures/arena-vitrecrag-2026-10-07/"
var arena: Node2D

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	arena = load("res://scenes/arena_prototype.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	arena.auto_you = true
	seed(9)
	for stage in 3:
		arena.team_size = 1
		arena._you = 4; arena._you_stage = stage
		arena._rival = 3; arena._rival_stage = stage
		arena._new_match()
		await _frames(45)
		_save("line_stage%d" % (stage + 1))
	# Kiln Heat: held still, heat should climb to 100 in about 2.2 s; walking cools it. You
	# steer nothing and the rival is held, so nothing walks Vitrecrag or knocks it about.
	arena.auto_you = false
	arena.poll_input = false
	arena._player_dir = Vector2.ZERO
	arena._you_stage = 2; arena._rival_stage = 2
	arena._new_match()
	await _frames(2)
	var me: Dictionary = arena._fighters[0]
	_hold(arena._fighters[1])
	me["heat"] = 0.0
	await _frames(75)
	var heat: float = me["heat"]
	me["heat"] = 0.0
	var cold: int = arena._dmg("molten_beam", 0, 1)
	me["heat"] = 100.0
	var hot: int = arena._dmg("molten_beam", 0, 1)
	_check("Kiln Heat", heat >= 100.0 and hot == roundi(cold * arena.KILN_BONUS),
		"after 2.5 s standing (walk time %.1f s): %.0f; cold beam %d, hot beam %d (x%.1f)" % [me["walk"], heat, cold, hot, arena.KILN_BONUS])
	arena.auto_you = true
	arena.poll_input = true
	# Molten Glass in a 3v3: the rivals held inside the ring round Vitrecrag.
	arena.team_size = 3
	arena._you = 4; arena._rival = 0
	arena._new_match()
	await _frames(3)
	for f in arena._fighters:
		_hold(f)
	arena._fighters[0]["stun"] = 0.0
	await _frames(37)
	# Set down round where Vitrecrag stands now (its AI may have stepped since).
	var at: Vector2 = arena._fighters[0]["body"].position
	var spots: Array = [Vector2(30, 4), Vector2(-24, -12), Vector2(6, -24)]
	var k := 0
	for j in arena._fighters.size():
		if arena._fighters[j]["team"] == 1:
			arena._fighters[j]["body"].position = at + spots[k]
			k += 1
	arena._fighters[0]["meter"] = 100
	arena.signature(0)
	var hp_before: Array = arena._fighters.map(func(f): return f["hp"])
	for t in [1.3 + 0.5, 1.3 + 1.0, 1.3 + 1.4, 1.3 + 1.8]:
		while arena._sig.active and arena._sig._t < t:
			await process_frame
		_save("glass_%.2fs" % t)
	await _frames(20)
	var line := ""
	var all_hurt := true
	for j in arena._fighters.size():
		var f: Dictionary = arena._fighters[j]
		line += "  [team %d] %s %d->%d" % [f["team"], f["name"], hp_before[j], f["hp"]]
		if f["team"] == 1 and f["hp"] >= hp_before[j]:
			all_hurt = false
	_check("Molten Glass hurt every rival", all_hurt, line.strip_edges())
	# AI 1v1 against Rampartroot.
	arena.team_size = 1
	arena._you = 4; arena._rival = 1
	arena._new_match()
	var frames := 0
	while arena._winner < 0 and frames < 2700:
		await process_frame
		frames += 1
		if frames == 150:
			_save("match")
	var w: Dictionary = arena._fighters[arena._winner] if arena._winner >= 0 else {}
	_check("Match vs Rampartroot", arena._winner >= 0, "%s after %.0f s; Vitrecrag dealt %d, Rampartroot dealt %d" % [w.get("name", "draw"), frames / 30.0,
		arena._fighters[0]["dealt"], arena._fighters[1]["dealt"]])
	quit()


## Holds fighter f still for a staged step: a long stun, and no charm or dodge to break it
## (Beads cleanse a stun; Claude, 2026-10-24).
func _hold(f: Dictionary) -> void:
	f["stun"] = 60.0
	f["charm_cd"] = 99.0
	f["dodge_cd"] = 99.0


func _check(label: String, ok: bool, detail: String) -> void:
	print("%s: %s -> %s" % [label, detail, "ok" if ok else "WRONG"])


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _save(name: String) -> void:
	root.get_texture().get_image().save_png(OUT + name + ".png")
