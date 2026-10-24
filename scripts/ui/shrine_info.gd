extends CanvasLayer
## Read-only creature information. The town still owns the stone and evolution actions.
const UI := preload("res://scripts/ui/ui_style.gd")
const ControlsText := preload("res://scripts/ui/controls_text.gd")
const Lines := preload("res://scripts/creatures/lines.gd")
const Evolution := preload("res://scripts/town/evolution.gd")
const Arena := preload("res://scripts/arena/arena_prototype.gd")
const Finish := preload("res://scripts/arena/creature_finish.gd")
const RebindPage := preload("res://scripts/ui/rebind_page.gd")   # its style_scroll_bar
const WAY_NAMES := {"flank": "Pincer hits", "ambush": "Hits on sleepers", "took": "Damage taken", "slam": "Slams", "healed": "Health restored"}
const SERVICES := ["growth", "stone_ask", "evolve_ask"]
## What the shrine says of a line nobody has seen grow (Claude, 2026-10-22, W23; a proposal line): it replaces
## "Later forms not defined" and "No evolution conditions are defined", which read as unfinished data.
const UNSEEN := "Nobody in Highbank has seen this line grow."
var town: Node2D
var screen: PanelContainer
var members: VBoxContainer
var details: VBoxContainer
var detail_scroll: ScrollContainer
var status: Label
var action: Button
var selected := 0
var tab := "growth"
var shown := false
var snapshot: Dictionary = {}
var panel_key := ""
var tabs: HBoxContainer
var keys_hint: Label     # the footer's key line and the close button, retold when the device changes
var close_button: Button

static func attach(owner: Node2D) -> void:
	var view = load("res://scripts/ui/shrine_info.gd").new()
	view.name = "ShrineInfo"
	view.town = owner
	owner.add_child(view)

static func member(rec: Dictionary, k: int) -> Dictionary:
	var party: Array = rec.get("party", [])
	if k < 0 or k >= party.size(): return {}
	var ln := int(party[k][0])
	var st := int(party[k][1])
	var forms: Array = Lines.of(ln)["forms"]
	var form: String = forms[st][0]
	var level := int(rec.get("levels", {}).get(ln, {}).get("lv", 1))
	var dungeon: GDScript = load(Evolution.DUNGEON)
	var c := dungeon.get_script_constant_map()
	var data := {"name": String(load(forms[st][1]).creature_name), "form": form, "level": level,
		"final": st >= 2, "iq": int(rec.get("iq", {}).get(ln, 0)), "ready": Evolution.ready(rec, k), "conditions": [],
		"next": String(load(forms[st + 1][1]).creature_name) if st + 1 < forms.size() else "",
		"moves": rec.get("taught", {}).get("%d:%d" % [ln, st], dungeon.moves_for(ln, st, level)).duplicate(),
		"learn": c["LEARN"].get(form, []).duplicate(true), "waiting": c["WAITING"].get(form, []).duplicate(true),
		"next_learn": [], "next_waiting": [], "pending": []}
	if st < 2 and c["EVO"].has(ln):
		var r: Dictionary = c["EVO"][ln]
		var g: Dictionary = rec.get("growth", {}).get("%d:%d" % [ln, st], {})
		data["conditions"] = [["Level", level, c["EVO_LEVEL"][st]], ["Knockouts", int(g.get("kos", 0)), r["kos"][st]],
			["Floors cleared", int(g.get("floors", 0)), r["floors"][st]], [WAY_NAMES.get(r["way"], r["way"]), int(g.get(r["way"], 0)), r["need"][st]]]
	if st + 1 < forms.size():
		data["next_learn"] = c["LEARN"].get(forms[st + 1][0], []).duplicate(true)
		data["next_waiting"] = c["WAITING"].get(forms[st + 1][0], []).duplicate(true)
	for entry in rec.get("pending_learn", []):
		if int(entry[0]) == ln and int(entry[1]) == st: data["pending"].append(entry[2])
	return data

func _label(text: String, role := "body", color := UI.TEXT) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", UI.font(role))
	label.add_theme_font_size_override("font_size", UI.type_size(role))
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE # Raw town polling owns Enter; avoid a second activation.
	button.custom_minimum_size.y = 52
	for state in ["normal", "hover", "pressed", "disabled"]:
		var frame := UI.frame("panel_focus" if state == "hover" else "panel_dim").duplicate()
		frame.content_margin_top = 12
		frame.content_margin_bottom = 12
		button.add_theme_stylebox_override(state, frame)
	UI.style_button(button)
	button.pressed.connect(callback)
	return button

