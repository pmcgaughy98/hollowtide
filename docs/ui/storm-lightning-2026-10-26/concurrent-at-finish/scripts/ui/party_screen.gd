extends Control
## The party screen (Claude, 2026-10-10). Preston: "party screen, portrait, move icons and buttons...
## start looking our unique legit game", then "party screen still has just a little bit of tells its
## A.I, use synthesis to study human made products". The first version laid four identical cards side
## by side with every fact at the same weight: the uniform grid that reads as generated. This one
## follows the structure of hand-made summary screens (pokeemerald's summary, read from pret as
## structure only; Explorers of Sky's team pages): one creature at a time, a fixed left column with
## the creature itself, pages to the right, and a detail panel for the chosen move.
##   left column  the team strip (headshots, the one shown raised), the creature on a parchment stage,
##                breathing, its name, essences and level
##   Status page  health, EXP, what evolving waits on, IQ and its skills with the next one to come
##   Moves page   the four moves with a cursor; the chosen move's essence, power, reach, recharge, what
##                it does and the body part it comes from
##   keys         Left / Right pages, Up / Down creatures (on Moves: Enter to pick a move, Up / Down,
##                Esc back to creatures); the mouse works on the strip, the tabs and the moves
## In the Hollow it reads the live run; in town, the carried record. `lines` keeps the facts as text.

const UI := preload("res://scripts/ui/ui_style.gd")
const ControlsText := preload("res://scripts/ui/controls_text.gd")   # its pair(), for the hint's arrow words
const Lines := preload("res://scripts/creatures/lines.gd")
const ArenaData := preload("res://scripts/arena/arena_prototype.gd")
const TeamRecord := preload("res://scripts/town/team_state.gd")
const MoveBody := preload("res://scripts/moves/move_body.gd")
const CreatureIdle := preload("res://scripts/ui/creature_idle.gd")
const Shrine := preload("res://scripts/ui/shrine_info.gd")   # its stone rule, words and dimming (LF7-07)
const DUNGEON := "res://scripts/dungeon/dungeon.gd"   # loaded, not preloaded: dungeon.gd preloads the pause menu
const PAGES := ["Status", "Moves"]
const LEFT := Rect2(64, 92, 360, 504)
const RIGHT := Rect2(440, 128, 648, 420)

var cards: Array = []
# A scene behind the creature by its first essence (Preston, 2026-10-10: "a scene behind them like we did
# for the old signature moves... each ember gets same scene"): the signature stages from the original
# battle screen (assets/backgrounds/signature_stages). An essence without one keeps the plain parchment.
const ESSENCE_STAGE := {
	"EMBER": "furnace_roar", "TIDE": "undertow", "BLOOM": "root_rampart",
	"ELECTRIC": "stormlantern", "STONE": "kingstone_rail", "GALE": "gale_bluff",
}
var _stages := {}


func _stage_tex(ess: String) -> Texture2D:
	if not _stages.has(ess):
		var path := "res://assets/backgrounds/signature_stages/%s.png" % ESSENCE_STAGE.get(ess, "")
		_stages[ess] = load(path) if ESSENCE_STAGE.has(ess) and ResourceLoader.exists(path) else null
	return _stages[ess]
var lines: Array[String] = []
var sel := 0          # which teammate is shown
var page := 0         # 0 Status, 1 Moves
var move_sel := 0
var picking := false  # on the Moves page, the cursor is on the moves
var _t := 0.0
var _iq_skills: Array = []
var _D: GDScript
var _sound: AudioStreamPlayer
var _sparkwick_art: Node2D
var _new_creature_art: Node2D


