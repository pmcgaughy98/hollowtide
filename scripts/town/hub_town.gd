extends Node2D
## The hub town blockout (Claude, 2026-10-09). The layout is scripts/town/town_layout.gd; this scene
## walks it. Codex fills the art: everything drawn here is a plain block standing in for a building,
## a lane, a cliff or the river (see docs/world/hub-layout-2026-10-09/README.md). The team walks
## tile by tile at the dungeon's scale, E or J uses the place in front of or under the leader, and
## the Mouth of the Hollow starts a dungeon run with the same team.

const Objective := preload("res://scripts/town/objective.gd")
const Layout := preload("res://scripts/town/town_layout.gd")
const Lines := preload("res://scripts/creatures/lines.gd")
const Arena := preload("res://scripts/arena/arena_prototype.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const Evolution := preload("res://scripts/town/evolution.gd")
const Jobs := preload("res://scripts/town/jobs.gd")
const StoragePanel := preload("res://scripts/town/storage_panel.gd")
const Storage := preload("res://scripts/town/storage.gd")   # R6, 2026-10-12
const Music := preload("res://scripts/audio/music.gd")
const RETURN_SPOT := Vector2i(24, 8)   # back from a run: on the Hall's steps (the guild, as in Explorers of Sky)
const FONT := preload("res://assets/fonts/Silkscreen-Bold.ttf")
const UI := preload("res://scripts/ui/ui_style.gd")   # the shared look (Claude, 2026-10-10)
const WALK_FPS := 12.0   # walk frames a second in town
const StoneScene := preload("res://scripts/dungeon/stone_scene.gd")
const BoardScene := preload("res://scripts/town/board_scene.gd")
const SceneKit := preload("res://scripts/town/scene_kit.gd")
const PilotEnd := preload("res://scripts/town/pilot_end.gd")   # the end card after the first growth (Claude, 2026-10-22)
const T := Layout.T
const VIEW := Vector2i(384, 216)
const SCALE := 3.0
const STEP_TIME := 0.13
const DIRS := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1)]
const BLOCK := {"grass": Color("#6f8f4e"), "terrace": Color("#8a7f5a"), "cliff": Color("#5a4a3a"), "water": Color("#3f6f96"),
	"path": Color("#b49a6a"), "building": Color("#7a5a44"), "roof": Color("#9c4a3a"), "area": Color("#c9b98a"), "spot": Color("#e0c060")}

var party: Array = [[0, 0], [1, 0]]
var roster: Array = []
var cleared := 0
var poll_input := true
var grid := PackedByteArray()
var team: Array[Dictionary] = []          # {line, stage, form, pos, node, sprite, art, facing}
var panel := {}                           # the place being shown, or {}
var busy := false
var _view: SubViewport
var _world: Node2D
var _labels: Node2D
var _hud: Node2D
var _building_exteriors: Node2D
# Town scenes (Claude, 2026-10-10): the Job Board meeting with the Shortcut Crew (scripts/town/board_scene.gd).
var talk: Array = []          # [speaker, line, "form:face"] shown one at a time; E reads on
var cutscene := false         # a scene plays: no walking, E reads the lines
var cam_focus: Variant = null # where the camera looks during a scene
var npcs: Array = []          # creatures in town that are not the team
var board_fx := {}            # the scene's marks: a "!", torn paper, dust
var shake := 0.0
var force_scenes := false     # the checks set poll_input off; this lets a scene still start in one
var scene_fx := {}            # bubbles and props for scenes built on scripts/town/scene_kit.gd


func _ready() -> void:
	grid = Layout.grid()
	_view = SubViewport.new()
	_view.size = VIEW
	_view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	add_child(_view)
	var screen := Sprite2D.new()
	screen.texture = _view.get_texture()
	screen.centered = false
	screen.scale = Vector2.ONE * SCALE
	screen.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(screen)
	_world = Node2D.new()
	_view.add_child(_world)
	var map := Sprite2D.new()
	map.centered = false
	map.texture = ImageTexture.create_from_image(paint())
	preload("res://scripts/town/world_finish.gd").apply(map)
	_world.add_child(map)
	if ResourceLoader.exists("res://scripts/town/building_exteriors.gd"):
		_building_exteriors = load("res://scripts/town/building_exteriors.gd").attach(_world, self)
	_labels = Node2D.new()
	_labels.z_index = 2000
	_labels.draw.connect(_draw_labels)
	_world.add_child(_labels)
	var layer := CanvasLayer.new()
	add_child(layer)
	_hud = Node2D.new()
	_hud.draw.connect(_draw_hud)
	layer.add_child(_hud)
	var crew_portraits := preload("res://scripts/ui/crew_portrait_canvas.gd").new()
	crew_portraits.name = "CrewPortraitFinish"
	_hud.add_child(crew_portraits)
	var news: String = TeamState.data.get("news", "")
	TeamState.data.erase("news")
	var at: Vector2i = RETURN_SPOT if news != "" else Layout.SPAWN
	# Back out of a building's room: standing on its door, below it (Claude, 2026-10-10).
	var back: String = TeamState.data.get("arrive_at", "")
	TeamState.data.erase("arrive_at")
	for p in Layout.PLACES:
		if p["id"] == back:
			at = p["door"] + Vector2i(0, 1)
	for k in party.size():
		var pos: Vector2i = at + Vector2i(0, k) if news != "" else (at + Vector2i(-k, 0) if k < 2 else at + Vector2i(1, 0))
		if not open_at(pos):
			pos = at
		team.append(_make(party[k][0], party[k][1], pos))
	_music_update()
	preload("res://scripts/ui/game_pause_menu.gd").attach(self)
	preload("res://scripts/ui/shrine_info.gd").attach(self)
	if BoardScene.pending(self):
		BoardScene.place_crew(self)   # the Shortcut Crew at the board until the team has met them
	# The return panels name the place the run went to (dungeon.gd writes last_run; Claude, 2026-10-22, GS-15).
	var went: String = String(TeamState.data.get("last_run", "the Hollow"))
	went = went.left(1).to_upper() + went.substr(1)   # it starts the sentence
	if news == "cleared":
		panel = {"name": "Back in Highbank", "what": "%s is cleared. The bag and the new partners came home." % went, "service": "news"}
		var parcel := String(_record().get("story", {}).get("parcel", ""))
		if parcel == "saved":
			panel = {"name": "Highbank", "what": "Out of the Hollow, up the far bank, and into a town above the flood. %s still has the parcel, dry. Couriers post their work on the Job Board." % _partner_name(), "service": "news"}
		elif parcel == "recovered":
			panel = {"name": "Back in Highbank", "what": "Rootbank Warren is behind you and the parcel is back. Starward will want to see it in the Wayline Hall. And with the crew out of the Warren, the river road's clear: the Storage is open.", "service": "news"}
		if stone_state() == "carried":
			panel["what"] = "Home from the Hollow with the %s from the Warden's pond. It hums near the Growth Shrine's empty socket." % StoneScene.STONE_NAME
	elif news == "fainted":
		panel = {"name": "Back in Highbank", "what": "%s got you up the bank somehow. The bag didn't make it, and the partners are resting. %s's still there when you are." % [_partner_name(), went], "service": "news"}
	# Arriving in Highbank is the save point (Claude, 2026-10-12): home from a run, out of a room, or a new
	# game's first arrival. The title's Continue reads it back. Setting out saves too (enter_hollow, start_replay).
	_record()
	TeamState.autosave()
	# The save says so, and the street comes up out of black (Claude, 2026-10-22, GS-11 and FEEL-13). A check
	# that adds the town as a plain child gets no fade unless a scene before it left one up.
	UI.toast(get_tree(), "Highbank remembers.")
	if get_tree().current_scene == self or get_tree().root.has_node(UI.FADE_NAME):
		UI.fade_in(get_tree())


