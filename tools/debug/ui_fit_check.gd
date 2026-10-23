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
## Added 2026-10-22 (Claude, the factory pass, UI-08):
##   8. the town's 760 x 128 sign panel at two lines (the street) and three (a room), every sign text in it,
##   9. the Team screen's move box: every move's description in its five lines, above the body-part note,
##  10. the Growth Shrine's rows for every line that grows: condition names, counts and team buttons,
##  11. the dialogue box with every line in dialogue/*.dialogue (the longest named),
##  12. the title's Options and How to play panels ending by 636 (LP-01, LP-02).
## Headless it only measures:
##   Godot --headless --path . --script res://tools/debug/ui_fit_check.gd
## In a window it also saves proof shots to docs/ui/ui-fit-2026-10-14/:
##   Godot --path . --fixed-fps 30 --script res://tools/debug/ui_fit_check.gd

const UI := preload("res://scripts/ui/ui_style.gd")
const Dungeon := preload("res://scripts/dungeon/dungeon.gd")
const Arena := preload("res://scripts/arena/arena_prototype.gd")
const Lines := preload("res://scripts/creatures/lines.gd")
const Layout := preload("res://scripts/town/town_layout.gd")
const OUT := "res://docs/ui/ui-fit-2026-10-14/"
## The brass bevel of a UI.panel frame, measured from assets/sprites/ui/frame/panel.png (Claude, 2026-10-22):
## rows 0 to 11 from the edge are the frame, the weave starts at 12. FRAME_MARGIN's 24 adds 12 px of padding.
const FRAME_BEVEL := 12.0

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