func setup(scene: Node) -> void:
	position = Vector2.ZERO
	size = Vector2(1152, 648)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_PASS
	_sound = AudioStreamPlayer.new()
	_sound.stream = load("res://assets/audio/sfx/ui/cursor.wav")
	_sound.volume_db = -12.0
	_sound.bus = &"UI"   # with the other menu clicks, off the effects slider (Claude, 2026-10-22, W12)
	add_child(_sound)
	_sparkwick_art = preload("res://scripts/ui/sparkwick_canvas.gd").new()
	add_child(_sparkwick_art)
	_new_creature_art = preload("res://scripts/ui/creature_detail_canvas.gd").new()
	add_child(_new_creature_art)
	_D = load(DUNGEON)
	var c: Dictionary = _D.get_script_constant_map()
	_iq_skills = c["IQ_SKILLS"]
	var in_hollow := "ents" in scene
	var rec: Dictionary = {"party": scene.party, "levels": scene.levels, "growth": scene.growth, "iq": scene.iq, "taught": scene.taught} if in_hollow else TeamRecord.data
	var live: Array = []
	if in_hollow:
		for e in scene.ents:
			if e["team"] == 0:
				live.append(e)
	var party: Array = rec.get("party", [])
	for k in party.size():
		var ln := int(party[k][0])
		var st := int(party[k][1])
		var form: Array = Lines.of(ln)["forms"][st]
		var data: CreatureData = load(form[1])
		var lv_rec: Dictionary = rec.get("levels", {}).get(ln, {"lv": 1, "exp": 0})
		var lv := int(lv_rec.get("lv", 1))
		var e: Dictionary = live[k] if k < live.size() else {}
		var key := "%d:%d" % [ln, st]
		var moves: Array = e["moves"] if not e.is_empty() else rec.get("taught", {}).get(key, _D.moves_for(ln, st, lv))
		var ess: Array = [CreatureData.Essence.keys()[data.essence]]
		if data.has_second_essence:
			ess.append(CreatureData.Essence.keys()[data.second_essence])
		var card := {"form": form[0], "name": data.creature_name, "lead": k == 0, "lv": lv, "exp": int(lv_rec.get("exp", 0)),
			"next": _D.exp_to_next(lv), "iq": int(rec.get("iq", {}).get(ln, 0)), "ess": ess, "moves": moves, "final": st >= 2,
			"hp": e.get("hp", -1), "max_hp": e.get("max_hp", -1), "cds": e.get("cds", {}), "basic": _D.basic_of(form[0])}
		if st < 2 and c["EVO"].has(ln):
			var r: Dictionary = c["EVO"][ln]
			var g: Dictionary = rec.get("growth", {}).get(key, {})
			card["evo"] = [["Level", lv, c["EVO_LEVEL"][st]], ["KOs", int(g.get("kos", 0)), r["kos"][st]],
				["Floors", int(g.get("floors", 0)), r["floors"][st]], [UI.WAY_NAMES.get(r["way"], r["way"]), int(g.get(r["way"], 0)), r["need"][st]]]   # the shrine's words (L6-22)
		# Whether the Warden's stone lets it grow whatever these counts, by the shrine's own rule on the carried record
		# (Claude, 2026-10-26, LF7-07): the leader and the partner at their first stage once the stone is set in.
		card["stone"] = Shrine.stone_lets(TeamRecord.data, k)
		var still := "res://assets/sprites/arena/%s/sw.png" % form[0]
		card["still"] = load(still) if ResourceLoader.exists(still) else null
		card["idle"] = CreatureIdle.frames(form[0])   # the big front idle, when the form has one
		card["idle_box"] = CreatureIdle.box(card["idle"])
		# The strip's headshot: a 16 x 16 cut of the dialogue face drawn 3x in the 48 px box, the dialogue's own pixel
		# size (Claude, 2026-10-23, UI-05; it was the 48 x 48 portrait.png at 1x). `face_cut` marks a cut: it is
		# drawn as the dialogue draws it, plain; a form without a dialogue face keeps its portrait.png and finish.
		card["face"] = UI.portrait_3x(String(form[0]))
		card["face_cut"] = UI.dialogue_portrait(String(form[0])) != null
		cards.append(card)
		lines.append("%s   Lv %d   Sense %d" % [String(data.creature_name).to_upper(), lv, card["iq"]] + ("   HP %d/%d" % [card["hp"], card["max_hp"]] if card["hp"] >= 0 else ""))
		if card.has("evo"):
			lines.append("To grow: " + ", ".join(card["evo"].map(func(b: Array) -> String: return "%s %d/%d" % b)))
			if card["stone"]:
				lines.append(Shrine.STONE_NOW)
		lines.append("Moves: " + ", ".join(moves.map(func(m: String) -> String: return ArenaData.MOVES[m]["name"] if ArenaData.MOVES.has(m) else m)))
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()   # the creature breathes


