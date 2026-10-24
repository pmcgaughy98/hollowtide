extends SceneTree
## The matchup picker (Claude, 2026-10-09): every slot on both sides is chosen, who you steer and
## your charm land on the right creature, the map and rocks follow, and a 2v2 works.
## Judged since Claude, 2026-10-24 (H23): the six fighters are the picked forms (names read
## from Arena.LINES), you steer the second slot with its charm, map and rocks follow, and the
## 2v2 has four fighters with the three named picks in place.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/arena_picker_check.gd
## Stills to docs/creatures/arena-picker-2026-10-09/.

const OUT := "res://docs/creatures/arena-picker-2026-10-09/"
const Arena := preload("res://scripts/arena/arena_prototype.gd")
var fails := 0

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var picker: Node2D = load("res://scenes/move_preview.tscn").instantiate()
	root.add_child(picker)
	await process_frame
	await process_frame
	_save("picker")
	# A 3v3 with every slot chosen: Warden, Galeshear, Starward against Scourmaw, Oxbowarchon, Vitrecrag.
	picker._size = 3
	picker._teams = [[[7, 2], [8, 2], [6, 2]], [[2, 2], [5, 2], [4, 2]]]
	picker._control = 1
	picker._charm = "aegis"
	picker._map = 1
	picker._rocks = false
	picker._build()
	await process_frame
	_save("picker_filled")
	picker.start_fight()
	await process_frame
	await process_frame
	var arena: Node2D = picker._arena
	var names := []
	for f in arena._fighters:
		names.append("%s:%s" % ["you" if f["team"] == 0 else "foe", f["name"]])
	print("3v3 from the picker: %s; you steer %s with charm %s; arena %d, rocks %d" % [str(names), arena._fighters[arena.controlled]["name"], arena._fighters[arena.controlled]["charm"], arena._arena, arena._rocks.size()])
	_save("fight_3v3")
	var want: Array = [[], []]
	for side in 2:
		for slot in picker._teams[side]:
			if slot != null:
				want[side].append(_form_name(slot[0], slot[1]))
	var got: Array = _names_by_team(arena)
	_ok("The six fighters are the picked forms in slot order", arena._fighters.size() == 6 and got[0] == want[0] and got[1] == want[1])
	var you_slots: Array = _slots_of(arena, 0)
	_ok("You steer the second you-slot", you_slots.size() >= 2 and arena.controlled == you_slots[1])
	_ok("Your charm is aegis", arena._fighters[arena.controlled]["charm"] == "aegis")
	_ok("The map is arena 1 with no rocks", arena._arena == 1 and arena._rocks.size() == 0)
	# Escape back, then a 2v2 with one slot left for the random fill.
	arena.queue_free()
	picker._arena = null
	picker._ui.visible = true
	picker._size = 2
	picker._teams = [[[0, 0], null, null], [[3, 1], [1, 2], null]]
	picker._control = 0
	picker._charm = ""
	picker._map = 0
	picker._rocks = true
	picker._build()
	await process_frame
	picker.start_fight()
	await process_frame
	await process_frame
	arena = picker._arena
	names.clear()
	for f in arena._fighters:
		names.append("%s:%s" % ["you" if f["team"] == 0 else "foe", f["name"]])
	print("2v2 with an empty slot filled at random: %s; you steer %s (charm %s, its role's)" % [str(names), arena._fighters[arena.controlled]["name"], arena._fighters[arena.controlled]["charm"]])
	_save("fight_2v2")
	got = _names_by_team(arena)
	var kith: String = _form_name(0, 0)
	_ok("The 2v2 has 4 fighters", arena._fighters.size() == 4)
	_ok("The three named picks are in place (%s; %s, %s)" % [kith, _form_name(3, 1), _form_name(1, 2)],
		kith in got[0] and _form_name(3, 1) in got[1] and _form_name(1, 2) in got[1])
	_ok("You steer %s with a charm set" % kith, arena._fighters[arena.controlled]["name"] == kith and String(arena._fighters[arena.controlled]["charm"]) != "")
	print("ARENA PICKER: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails > 0 else 0)


## The display name of line l at stage st, read from the creature file Arena.LINES points to.
func _form_name(l: int, st: int) -> String:
	return String(load(Arena.LINES[l]["forms"][st][1]).creature_name)


## Fighter names split by team, in fighter order: [yours, theirs].
func _names_by_team(arena: Node2D) -> Array:
	var out: Array = [[], []]
	for f in arena._fighters:
		out[f["team"]].append(String(f["name"]))
	return out


## The fighter indices on one team, in order.
func _slots_of(arena: Node2D, team: int) -> Array:
	var out := []
	for j in arena._fighters.size():
		if arena._fighters[j]["team"] == team:
			out.append(j)
	return out


## One judged line: "what -> ok" or "what -> FAIL" (Claude, 2026-10-24).
func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _save(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return   # no rendered image headless; stills need a window
	root.get_texture().get_image().save_png(OUT + name + ".png")