func _scroll() -> ScrollContainer:
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# The pixel bar from the UI frames, which also keeps its width clear of the rows (Claude, 2026-10-24, S3 / LV-34).
	RebindPage.style_scroll_bar(scroll.get_v_scroll_bar())
	return scroll

func _ready() -> void:
	layer = 60
	screen = PanelContainer.new()
	screen.position = Vector2(48, 42)
	screen.size = Vector2(1056, 540)
	screen.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	screen.add_theme_stylebox_override("panel", UI.frame("panel").duplicate())
	add_child(screen)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	screen.add_child(column)
	column.add_child(_label("Growth Shrine", "name", UI.EDGE_LIGHT))
	status = _label("", "body", UI.MUTED)
	status.custom_minimum_size.y = 30
	column.add_child(status)
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 18)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(body)
	var list_scroll := _scroll()
	list_scroll.custom_minimum_size.x = 258
	list_scroll.size_flags_horizontal = Control.SIZE_FILL
	body.add_child(list_scroll)
	members = VBoxContainer.new()
	members.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	members.add_theme_constant_override("separation", 8)
	list_scroll.add_child(members)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right)
	tabs = HBoxContainer.new()
	right.add_child(tabs)
	for kind in ["growth", "moves"]:
		var button := _button(kind.to_upper(), _set_tab.bind(kind))
		button.name = kind.capitalize() + "Tab"
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tabs.add_child(button)
	detail_scroll = _scroll()
	detail_scroll.name = "DetailScroll"
	right.add_child(detail_scroll)
	details = VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 7)
	detail_scroll.add_child(details)
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 12)
	column.add_child(footer)
	keys_hint = _label("", "label", UI.MUTED)
	keys_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	keys_hint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	footer.add_child(keys_hint)
	action = _button("Close", town.act_use)
	action.name = "ShrineAction"
	action.custom_minimum_size.x = 210
	footer.add_child(action)
	close_button = _button("", _close)
	footer.add_child(close_button)
	_hints()
	# The keys named are the device's in use: W/S and E on a keyboard, the D-pad and A on a pad (Claude, 2026-10-23).
	var prefs := get_node_or_null("/root/InputPrefs")
	if prefs != null:
		prefs.device_changed.connect(_on_device)
	screen.hide()

func _on_device(_device: String) -> void:
	_hints()

## The footer's words from the live bindings (ControlsText): "W/S team   A/D page   PgUp/PgDn scroll", the
## action button's "E set stone" and "Esc close" on a keyboard; the pad's buttons on a pad.
func _hints() -> void:
	var words := "%s team   %s page   %s scroll" % [ControlsText.pair("move_up", "move_down"), ControlsText.pair("move_left", "move_right"), ControlsText.pair("page_up", "page_down")]
	var role := UI.fit(words, "label", 520.0)
	keys_hint.text = words
	keys_hint.add_theme_font_override("font", UI.font(role))
	keys_hint.add_theme_font_size_override("font_size", UI.type_size(role))
	close_button.text = "%s close" % UI.binding_text("cancel")
	var service: String = town.panel.get("service", "") if town != null else ""
	action.text = "%s %s" % [ControlsText.advance_text(), "set stone" if service == "stone_ask" else ("grow" if service == "evolve_ask" else "close")]

func _process(_delta: float) -> void:
	var active: bool = town.panel.get("service", "") in SERVICES and not town.cutscene and town.talk.is_empty() and not town.evolving_now
	if active and (not shown or panel_key != _panel_key()):
		selected = int(town.panel.get("k", 0))
		tab = "growth"
		_rebuild()
	shown = active
	screen.visible = active

func _panel_key() -> String:
	return "%s:%d:%s:%s" % [town.panel.get("service", ""), int(town.panel.get("k", 0)), town.stone_state(), str(town.party)]

func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