func _beep() -> void:
	if is_instance_valid(_sound):
		_sound.play()


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree() or cards.is_empty() or not (event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion) or not event.is_pressed() or event.is_echo():
		return
	# Godot's menu directions through UI.pressed (Claude, 2026-10-23, FEEL-01): the same keys, the D-pad, and now
	# the left stick, once per push. Choose and back stay the engine's ui_accept and ui_cancel, as every menu
	# button reads them (the menus context): a chord-muted A would fall through to the focused Back button.
	var left := UI.pressed(event, "ui_left")
	var right := UI.pressed(event, "ui_right")
	var up := UI.pressed(event, "ui_up")
	var down := UI.pressed(event, "ui_down")
	var handled := true
	if left or right:
		page = (page + (1 if right else -1) + PAGES.size()) % PAGES.size()
		picking = false
	elif up or down:
		var step := 1 if down else -1
		if picking:
			move_sel = posmod(move_sel + step, maxi(1, cards[sel]["moves"].size()))
		else:
			sel = posmod(sel + step, cards.size())
			move_sel = 0
	elif event.is_action_pressed("ui_accept") and page == 1 and not picking:
		picking = true
	elif event.is_action_pressed("ui_cancel") and picking:
		picking = false
	else:
		handled = false
	if handled:
		_beep()
		get_viewport().set_input_as_handled()


func _gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	var p: Vector2 = event.position
	for k in cards.size():
		if _tab_rect(k).has_point(p):
			sel = k
			move_sel = 0
			_beep()
	for k in PAGES.size():
		if _page_rect(k).has_point(p):
			page = k
			picking = false
			_beep()
	if page == 1:
		for k in cards[sel]["moves"].size():
			if _move_rect(k).has_point(p):
				move_sel = k
				picking = true
				_beep()


func _tab_rect(k: int) -> Rect2:
	return Rect2(LEFT.position.x + 26 + k * 58, LEFT.position.y + 24 - (4 if k == sel else 0), 50, 50)


func _page_rect(k: int) -> Rect2:
	return Rect2(RIGHT.position.x + 12 + k * 132, RIGHT.position.y - 34, 126, 36)


## The moves sit in a well as tall as the list, a row every 60 px with 17 px above the first and below the
## last: rows x 60 + 24 (Claude, 2026-10-22, LP-08). Its top lines up with the move box beside it.
func _move_rect(k: int) -> Rect2:
	return Rect2(RIGHT.position.x + 20, RIGHT.position.y + 39 + k * 60, 290, 50)


func _move_well(rows: int) -> Rect2:
	return Rect2(RIGHT.position.x + 12, RIGHT.position.y + 22, 306, rows * 60 + 24)


## The creature's scale on the stage: a whole number from 1 to 2 (Claude, 2026-10-22, LP-08 and UI-04). Half
## steps drew some art pixels two screen pixels wide and their neighbours one. The checks read it per form.
func scale_for(c: Dictionary) -> float:
	var idle: Array = c["idle"]
	if not idle.is_empty():
		var ib: Rect2i = c["idle_box"]
		return clampf(floorf(minf(236.0 / maxi(1, ib.size.y), 310.0 / maxi(1, ib.size.x))), 1.0, 2.0)
	var tex: Texture2D = c["still"]
	if tex == null:
		return 1.0
	var used := tex.get_image().get_used_rect()
	return clampf(floorf(minf(220.0 / maxi(1, used.size.y), 300.0 / maxi(1, used.size.x))), 1.0, 2.0)