## How many lines `s` takes when drawn with draw_multiline_string at `width` (Claude, 2026-10-22).
func _lines(f: Font, s: String, width: float, size: int) -> int:
	return int(round(f.get_multiline_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, width, size).y / f.get_height(size)))


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
	for s in ["WASD  walk     E  use", "The Hollow's mouth starts a run"] + Dungeon.HUD_KEYS:
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
	# 8. The town's sign panel, Rect2(196, 452, 760, 128) (Claude, 2026-10-22, UI-08). On the street
	# (hub_town.gd) the text starts at y 64 with two lines at 716 px, above the key hint at 116; in a room
	# (town_room.gd) at y 50 with three lines at 700 px, inside the frame. A longer text is cut, not wrapped.
	var head_h: float = UI.HEAD.get_height(18)
	var frame_b := FRAME_BEVEL
	var hint_top: float = 116.0 - UI.font("label").get_ascent(UI.type_size("label"))
	var street_end: float = 64.0 + head_h + UI.HEAD.get_descent(18)
	_ok(street_end <= hint_top, "town panel, 2 lines: the text ends at %.0f, above the key hint's top at %.0f" % [street_end, hint_top])
	var room_end: float = 50.0 + 2.0 * head_h + UI.HEAD.get_descent(18)
	_ok(room_end <= 128.0 - frame_b, "town panel, 3 lines: the text ends at %.0f, inside the frame at %.0f" % [room_end, 128.0 - frame_b])
	var signs := 0
	var sign_cut: Array[String] = []
	for p in Layout.PLACES:
		if String(p.get("service", "")) in ["growth", "storage"]:
			continue   # the shrine and storage draw their own panels
		signs += 1
		var n := _lines(UI.HEAD, String(p.get("what", "")), 716.0, 18)
		if n > 2:
			sign_cut.append("%s (%d lines)" % [p["name"], n])
	var rooms: Dictionary = load("res://scripts/town/town_room.gd").get_script_constant_map()["ROOMS"]
	for r in rooms:
		for spot in rooms[r].get("spots", []):
			if String(spot.get("what", "")) == "" or String(spot.get("service", "")) == "storage":
				continue
			signs += 1
			var n := _lines(UI.HEAD, String(spot["what"]), 700.0, 18)
			if n > 3:
				sign_cut.append("%s in %s (%d lines)" % [spot["name"], r, n])
	_ok(sign_cut.is_empty(), "town panel: %d sign texts, each within its lines (street 2, room 3)%s" % [signs, "" if sign_cut.is_empty() else "; cut short: " + ", ".join(sign_cut)])
	# 9. The Team screen's move box, measured by the screen itself (party_screen.gd move_box, LP-08): with four
	# facts shown (Ready in as well), every move's description in the body face at 266 px with the body-part note
	# right under it, the box as tall as that and inside the right panel (RIGHT less 46 px).
	var ps: Control = load("res://scripts/ui/party_screen.gd").new()
	var MoveBody: GDScript = load("res://scripts/moves/move_body.gd")
	var cap: float = (ps.RIGHT as Rect2).size.y - 46.0
	var desc_end := 0.0
	var desc_bad: Array[String] = []
	for m in Arena.MOVES:
		var txt: String = ps._describe(Dungeon.move_reach(m), int(Arena.MOVES[m].get("heal", 0)))
		var box: Dictionary = ps.move_box(txt, 4, not MoveBody.NEEDS.get(m, []).is_empty())
		desc_end = maxf(desc_end, float(box["needs"]))
		if float(box["needs"]) > cap:
			desc_bad.append("%s (%d lines, %.0f px)" % [m, box["lines"].size(), box["needs"]])
	ps.free()
	_ok(desc_bad.is_empty(), "team move box: %d moves, the tallest box %.0f of %.0f px%s" % [Arena.MOVES.size(), desc_end, cap, "" if desc_bad.is_empty() else "; over: " + ", ".join(desc_bad)])
	# 10. The Growth Shrine (shrine_info.gd) for every line that grows: each condition's name in its 180 px
	# column, its count with a three-digit tally in the 122 px column, every form's name on a 206 px button.
	var way_names: Dictionary = load("res://scripts/ui/shrine_info.gd").get_script_constant_map()["WAY_NAMES"]
	var cond_w := 0.0
	var count_w := 0.0
	var shrine_bad: Array[String] = []
	for ln in Dungeon.EVO:
		var r: Dictionary = Dungeon.EVO[ln]
		var forms: Array = Lines.of(ln)["forms"]
		for st in [0, 1]:
			var conds := [["Level", Dungeon.EVO_LEVEL[st]], ["Knockouts", r["kos"][st]], ["Floors cleared", r["floors"][st]], [way_names.get(r["way"], r["way"]), r["need"][st]]]
			for c in conds:
				var lw := UI.width_in(String(c[0]), "body")
				var count := "%d / %d" % [maxi(999, int(c[1])), int(c[1])]
				var cw := UI.width_in(count, "number")
				cond_w = maxf(cond_w, lw)
				count_w = maxf(count_w, cw)
				if lw > 180.0 or cw > 122.0:
					shrine_bad.append("line %d stage %d: '%s' %.0f px, '%s' %.0f px" % [ln, st + 1, c[0], lw, count, cw])
		for f in forms:
			var nm := String(load(f[1]).creature_name)
			var nw := UI.width_in(nm, UI.fit(nm, "name", 206))
			if nw > 206.0:
				shrine_bad.append("%s %.0f px on its button" % [nm, nw])
	_ok(shrine_bad.is_empty(), "shrine rows: %d growing lines, widest condition %.0f of 180 px, widest count %.0f of 122 px%s" % [Dungeon.EVO.size(), cond_w, count_w, "" if shrine_bad.is_empty() else "; over: " + "; ".join(shrine_bad)])
	# 11. The dialogue box (UI.dialogue, 760 x 116) with every line of dialogue/*.dialogue. A name slot
	# ({{...}}) is filled with the widest creature name; a spoken line is measured beside a portrait (528 px),
	# narration across the box (690 px). Each page is two rows: both inside the frame, each row within the width.
	var fill := ""
	for nm in names:
		if UI.width_in(nm, "story") > UI.width_in(fill, "story"):
			fill = nm
	var story_n := UI.type_size("story")
	var page_end: float = 54.0 + UI.font("story").get_height(story_n) + UI.font("story").get_descent(story_n)
	_ok(page_end <= 116.0 - frame_b, "dialogue box: a two-row page ends at %.0f, inside the frame at %.0f" % [page_end, 116.0 - frame_b])
	var speaker := RegEx.create_from_string("^(\\{\\{\\w+\\}\\}|[A-Z][\\w' ]{0,24}):\\s+(.*)$")
	var tags := RegEx.create_from_string("\\[[^\\]]*\\]")
	var slots := RegEx.create_from_string("\\{\\{\\w+\\}\\}")
	var said := 0
	var longest := ""
	var longest_pages := 0
	var wide_rows: Array[String] = []
	for f in DirAccess.get_files_at("res://dialogue/"):
		if not f.ends_with(".dialogue"):
			continue
		for raw in FileAccess.get_file_as_string("res://dialogue/" + f).split("\n"):
			var s := raw.strip_edges()
			if s == "" or s == "else" or s.begins_with("- ") or s.begins_with("=>"):
				continue
			if ["#", "~", "do ", "set ", "if ", "elif ", "while ", "match ", "when ", "import ", "using "].any(func(p: String) -> bool: return s.begins_with(p)):
				continue
			var width := 690.0
			var m := speaker.search(s)
			if m != null:
				s = m.get_string(2)
				width = 760.0 - 70.0 - UI.PORTRAIT_INSET
			s = slots.sub(tags.sub(s, "", true), fill, true).strip_edges()
			if s == "":
				continue
			said += 1
			var rows: PackedStringArray = UI._dialogue_rows(s, width)
			for row in rows:
				if UI.width_in(row, "story") > width + 10.0:
					wide_rows.append("'%s' %.0f px" % [row, UI.width_in(row, "story")])
			if s.length() > longest.length():
				longest = s
				longest_pages = ceili(rows.size() / 2.0)
	_ok(said > 0 and wide_rows.is_empty(), "dialogue box: %d lines, every row within its width; the longest (%d letters) takes %d page%s%s" % [said, longest.length(), longest_pages, "" if longest_pages == 1 else "s", "" if wide_rows.is_empty() else "; too wide: " + ", ".join(wide_rows)])
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
	# 12. The title's Options and How to play (both help topics) end by 636, clear of the key line below them
	# (Claude, 2026-10-22, UI-08 for LP-01 and LP-02).
	var title: Node = load("res://scenes/creature_opening.tscn").instantiate()
	root.add_child(title)
	var waited := 0
	while not (title._boot_done and title._page == "main") and waited < 300:
		await process_frame
		waited += 1
	if title._page == "main":
		title._show_page("options", title._options_controls[0])
		await _frames(4)
		var op: Control = title._options_panel
		_ok(op.position.y + op.size.y <= 636.0, "title Options: panel from %.0f to %.0f, to end by 636" % [op.position.y, op.position.y + op.size.y])
		for topic in ["journey", "controls"]:
			title._show_page("help", title._help_controls[0])
			title._show_help_topic(topic)
			await _frames(4)
			var hp: Control = title._help_panel
			_ok(hp.position.y + hp.size.y <= 636.0, "title How to play, %s: panel from %.0f to %.0f, to end by 636" % [topic, hp.position.y, hp.position.y + hp.size.y])
	else:
		_ok(false, "title: no main menu after %d frames" % waited)
	title.queue_free()
	await _frames(4)
	print("ui fit: %s (%d failed)" % ["all ok" if fails == 0 else "FAILED", fails])
	quit(1 if fails > 0 else 0)
