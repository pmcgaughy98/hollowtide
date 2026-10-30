extends SceneTree
## Pass 9 D1 probe (Claude, 2026-10-27, dungeon lane; a method file, not a check). Stages the Hollow's boss floor the
## way the pass 9 audit's warden phase did (seed 7, the Warden's entrance read through), then puts the leader 1 to 7
## tiles straight below the Warden and logs, for each distance: where boss_focus aims, whether the map's edge clamp
## moved that aim, and where the Warden's crest (its top opaque row) and the leader's opaque box land on the screen.
## Windowed (1152x648), it also saves a still per distance into the folder given after `--`.
##   Godot --path . --fixed-fps 30 --resolution 1152x648 --script res://docs/team/sweep-2026-10-20/pass9-dungeon/method/d1_warden_probe.gd -- <out dir>

const UI := preload("res://scripts/ui/ui_style.gd")
const BAR_FOOT_SCREEN := 56.0   # the boss bar's panel is Rect2(396, 10, 360, 46) in dungeon.gd _draw_hud
const CARDS_TOP_SCREEN := 580.0 # the move cards' top edge (BOSS_LEAD_LOW's comment)
var out := ""
var shots := false


func _initialize() -> void:
	_run.call_deferred()


func F(n := 1) -> void:
	for k in n:
		await process_frame


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	out = args[0] if args.size() > 0 else ""
	shots = out != "" and DisplayServer.get_name() != "headless"
	if shots:
		DirAccess.make_dir_recursive_absolute(out)
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 7
	dg.poll_input = false
	dg.dungeon = "hollow"
	dg.party = [[0, 1], [1, 0], [10, 0]]
	root.add_child(dg)
	current_scene = dg
	await F(10)
	dg.floor_n = dg.floors() + 1
	dg._build_floor(true)
	for k in 30 * 90:
		await F()
		if not dg.talk.is_empty() and bool(UI._line.get("done", true)):
			dg.act_talk()
		if k > 30 and dg.talk.is_empty() and not dg.cutscene and not dg.busy:
			break
	if dg.boss < 0:
		print("D1 no boss on the floor")
		quit(1)
		return
	var b: Dictionary = dg.ents[dg.boss]
	var lead: Dictionary = dg.ents[0]
	var map_px: Vector2 = Vector2(dg.data["w"], dg.data["h"]) * float(C(dg, "T"))
	var half: Vector2 = Vector2(C(dg, "VIEW")) * 0.5
	print("D1 boss %s at tile %s node %s; head_y %.1f; map %s px; view %s; BOSS_LEAD_LOW %.0f HIGH %.0f BAR_FOOT %.0f" % [
		b["name"], str(b["pos"]), str(b["node"].position), dg._head_y(b), str(map_px), str(C(dg, "VIEW")),
		C(dg, "BOSS_LEAD_LOW"), C(dg, "BOSS_LEAD_HIGH"), C(dg, "BOSS_BAR_FOOT")])
	var all_ok := true
	for dy in [1, 2, 3, 4, 5, 6, 7]:
		var want: Vector2i = b["pos"] + Vector2i(0, dy)
		var spot := Vector2i(-99, -99)
		for dx in [0, 1, -1, 2, -2]:
			if dg._floor_at(want + Vector2i(dx, 0)):
				spot = want + Vector2i(dx, 0)
				break
		if spot == Vector2i(-99, -99):
			print("D1 dy %d: no floor" % dy)
			continue
		lead["pos"] = spot
		dg._place(lead)
		for k in 120:
			await F()
			if not dg.talk.is_empty():
				dg.act_talk()
		var focus: Vector2 = dg.boss_focus(lead["node"].position, b)
		var clamped: Vector2 = focus.clamp(half, map_px - half)
		var wb: Rect2 = dg.sprite_screen_box(b)
		var lb: Rect2 = dg.sprite_screen_box(lead)
		var crest_ok := wb.position.y >= BAR_FOOT_SCREEN and wb.end.y <= 648.0
		var lead_ok := lb.position.y >= 0.0 and lb.end.y <= 648.0
		all_ok = all_ok and crest_ok
		print("D1 dy %d: leader tile %s; aim %s, map clamp moved it %s; Warden crest %.0f feet %.0f (bar foot %.0f, gap %.0f) -> %s; leader top %.0f feet %.0f (cards %.0f) -> %s" % [
			dy, str(spot), str(focus.round()), str((clamped - focus).round()), wb.position.y, wb.end.y,
			BAR_FOOT_SCREEN, wb.position.y - BAR_FOOT_SCREEN, "whole Warden under the bar" if crest_ok else "CUT",
			lb.position.y, lb.end.y, CARDS_TOP_SCREEN, "leader on screen" if lead_ok else "leader OFF SCREEN"])
		if shots:
			await F(2)
			root.get_texture().get_image().save_png(out.path_join("D1_warden_dy%d.png" % dy))
	print("D1 summary: whole Warden under the bar at every distance: %s" % all_ok)
	quit(0)


func C(dg: Node, name: String) -> Variant:
	return dg.get_script().get_script_constant_map()[name]