func _ess_of_move(m: String, c: Dictionary) -> String:
	var e: int = ArenaData.MOVE_ESSENCE.get(m, -1)
	return CreatureData.Essence.keys()[e] if e >= 0 else String(c["ess"][0])


func _draw() -> void:
	_new_creature_art.clear()
	# The frame starts 20 px higher than it did so the heading has the pause pages' room above it (Claude, 2026-10-26).
	var frame := Rect2(40, 8, 1072, 612)
	UI.panel(self, frame, 0.97)
	# The heading every pause page has (Claude, 2026-10-26, L7-22): the page's name in capitals in the title face, in
	# parchment with its drop shadow, where a small "Team" in the name colour sat.
	UI.say(self, Vector2(64, 72), "TEAM", "title", UI.TEXT)
	# The keys of the device in use (Claude, 2026-10-23): Esc on a keyboard, B on a pad, from the Input Map; the arrow
	# words too since pass 6 (Claude, 2026-10-24, W18): "D-pad Left/Right" on a pad, whatever ui_left and ui_right hold.
	UI.text(self, Vector2(64, 72), "%s  page     %s  creature     %s  back" % [ControlsText.pair("ui_left", "ui_right"), ControlsText.pair("ui_up", "ui_down"), UI.binding_text("ui_cancel")], 14, UI.MUTED, 1024, HORIZONTAL_ALIGNMENT_RIGHT)
	draw_line(Vector2(64, 80), Vector2(1088, 80), Color(UI.EDGE, 0.5), 1.0)
	if cards.is_empty():
		UI.text(self, Vector2(64, 130), "No team yet.", 20, UI.MUTED)
		return
	var c: Dictionary = cards[sel]
	_sparkwick_art.draws.clear()
	_draw_left(c)
	_sparkwick_art.queue_redraw()
	for k in PAGES.size():
		var r := _page_rect(k)
		var on := k == page
		# The open page is a brass tab with dark ink, as a speaker's name plate; the other is a dark slot.
		if on:
			draw_style_box(UI.frame("nameplate"), r)
		else:
			draw_rect(r.grow(-3.0), Color(0, 0, 0, 0.45))
			draw_rect(r.grow(-3.0), Color(UI.EDGE, 0.5), false, 3.0)
		UI.text(self, r.position + Vector2(0, 26), PAGES[k], 19, Color("#2a1f14") if on else UI.MUTED, r.size.x, HORIZONTAL_ALIGNMENT_CENTER)
	UI.panel(self, RIGHT, 0.85)
	if page == 0:
		_draw_status(c)
	else:
		_draw_moves(c)


