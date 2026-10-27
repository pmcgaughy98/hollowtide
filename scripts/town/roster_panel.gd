extends RefCounted
## The Roster Board's panel (Claude, 2026-10-26, pass 8 R6 / L-01), built like storage_panel.gd. A recruit that finds
## the team full "will wait at the Wayline Tower" (dungeon.gd): it goes to the record's "roster". Once the team are
## runners, the Roster Board in the Hall opens this panel: the creatures waiting at the Hall on the left, the team on the
## right. Choosing a waiting creature brings it onto the team, into an open slot, or, when the team is full, in place of
## the member chosen next. Choosing a member in slots 2 to 4 sends it to wait, or, when that would leave the leader
## alone, trades it for the waiting creature chosen next. The leader is never moved, and the team keeps two at least:
## the story's scenes give slot 2 the partner's lines. Every change is saved at once. All the words are proposals.
##   W/S choose, A/D change column, E pick, Esc let go of a pick or close (the pad: D-pad, A, B).
const UI := preload("res://scripts/ui/ui_style.gd")
const SceneKit := preload("res://scripts/town/scene_kit.gd")
const Lines := preload("res://scripts/creatures/lines.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const StoragePanel := preload("res://scripts/town/storage_panel.gd")
const TEAM_MAX := 4      # four on a run, as the dungeon's TEAM_MAX
const TEAM_MIN := 2      # the leader and one more
const ROWS := 5          # waiting rows shown at once; the list scrolls with the cursor
const ROW_H := 56.0      # a 48 px face (UI.portrait_3x) and its edge
const TOP := 104.0       # the first row, under the column headings
const COL_W := 372.0     # each column's width
const GAP := 28.0        # between the columns
const GUTTER := 28.0     # right of the waiting rows, where the scroll arrows sit
const BOX := Rect2(166, 64, 820, TOP + ROWS * ROW_H + 74.0)
const NOTE := "Who runs and who waits at the Tower. The leader always runs."
const NAME_W := 180.0    # a row's name column


## The record with its roster list, made if a save has none yet.
static func _rec(host: Node) -> Dictionary:
	var rec: Dictionary = host._record()
	if not rec.has("roster") or not (rec["roster"] is Array):
		rec["roster"] = []
	return rec


## The panel a host opens: the cursor on the first waiting creature, or on slot 2 when nobody waits.
static func open_panel(host: Node) -> Dictionary:
	var waiting: Array = _rec(host)["roster"]
	var p := {"name": "Roster Board", "service": "roster", "side": "team", "row": 1, "rows": {"wait": 0, "team": 1}, "held": {}, "top": 0, "said": ""}
	if not waiting.is_empty():
		_go(p, "wait", 0)
	return p


## Up and down in the column the cursor is in. The team's column is slots 2 to 4; the leader's row is never chosen.
static func move(host: Node, dy: int) -> void:
	var p: Dictionary = host.panel
	if String(p["side"]) == "wait":
		var n: int = (_rec(host)["roster"] as Array).size()
		if n < 2:
			return
		p["row"] = posmod(int(p["row"]) + dy, n)
		p["top"] = _top(p, n)
	else:
		p["row"] = posmod(int(p["row"]) - 1 + dy, TEAM_MAX - 1) + 1
	host._ui_sfx("cursor")


## Left to the waiting creatures, right to the team. Nothing to go to when nobody waits.
static func side(host: Node, dx: int) -> void:
	var p: Dictionary = host.panel
	var to := "wait" if dx < 0 else "team"
	var n: int = (_rec(host)["roster"] as Array).size()
	if String(p["side"]) == to or (to == "wait" and n == 0):
		return
	var row := int(p["rows"].get(to, 0 if to == "wait" else 1))
	_go(p, to, clampi(row, 0, n - 1) if to == "wait" else clampi(row, 1, TEAM_MAX - 1))
	host._ui_sfx("cursor")


## E (or A) on the row under the cursor.
static func pick(host: Node) -> void:
	var p: Dictionary = host.panel
	var rec := _rec(host)
	var party: Array = rec["party"]
	var waiting: Array = rec["roster"]
	var row := int(p["row"])
	var held: Dictionary = p.get("held", {})
	if String(p["side"]) == "wait":
		if row < 0 or row >= waiting.size():
			_deny(host, "")
		elif String(held.get("side", "")) == "team":
			_trade(host, int(held["row"]), row)
		elif party.size() < TEAM_MAX:
			_join(host, row)
		else:   # the team is full: this one is held while the member to swap is chosen
			p["held"] = {"side": "wait", "row": row}
			_go(p, "team", 1)
			p["said"] = "Who waits at the Tower instead?"
			host._ui_sfx("confirm")
		return
	if row < 1 or row >= TEAM_MAX:
		_deny(host, "")
	elif String(held.get("side", "")) == "wait":
		if row >= party.size():
			_join(host, int(held["row"]))
		else:
			_trade(host, row, int(held["row"]))
	elif row >= party.size():   # an open slot: choose who joins from the other column
		if waiting.is_empty():
			_deny(host, "Nobody is waiting at the Tower yet.")
		else:
			_go(p, "wait", 0)
			p["said"] = "Who joins the team?"
			host._ui_sfx("cursor")
	elif party.size() > TEAM_MIN:
		var who: Array = party[row]
		party.remove_at(row)
		waiting.append(who)
		_done(host, "%s waits at the Tower." % _name(who))
	elif waiting.is_empty():
		_deny(host, "The leader needs someone along.")
	else:   # the last one with the leader: held while the one to bring in is chosen
		p["held"] = {"side": "team", "row": row}
		_go(p, "wait", 0)
		p["said"] = "Who comes along instead?"
		host._ui_sfx("confirm")


## Esc with a creature held lets go of it and keeps the panel open (true); otherwise the host closes the panel.
static func back(host: Node) -> bool:
	var p: Dictionary = host.panel
	if (p.get("held", {}) as Dictionary).is_empty():
		return false
	p["held"] = {}
	p["said"] = ""
	host._ui_sfx("cancel")
	return true


static func _join(host: Node, wait_row: int) -> void:
	var rec := _rec(host)
	var who: Array = rec["roster"][wait_row]
	(rec["roster"] as Array).remove_at(wait_row)
	(rec["party"] as Array).append(who)
	_done(host, "%s joins the team." % _name(who))


static func _trade(host: Node, slot: int, wait_row: int) -> void:
	var rec := _rec(host)
	var party: Array = rec["party"]
	var waiting: Array = rec["roster"]
	var going: Array = party[slot]
	var coming: Array = waiting[wait_row]
	party[slot] = coming
	waiting[wait_row] = going
	_done(host, "%s joins the team. %s waits at the Tower." % [_name(coming), _name(going)])


## A change made: say so, let go of any pick, keep the cursor on a row that exists, save, and remake the room's team.
static func _done(host: Node, said: String) -> void:
	var p: Dictionary = host.panel
	var waiting: Array = _rec(host)["roster"]
	p["said"] = said
	p["held"] = {}
	if waiting.is_empty():
		_go(p, "team", int(p["rows"].get("team", 1)))
	elif String(p["side"]) == "wait":
		p["row"] = clampi(int(p["row"]), 0, waiting.size() - 1)
		p["top"] = _top(p, waiting.size())
	host._ui_sfx("confirm")
	TeamState.autosave()
	host.refresh_team()


static func _deny(host: Node, said: String) -> void:
	if said != "":
		host.panel["said"] = said
	host.last_sfx = "denied"
	host._sfx("denied")


## The cursor to column `to` on `row`, remembering the row it leaves.
static func _go(p: Dictionary, to: String, row: int) -> void:
	p["rows"][String(p["side"])] = int(p["row"])
	p["side"] = to
	p["row"] = row
	if to == "wait":
		p["top"] = _top(p, 1 << 20)


## The first waiting row shown: kept where it was unless the cursor has left the window.
static func _top(p: Dictionary, n: int) -> int:
	var sel := int(p["row"])
	var top := clampi(int(p.get("top", 0)), 0, maxi(0, n - ROWS))
	if sel < top:
		top = sel
	elif sel >= top + ROWS:
		top = sel - ROWS + 1
	return clampi(top, 0, maxi(0, n - ROWS))


## A creature's name for the panel: its kept name, or its form's word while the name is still being read.
static func _name(who: Array) -> String:
	var n := SceneKit.name_ready(int(who[0]), int(who[1]))
	return n if n != "" else String(Lines.of(int(who[0]))["forms"][int(who[1])][0]).capitalize()


static func draw(host: Node, h: CanvasItem) -> void:
	var p: Dictionary = host.panel
	var rec := _rec(host)
	var party: Array = rec["party"]
	var waiting: Array = rec["roster"]
	var held: Dictionary = p.get("held", {})
	var box := BOX
	h.draw_style_box(StoragePanel._solid_frame(), box)
	UI.nameplate(h, box.position + Vector2(28, -22), "Roster Board", 22)
	UI.text(h, box.position + Vector2(30, 46), NOTE, 16, UI.MUTED, box.size.x - 60)
	var left := box.position.x + 24.0
	var right := left + COL_W + GAP
	UI.text(h, Vector2(left + 6, box.position.y + 84), "Waiting at the Tower", 18, UI.EDGE_LIGHT, COL_W - 12)
	UI.text(h, Vector2(right + 6, box.position.y + 84), "The team", 18, UI.EDGE_LIGHT, COL_W - 12)
	# The waiting creatures, scrolling with the cursor.
	var top := _top(p, waiting.size())
	if waiting.is_empty():
		UI.text(h, Vector2(left + 10, box.position.y + TOP + 32), "Nobody is waiting yet.", 18, UI.MUTED, COL_W - 20)
	for slot in mini(ROWS, waiting.size() - top):
		var k := top + slot
		var r := Rect2(left, box.position.y + TOP + slot * ROW_H, COL_W - GUTTER, ROW_H - 6)
		_row(h, rec, r, waiting[k], String(p["side"]) == "wait" and k == int(p["row"]), String(held.get("side", "")) == "wait" and int(held.get("row", -1)) == k, "")
	var arrow: Texture2D = UI.icon("frame/arrow")
	if arrow != null and waiting.size() > ROWS:
		var ax := roundf(left + COL_W - (GUTTER + arrow.get_width()) * 0.5)
		if top > 0:
			h.draw_set_transform(Vector2(ax, box.position.y + TOP + 18 + arrow.get_height() * 0.5), 0.0, Vector2(1, -1))
			h.draw_texture(arrow, Vector2.ZERO)
			h.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		if top + ROWS < waiting.size():
			h.draw_texture(arrow, Vector2(ax, box.position.y + TOP + (ROWS - 1) * ROW_H + 26 - arrow.get_height() * 0.5))
	# The team: the leader's row first, never chosen, then slots 2 to 4 (an open one says so).
	for k in TEAM_MAX:
		var r := Rect2(right, box.position.y + TOP + k * ROW_H, COL_W, ROW_H - 6)
		var on := String(p["side"]) == "team" and k == int(p["row"])
		var is_held := String(held.get("side", "")) == "team" and int(held.get("row", -1)) == k
		if k < party.size():
			_row(h, rec, r, party[k], on, is_held, "leads" if k == 0 else "")
		else:
			if on:
				h.draw_rect(r, UI.FOCUS)
				h.draw_rect(r, UI.EDGE_LIGHT, false, 2.0)
			UI.text(h, r.position + Vector2(62, 32), "Open", 19, UI.MUTED, COL_W - 80)
	if String(p.get("said", "")) != "":
		UI.text(h, Vector2(box.position.x + 30, box.end.y - 44), String(p["said"]), 16, UI.EDGE_LIGHT, box.size.x - 60)
	UI.text(h, Vector2(box.position.x + 30, box.end.y - 20), keys_line(not held.is_empty()), 15, UI.MUTED, box.size.x - 60, HORIZONTAL_ALIGNMENT_RIGHT)


## Key hints in the column style, key then action, the device's own keys (as storage_panel.gd's): on a keyboard
## "W/S  choose     A/D  column     E  pick     Esc  close", and "let go" for Esc while a creature is held.
static func keys_line(holding: bool) -> String:
	return "%s  choose     %s  column     %s  pick     %s  %s" % [SceneKit.pick_keys(), SceneKit.side_keys(), SceneKit.use_key(), UI.binding_text(&"cancel"), "let go" if holding else "close"]


## One creature's row: its face, its name and its level; lit under the cursor, edged in brass while it is held.
static func _row(h: CanvasItem, rec: Dictionary, r: Rect2, who: Array, on: bool, held: bool, tag: String) -> void:
	if on:
		h.draw_rect(r, UI.FOCUS)
	if on or held:
		h.draw_rect(r, UI.EDGE_LIGHT if on else UI.EDGE, false, 2.0 if on else 3.0)
	var form := String(Lines.of(int(who[0]))["forms"][int(who[1])][0])
	var face := Rect2(r.position + Vector2(4, (r.size.y - 48.0) * 0.5), Vector2(48, 48)).abs()
	face.position = face.position.round()
	h.draw_rect(face.grow(2), UI.EDGE)
	h.draw_rect(face, UI.PORTRAIT_BG)
	var tex: Texture2D = UI.portrait_3x(form)
	if tex != null:
		h.draw_texture_rect(tex, face, false)
	var lv := int(rec.get("levels", {}).get(int(who[0]), {}).get("lv", 1))
	UI.text(h, r.position + Vector2(62, 32), _name(who), 19, UI.EDGE_LIGHT if on else UI.TEXT, NAME_W)
	UI.text(h, r.position + Vector2(246, 32), ("%s   Lv %d" % [tag, lv]) if tag != "" else "Lv %d" % lv, 17, UI.TEXT, r.size.x - 256, HORIZONTAL_ALIGNMENT_RIGHT)
