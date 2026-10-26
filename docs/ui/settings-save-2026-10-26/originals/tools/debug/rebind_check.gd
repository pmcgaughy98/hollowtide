extends SceneTree
## The Rebind keys page end to end (Claude, 2026-10-23, factory pass 3: U3 for LO-12, with U1, U2, U5 and U6).
## It opens the real pause menu on its "rebind" page, then:
##   1. rebinds Attack's first key on the keyboard and Bag's button on the pad, through the page's own take(),
##   2. picks Attack's second keyboard cell with Right (U5), rebinds it, and checks the first key stays and the
##      clash rule still refuses a key Bag already uses,
##   3. lays project.godot's map back and reloads InputPrefs (a new launch): the bindings and UI.binding_text follow,
##   4. saves menu_preferences.cfg the way the title does (main_menu.gd's _save_preferences, a fresh file of the five
##      title keys) and checks the bindings, text speed and full screen all survive in game_prefs.cfg (U1),
##   5. checks a game key a menu still saves in the title's file, and an older install's prefs, move over (U1),
##   6. checks a check run keeps project.godot's map and its window (U2, InputPrefs._applies),
##   7. checks the listening row is one centred line and the scrolled list shows only whole rows (U6),
##   8. resets every action to the defaults.
## Both prefs files (and their .bak and .tmp) are backed up first and put back byte for byte at the end; the check
## prints their SHA-256 before and after. Headless, a few seconds:
##   Godot --headless --path . --fixed-fps 30 --script res://tools/debug/rebind_check.gd
## In a window it also saves two stills of the page (scrolled to its end, and listening) to the folder named:
##   Godot --path . --fixed-fps 30 --script res://tools/debug/rebind_check.gd -- --shots=C:/some/folder

const UI := preload("res://scripts/ui/ui_style.gd")
const MENU := "res://scripts/ui/game_pause_menu.gd"
const TITLE_KEYS := [["audio", "master", 50.0], ["audio", "music", 100.0], ["audio", "sfx", 100.0],
	["menu", "reduce_motion", false], ["menu", "courier", "Female"]]   # what main_menu.gd's _save_preferences writes

var fails := 0
var kept := {}        # a prefs file's path -> its bytes before the check, or null when it was not there
var shots := ""


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shots="):
			shots = a.trim_prefix("--shots=")
	if DisplayServer.get_name() == "headless":
		shots = ""
	_run.call_deferred()


func _ok(cond: bool, what: String) -> void:
	print(("ok    " if cond else "FAIL  ") + what)
	if not cond:
		fails += 1


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _paths() -> Array:
	var out := []
	for base in [UI.PREFS_PATH, UI.GAME_PREFS_PATH]:
		for end in ["", ".bak", ".tmp"]:
			out.append(base + end)
	return out


func _hashes() -> String:
	var out := PackedStringArray()
	for p in [UI.PREFS_PATH, UI.GAME_PREFS_PATH]:
		out.append("%s %s" % [p.get_file(), FileAccess.get_sha256(p).left(16) if FileAccess.file_exists(p) else "none"])
	return ", ".join(out)


func _backup() -> void:
	for p: String in _paths():
		kept[p] = FileAccess.get_file_as_bytes(p) if FileAccess.file_exists(p) else null


func _clear() -> void:
	for p: String in _paths():
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(p))
	UI.reload_prefs()


func _restore() -> void:
	_clear()
	for p: String in kept:
		if kept[p] != null:
			var f := FileAccess.open(p, FileAccess.WRITE)
			f.store_buffer(kept[p])
			f.close()
	UI.reload_prefs()


## project.godot's map for every action the page lists, without touching a file (a fresh launch's map).
func _project_map() -> void:
	for a: String in UI.INPUT_NAMES:
		var setting: Variant = ProjectSettings.get_setting("input/" + a)
		if setting is Dictionary and InputMap.has_action(a):
			InputMap.action_erase_events(a)
			for ev in setting.get("events", []):
				if ev is InputEvent:
					InputMap.action_add_event(a, ev.duplicate())


## What an action's keyboard keys print, in order: ["J", "Space"].
func _keys(action: String) -> Array:
	var out := []
	for ev: InputEvent in InputMap.action_get_events(action):
		if ev is InputEventKey:
			out.append(UI.event_text(ev))
	return out


func _key(code: Key) -> InputEventKey:
	var k := InputEventKey.new()
	k.physical_keycode = code
	k.keycode = code
	k.pressed = true
	return k


func _button(index: JoyButton) -> InputEventJoypadButton:
	var b := InputEventJoypadButton.new()
	b.button_index = index
	b.pressed = true
	return b


## Every heading and row in the list either sits wholly inside the scroll's view or is hidden; `what` names the spot.
func _whole_rows(page: Node, what: String) -> void:
	var scroll: ScrollContainer = page.scroll
	var top := float(scroll.scroll_vertical)
	var bottom := top + scroll.size.y
	var cut := PackedStringArray()
	var shown := 0
	for c in page.list.get_children():
		var item := c as Control
		var whole := item.position.y >= top - 0.5 and item.position.y + item.size.y <= bottom + 0.5
		if page.shows(item):
			shown += 1
			if not whole:
				cut.append(item.name)
	_ok(cut.is_empty() and shown >= 4, "rebind list %s: %d headings and rows show, none cut by the edge%s" % [what, shown, "" if cut.is_empty() else " (cut: " + ", ".join(cut) + ")"])