## The stand-in picture: terrain bands, cliffs, the river, lanes, then each place as a block. Codex
## replaces this with art drawn to the same rects.
static func paint() -> Image:
	var blockout := paint_blockout()
	var ground := blockout
	if ResourceLoader.exists("res://scripts/town/highbank_ground_painter.gd"):
		ground = load("res://scripts/town/highbank_ground_painter.gd").paint(blockout)
	# The dungeons' treatment over Codex's ground, leaving Codex's places as they are (Claude, 2026-10-10).
	if ResourceLoader.exists("res://scripts/town/highbank_painter.gd"):
		ground = load("res://scripts/town/highbank_painter.gd").paint(ground)
	return ground


static func paint_blockout() -> Image:
	var img := Image.create(Layout.W * T, Layout.H * T, false, Image.FORMAT_RGBA8)
	for y in Layout.H:
		var kind: String = Layout.band_of(y)
		img.fill_rect(Rect2i(0, y * T, Layout.W * T, T), BLOCK[kind])
		if kind == "cliff":
			for x in Layout.W:
				img.fill_rect(Rect2i(x * T, y * T + T - 6, T, 6), BLOCK[kind].darkened(0.3))
	for r in Layout.PATHS:
		img.fill_rect(Rect2i(r.position * T, r.size * T), BLOCK["path"])
	for p in Layout.PLACES:
		var r: Rect2i = p["rect"]
		var px := Rect2i(r.position * T, r.size * T)
		match p["kind"]:
			"building":
				img.fill_rect(px, BLOCK["building"])
				img.fill_rect(Rect2i(px.position, Vector2i(px.size.x, px.size.y / 2)), BLOCK["roof"])
			"area":
				img.fill_rect(px.grow(-2), BLOCK["area"])
			"spot":
				img.fill_rect(px.grow(-4), BLOCK["spot"])
		var d: Vector2i = p["door"]
		img.fill_rect(Rect2i(d * T + Vector2i(6, 4), Vector2i(T - 12, T - 4)), Color("#2a1a12") if p["kind"] == "building" else Color(1, 0.95, 0.6))
	return img


func _make(line: int, stage: int, pos: Vector2i) -> Dictionary:
	var form: String = Lines.of(line)["forms"][stage][0]
	var node := Node2D.new()
	_world.add_child(node)
	var sprite := Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.add_child(sprite)
	preload("res://scripts/arena/creature_finish.gd").apply(sprite)
	# The town set: every creature half again its dungeon size, so the world reads bigger than a dungeon
	# floor (Preston, 2026-10-10: "they look too small"; built by build_dungeon_set.py --set=town --scale=1.5).
	var set := "town" if ResourceLoader.exists("res://assets/sprites/arena/%s/town/s.png" % form) else ("dungeon" if ResourceLoader.exists("res://assets/sprites/arena/%s/dungeon/s.png" % form) else "small")
	var still := {}
	var walk := {}   # facing -> the walk cycle (the dungeon set's 8 frames), so the team walks, not slides
	for f in Arena.FACINGS:
		still[f] = load("res://assets/sprites/arena/%s/%s/%s.png" % [form, set, f])
		var frames: Array = []
		for k in 8:
			var path := "res://assets/sprites/arena/%s/%s/walk_%s_f%d.png" % [form, set, f, k]
			if ResourceLoader.exists(path):
				frames.append(load(path))
		walk[f] = frames
	var e := {"line": line, "stage": stage, "form": form, "pos": pos, "node": node, "sprite": sprite, "still": still, "walk": walk,
		"facing": "s", "walk_t": 0.0, "walk_clock": 0.0}
	_place(e)
	return e


## Knocked flat: its lying-down sleep pose (the action frames), from the town set if built.
func _down_tex(e: Dictionary) -> Texture2D:
	for set in ["town", "dungeon"]:
		var path := "res://assets/sprites/arena/%s/%s/sleep_s_f0.png" % [e["form"], set]
		if ResourceLoader.exists(path):
			return load(path)
	return e["still"][e["facing"]]


func _px(t: Vector2i) -> Vector2:
	return Vector2(t) * T + Vector2(T * 0.5, T * 0.78)


func _place(e: Dictionary) -> void:
	e["node"].position = _px(e["pos"])
	if e.get("walk_t", 0.0) <= 0.0:
		e["sprite"].texture = e["still"][e["facing"]]   # mid-walk it keeps the walk frame
	e["sprite"].position = Vector2(0, -e["sprite"].texture.get_size().y * 0.5 + 4)
	e["node"].z_index = int(e["node"].position.y)


func open_at(t: Vector2i) -> bool:
	return t.x >= 0 and t.y >= 0 and t.x < Layout.W and t.y < Layout.H and grid[t.y * Layout.W + t.x] == Layout.OPEN


func _facing_of(d: Vector2i) -> String:
	return Arena.FACINGS[DIRS.find(d)] if DIRS.has(d) else "s"