func _rebuild() -> void:
	snapshot = town._record().duplicate(true)
	panel_key = _panel_key()
	_clear(members)
	for k in snapshot.get("party", []).size():
		var data := member(snapshot, k)
		var role := UI.fit(data["name"], "name", 206)
		var button := _button(data["name"], select.bind(k))
		button.name = "Member%d" % k
		button.custom_minimum_size.y = 76
		button.add_theme_font_override("font", UI.font(role))
		button.add_theme_font_size_override("font_size", UI.type_size(role))
		var frame := UI.frame("panel_focus" if k == selected else "panel_dim").duplicate()
		frame.content_margin_top = 12
		frame.content_margin_bottom = 12
		button.add_theme_stylebox_override("normal", frame)
		members.add_child(button)
	if snapshot.get("party", []).is_empty(): members.add_child(_label("No team yet."))
	status.text = "Shrine dormant: the socket is empty. You can still read your team's growth." if town.stone_state() == "" else ("The pond stone is carried. Set it in to wake the shrine." if town.stone_state() == "carried" else "Shrine awake. All four conditions must be met to grow.")
	_hints()   # the action button's words: "E set stone", "E grow", "E close" (A on a pad)
	_render_detail()

func select(k: int) -> void:
	var count: int = town._record().get("party", []).size()
	if count == 0: return
	if posmod(k, count) != selected: UI.tick("cursor")   # W/S or a click moved the choice (Claude, 2026-10-22, W23)
	selected = posmod(k, count)
	# Selection offers the same confirmation for this creature; no rule or record changes.
	if town.stone_state() == "installed":
		if Evolution.ready(town._record(), selected):
			town.panel["service"] = "evolve_ask"
			town.panel["k"] = selected
			town.panel["what"] = "%s is ready to grow. Let it grow here?" % member(town._record(), selected)["name"]
		else:
			town.panel["service"] = "growth"
			town.panel.erase("k")
	_rebuild()
	_reveal_selected.call_deferred()

func _reveal_selected() -> void:
	if selected < members.get_child_count():
		members.get_parent().ensure_control_visible(members.get_child(selected))

func _set_tab(kind: String) -> void:
	if kind != tab: UI.tick("cursor")
	tab = kind
	_render_detail()

func _portrait(form: String) -> Control:
	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", UI.frame("portrait").duplicate())
	var well := Control.new()
	well.custom_minimum_size = Vector2(72, 72)
	well.clip_contents = true
	frame.add_child(well)
	var background := ColorRect.new()
	background.color = UI.PORTRAIT_BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	well.add_child(background)
	# The same 24 x 24 face cut every other screen shows (UI.portrait_3x, with its own fallback), drawn at a whole
	# 3x of the cut in the 72 px well: its 48 px texture is the cut at 2x, so 1.5 here (Claude, 2026-10-23, T8 / LO-06;
	# it was the old 48 px portrait.png through the town's _face, now gone).
	var tex: Texture2D = UI.portrait_3x(form)
	if tex != null:
		var sprite := Sprite2D.new()
		sprite.centered = false
		sprite.texture = tex
		sprite.scale = Vector2(72, 72) / tex.get_size()
		Finish.apply(sprite, false, form)
		well.add_child(sprite)
	return frame