func _draw_left(c: Dictionary) -> void:
	UI.panel(self, LEFT, 0.85)
	# The team strip: everyone's headshot, the one shown raised and lit.
	for k in cards.size():
		var r := _tab_rect(k)
		draw_rect(r, UI.PORTRAIT_BG if k == sel else Color(UI.PORTRAIT_BG, 0.45))
		if cards[k]["face"] != null:
			var tint := Color.WHITE if k == sel else Color(1, 1, 1, 0.55)
			if cards[k]["face_cut"]:
				draw_texture_rect(cards[k]["face"], Rect2(r.position + Vector2(1, 1), Vector2(48, 48)), false, tint)
			elif cards[k]["form"] == "sparkwick":
				_sparkwick_art.draws.append({"at": Vector2.ZERO, "scale": Vector2.ONE, "tex": cards[k]["face"], "dest": r.grow(-1.0), "region": Rect2(Vector2.ZERO, cards[k]["face"].get_size()), "colour": tint})
			elif preload("res://scripts/arena/creature_finish.gd").new_creature(String(cards[k]["form"])):
				_new_creature_art.paint(cards[k]["face"], r.grow(-2.0), Rect2(Vector2.ZERO, cards[k]["face"].get_size()), tint)
			else:
				draw_texture_rect(cards[k]["face"], r.grow(-1.0), false, tint)
		draw_rect(r, UI.EDGE_LIGHT if k == sel else UI.EDGE, false, 2.0 if k == sel else 1.0)
	# The stage: parchment, a soft floor shadow, the creature turned to its right, breathing.
	var stage := Rect2(LEFT.position + Vector2(22, 84), Vector2(316, 266))
	draw_style_box(UI.frame("portrait"), stage)
	var scene: Texture2D = _stage_tex(String(c["ess"][0])) if not c["ess"].is_empty() else null
	if scene != null:
		# Fill the frame's inside, cropped from the scene's middle with its floor at the bottom, at a whole
		# scale of at least 1 (Claude, 2026-10-22, LP-08): a 0.97 shrink dropped rows of the painted stage.
		var inner := stage.grow(-9.0)
		var ks := maxf(1.0, floorf(inner.size.y / scene.get_height()))
		var cut := inner.size / ks
		var src := Rect2((scene.get_width() - cut.x) * 0.5, scene.get_height() - cut.y, cut.x, cut.y)
		draw_texture_rect_region(scene, inner, src, Color(0.86, 0.86, 0.86) if c["hp"] != 0 else Color(0.5, 0.5, 0.5))
		draw_rect(inner, UI.EDGE, false, 1.0)
	var idle: Array = c["idle"]
	if not idle.is_empty():
		# The detailed front idle, playing, turned to its right like the headshots (mirrored).
		var ib: Rect2i = c["idle_box"]
		var k := scale_for(c)
		var foot := stage.position + Vector2(stage.size.x * 0.5, stage.size.y - 18)
		draw_set_transform(foot, 0.0, Vector2(1.0, 0.28))
		draw_circle(Vector2.ZERO, ib.size.x * k * 0.42, Color(0, 0, 0, 0.18))
		draw_set_transform(foot + Vector2(0, -ib.size.y * k), 0.0, Vector2(-k, k))
		var tint := Color(0.6, 0.6, 0.6) if c["hp"] == 0 else Color.WHITE
		if c["form"] == "sparkwick":
			_sparkwick_art.draws.append({"at": foot + Vector2(0, -ib.size.y * k), "scale": Vector2(-k, k), "tex": CreatureIdle.frame_at(idle, _t), "dest": Rect2(-ib.size.x * 0.5, 0, ib.size.x, ib.size.y), "region": Rect2(ib), "colour": tint})
		else:
			draw_texture_rect_region(CreatureIdle.frame_at(idle, _t), Rect2(-ib.size.x * 0.5, 0, ib.size.x, ib.size.y), Rect2(ib), tint)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var tex: Texture2D = c["still"]
	if tex != null and idle.is_empty():
		var used := tex.get_image().get_used_rect()
		var k := scale_for(c)   # whole steps keep every pixel the same size
		var foot := stage.position + Vector2(stage.size.x * 0.5, stage.size.y - 26)
		var shadow_w := used.size.x * k * 0.45
		draw_set_transform(foot, 0.0, Vector2(1.0, 0.28))
		draw_circle(Vector2.ZERO, shadow_w, Color(0, 0, 0, 0.18))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		var breathe := roundf(sin(_t * 2.2) * 1.5)
		var dest := Rect2(foot.x - (used.size.x * 0.5) * k, foot.y - used.size.y * k + breathe, used.size.x * k, used.size.y * k)
		if preload("res://scripts/arena/creature_finish.gd").new_creature(String(c["form"])):
			_new_creature_art.paint(tex, dest, Rect2(used), Color(0.6, 0.6, 0.6) if c["hp"] == 0 else Color.WHITE)
		else:
			draw_texture_rect_region(tex, dest, Rect2(used), Color(0.6, 0.6, 0.6) if c["hp"] == 0 else Color.WHITE)
	# Name, essences, level.
	var y := stage.end.y + 36
	UI.text(self, Vector2(LEFT.position.x + 18, y), String(c["name"]), 26, UI.EDGE_LIGHT if c["lead"] else UI.TEXT)
	var ix := LEFT.position.x + 18
	for es in c["ess"]:
		var it := UI.essence_icon(es)
		if it != null:
			draw_texture(it, Vector2(ix, y + 12))
		UI.text(self, Vector2(ix + 36, y + 34), String(es).capitalize(), 15, UI.MUTED)
		ix += 110
	UI.text(self, Vector2(LEFT.position.x + 18, y), "Lv %d" % c["lv"], 22, UI.TEXT, 324, HORIZONTAL_ALIGNMENT_RIGHT)
	if c["lead"]:
		UI.text(self, Vector2(LEFT.position.x + 18, y + 34), "Leader", 15, UI.EDGE_LIGHT, 324, HORIZONTAL_ALIGNMENT_RIGHT)