## One step for the leader; the partners follow in a chain, each to where the one ahead stood.
func act_move(d: Vector2i) -> void:
	if busy or cutscene or not panel.is_empty():
		return
	var lead: Dictionary = team[0]
	lead["facing"] = _facing_of(d)
	var to: Vector2i = lead["pos"] + d
	if not open_at(to) or (d.x != 0 and d.y != 0 and (not open_at(lead["pos"] + Vector2i(d.x, 0)) or not open_at(lead["pos"] + Vector2i(0, d.y)))):
		_place(lead)
		return
	busy = true
	var trail: Array = team.map(func(e: Dictionary) -> Vector2i: return e["pos"])
	lead["pos"] = to
	# Every leader step, each follower takes the tile the one ahead just left, so the line keeps its shape
	# and no two share a tile (Claude, 2026-10-22, LP-18; before, a follower one diagonal off stayed put).
	for k in range(1, team.size()):
		var fd: Vector2i = (trail[k - 1] - team[k]["pos"]).clamp(Vector2i(-1, -1), Vector2i(1, 1))
		if fd != Vector2i.ZERO:
			team[k]["facing"] = _facing_of(fd)
		team[k]["pos"] = trail[k - 1]
	for e in team:
		if _px(e["pos"]) != e["node"].position:
			e["walk_t"] = STEP_TIME + 0.06   # walk while it moves (a held key keeps the cycle going)
		else:
			e["sprite"].texture = e["still"][e["facing"]]
		create_tween().tween_property(e["node"], "position", _px(e["pos"]), STEP_TIME)
	await get_tree().create_timer(STEP_TIME).timeout
	for e in team:
		_place(e)
	busy = false
	_music_update()
	if not npcs.is_empty() and not cutscene and (poll_input or force_scenes) and lead["pos"].distance_to(BoardScene.board_door()) <= BoardScene.TRIGGER:
		_npcs_home()   # the scene is blocked from where the crew were placed; the camera cut hides the snap
		BoardScene.run(self)
		return
	if Layout.place_at(lead["pos"]).get("service", "") == "dungeon":
		act_use()


## Use the place the leader stands on or faces: show what it is; the Mouth of the Hollow starts a run.
func act_use() -> Dictionary:
	if evolving_now:
		return {}
	if panel.get("service", "") == "evolve_ask":
		evolve_at_shrine(int(panel["k"]))
		return {}
	if panel.get("service", "") == "stone_ask":
		install_stone()
		return {}
	if panel.get("service", "") == "board":
		act_board_pick()
		return {}
	if panel.get("service", "") == "storage":
		act_store(1)
		return {}
	if panel.get("service", "") == "way_pick":
		start_replay(String(REPLAYS[int(panel["sel"])][0]))
		return {}
	if not panel.is_empty():
		_close_panel()
		return {}
	var lead: Dictionary = team[0]
	var p: Dictionary = Layout.place_at(lead["pos"])
	if p.is_empty():
		p = Layout.place_at(lead["pos"] + DIRS[Arena.FACINGS.find(lead["facing"])])
	if p.is_empty():
		return {}
	if p["service"] == "dungeon":
		enter_hollow()
		return p
	if p["service"] in ["home", "guild"]:
		enter_room("home" if p["service"] == "home" else "hall")
		return p
	if SHUT.has(p["service"]):
		# Not open in this build: a sign in the town's voice, no door sound, and no "id" in the panel so
		# building_exteriors.gd keeps the door shut (Claude, 2026-10-22, GS-12).
		panel = {"name": p["name"], "what": SHUT[p["service"]], "service": "shut"}
		return p
	panel = p
	if p["service"] == "growth":
		panel = _shrine_panel(p)
	if p["service"] == "jobs":
		panel = _board_panel(p)
		_sfx("board_paper")
	elif p["service"] == "storage":   # The same route gate; unlocked service is now inside its painted room.
		if Storage.open(_record()):
			panel = {}
			enter_room("storage")
		else:
			panel = _storage_panel(p)
			_sfx("door")
	elif p["service"] in DOOR_SERVICES:
		_sfx("door")
	return p


# ---------------------------------------------------------------- the Storage (R6)

func _storage_panel(p: Dictionary) -> Dictionary:
	if not Storage.open(_record()):
		return {"name": p["name"], "what": Storage.shut_text(), "service": "storage_shut"}
	return {"name": p["name"], "service": "storage", "sel": 0, "said": ""}


func storage_rows() -> Array:
	return StoragePanel.entries(self)


## E puts one of the chosen kind in (n = 1); R takes one out (n = -1).
func act_store(n: int) -> void:
	StoragePanel.store(self, n)


func act_store_move(dy: int) -> void:
	StoragePanel.select_row(self, dy)


func _draw_storage(h: CanvasItem) -> void:
	StoragePanel.draw(self, h)


## After the pilot the way down offers every dungeon again. A replay has no boss floor (dungeon.gd `replay`),
## so the crew and the Warden's scenes don't play twice; the last stairs clear it.
const REPLAYS := [["mouth", "Hollow Mouth"], ["first", "Rootbank Warren"], ["hollow", "The Hollow"]]


func start_replay(id: String) -> void:
	panel = {}
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	TeamState.data["party"] = party.duplicate(true)
	TeamState.autosave()   # what the town changed (jobs, story) is kept even if the run is abandoned
	UI.toast(get_tree(), "Highbank remembers.")   # GS-11
	TeamState.give_to(dg)
	dg.dungeon = id
	dg.replay = true
	dg.return_to_town = true
	if is_inside_tree() and get_tree().current_scene == self:
		await _leave_to(dg)
	else:
		set_meta("entered", id)   # the checks read this instead of leaving the scene
		dg.free()


## Places with a door (Claude, 2026-10-09): opening one plays the door; the job board rustles paper.
## Lookouts, the waymark and the landing are open air and stay quiet.
const DOOR_SERVICES := ["guild", "home", "shop", "storage", "scrolls", "arena", "growth"]
## Shut for this build (Claude, 2026-10-22, GS-12; Preston's call 9 defaults to shut signs, the Yard is not
## wired). Proposals, his to rewrite. building_exteriors.gd draws the boards, the chain and the rope.
const SHUT := {
	"shop": "Boards across the door. A card's tucked behind them: \"Out restocking. Back when the boats run again.\"",
	"scrolls": "The cellar lid's chained shut. A note on the chain says the Keeper is sorting scrolls and not taking callers yet.",
	"arena": "There's a rope across the gate, and a board hung off it: \"Yard's closed till the ground dries out.\"",
}
var last_sfx := ""


func _sfx(name: String) -> void:
	last_sfx = name
	var path := "res://assets/audio/sfx/dungeon/%s.wav" % name
	if not ResourceLoader.exists(path):
		return   # a missing take stays quiet rather than playing a null stream (GS-21)
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	p.bus = &"SFX"
	p.volume_db = -4.0
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)


## The town's track by where the leader is: Highbank's theme on the bluff, the Hall's march around
## Wayline Hall, the ferry landing's quiet theme on the terraces below the cliff.
func music_track() -> String:
	var p: Vector2i = team[0]["pos"]
	if p.y >= 19:
		return "ferry_landing"
	if Rect2i(17, 0, 14, 9).has_point(p):
		return "wayline_hall"
	return "highbank"


func _music_update() -> void:
	if not team.is_empty():
		Music.play(get_tree(), music_track())


