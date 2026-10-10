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
const ArenaData := preload("res://scripts/arena/arena_prototype.gd")
const TeamRecord := preload("res://scripts/town/team_state.gd")
const MoveBody := preload("res://scripts/moves/move_body.gd")
const CreatureIdle := preload("res://scripts/ui/creature_idle.gd")
const DUNGEON := "res://scripts/dungeon/dungeon.gd"   # loaded, not preloaded: dungeon.gd preloads the pause menu
const WAY_NAMES := {"flank": "Pincers", "ambush": "Ambushes", "took": "Hits taken", "slam": "Slams", "healed": "Healing"}
const PAGES := ["Status", "Moves"]
const LEFT := Rect2(64, 92, 360, 504)
const RIGHT := Rect2(440, 128, 648, 420)

var cards: Array = []
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


func setup(scene: Node) -> void:
	position = Vector2.ZERO
	size = Vector2(1152, 648)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_PASS
	_sound = AudioStreamPlayer.new()
	_sound.stream = load("res://assets/audio/sfx/ui/cursor.wav")
	_sound.volume_db = -12.0
	add_child(_sound)
	_sparkwick_art = preload("res://scripts/ui/sparkwick_canvas.gd").new()
	add_child(_sparkwick_art)
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
		var form: Array = ArenaData.LINES[ln]["forms"][st]
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
				["Floors", int(g.get("floors", 0)), r["floors"][st]], [WAY_NAMES.get(r["way"], r["way"]), int(g.get(r["way"], 0)), r["need"][st]]]
		var still := "res://assets/sprites/arena/%s/sw.png" % form[0]
		card["still"] = load(still) if ResourceLoader.exists(still) else null
		card["idle"] = CreatureIdle.frames(form[0])   # the big front idle, when the form has one
		card["idle_box"] = CreatureIdle.box(card["idle"])
		var face := "res://assets/sprites/arena/%s/portrait.png" % form[0]
		card["face"] = load(face) if ResourceLoader.exists(face) else null
		cards.append(card)
		lines.append("%s   Lv %d   IQ %d" % [String(data.creature_name).to_upper(), lv, card["iq"]] + ("   HP %d/%d" % [card["hp"], card["max_hp"]] if card["hp"] >= 0 else ""))
		if card.has("evo"):
			lines.append("To evolve: " + ", ".join(card["evo"].map(func(b: Array) -> String: return "%s %d/%d" % b)))
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
	if not is_visible_in_tree() or cards.is_empty() or not (event is InputEventKey or event is InputEventJoypadButton) or not event.is_pressed() or event.is_echo():
		return
	var handled := true
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		page = (page + (1 if event.is_action_pressed("ui_right") else -1) + PAGES.size()) % PAGES.size()
		picking = false
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		var step := 1 if event.is_action_pressed("ui_down") else -1
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


func _move_rect(k: int) -> Rect2:
	return Rect2(RIGHT.position.x + 20, RIGHT.position.y + 26 + k * 58, 290, 50)


func _ess_of_move(m: String, c: Dictionary) -> String:
	var e: int = ArenaData.MOVE_ESSENCE.get(m, -1)
	return CreatureData.Essence.keys()[e] if e >= 0 else String(c["ess"][0])