func _section(at: Vector2, title: String, col := UI.EDGE_LIGHT) -> void:
	UI.text(self, at, title, 18, col)
	draw_line(at + Vector2(UI.width_of(title, 18) + 10, -6), Vector2(RIGHT.end.x - 20, at.y - 6), Color(UI.EDGE, 0.45), 1.0)


func _draw_status(c: Dictionary) -> void:
	var x := RIGHT.position.x + 22
	var y := RIGHT.position.y + 40
	_section(Vector2(x, y), "Condition")
	UI.text(self, Vector2(x, y + 34), "Health", 16, UI.MUTED)
	if c["hp"] >= 0:
		var hk: float = float(c["hp"]) / maxf(1.0, c["max_hp"])
		UI.bar(self, Rect2(x + 110, y + 22, 300, 12), hk, UI.hp_col(hk))
		UI.text(self, Vector2(x + 424, y + 35), "%d / %d" % [c["hp"], c["max_hp"]], 16, UI.TEXT)
	else:
		UI.text(self, Vector2(x + 110, y + 35), "Rested in town", 16, UI.TEXT)
	UI.text(self, Vector2(x, y + 64), "EXP", 16, UI.MUTED)
	UI.bar(self, Rect2(x + 110, y + 52, 300, 12), float(c["exp"]) / maxf(1.0, c["next"]), UI.ALLY)
	UI.text(self, Vector2(x + 424, y + 65), "%d more to Lv %d" % [c["next"] - c["exp"], c["lv"] + 1], 16, UI.TEXT)
	y += 104
	if c.has("evo"):
		# Under the Warden's stone the counts are not needed this time (Claude, 2026-10-26, LF7-07): the heading, names,
		# gauges and counts take the shrine's dimmed parchment, the shrine's line says why under the heading, and the
		# rows close up from 26 px to 22 so the Sense rows below keep their place.
		var stone: bool = c.get("stone", false)
		var dim := Color(UI.MUTED, Shrine.STONE_DIM)
		_section(Vector2(x, y), "Growing waits on", dim if stone else UI.EVO)
		var top: float = y + 30
		var step := 26
		if stone:
			UI.text(self, Vector2(x, y + 26), Shrine.STONE_NOW, 16, UI.EVO, 600)
			top = y + 38
			step = 22
		for b in c["evo"].size():
			var row: Array = c["evo"][b]
			var yy: float = top + b * step
			var done: bool = row[1] >= row[2]
			UI.text(self, Vector2(x, yy + 12), String(row[0]), 16, dim if stone else (UI.TEXT if done else UI.MUTED))
			UI.bar(self, Rect2(x + 110, yy + 2, 300, 10), float(row[1]) / maxf(1.0, row[2]), dim if stone else (UI.HP_GOOD if done else UI.EVO))
			UI.text(self, Vector2(x + 424, yy + 13), ("%d / %d" % [row[1], row[2]]) + ("   done" if done else ""), 15, dim if stone else (UI.HP_GOOD if done else UI.TEXT))
	else:
		_section(Vector2(x, y), "Final stage", UI.EDGE_LIGHT)
		UI.text(self, Vector2(x, y + 34), "This line has nowhere further to grow.", 16, UI.MUTED)
	y += 146
	_section(Vector2(x, y), "Sense %d" % c["iq"])
	var shown := 0
	for sk in _iq_skills:
		if c["iq"] >= sk["at"] and shown < 3:
			UI.text(self, Vector2(x, y + 30 + shown * 24), String(sk["name"]), 16, UI.TEXT)
			UI.text(self, Vector2(x + 150, y + 30 + shown * 24), String(sk["what"]), 14, UI.MUTED, 440)
			shown += 1
	for sk in _iq_skills:
		if c["iq"] < sk["at"]:
			UI.text(self, Vector2(x, y + 30 + shown * 24), "At Sense %d: %s" % [sk["at"], sk["name"]], 15, Color(UI.MUTED, 0.75), 600)
			break


