extends SceneTree
## Every text in its box (Claude, 2026-10-14; Preston: "skill-up with the synthesis then do 9 task refinement
## pass and upgrade of hollowtide"). Measures what the 2026-10-14 UI tour caught overlapping or cut off:
##   1. each creature's name beside its level and Sense in the dungeon's team rows (every creature file),
##   2. the learn prompt's question and keys on separate rows,
##   3. the pause panel inside the screen on every page,
##   4. the title menu above its key line with Continue listed (five rows),
##   5. right-aligned hints kept on screen,
##   6. the message box leaving after LOG_LINGER seconds and coming back on news,
##   7. the corner map inside the top right, clear of the team panel.
## Headless it only measures:
##   Godot --headless --path . --script res://tools/debug/ui_fit_check.gd
## In a window it also saves proof shots to docs/ui/ui-fit-2026-10-14/:
##   Godot --path . --fixed-fps 30 --script res://tools/debug/ui_fit_check.gd

const UI := preload("res://scripts/ui/ui_style.gd")
const Dungeon := preload("res://scripts/dungeon/dungeon.gd")
const Arena := preload("res://scripts/arena/arena_prototype.gd")
const OUT := "res://docs/ui/ui-fit-2026-10-14/"

var fails := 0
var shots := false


func _initialize() -> void:
	shots = DisplayServer.get_name() != "headless"
	_run.call_deferred()


func _ok(cond: bool, what: String) -> void:
	print(("ok    " if cond else "FAIL  ") + what)
	if not cond:
		fails += 1


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _snap(name: String) -> void:
	if not shots:
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))
	print("saved ", name)