func _render_detail() -> void:
	_clear(details)
	detail_scroll.scroll_vertical = 0
	for button in tabs.get_children():
		button.add_theme_color_override("font_color", UI.EDGE_LIGHT if button.name == tab.capitalize() + "Tab" else UI.TEXT)
	var data := member(snapshot, selected)
	if data.is_empty():
		details.add_child(_label("Your travelling team will appear here."))
		return
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 18)
	details.add_child(head)
	head.add_child(_portrait(data["form"]))
	var title := VBoxContainer.new()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	title.add_child(_label(data["name"], "name", UI.EDGE_LIGHT))
	title.add_child(_label("Lv %d    Sense %d" % [data["level"], data["iq"]], "number"))
	title.add_child(_label("Final stage" if data["final"] else (UNSEEN if data["next"] == "" else "Next form: " + data["next"]), "body", UI.MUTED))
	if tab == "growth":
		if not data["conditions"].is_empty():
			details.add_child(_label("To grow", "label", UI.EDGE_LIGHT))   # the rows' heading (Claude, 2026-10-22, W24)
		for condition in data["conditions"]:
			var row := HBoxContainer.new()
			row.custom_minimum_size.y = 26
			details.add_child(row)
			var label := _label(condition[0], "body")
			label.custom_minimum_size.x = 180
			row.add_child(label)
			# The game's own gauge (UI.bar: dark well, fill, brass rim), green once met, as on the Team screen
			# (Claude, 2026-10-22, W23; it was a ProgressBar in flat boxes).
			var met: bool = int(condition[1]) >= int(condition[2])
			var frac: float = float(condition[1]) / maxf(1.0, float(condition[2]))
			var bar := Control.new()
			bar.name = "Gauge"
			bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			bar.custom_minimum_size.y = 10
			bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
			bar.draw.connect(func() -> void: UI.bar(bar, Rect2(Vector2.ZERO, bar.size), frac, UI.HP_GOOD if met else UI.EVO))
			row.add_child(bar)
			# "n / goal" right-aligned at the row's end, which stops at the scrollbar now that the bar's width is kept
			# clear; the column is never narrower than the words, so the gauge gives way and the goal always shows
			# (Claude, 2026-10-24, S1 / LV-04: the goal after the slash sat under the bar).
			var said := "%d / %d" % [condition[1], condition[2]]
			var count := _label(said, "number", UI.HP_GOOD if met else UI.EVO)
			count.autowrap_mode = TextServer.AUTOWRAP_OFF
			count.custom_minimum_size.x = maxf(122.0, ceilf(UI.font("number").get_string_size(said, HORIZONTAL_ALIGNMENT_LEFT, -1, UI.type_size("number")).x))
			count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			row.add_child(count)
			var gap := Control.new()   # two UI pixels between the goal and the bar's rule
			gap.custom_minimum_size.x = 6
			gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row.add_child(gap)
		var message: String = "This is its final form." if data["final"] else (("All conditions met. This creature can grow here." if town.stone_state() == "installed" else "All conditions met. Ready here once the shrine is awake.") if data["ready"] else "Keep exploring to meet the remaining conditions.")
		if not data["final"] and data["conditions"].is_empty(): message = "" if data["next"] == "" else UNSEEN   # the head row already says it
		if message != "": details.add_child(_label(message, "body", UI.EVO if data["ready"] else UI.MUTED))
	else:
		details.add_child(_label("Known moves", "label", UI.EDGE_LIGHT))
		for move in data["moves"]: details.add_child(_label(_move_name(move)))
		_learn_rows("This form's learnset", data["learn"], false)
		_learn_rows("After growing into " + data["next"], data["next_learn"], false)
		# Moves the Hollow cannot teach yet stay off the page (Claude, 2026-10-22, W23): "unavailable in the
		# dungeon" read as unfinished data. They are still in data["waiting"] and data["next_waiting"].
		if not data["pending"].is_empty():
			details.add_child(_label("Waiting for the next run's move choice", "label", UI.EDGE_LIGHT))
			for move in data["pending"]: details.add_child(_label(_move_name(move)))
		details.add_child(_label("Four move slots. The next run offers moves that did not fit after evolution.", "body", UI.MUTED))

func _move_name(id: String) -> String:
	return String(Arena.MOVES.get(id, {}).get("name", id))

func _learn_rows(heading: String, entries: Array, waiting: bool) -> void:
	if entries.is_empty(): return
	details.add_child(_label(heading, "label", UI.MUTED if waiting else UI.EDGE_LIGHT))
	for entry in entries:
		var when: String = "On evolution" if entry[0] is String else "Lv %d" % int(entry[0])
		details.add_child(_label("%s   %s%s" % [when, _move_name(entry[1]), " (not taught yet)" if waiting else ""]))

func _close() -> void:
	UI.tick("cancel")
	town.panel = {}
	screen.hide()

func poll() -> bool:
	if town.cutscene or not town.talk.is_empty() or town.evolving_now: return false
	if town.panel.get("service", "") not in SERVICES: return false
	# Actions, not keys (Claude, 2026-10-23, FEEL-01): the same W/S, A/D, Page Up/Down, E/J/Enter and Esc on a
	# keyboard (physical keys now, as in a Hollow), the D-pad or left stick, the right stick, A or X and B on a
	# pad, and whatever the player rebound. The shared tap memory (UI.tapped) replaces the town's _tapped.
	if UI.tapped("move_up"): select(selected - 1)
	if UI.tapped("move_down"): select(selected + 1)
	if UI.tapped("move_left"): _set_tab("growth")
	if UI.tapped("move_right"): _set_tab("moves")
	if UI.tapped("page_up"): detail_scroll.scroll_vertical -= 120
	if UI.tapped("page_down"): detail_scroll.scroll_vertical += 120
	if UI.tapped_any(["confirm", "interact"]): town.act_use()
	if UI.tapped("cancel"): _close()
	return true