func _draw_moves(c: Dictionary) -> void:
	var moves: Array = c["moves"]
	move_sel = clampi(move_sel, 0, maxi(0, moves.size() - 1))
	if not moves.is_empty():
		var well := _move_well(moves.size())
		draw_rect(well, Color(0, 0, 0, 0.22))
		draw_rect(well, Color(UI.EDGE, 0.6), false, 1.0)
	for k in moves.size():
		var m: String = moves[k]
		var mv: Dictionary = ArenaData.MOVES.get(m, {"name": m, "damage": 0})
		var r := _move_rect(k)
		var on := k == move_sel
		draw_rect(r, UI.FOCUS if on else Color(0, 0, 0, 0.25))
		draw_rect(r, (UI.EDGE_LIGHT if picking else UI.EDGE) if on else Color(UI.EDGE, 0.35), false, 2.0 if on else 1.0)
		var it := UI.essence_icon(_ess_of_move(m, c))
		if it != null:
			draw_texture(it, r.position + Vector2(9, 9))
		UI.text(self, r.position + Vector2(52, 24), String(mv["name"]), 19, UI.TEXT)
		UI.text(self, r.position + Vector2(52, 43), ("Heal %d" % mv["heal"]) if mv.get("heal", 0) > 0 else ("Power %d" % mv["damage"]), 14, UI.MUTED)
		if m == c["basic"]:
			UI.text(self, r.position + Vector2(0, 24), "Basic", 14, UI.EDGE_LIGHT, r.size.x - 12, HORIZONTAL_ALIGNMENT_RIGHT)
	if moves.is_empty():
		return
	# The chosen move, in full.
	var m: String = moves[move_sel]
	var mv: Dictionary = ArenaData.MOVES.get(m, {"name": m, "damage": 0, "range": 0.0, "cooldown": 0.0})
	var reach: Dictionary = _D.move_reach(m)
	var heal: int = mv.get("heal", 0)
	var turns := maxi(1, int(ceil(mv["cooldown"])))
	var facts := [["Power", ("heals %d a turn" % heal) if heal > 0 else str(mv["damage"])],
		["Reach", "%s %d" % [String(reach["kind"]).capitalize(), reach["n"]]],
		["Recharge", "none, the basic" if m == c["basic"] else "%d turn%s" % [turns, "" if turns == 1 else "s"]]]
	var cd: int = int(c["cds"].get(m, 0))
	if cd > 0:
		facts.append(["Ready in", "%d turn%s" % [cd, "" if cd == 1 else "s"]])
	var parts: Array = MoveBody.NEEDS.get(m, [])
	var box := move_box(_describe(reach, heal), facts.size(), not parts.is_empty())
	var d := Rect2(RIGHT.position.x + 326, RIGHT.position.y + 22, 302, float(box["height"]))
	draw_rect(d, Color(0, 0, 0, 0.22))
	draw_rect(d, Color(UI.EDGE, 0.6), false, 1.0)
	var ess := _ess_of_move(m, c)
	var big := UI.essence_icon(ess)
	if big != null:
		draw_texture_rect(big, Rect2(d.position + Vector2(16, 16), Vector2(48, 48)), false)
	UI.text(self, d.position + Vector2(76, 40), String(mv["name"]), 22, UI.EDGE_LIGHT, 220)
	UI.text(self, d.position + Vector2(76, 62), String(ess).capitalize(), 16, UI.MUTED)
	for k in facts.size():
		UI.text(self, d.position + Vector2(18, 104 + k * 26), String(facts[k][0]), 16, UI.MUTED)
		UI.text(self, d.position + Vector2(120, 104 + k * 26), String(facts[k][1]), 16, UI.TEXT, 170)
	var rule: float = d.position.y + float(box["rule"])
	draw_line(Vector2(d.position.x + 16, rule), Vector2(d.end.x - 16, rule), Color(UI.EDGE, 0.4), 1.0)
	# The description in the body face, a row at a time.
	var rows: PackedStringArray = box["lines"]
	for i in rows.size():
		UI.say(self, Vector2(d.position.x + 18, d.position.y + float(box["first"]) + i * float(box["line_h"])), rows[i], "body", UI.TEXT, d.size.x - 36)
	if not parts.is_empty():   # the body part right under what the move does (LP-08)
		UI.text(self, Vector2(d.position.x + 18, d.position.y + float(box["parts"])), "Comes from its %s" % " and ".join(parts), 14, UI.MUTED, d.size.x - 36)