## The Growth Shrine (Claude, 2026-10-10; Preston: evolving happens "outside dungeon at a specific
## location"): it names who is ready and asks before anything changes; yes plays the evolution scene
## (scripts/ui/evolution_scene.gd) and applies it to the carried record (scripts/town/evolution.gd).
var evolving_now := false
var evolved_log: Array = []   # [old name, new name], for the checks


func _record() -> Dictionary:
	if TeamState.data.is_empty():
		TeamState.start(party)
	TeamState.data["party"] = party.duplicate(true)
	return TeamState.data


## The Job Board (scripts/town/jobs.gd): finished jobs are paid first, then the board lists the jobs
## the team carries and the open requests. W/S choose, E takes or puts back, Esc closes.
func _board_panel(p: Dictionary) -> Dictionary:
	var rec := _record()
	Jobs.refresh(rec)
	var paid := Jobs.pay(rec)
	var out := {"name": p["name"], "service": "board", "sel": 0, "paid": paid, "said": ""}
	_cache_board(out, Jobs.rows(rec))
	return out


var _faces := {}


## A creature's 48 px headshot (tools/arena/build_portraits.py), loaded once. The board's rows now cut theirs from
## the dialogue face (UI.portrait_3x, UI-05); shrine_info.gd still asks for this one, at 72 px.
func _face(form: String) -> Texture2D:
	if not _faces.has(form):
		var path := "res://assets/sprites/arena/%s/portrait.png" % form
		_faces[form] = load(path) if ResourceLoader.exists(path) else null
	return _faces[form]


## The jobs as they stand now. With the board open this also rebuilds its drawn rows, so a change made
## outside the panel (a check's toggle) shows on the next frame.
func board_rows() -> Array:
	var rows := Jobs.rows(_record())
	if panel.get("service", "") == "board":
		_cache_board(panel, rows)
	return rows


## Everything the board draws, built once when it opens or changes, not every frame (Claude, 2026-10-22,
## LP-12): the rank line, the taken count, and per row its job, title, where line, reward line and tab.
func _cache_board(into: Dictionary, rows: Array) -> void:
	var rec: Dictionary = TeamState.data
	var rk: Array = Jobs.rank_of(int(rec.get("rank", 0)))
	into["rank_s"] = "Courier Rank %d    %d points" % [rk[0], int(rec.get("rank", 0))] + ("" if rk[1] < 0 else "  (%d for the next)" % rk[1])
	into["taken_s"] = "Taken %d / %d" % [rec.get("jobs", []).size(), Jobs.TAKE_MAX]
	var drawn: Array = []
	for j in rows:
		var done: bool = j.get("done", false)
		var where := "done, paid on return"
		if done and j["kind"] == "delivery":
			where = "delivered, %s" % Jobs.result_text(j)
		elif not done:
			where = {"rescue": "lost there", "lost_item": "dropped there"}.get(j["kind"], "%s, pay x2" % Jobs.cond_text(j))
		drawn.append({"job": j, "title": Jobs.title(j), "where": "B%dF   %s" % [int(j["floor"]), where],
			"reward": "%s x%d   +%d" % [Jobs.item_name(j["reward"]), int(j["count"]), int(j["pts"])],
			"face": UI.portrait_3x(Jobs.client_form(j)), "icon": UI.item_icon(String(j["reward"])),
			"cargo": UI.item_icon("parcel") if j["kind"] == "delivery" else null, "taken": Jobs.is_taken(rec, j)})
	into["rows"] = drawn


func act_board_pick() -> void:
	var rows: Array = panel["rows"].map(func(r: Dictionary) -> Dictionary: return r["job"]) if panel.has("rows") else board_rows()
	if rows.is_empty():
		return
	var k: int = clampi(int(panel.get("sel", 0)), 0, rows.size() - 1)
	panel["said"] = Jobs.toggle(_record(), rows[k])
	panel["paid"] = []
	board_rows()   # the order and the tabs changed: rebuild the drawn rows once
	_ui_sfx("confirm")


func act_board_move(dy: int) -> void:
	var n: int = panel["rows"].size() if panel.has("rows") else board_rows().size()
	if n > 0:
		panel["sel"] = posmod(int(panel.get("sel", 0)) + dy, n)
		_ui_sfx("cursor")


## Menu clicks go through the shared helper, on the "UI" bus (Claude, 2026-10-22, GS-21). storage_panel.gd
## calls this too; last_sfx stays for the checks.
func _ui_sfx(name: String) -> void:
	last_sfx = name
	UI.tick(name)


func _shrine_panel(p: Dictionary) -> Dictionary:
	# The shrine sleeps until the pond stone is set in it (the pilot's payoff, docs/design/pilot-story-2026-10-10.md).
	match stone_state():
		"":
			return {"name": p["name"], "what": "The shrine is dark. At its heart is a round socket, empty, worn smooth, as if something sat there once.", "service": "growth"}
		"carried":
			return {"name": p["name"], "what": "The %s grows warm as you near the empty socket. Set it in?" % StoneScene.STONE_NAME, "service": "stone_ask"}
	var ready := Evolution.ready_list(_record())
	if ready.is_empty():
		return {"name": p["name"], "what": "No one is ready to grow yet. The Team page (%s) shows what each creature still needs." % UI.binding_text(&"pause"), "service": "growth"}
	var k: int = ready[0]
	var name: String = load(Lines.of(party[k][0])["forms"][party[k][1]][1]).creature_name
	return {"name": p["name"], "what": "%s is ready to grow. Let it grow here?      %s  yes      %s  not now" % [name, SceneKit.use_key(), UI.binding_text(&"cancel")], "service": "evolve_ask", "k": k}


## The pilot's order (docs/design/pilot-story-2026-10-10.md): Rootbank Warren waits until the guild sends
## the team after the stolen parcel, and The Hollow waits until Starward has the parcel back. A record
## with no parcel story (an older save, a check) is not held back. Returns why not, or "".
func story_gate(dungeon_id: String) -> String:
	var story: Dictionary = _record().get("story", {})
	var parcel := String(story.get("parcel", ""))
	if dungeon_id == "first":
		if parcel == "saved":
			return "%s hugs the parcel. \"This is Wayline mail. The Wayline ought to see it before we go anywhere.\" The Job Board is right there." % _partner_name()
		if parcel == "stolen" and not story.get("guild_trial", false):
			return "%s stops you. \"We can't go chasing them by ourselves. We gotta tell the Hall first.\"" % _partner_name()
	elif dungeon_id == "hollow" and parcel == "recovered":
		return "%s holds up the parcel. \"Starward's gonna want to see this first.\" The Wayline Hall is up the street." % _partner_name()
	return ""


func _partner_name() -> String:
	if party.size() < 2:
		return "Your partner"
	return load(Lines.of(party[1][0])["forms"][party[1][1]][1]).creature_name


## The pilot's story state carried in the team record: the pond stone is "", "carried" or "installed".
func stone_state() -> String:
	return String(_record().get("story", {}).get("stone", ""))