func _draw() -> void:
	var frame := Rect2(40, 28, 1072, 592)
	UI.panel(self, frame, 0.97)
	UI.text(self, Vector2(64, 70), "Team", 30, UI.EDGE_LIGHT)
	UI.text(self, Vector2(64, 70), "Left / Right  page     Up / Down  creature     Esc  back", 14, UI.MUTED, 1024, HORIZONTAL_ALIGNMENT_RIGHT)
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
			if cards[k]["form"] == "sparkwick":
				_sparkwick_art.draws.append({"at": Vector2.ZERO, "scale": Vector2.ONE, "tex": cards[k]["face"], "dest": r.grow(-1.0), "region": Rect2(Vector2.ZERO, cards[k]["face"].get_size()), "colour": tint})
			else:
				draw_texture_rect(cards[k]["face"], r.grow(-1.0), false, tint)
		draw_rect(r, UI.EDGE_LIGHT if k == sel else UI.EDGE, false, 2.0 if k == sel else 1.0)
	# The stage: parchment, a soft floor shadow, the creature turned to its right, breathing.
	var stage := Rect2(LEFT.position + Vector2(22, 84), Vector2(316, 266))
	draw_style_box(UI.frame("portrait"), stage)
	var idle: Array = c["idle"]
	if not idle.is_empty():
		# The detailed front idle, playing, turned to its right like the headshots (mirrored).
		var ib: Rect2i = c["idle_box"]
		var k := clampf(minf(236.0 / ib.size.y, 310.0 / ib.size.x), 0.5, 2.0)
		k = floorf(k * 2.0) / 2.0
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
		var k := clampf(minf(220.0 / used.size.y, 300.0 / used.size.x), 1.0, 2.0)
		k = floorf(k * 2.0) / 2.0   # whole or half steps keep the pixels square
		var foot := stage.position + Vector2(stage.size.x * 0.5, stage.size.y - 26)
		var shadow_w := used.size.x * k * 0.45
		draw_set_transform(foot, 0.0, Vector2(1.0, 0.28))
		draw_circle(Vector2.ZERO, shadow_w, Color(0, 0, 0, 0.18))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		var breathe := roundf(sin(_t * 2.2) * 1.5)
		var dest := Rect2(foot.x - (used.size.x * 0.5) * k, foot.y - used.size.y * k + breathe, used.size.x * k, used.size.y * k)
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
		_section(Vector2(x, y), "Evolving waits on", UI.EVO)
		for b in c["evo"].size():
			var row: Array = c["evo"][b]
			var yy: float = y + 30 + b * 26
			var done: bool = row[1] >= row[2]
			UI.text(self, Vector2(x, yy + 12), String(row[0]), 16, UI.TEXT if done else UI.MUTED)
			UI.bar(self, Rect2(x + 110, yy + 2, 300, 10), float(row[1]) / maxf(1.0, row[2]), UI.HP_GOOD if done else UI.EVO)
			UI.text(self, Vector2(x + 424, yy + 13), ("%d / %d" % [row[1], row[2]]) + ("   done" if done else ""), 15, UI.HP_GOOD if done else UI.TEXT)
	else:
		_section(Vector2(x, y), "Final stage", UI.EDGE_LIGHT)
		UI.text(self, Vector2(x, y + 34), "This line has nowhere further to grow.", 16, UI.MUTED)
	y += 146
	_section(Vector2(x, y), "IQ %d" % c["iq"])
	var shown := 0
	for sk in _iq_skills:
		if c["iq"] >= sk["at"] and shown < 3:
			UI.text(self, Vector2(x, y + 30 + shown * 24), String(sk["name"]), 16, UI.TEXT)
			UI.text(self, Vector2(x + 150, y + 30 + shown * 24), String(sk["what"]), 14, UI.MUTED, 440)
			shown += 1
	for sk in _iq_skills:
		if c["iq"] < sk["at"]:
			UI.text(self, Vector2(x, y + 30 + shown * 24), "At IQ %d: %s" % [sk["at"], sk["name"]], 15, Color(UI.MUTED, 0.75), 600)
			break


func _draw_moves(c: Dictionary) -> void:
	var moves: Array = c["moves"]
	move_sel = clampi(move_sel, 0, maxi(0, moves.size() - 1))
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
	var d := Rect2(RIGHT.position.x + 326, RIGHT.position.y + 22, 302, 380)
	draw_rect(d, Color(0, 0, 0, 0.22))
	draw_rect(d, Color(UI.EDGE, 0.6), false, 1.0)
	var ess := _ess_of_move(m, c)
	var big := UI.essence_icon(ess)
	if big != null:
		draw_texture_rect(big, Rect2(d.position + Vector2(16, 16), Vector2(48, 48)), false)
	UI.text(self, d.position + Vector2(76, 40), String(mv["name"]), 22, UI.EDGE_LIGHT, 220)
	UI.text(self, d.position + Vector2(76, 62), String(ess).capitalize(), 16, UI.MUTED)
	var reach: Dictionary = _D.move_reach(m)
	var heal: int = mv.get("heal", 0)
	var turns := maxi(1, int(ceil(mv["cooldown"])))
	var facts := [["Power", ("heals %d a turn" % heal) if heal > 0 else str(mv["damage"])],
		["Reach", "%s %d" % [String(reach["kind"]).capitalize(), reach["n"]]],
		["Recharge", "none, the basic" if m == c["basic"] else "%d turn%s" % [turns, "" if turns == 1 else "s"]]]
	var cd: int = int(c["cds"].get(m, 0))
	if cd > 0:
		facts.append(["Ready in", "%d turn%s" % [cd, "" if cd == 1 else "s"]])
	for k in facts.size():
		UI.text(self, d.position + Vector2(18, 104 + k * 26), String(facts[k][0]), 16, UI.MUTED)
		UI.text(self, d.position + Vector2(120, 104 + k * 26), String(facts[k][1]), 16, UI.TEXT, 170)
	var y := d.position.y + 104 + facts.size() * 26 + 16
	draw_line(Vector2(d.position.x + 16, y - 8), Vector2(d.end.x - 16, y - 8), Color(UI.EDGE, 0.4), 1.0)
	draw_multiline_string(UI.HEAD, Vector2(d.position.x + 18, y + 14), _describe(reach, heal), HORIZONTAL_ALIGNMENT_LEFT, d.size.x - 36, 16, 5, UI.TEXT)
	var parts: Array = MoveBody.NEEDS.get(m, [])
	if not parts.is_empty():
		UI.text(self, Vector2(d.position.x + 18, d.end.y - 18), "Comes from its %s" % " and ".join(parts), 14, UI.MUTED, d.size.x - 36)


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