## The move box's layout, measured down from its top (Claude, 2026-10-22, LP-08): the facts, a rule, the
## description in the body face wrapped at 266 px, then the body-part note right under it. The box is as tall
## as that, never past the right panel's frame. "first" and "parts" are baselines; the checks call this with
## every move's description.
func move_box(desc: String, facts_n: int, has_parts: bool) -> Dictionary:
	var f := UI.font("body")
	var n := UI.type_size("body")
	var lf := UI.font("label")
	var ln := UI.type_size("label")
	var line_h := f.get_height(n) + 2.0
	var lines := UI.wrap_text(desc, 266.0, "body").split("\n")
	var rule := 104.0 + (facts_n - 1) * 26.0 + 16.0
	var first := rule + 10.0 + f.get_ascent(n)
	var end := first + (lines.size() - 1) * line_h + f.get_descent(n)
	var parts := end + 10.0 + lf.get_ascent(ln) if has_parts else end
	var bottom := (parts + lf.get_descent(ln) if has_parts else end) + 16.0
	return {"lines": lines, "line_h": line_h, "rule": rule, "first": first, "parts": parts,
		"height": minf(roundf(bottom), RIGHT.size.y - 46.0), "needs": roundf(bottom)}


func _describe(reach: Dictionary, heal: int) -> String:
	if heal > 0:
		return "Plants its roots and a spring wells up: it and every teammate beside it heal now and at the end of each turn it stays, and it cannot be pushed while rooted."
	match String(reach["kind"]):
		"front":
			return "Strikes the foe right in front of it."
		"dash":
			return "Dashes up to %d tiles and hits the first foe in the way, knocking it back." % reach["n"]
		"line":
			return "Hits the first foe in a straight line up to %d tiles away." % reach["n"]
		"burst":
			return "Lands on the first foe up to %d tiles away and bursts, hitting everything around it." % reach["n"]
	return "Hits a foe within %d tiles." % reach["n"]