var stone_fx := {}   # the stone on its way into the socket, and the wave of light when the shrine wakes
var shrine_view := false   # the camera looks at the shrine, above the text box, while the stone goes in


## The socket: the emblem at the heart of Codex's shrine art (assets/sprites/world/growth_shrine_2026_10_10).
func _socket_px() -> Vector2:
	var shrine: Dictionary = Layout.PLACES.filter(func(p: Dictionary) -> bool: return p["id"] == "shrine")[0]
	return Vector2(shrine["rect"].position * T) + Vector2(72, 64)


## The stone leaves the leader, settles into the socket, and the shrine wakes in a ring of light.
func install_stone() -> void:
	evolving_now = true   # holds input like the evolution scene
	panel = {}
	shrine_view = true
	var from: Vector2 = team[0]["node"].position + Vector2(0, -30)
	var to := _socket_px()
	_sfx("presence_swell")
	var tw := create_tween()
	tw.tween_method(func(t: float) -> void: stone_fx["at"] = from.lerp(to, t) + Vector2(0, -24.0 * sin(t * PI)), 0.0, 1.0, 1.4).set_trans(Tween.TRANS_SINE)
	await tw.finished
	stone_fx.erase("at")
	_record()["story"] = _record().get("story", {})
	_record()["story"]["stone"] = "installed"
	_sfx("evolve_ready")
	stone_fx["wake_at"] = Time.get_ticks_msec()
	await get_tree().create_timer(1.6).timeout
	stone_fx.erase("wake_at")
	panel = {"name": "Growth Shrine", "what": "The stone settles into the socket, and the shrine wakes: light runs through its old stones. A creature that is ready can grow here now.", "service": "growth_done"}
	evolving_now = false


## Over the town: the stone in its socket once set (a slow pulse, motes rising), the dark socket before,
## the stone in flight, and the ring of light as the shrine wakes.
func _draw_stone() -> void:
	var c := _labels
	var t := Time.get_ticks_msec() / 1000.0
	var sock := _socket_px()
	if stone_state() == "installed" and not stone_fx.has("at"):
		for k in 4:   # motes drifting up off it
			var ph := fmod(t * 0.5 + k / 4.0, 1.0)
			var p := (sock + Vector2(sin(k * 2.3 + t) * 6.0, -6.0 - ph * 26.0)).round()
			c.draw_rect(Rect2(p, Vector2(1, 1)), Color(0.75, 0.97, 0.94, 1.0 - ph))
		StoneScene.draw_stone(c, sock + Vector2(0, -4), t, 1.0)
	else:
		c.draw_set_transform(sock, 0.0, Vector2(1.0, 0.5))
		c.draw_circle(Vector2.ZERO, 6.0, Color("#2a2420"))
		c.draw_circle(Vector2(0, 1), 4.0, Color("#15110e"))
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if stone_fx.has("at"):
		StoneScene.draw_stone(c, stone_fx["at"], t, 1.0)
	if stone_fx.has("wake_at"):
		var a: float = (Time.get_ticks_msec() - int(stone_fx["wake_at"])) / 1600.0
		c.draw_set_transform(sock, 0.0, Vector2(1.0, 0.55))
		c.draw_arc(Vector2.ZERO, 8.0 + a * 70.0, 0, TAU, 48, Color(0.75, 0.97, 0.94, 1.0 - a), 2.0)
		c.draw_arc(Vector2.ZERO, 4.0 + a * 46.0, 0, TAU, 40, Color(1, 1, 1, (1.0 - a) * 0.6), 1.0)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func evolve_at_shrine(k: int) -> void:
	evolving_now = true
	panel = {}
	var rec := _record()
	var ln: int = party[k][0]
	var st: int = party[k][1]
	var scene: CanvasLayer = load("res://scripts/ui/evolution_scene.gd").new()
	add_child(scene)
	await scene.run(Lines.of(ln)["forms"][st][0], Lines.of(ln)["forms"][st + 1][0],
		load(Lines.of(ln)["forms"][st][1]).creature_name, load(Lines.of(ln)["forms"][st + 1][1]).creature_name, not poll_input)
	scene.queue_free()
	var res := Evolution.evolve(rec, k)
	party = rec["party"].duplicate(true)
	evolved_log.append([res["old_name"], res["new_name"]])
	# Its sprite on the street becomes the new form.
	var old_e: Dictionary = team[k]
	team[k] = _make(ln, st + 1, old_e["pos"])
	team[k]["facing"] = old_e["facing"]
	_place(team[k])
	old_e["node"].queue_free()
	var notes: Array = []
	if not res["learned"].is_empty():
		notes.append("It learned %s." % ", ".join(res["learned"].map(func(m: String) -> String: return Arena.MOVES[m]["name"])))
	if not res["lost"].is_empty():
		notes.append("Its new body can't use %s." % ", ".join(res["lost"].map(func(m: String) -> String: return Arena.MOVES[m]["name"])))
	if not res["waiting"].is_empty():
		notes.append("%s will be offered on the next run." % ", ".join(res["waiting"].map(func(m: String) -> String: return Arena.MOVES[m]["name"])))
	# "grew" marks a real growth (install_stone's line shares the service): closing it rolls the end card once.
	panel = {"name": "Growth Shrine", "what": "%s has grown into %s! %s" % [res["old_name"], res["new_name"], " ".join(notes)], "service": "growth_done", "grew": true}
	evolving_now = false


## Close the open panel (E on a sign, or Esc). Closing the first growth's line rolls the end card
## (scripts/town/pilot_end.gd, GS-16), once per save.
func _close_panel() -> void:
	var grew: bool = panel.get("grew", false)
	panel = {}
	if grew and PilotEnd.due(_record()):
		end_card()


## The end card after the first growth; the pilot check awaits it (with poll_input off it reads itself).
func end_card() -> void:
	await PilotEnd.run(self)


## Leave the street for another scene: the black fade first, then the change, then the fade lifts off
## the new scene (Claude, 2026-10-22, GS-11). A scene of ours that lifts it in its own _ready
## (hollow_approach.gd) is changed to without the last step.
func _leave_to(next: Node, lifts_itself := false) -> void:
	busy = true   # no steps while the screen goes dark
	var tree := get_tree()
	await UI.fade_out(tree)
	tree.change_scene_to_node(next)
	if not lifts_itself:
		UI.fade_in(tree)


## Step inside the Home or the Wayline Hall: a room at the town's scale (scripts/town/town_room.gd).
func enter_room(id: String) -> void:
	_sfx("door")
	TeamState.data["party"] = party.duplicate(true)
	if is_inside_tree() and get_tree().current_scene == self:
		var room: Node = load("res://scenes/town_room.tscn").instantiate()
		room.room_id = id
		await _leave_to(room)
	else:
		set_meta("entered_room", id)   # the checks read this instead of leaving the scene