func _snap(name: String) -> void:
	if shots == "":
		return
	await RenderingServer.frame_post_draw
	var path := shots.path_join(name + ".png")
	root.get_texture().get_image().save_png(path)
	print("saved ", path)


func _run() -> void:
	_backup()
	var before := _hashes()
	print("prefs before: ", before)
	_clear()   # a new player: no prefs files at all
	_project_map()
	var prefs: Node = root.get_node_or_null("InputPrefs")
	_ok(prefs != null, "the InputPrefs autoload is there")
	if prefs == null:
		_finish(before)
		return
	# 6 first (U2): this run is a check, so InputPrefs keeps project.godot's map and never goes full screen.
	_ok(not prefs._applies(false) and prefs._applies(true), "a check run skips saved bindings and the saved screen mode unless forced (InputPrefs._applies)")
	var host := Node2D.new()
	host.name = "RebindHost"
	root.add_child(host)
	var menu: CanvasLayer = load(MENU).new()
	menu.name = "GamePauseMenu"
	host.add_child(menu)
	await _frames(2)
	menu.open()
	menu.show_page("rebind")
	await _frames(6)
	var page: Node = menu.content.get_node_or_null("RebindPage")
	_ok(page != null, "the pause menu's rebind page opens")
	if page == null:
		menu.resume()
		_finish(before)
		return
	_ok(page.row_text("attack") == "J / Space | A" and page.row_text("rest") == "Z / . | RB+B", "rows read the defaults: Attack '%s', Rest '%s'" % [page.row_text("attack"), page.row_text("rest")])
	_ok(UI.width_in(page.hint.text, "label") <= page.ROW_W, "the key line fits the page: '%s' %.0f of %.0f px" % [page.hint.text, UI.width_in(page.hint.text, "label"), page.ROW_W])
	# 7a (U6): a listening row says one line across both columns.
	page.listen("attack")
	var row: Button = page.rows["attack"]
	var prompt := row.get_node("Prompt") as Label
	_ok(page.row_text("attack") == "Press a key or a button" and prompt.visible and not (row.get_node("Keys") as Label).visible and not (row.get_node("Pad") as Label).visible, "listening: the row reads '%s' as one line, the columns hidden" % page.row_text("attack"))
	_ok(prompt.position.x == page.KEY_X and prompt.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER and UI.width_in(prompt.text, "body") <= prompt.size.x, "listening: the prompt is centred across both columns (%.0f px wide from x %.0f)" % [prompt.size.x, prompt.position.x])
	# 1. Attack's first key on the keyboard.
	page.take(_key(KEY_K))
	_ok(page.listening == "" and _keys("attack") == ["K", "Space"], "keyboard: Attack's first key is now K, Space kept (%s)" % ", ".join(_keys("attack")))
	_ok(UI.binding_text("attack", "keyboard") == "K" and page.row_text("attack").begins_with("K / Space |"), "keyboard: the hints and the row follow ('%s', '%s')" % [UI.binding_text("attack", "keyboard"), page.row_text("attack")])
	# 1b. Bag's button on the pad.
	page.listen("bag")
	page.take(_button(JOY_BUTTON_LEFT_STICK))
	_ok(page.listening == "" and UI.binding_text("bag", "pad") == "L3" and page.row_text("bag").ends_with("| L3"), "pad: Bag's button is now L3 ('%s')" % page.row_text("bag"))
	# 2 (U5). Right on the Attack row picks its second keyboard cell; the next key replaces Space, not K.
	row.grab_focus()
	await _frames(2)
	var first_marked: bool = page.cell_marked("attack", 0) and not page.cell_marked("attack", 1)
	for down in [true, false]:
		var right := _key(KEY_RIGHT)
		right.pressed = down
		Input.parse_input_event(right)
		await _frames(2)
	_ok(first_marked and int(page.key_cell.get("attack", 0)) == 1 and page.cell_marked("attack", 1) and not page.cell_marked("attack", 0), "Right on the Attack row picks its second keyboard cell, shown in gold instead of the first")
	page.listen("attack")
	page.take(_key(KEY_U))
	_ok(_keys("attack") == ["K", "U"], "second key: Space became U and the first key K is unchanged (%s)" % ", ".join(_keys("attack")))
	page.listen("attack")
	page.take(_key(KEY_I))
	_ok(page.listening == "attack" and page.message.contains("already Bag") and _keys("attack") == ["K", "U"] and _keys("bag") == ["I"], "second key: I is refused, Bag keeps it and the page keeps listening ('%s')" % page.message)
	page.take(_key(KEY_ESCAPE))
	_ok(page.listening == "", "Esc stops listening")
	var game := ConfigFile.new()
	_ok(game.load(UI.GAME_PREFS_PATH) == OK and game.has_section_key("input", "attack") and game.has_section_key("input", "bag") and not FileAccess.file_exists(UI.PREFS_PATH), "saved in game_prefs.cfg, the title's file untouched")
	# 3. A new launch: project.godot's map, then the saved bindings laid over it.
	_project_map()
	var n: int = prefs.apply_saved(true)
	_ok(n == 2 and _keys("attack") == ["K", "U"] and UI.binding_text("attack", "keyboard") == "K" and UI.binding_text("bag", "pad") == "L3", "reloaded: %d actions back (Attack %s, Bag on the pad %s)" % [n, ", ".join(_keys("attack")), UI.binding_text("bag", "pad")])
	# 4 (U1). Text speed, full screen and a title key saved, then the title saves its file whole, as main_menu.gd does.
	UI.save_pref("menu", "text_speed", 2)
	UI.save_pref("display", "fullscreen", true)
	UI.save_pref("audio", "master", 80.0)
	var title := ConfigFile.new()
	for k: Array in TITLE_KEYS:
		title.set_value(k[0], k[1], k[2])
	title.save(UI.PREFS_PATH)
	UI.reload_prefs()
	_project_map()
	prefs.apply_saved(true)
	_ok(_keys("attack") == ["K", "U"] and UI.binding_text("bag", "pad") == "L3", "after a title save: the rebinds survive")
	_ok(UI.text_speed() == 2 and UI.screen_full(), "after a title save: text speed (%d) and full screen (%s) survive" % [UI.text_speed(), UI.screen_full()])
	title = ConfigFile.new()
	title.load(UI.PREFS_PATH)
	_ok(float(title.get_value("audio", "master", 0.0)) == 50.0 and title.get_sections().size() == 2, "after a title save: the title's file holds its own keys only (%s)" % ", ".join(title.get_sections()))
	# 5 (U1). A menu that still saves text speed in the title's file: the next read moves it over.
	title.set_value("menu", "text_speed", 0)
	title.save(UI.PREFS_PATH)
	UI.reload_prefs()
	var speed := UI.text_speed()
	title = ConfigFile.new()
	title.load(UI.PREFS_PATH)
	_ok(speed == 0 and not title.has_section_key("menu", "text_speed") and title.has_section_key("menu", "courier"), "text speed saved in the title's file moves to game_prefs.cfg on the next read (now %d)" % speed)
	# 5b (U1). An older install: no game_prefs.cfg, everything in the title's file. Moved over once.
	_clear()
	title = ConfigFile.new()
	for k: Array in TITLE_KEYS:
		title.set_value(k[0], k[1], k[2])
	title.set_value("input", "attack", [{"key": KEY_H}, {"button": 0}])
	title.set_value("menu", "text_speed", 2)
	title.set_value("display", "fullscreen", true)
	title.save(UI.PREFS_PATH)
	_project_map()
	prefs.apply_saved(true)
	title = ConfigFile.new()
	title.load(UI.PREFS_PATH)
	_ok(_keys("attack") == ["H"] and UI.text_speed() == 2 and UI.screen_full() and FileAccess.file_exists(UI.GAME_PREFS_PATH), "an older install's prefs move to game_prefs.cfg: Attack %s, text speed %d, full screen %s" % [", ".join(_keys("attack")), UI.text_speed(), UI.screen_full()])
	_ok(not title.has_section("input") and not title.has_section("display") and str(title.get_value("menu", "courier", "")) == "Female", "an older install: the title's file keeps the courier and loses only the moved keys")
	# 7b (U6). Scrolled to the end, and back at the top: only whole rows show.
	page.refresh()
	(page.rows["fullscreen"] as Control).grab_focus()
	await _frames(8)
	_whole_rows(page, "scrolled to its end")
	await _snap("rebind_scrolled_end")
	page.listen("pause")
	await _frames(4)
	await _snap("rebind_listening")
	page.take(_key(KEY_ESCAPE))
	(page.rows["move_up"] as Control).grab_focus()
	await _frames(8)
	_whole_rows(page, "at its top")
	# 8. Every action back to the defaults (two presses of Reset to defaults).
	page._reset_pressed()
	page._reset_pressed()
	game = UI.load_game_prefs()
	_ok(_keys("attack") == ["J", "Space"] and UI.binding_text("bag", "pad") == "Y" and not game.has_section("input"), "Reset to defaults: Attack %s, Bag on the pad %s, nothing saved" % [", ".join(_keys("attack")), UI.binding_text("bag", "pad")])
	menu.resume()
	await _frames(4)
	host.queue_free()
	await _frames(2)
	_finish(before)


func _finish(before: String) -> void:
	_project_map()
	_restore()
	var after := _hashes()
	print("prefs after:  ", after)
	_ok(after == before, "both prefs files are back as they were (SHA-256 %s)" % after)
	print("rebind: %s (%d failed)" % ["all ok" if fails == 0 else "FAILED", fails])
	quit(1 if fails > 0 else 0)