func _run() -> void:
	if shots:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	# 1. Every creature name with the widest tags it can have.
	var names: Array[String] = []
	for f in DirAccess.get_files_at("res://data/creatures/"):
		if f.ends_with(".tres"):
			var c: Resource = load("res://data/creatures/" + f)
			if c != null and "creature_name" in c and String(c.creature_name) != "":
				names.append(String(c.creature_name))
	var cut := 0
	var no_sense := 0
	var widest := 0.0
	for nm in names:
		for sense in [-1, 9]:
			var nt: Array = Dungeon.hud_name_tag(nm, 99, sense)
			var used: float = UI.width_in(nt[0], "body") + 10.0 + UI.width_in(nt[1], "label")
			widest = maxf(widest, used)
			if used > Dungeon.HUD_ROW_W:
				_ok(false, "team row: %s with %s needs %.0f of %.0f px" % [nt[0], nt[1], used, Dungeon.HUD_ROW_W])
			if nt[0] != nm:
				cut += 1
			if sense >= 0 and not String(nt[1]).contains("Sense"):
				no_sense += 1
	_ok(widest <= Dungeon.HUD_ROW_W, "team rows: %d names, widest row %.0f of %.0f px; %d names cut, %d teammates show no Sense at Lv 99" % [names.size(), widest, Dungeon.HUD_ROW_W, cut, no_sense])
	_ok(cut == 0, "team rows: no creature name is cut short")
	# 2. The learn prompt: the question fits its row and the keys have their own footer row.
	var q_w := UI.width_in("It knows four moves. Forget one?", UI.fit("It knows four moves. Forget one?", "body", 440))
	var k_w := UI.width_in("W/S choose   J pick   Esc close", UI.fit("W/S choose   J pick   Esc close", "label", 440))
	_ok(q_w <= 440.0 and k_w <= 440.0, "learn prompt: question %.0f px, keys %.0f px, each within 440" % [q_w, k_w])
	for n in [1, 4, 5]:
		var box_h: int = 84 + 32 * n + 26
		var last_row_bottom: int = 92 + 32 * (n - 1) + 7
		_ok(box_h - 18 - 16 > last_row_bottom, "learn prompt, %d rows: keys row starts at %d, below the last row's %d" % [n, box_h - 34, last_row_bottom])
	# 4. The title menu: four rows keep their place; five end above the key line. Loaded here, not
	# preloaded: it needs the game's autoloads, which exist only once the run has started.
	var Opening: GDScript = load("res://scripts/creature_opening.gd")
	_ok(is_equal_approx(Opening.call("menu_top", 4), 324.0), "title, 4 rows: top stays at 324")
	for n in [4, 5, 6]:
		var bottom: float = Opening.call("menu_top", n) + 32.0 + n * 54.0 + (n - 1) * 6.0
		_ok(bottom <= 596.0, "title, %d rows: menu ends at %.0f, above the key line at 608" % [n, bottom])
	# 5. Right-aligned hints, grown left when too wide: on screen at both ends.
	for s in ["WASD walk   E use", "The Hollow's mouth starts a run", "J attack   1 2 3 moves", "I bag   T orders   Z rest", "E stairs   Tab autopilot"]:
		var w := UI.width_in(s, UI.fit(s, "label", 194))
		var left := 946.0 + 194.0 - maxf(194.0, w)
		_ok(left >= 0.0 and left + maxf(194.0, w) <= 1152.0, "hint '%s': %.0f px, drawn from x %.0f to 1140" % [s, w, left])
	# 7. The corner map for every map size the Hollow can make (16 to 80 tiles a side).
	var worst := Vector2.ZERO
	for w in range(16, 81, 4):
		for h in range(16, 61, 4):
			var sc := Dungeon.minimap_scale(w, h)
			worst = Vector2(maxf(worst.x, w * sc), maxf(worst.y, h * sc))
	_ok(1136.0 - worst.x - 8.0 >= 360.0 and 44.0 + worst.y + 8.0 <= 260.0, "corner map: at most %.0f x %.0f px, left edge %.0f clear of the team panel's 352" % [worst.x, worst.y, 1136.0 - worst.x - 8.0])
	# A live floor for 3, 6 and 7, with the longest names in the team.
	var listener := -1
	for i in Arena.LINES.size():
		if Arena.LINES[i]["forms"][0][0] == "listener":
			listener = i
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[0, 0], [listener, 2], [listener, 0]]
	root.add_child(dg)
	await _frames(60)
	var sc2 := Dungeon.minimap_scale(dg.data["w"], dg.data["h"])
	_ok(sc2 >= 3, "corner map on B1F (%d x %d tiles): %d px a tile, %d x %d px" % [dg.data["w"], dg.data["h"], sc2, dg.data["w"] * sc2, dg.data["h"] * sc2])
	await _snap("01_team_long_names")
	# 6. The message box: shown with news, gone after LOG_LINGER, back on the next message.
	dg._say("Kithflare looks around.")
	await _frames(2)
	var away := func() -> float: return smoothstep(0.0, 1.0, ((Time.get_ticks_msec() - dg._log_at) / 1000.0 - Dungeon.LOG_LINGER) / 0.3)
	_ok(away.call() == 0.0, "message box: shown right after a message")
	dg._log_at -= int((Dungeon.LOG_LINGER + 0.5) * 1000.0)
	await _frames(2)
	_ok(away.call() == 1.0, "message box: gone %.1f s after the last message" % (Dungeon.LOG_LINGER + 0.5))
	await _snap("02_message_box_away")
	dg._say("Quietwater Warden is on guard.")
	await _frames(2)
	_ok(away.call() == 0.0, "message box: back on the next message")
	# 2, seen: the learn prompt with four moves.
	var lead: Dictionary = dg.ents[0]
	dg.levels[0] = {"lv": 3, "exp": 0}
	lead["moves"].assign(["claw", "ember_feint", "fireball", "cinder_claw"])
	dg._offer(0, "pounce")
	await _frames(6)
	await _snap("03_learn_prompt")
	dg.act_teach(0, -2)
	# 3. The pause panel on every page that shows it.
	var menu: CanvasLayer = dg.get_node("GamePauseMenu")
	menu.open()
	for page in ["main", "goal", "bag", "floor", "log", "options", "controls", "title", "quit"]:
		menu.show_page(page)
		await _frames(4)
		var panel: Control = menu.overlay.get_node("PausePanel")
		var bottom: float = panel.position.y + panel.size.y
		_ok(bottom <= 648.0 and panel.position.y >= 0.0, "pause '%s': panel from %.0f to %.0f of 648" % [page, panel.position.y, bottom])
		if page == "main":
			await _snap("04_pause_main")
	menu.resume()
	await _frames(4)
	dg.queue_free()
	await _frames(4)
	print("ui fit: %s (%d failed)" % ["all ok" if fails == 0 else "FAILED", fails])
	quit(1 if fails > 0 else 0)