func enter_hollow() -> void:
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	if TeamState.data.is_empty():
		TeamState.start(party)
	TeamState.data["party"] = party.duplicate(true)
	TeamState.autosave()   # setting out: the town's changes are kept even if the run is abandoned
	TeamState.give_to(dg)
	# The next dungeon whose boss is not beaten (the town has one way down for now; Codex's layout
	# can give each its own entrance later).
	var beaten: Array = TeamState.data.get("beaten", [])
	if "hollow" in beaten:   # the pilot is done: any dungeon can be run again (Preston, 2026-10-11)
		dg.free()
		panel = {"name": "The way down", "what": "Where to?", "service": "way_pick", "sel": 0}
		return
	dg.dungeon = "hollow" if "first" in beaten else "first"
	dg.return_to_town = true
	var not_yet := story_gate(dg.dungeon)
	if not_yet != "":
		dg.free()
		panel = {"name": "The way down", "what": not_yet, "service": "news"}
		set_meta("gated", not_yet)
		return
	UI.toast(get_tree(), "The run is kept.")   # setting out: the autosave above (GS-11)
	if is_inside_tree() and get_tree().current_scene == self:
		if dg.dungeon == "hollow":
			# The Hollow is reached on foot: the riverbank, the walkway node, then its entrance
			# (Preston, 2026-10-10). hollow_approach.gd starts the run itself and lifts the fade.
			dg.free()
			await _leave_to(load("res://scenes/hollow_approach.tscn").instantiate(), true)
			return
		await _leave_to(dg)
	else:
		set_meta("entered", true)   # the checks read this instead of leaving the scene
		dg.free()


func _process(_delta: float) -> void:
	if poll_input and not busy and not evolving_now:
		_poll()
	_npc_idle(_delta)
	# The walk cycle (Claude, 2026-10-10; Preston: "they just hopped without animation").
	var movers: Array = []
	movers.append_array(team)
	movers.append_array(npcs)
	for e in movers:
		if e.get("down", false):
			e["sprite"].texture = _down_tex(e)   # knocked flat in a scene
			continue
		if e["walk_t"] > 0.0:
			e["walk_t"] -= _delta
			e["walk_clock"] += _delta
			var frames: Array = e["walk"].get(e["facing"], [])
			if not frames.is_empty():
				e["sprite"].texture = frames[int(e["walk_clock"] * WALK_FPS) % frames.size()]
			if e["walk_t"] <= 0.0:
				e["sprite"].texture = e["still"][e["facing"]]
	if not team.is_empty():
		var half := Vector2(VIEW) * 0.5
		if shrine_view and not evolving_now and panel.is_empty():
			shrine_view = false   # back to following the leader once the shrine's line is closed
		var look: Vector2 = (_socket_px() + Vector2(0, 22)) if shrine_view else (team[0]["node"].position + Vector2(0, -12))
		if cam_focus != null:
			look = cam_focus
		var focus: Vector2 = look.clamp(half, Vector2(Layout.W, Layout.H) * T - half)
		shake = maxf(0.0, shake - _delta * 12.0)
		_world.position = (half - focus + Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake).round()
	_labels.queue_redraw()
	_hud.queue_redraw()


## Townsfolk idle (Claude, 2026-10-22, GS-14): every 4 to 8 s a creature that is not on the team takes one
## or two steps toward a random open tile within 2 of where it was placed, then the next time back home, so
## the crew stay mostly at their board; never onto or through a door. Within 2 tiles of the leader it stops
## and turns to look. Scenes hold everyone still.
const IDLE_RANGE := 2
const IDLE_STEP := 0.3   # seconds a tile: an amble, slower than the team's walk


func _npc_idle(delta: float) -> void:
	if cutscene or team.is_empty():
		return
	var lead: Vector2i = team[0]["pos"]
	for e in npcs:
		if not is_instance_valid(e["node"]) or not e["node"].visible or e.get("down", false):
			continue
		if not e.has("home"):
			e["home"] = e["pos"]
			e["home_facing"] = e["facing"]
			e["idle_t"] = randf_range(4.0, 8.0)
			e["idle_path"] = []
			e["idle_step"] = 0.0
		if e["idle_step"] > 0.0:   # a step under way
			e["idle_step"] -= delta
			if e["idle_step"] <= 0.0:
				if e["idle_path"].is_empty():
					if e["pos"] == e["home"]:
						e["facing"] = e["home_facing"]
					_place(e)
				else:
					_npc_step(e)
			continue
		var gap: Vector2i = (lead - e["pos"]).abs()
		if maxi(gap.x, gap.y) <= 2:
			var look: Vector2i = (lead - e["pos"]).clamp(Vector2i(-1, -1), Vector2i(1, 1))
			if look != Vector2i.ZERO and e["facing"] != _facing_of(look):
				e["facing"] = _facing_of(look)
				_place(e)
			continue
		e["idle_t"] -= delta
		if e["idle_t"] > 0.0:
			continue
		e["idle_t"] = randf_range(4.0, 8.0)
		var goal: Vector2i = e["home"]
		if e["pos"] == e["home"]:
			var picks: Array = []
			for y in range(-IDLE_RANGE, IDLE_RANGE + 1):
				for x in range(-IDLE_RANGE, IDLE_RANGE + 1):
					var t: Vector2i = e["home"] + Vector2i(x, y)
					if t != e["pos"] and open_at(t) and not _door_tile(t) and not _someone_at(t):
						picks.append(t)
			if picks.is_empty():
				continue
			goal = picks.pick_random()
		var route: Array = SceneKit.path(self, e, goal).slice(0, randi_range(1, 2))
		for k in route.size():
			if _door_tile(route[k]):
				route = route.slice(0, k)
				break
		if not route.is_empty():
			e["idle_path"] = route
			_npc_step(e)


## One idle step along the creature's short route, with its walk frames; depth follows its feet.
func _npc_step(e: Dictionary) -> void:
	var t: Vector2i = e["idle_path"].pop_front()
	e["facing"] = _facing_of((t - e["pos"]).clamp(Vector2i(-1, -1), Vector2i(1, 1)))
	e["pos"] = t
	e["walk_t"] = IDLE_STEP + 0.06
	e["idle_step"] = IDLE_STEP
	var node: Node2D = e["node"]
	if e.get("idle_tw") is Tween and e["idle_tw"].is_valid():
		e["idle_tw"].kill()
	var follow := func(p: Vector2) -> void:
		node.position = p
		node.z_index = int(p.y)
	e["idle_tw"] = create_tween()
	e["idle_tw"].tween_method(follow, node.position, _px(t), IDLE_STEP)


## Back to where they were placed, facing as placed, at once (before a scene that blocks from there).
func _npcs_home() -> void:
	for e in npcs:
		if not e.has("home") or not is_instance_valid(e["node"]):
			continue
		if e.get("idle_tw") is Tween and e["idle_tw"].is_valid():
			e["idle_tw"].kill()
		e["idle_path"] = []
		e["idle_step"] = 0.0
		e["walk_t"] = 0.0
		e["pos"] = e["home"]
		e["facing"] = e["home_facing"]
		_place(e)


func _door_tile(t: Vector2i) -> bool:
	return not Layout.place_at(t).is_empty()


func _someone_at(t: Vector2i) -> bool:
	for e in team:
		if e["pos"] == t:
			return true
	for e in npcs:
		if e["pos"] == t:
			return true
	return false


## Every press is an action in the Input Map (Claude, 2026-10-23, factory pass 2: controller support), read
## through ui_style.gd's helpers: the keyboard keeps its keys (E, J or Enter uses, Esc closes, W/S choose, R takes
## out), and a pad walks with the stick or D-pad, uses with A or X, and closes with B. The tap memory is shared
## (UI.tapped), so shrine_info.gd reads its page from it too; the town's own _tapped and _keys_was are gone.
func _poll() -> void:
	if get_node("ShrineInfo").poll():
		return
	if cutscene:   # a scene plays itself; E (or J, Enter, Space) reads its lines
		if not talk.is_empty() and UI.tapped_any(UI.INPUT_ADVANCE):
			if UI.line_done(String(talk[0][1])):
				talk.pop_front()
			else:
				UI.finish_line()   # the first press shows the rest of the line, the next moves on
		return
	if panel.get("service", "") == "board":
		if UI.tapped(&"move_up"):
			act_board_move(-1)
		if UI.tapped(&"move_down"):
			act_board_move(1)
	if panel.get("service", "") == "storage":
		if UI.tapped(&"move_up"):
			act_store_move(-1)
		if UI.tapped(&"move_down"):
			act_store_move(1)
		if UI.tapped(&"take_out"):
			act_store(-1)
	if panel.get("service", "") == "way_pick":
		var dy := int(UI.tapped(&"move_down")) - int(UI.tapped(&"move_up"))
		if dy != 0:
			panel["sel"] = posmod(int(panel["sel"]) + dy, REPLAYS.size())
			UI.tick("cursor")   # GS-21
	if UI.tapped_any([&"confirm", &"interact"]):
		act_use()
		return
	if UI.tapped(&"cancel") and not panel.is_empty():
		UI.tick("cancel")   # GS-21
		_close_panel()
	var d := UI.dir8()
	if d != Vector2i.ZERO:
		act_move(d)


func _draw_labels() -> void:
	_draw_stone()
	BoardScene.draw(self, _labels)
	preload("res://scripts/town/scene_kit.gd").draw(self, _labels)
	for p in Layout.PLACES:
		if is_instance_valid(_building_exteriors) and _building_exteriors.buildings.has(p["id"]):
			continue   # Finished entrances have their own sign / lantern; other plaques stay.
		var r: Rect2i = p["rect"]
		var at := Vector2(r.position.x * T, r.position.y * T + (r.size.y * T) * 0.5)
		# A small signboard: a dark plaque with a brass rim behind the name, so it reads on any ground.
		var name := String(p["name"]).to_upper()
		var w: float = FONT.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x + 10.0
		var mid: float = at.x + r.size.x * T * 0.5
		# Landing overlaps the finished Mouth; keep its temporary plaque at its own spot.
		if p["id"] == "landing" and is_instance_valid(_building_exteriors) and _building_exteriors.buildings.has("gate"):
			mid = p["door"].x * T + T * 0.5
			at.y = p["door"].y * T + 6
		var plaque := Rect2(Vector2(mid - w * 0.5, at.y - 9).round(), Vector2(w, 13).round())
		_labels.draw_rect(plaque, Color(UI.PANEL, 0.82))
		_labels.draw_rect(plaque, Color(UI.EDGE, 0.9), false, 1.0)
		_labels.draw_string(FONT, Vector2(plaque.position.x, at.y).round(), name, HORIZONTAL_ALIGNMENT_CENTER, plaque.size.x, 8, UI.TEXT)


func _draw_hud() -> void:
	_hud.get_node("CrewPortraitFinish").clear()
	# The shared look (scripts/ui/ui_style.gd), as in the Hollow: where you are at the top left, the
	# keys short at the bottom right, a place's sign in a panel at the bottom. Claude, 2026-10-10.
	var h := _hud
	if cutscene:   # a scene: only its lines (Explorers of Sky clears the HUD for a cutscene)
		if not talk.is_empty():
			var sl: Array = talk[0]
			var sf: String = String(sl[2]) if sl.size() > 2 else ""
			UI.dialogue(h, Rect2(196, 452, 760, 116), String(sl[0]), String(sl[1]), UI.dialogue_portrait(sf) if sf != "" else null, Time.get_ticks_msec() / 1000.0, 20, sf.get_slice(":", 1) if ":" in sf else "normal")
		return
	if panel.get("service", "") in ["growth", "stone_ask", "evolve_ask"]:
		return # The browsable ShrineInfo panel owns this presentation.
	# The place and "Next:" panels step aside while a panel is open: the board sits where "Next:" does
	# (Claude, 2026-10-22, LP-23). The walk keys go too; every panel shows its own.
	if panel.is_empty():
		UI.panel(h, Rect2(6, 6, 330, 54))
		UI.text(h, Vector2(28, 43), "Highbank", 26, UI.EDGE_LIGHT)
		var here: Dictionary = Layout.place_at(team[0]["pos"]) if not team.is_empty() else {}
		if not here.is_empty():
			UI.text(h, Vector2(28, 43), String(here["name"]), 16, UI.TEXT, 282, HORIZONTAL_ALIGNMENT_RIGHT)
		# What to do next, always on screen (Preston, 2026-10-11: "objective tab so players know where to go").
		var goal: Dictionary = Objective.current(TeamState.data.get("story", {}), TeamState.data.get("beaten", []))
		UI.panel(h, Rect2(6, 64, 600, 34), 0.9)
		UI.text(h, Vector2(26, 87), "Next:  " + String(goal["short"]), 16, UI.TEXT, 570)
		if talk.is_empty():
			_draw_key_strip(h)
	if not talk.is_empty():
		var line: Array = talk[0]
		var form: String = String(line[2]) if line.size() > 2 else ""
		var face: String = form.get_slice(":", 1) if ":" in form else "normal"
		UI.dialogue(h, Rect2(196, 452, 760, 116), String(line[0]), String(line[1]), UI.dialogue_portrait(form) if form != "" else null, Time.get_ticks_msec() / 1000.0, 20, face)
	elif panel.get("service", "") == "board":
		_draw_board(h)
	elif panel.get("service", "") == "storage":
		_draw_storage(h)
	elif panel.get("service", "") == "way_pick":
		var box := Rect2(196, 452 - 34 * REPLAYS.size(), 760, 92 + 34 * REPLAYS.size())
		UI.panel(h, box, 0.95)
		UI.text(h, box.position + Vector2(22, 34), String(panel["name"]), 23, UI.EDGE_LIGHT, 716)
		for i in REPLAYS.size():
			var at := box.position + Vector2(48, 72 + 34 * i)
			var on: bool = i == int(panel["sel"])
			if on:
				UI.text(h, at - Vector2(24, 0), ">", 20, UI.EDGE_LIGHT)
			UI.text(h, at, String(REPLAYS[i][1]), 20, UI.EDGE_LIGHT if on else UI.TEXT)
		UI.text(h, box.end - Vector2(738, 14), "%s  choose     %s  go     %s  not now" % [SceneKit.pick_keys(), SceneKit.use_key(), UI.binding_text(&"cancel")], 15, UI.MUTED, 716, HORIZONTAL_ALIGNMENT_RIGHT)
	elif not panel.is_empty():
		var box := Rect2(196, 452, 760, 128)
		UI.panel(h, box, 0.95)
		UI.text(h, box.position + Vector2(22, 34), String(panel["name"]), 23, UI.EDGE_LIGHT, 716)
		h.draw_multiline_string(UI.HEAD, box.position + Vector2(22, 64), String(panel["what"]), HORIZONTAL_ALIGNMENT_LEFT, 716, 18, 2, UI.TEXT)
		# The keys of the device in use (2026-10-23): "E  close" on a keyboard, "A  close" on a pad.
		var use := SceneKit.use_key()
		var back := UI.binding_text(&"cancel")
		var hint := ("%s  grow     %s  not now" % [use, back]) if panel.get("service", "") == "evolve_ask" else (("%s  set it in     %s  not now" % [use, back]) if panel.get("service", "") == "stone_ask" else "%s  close" % use)
		UI.text(h, box.position + Vector2(22, 116), hint, 15, UI.MUTED, 716, HORIZONTAL_ALIGNMENT_RIGHT)


## The walk keys, bottom right, on a label-role strip in the panel frame so they read on any ground
## (Claude, 2026-10-22, GS-21; before, bare text over the street). Since 2026-10-23 the keys are the device's:
## "WASD walk   E use" on a keyboard, "Stick walk   A use" on a pad.
func key_lines() -> Array:
	return ["%s walk   %s use" % [SceneKit.walk_keys(), SceneKit.use_key()], "The Hollow's mouth starts a run"]


func _draw_key_strip(h: CanvasItem) -> void:
	var lines := key_lines()
	var w := 0.0
	for s in lines:
		w = maxf(w, UI.width_in(s, "label"))
	var strip := Rect2(Vector2(1146 - w - 40, 538), Vector2(w + 40, 62))
	UI.panel(h, strip, 0.85)
	for k in lines.size():
		UI.say(h, strip.position + Vector2(20, 26 + 20 * k), lines[k], "label", Color(UI.MUTED, 0.95))


## The board, drawn the Explorers of Sky way: the rank at the top, one row per request with the
## client's headshot, where to go and what it pays; a brass TAKEN tab on the ones in the satchel.
## It draws from the rows built when it opened (_cache_board, LP-12), not from the jobs every frame.
func _draw_board(h: CanvasItem) -> void:
	if not panel.has("rows"):
		board_rows()
	var rows: Array = panel["rows"]
	var box := Rect2(166, 64, 820, 132 + 70 * maxi(1, rows.size()))
	UI.panel(h, box, 0.96)
	UI.nameplate(h, box.position + Vector2(28, -22), String(panel["name"]), 22)
	UI.text(h, box.position + Vector2(30, 46), String(panel["rank_s"]), 18, UI.EDGE_LIGHT)
	UI.text(h, box.position + Vector2(30, 46), String(panel["taken_s"]), 16, UI.MUTED, box.size.x - 60, HORIZONTAL_ALIGNMENT_RIGHT)
	var note := ""
	if not panel.get("paid", []).is_empty():
		note = "Paid: " + "   ".join(panel["paid"])
	elif String(panel.get("said", "")) != "":
		note = String(panel["said"])
	UI.text(h, box.position + Vector2(30, 74), note if note != "" else "Take a request, then go down to the Hollow. Reach the client on its floor.", 16, UI.TEXT if note != "" else UI.MUTED, box.size.x - 60)
	if rows.is_empty():
		UI.text(h, box.position + Vector2(30, 124), "No requests today.", 18, UI.MUTED)
	for k in rows.size():
		var row: Dictionary = rows[k]
		var r := Rect2(box.position + Vector2(24, 94 + k * 70), Vector2(box.size.x - 48, 62))
		var on: bool = k == int(panel.get("sel", 0))
		if on:
			h.draw_rect(r, UI.FOCUS)
			h.draw_rect(r, UI.EDGE_LIGHT, false, 2.0)
		var face_r := Rect2(r.position + Vector2(8, 7), Vector2(48, 48))
		h.draw_rect(face_r, UI.PORTRAIT_BG)
		if row["face"] != null:
			h.draw_texture_rect(row["face"], face_r, false)
		h.draw_rect(face_r, UI.EDGE, false, 1.0)
		# Delivery cargo has its own icon; the reward keeps its existing icon.
		var cargo: Texture2D = row["cargo"]
		var cargo_inset := 40 if cargo != null else 0
		if cargo != null:
			h.draw_texture(cargo, r.position + Vector2(70, 11))
		UI.text(h, r.position + Vector2(70 + cargo_inset, 27), String(row["title"]), 20, UI.EDGE_LIGHT if on else UI.TEXT, 340 - cargo_inset)
		# The where line is prose in the body face on every row, delivery or not (LP-24; at size 15 it had
		# fallen to the capital label face).
		UI.say(h, r.position + Vector2(70 + cargo_inset, 51), String(row["where"]), "body", UI.MUTED, 340 - cargo_inset)
		if row["icon"] != null:
			h.draw_texture(row["icon"], r.position + Vector2(420, 15))
		UI.text(h, r.position + Vector2(458, 37), String(row["reward"]), 16, UI.TEXT, 180)
		if row["taken"]:
			UI.nameplate(h, r.position + Vector2(r.size.x - 112, 13), "Taken", 18)
	UI.text(h, box.end + Vector2(-box.size.x + 30, -22), "%s  choose     %s  take or put back     %s  close" % [SceneKit.pick_keys(), SceneKit.use_key(), UI.binding_text(&"cancel")], 15, UI.MUTED, box.size.x - 60, HORIZONTAL_ALIGNMENT_RIGHT)
