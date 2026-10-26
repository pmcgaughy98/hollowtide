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
const GuildCrew := preload("res://scripts/town/guild_crew.gd")
const PilotEnd := preload("res://scripts/town/pilot_end.gd")   # the end card after the first growth (Claude, 2026-10-22)
const WorldFinish := preload("res://scripts/town/world_finish.gd")   # the street's ink finish (shader and cliff mask)
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
## Arrival timing (Claude, 2026-10-23, T1 / LO-03): each step of _ready in milliseconds, in order, for
## tools/debug/timing_check.gd. The painted street is kept for the session (_street below), so only the first
## arrival paints; street_cached says whether this one reused it.
var ready_ms := {}
var street_cached := false
var toasted := false          # this arrival showed "Highbank remembers." (T6; the checks read it)
var _lap_at := 0
## The painted street and its finish, kept for the whole session, keyed by the layout (a moved door or lane paints
## afresh), as dungeon.gd keeps its floor pictures; and whether Highbank has been reached yet this session.
static var _street := {}
static var _arrived := false
## The painted street on disk (Claude, 2026-10-24, pass 5 T10 / PERF-02): painting it is 4 to 5 s of the first arrival,
## so the picture is saved once under user:// and read back in a later session. Its file is named by _street_key():
## the layout, STREET_VERSION, and the modified times of the painters and the art they read (in the editor a change to
## any of them paints afresh; an exported game reads 0 for them all). Raise STREET_VERSION whenever a street painter
## changes what it draws. 1 was the street before pass 5's T9; 2 before pass 8's T10 (the Job Board's worn earth).
const STREET_VERSION := 3
const STREET_DIR := "user://street"
const STREET_SOURCES := [
	"res://scripts/town/hub_town.gd", "res://scripts/town/town_layout.gd", "res://scripts/town/highbank_ground_painter.gd",
	"res://scripts/town/highbank_painter.gd", "res://scripts/town/world_tile_art.gd", "res://scripts/town/town_detail_art.gd",
	"res://scripts/town/world_finish.gd", "res://scripts/town/job_board_painter.gd", "res://scripts/town/wayline_hall_painter.gd",
	"res://scripts/town/home_painter.gd", "res://scripts/town/item_shop_painter.gd", "res://scripts/town/storage_painter.gd",
	"res://scripts/town/growth_shrine_painter.gd", "res://scripts/town/scroll_keeper_painter.gd",
	"res://scripts/town/training_yard_painter.gd", "res://scripts/town/crossroads_painter.gd",
	"res://scripts/town/hollow_mouth_painter.gd", "res://scripts/dungeon/ruin_painter.gd", "res://scripts/dungeon/valley_painter.gd",
	"res://scripts/dungeon/dungeon_tile_art.gd", "res://scripts/art/selout.gd",
	"res://assets/sprites/world/world_tiles_2026_10_10/", "res://assets/sprites/world/town_detail_2026_10_10/",
	"res://assets/sprites/world/growth_shrine_2026_10_10/", "res://assets/sprites/world/home_2026_10_09/",
	"res://assets/sprites/world/item_shop_2026_10_09/", "res://assets/sprites/world/wayline_hall_2026_10_10/",
	"res://assets/sprites/world/wayline_hall_2026_10_09/", "res://assets/sprites/world/hollow_mouth_2026_10_10/",
	"res://assets/sprites/world/training_yard_2026_10_10/", "res://assets/sprites/world/job_board_2026_10_10/",
	"res://assets/sprites/world/job_board_selout_2026_10_10/", "res://assets/tilesets/dungeon_tiles_2026_10_10/",
]
static var _sources_stamp := ""   # STREET_SOURCES' modified times, read once a session
var street_from_disk := false     # this arrival read the street picture from disk (the checks read it)
## The team's and the townsfolk's sprites, held for the session (Claude, 2026-10-24, pass 5 T11 / PERF-04): a town that
## is freed let its textures go, so every arrival and every room loaded them from disk again (159 to 184 ms). Held here,
## later load() calls in this script, town_room.gd and board_scene.gd find them in Godot's resource cache. Path ->
## texture, or null for a picture that does not exist (so its check is made once).
static var _held := {}
## Read on a thread and kept for the session (Claude, 2026-10-24, pass 6 T1 / L6-15): the first Job Board of a session
## compiled dungeon.gd on the main thread (about 490 ms of an 820 ms open) and the Hall's door loaded the room scene
## while the street was still on screen (about 360 ms). Both are asked for when Highbank has come up (_warm_up) and
## kept here; the way down and the doors read their scenes on a thread under the fade (_leave_to). Path -> resource.
const ROOM_SCENE := "res://scenes/town_room.tscn"
const DUNGEON_SCENE := "res://scenes/dungeon.tscn"
const APPROACH_SCENE := "res://scenes/hollow_approach.tscn"
static var _kept := {}
## The board's slow pieces per request (T1): its title, where it is, the reward's name, the client's face and the
## reward's icon. They came from load() calls each time the board opened (about 140 ms an open). Built once, a request a
## frame after the arrival, and read back by _cache_board. Key -> {title, place, item, face, icon}.
static var _job_bits := {}


func _lap(step: String) -> void:
	var now := Time.get_ticks_usec()
	ready_ms[step] = (now - _lap_at) / 1000.0
	_lap_at = now


func _ready() -> void:
	_lap_at = Time.get_ticks_usec()
	var began := _lap_at
	# The session's first arrival paints the street and loads every sprite: the place card goes up on black first and
	# two frames are drawn before any of it starts (Claude, 2026-10-24, pass 4 T4 / L03a). Since pass 7 (Claude,
	# 2026-10-26, T1 / L7-03) the street is painted on a worker thread (street_on_thread) while the card's lantern
	# flickers, the team's sprites (and the crew's, when they wait at the board) are read on loader threads beside it,
	# and the slow step after it gets a frame of its own, so no frame of the arrival holds the screen still (one frame
	# had been 4.4 s). A check with poll_input off adds the town and reads it at once, so it builds as before; so does a
	# headless run (`threaded` false), which counts its waits in frames and can quit with a worker still painting.
	var carded := poll_input and not _street.has(_street_key())
	var threaded := carded and DisplayServer.get_name() != "headless"
	# With the street kept (baked during the road talk, or a return), a player's arrival under the last scene's black
	# reads the team's and the crew's sprites on loader threads too, before building, as the card does (Claude,
	# 2026-10-26, pass 8 T5 / L15): read here they were up to 0.36 s and 0.41 s of the arrival's one long frame. With
	# no black up (back from the Hollow's walkway, which lifts its own veil) the town builds at once, as before.
	var reads_first := not carded and poll_input and DisplayServer.get_name() != "headless" and get_tree().root.has_node(UI.FADE_NAME)
	if reads_first:
		set_process(false)   # nothing to move or draw until the town is built (as under the card)
		var sprites := _team_paths()
		_request(sprites)
		if BoardScene.pending(self):
			SceneKit.read_ahead(BoardScene.SPOTS.keys())
		await _collect(get_tree(), sprites)
		if not is_inside_tree():
			return
		_lap("sprites on threads")
	if carded:
		set_process(false)   # nothing to move or draw until the town is built
		_card_up()
		if threaded:
			# The view and the street's ink shader get their first draw now, with the card's first frame and before its
			# lantern is lit (T5), so the frame that first draws the street, later under the moving lantern, is not also
			# the one that makes them (0.2 to 0.3 s of it in a window).
			_make_view()
			_warm_finish()
		for k in 2:
			await get_tree().process_frame
		if not is_inside_tree():
			return
		_card_light()
		_lap("place card")
	if threaded:
		var reads := _team_paths() + STREET_ART_SCRIPTS + STREET_TRACKS.map(func(t: String) -> String: return Music.DIR % t)
		_request(reads)
		if BoardScene.pending(self):
			SceneKit.read_ahead(BoardScene.SPOTS.keys())
		await _collect(get_tree(), STREET_ART_SCRIPTS)   # street_on_thread reads their art on this thread
		await street_on_thread(get_tree(), ready_ms)
		await _collect(get_tree(), reads)
		if not is_inside_tree():
			return
		_card_settle()
		_lap("street and sprites on threads")
	grid = Layout.grid()
	_close_shut_areas()
	if _view == null:
		_make_view()
	_lap("grid and view")
	var map := Sprite2D.new()
	map.centered = false
	street_cached = _street.has(_street_key())
	var street := street_picture(ready_ms)
	street_from_disk = not street_cached and bool(street.get("from_disk", false))
	map.texture = street["tex"]
	map.material = street["finish"]
	_world.add_child(map)
	var warm := _world.get_node_or_null("WarmFinish")
	if warm != null:
		warm.queue_free()
	_lap("street picture")
	if threaded:   # the street's first draw, then the exteriors', each on a frame of its own under the card (T1)
		await get_tree().process_frame
		if not is_inside_tree():
			return
		_lap("the street's first frame")
	if ResourceLoader.exists("res://scripts/town/building_exteriors.gd"):
		_building_exteriors = load("res://scripts/town/building_exteriors.gd").attach(_world, self)
	_lap("building exteriors")
	if threaded:
		await get_tree().process_frame
		if not is_inside_tree():
			return
		_lap("the exteriors' first frame")
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
	_lap("hud and arrival spot")
	for k in party.size():
		team.append(_make(party[k][0], party[k][1], at))
	var placed := arrival_tiles(at, team.size(), _boxes())   # spaced by the sprites' own sizes (T8)
	for k in team.size():
		team[k]["pos"] = placed[k]
		_place(team[k])
	_lap("team sprites")
	_music_update(true)   # arriving: the zone's track at once (T3)
	preload("res://scripts/ui/game_pause_menu.gd").attach(self)
	preload("res://scripts/ui/shrine_info.gd").attach(self)
	_lap("menus")
	if BoardScene.pending(self):
		BoardScene.place_crew(self)   # the Shortcut Crew at the board until the team has met them
		for e in npcs:
			_hold(e)
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
	_lap("crew and news")
	_record()
	TeamState.autosave()
	# The save says so, and the street comes up out of black (Claude, 2026-10-22, GS-11 and FEEL-13). A check
	# that adds the town as a plain child gets no fade unless a scene before it left one up. The words come on a
	# homecoming from a run and on the session's first arrival (a new game, the title's Continue), not on every
	# step out of a door (Claude, 2026-10-23, T6 / L32); the save is made every time all the same.
	if news != "" or not _arrived:
		UI.toast(get_tree(), "Highbank remembers.")
		toasted = true
	_arrived = true
	var lifts := get_tree().current_scene == self or get_tree().root.has_node(UI.FADE_NAME)
	if reads_first:
		set_process(true)
	if lifts and not carded and poll_input and DisplayServer.get_name() != "headless":
		# The build's long frame and the street's first draw stay under the black (Claude, 2026-10-26, pass 8 T5 / L15):
		# coming home, the fade had started in this frame and its first step came after a 0.3 to 0.8 s frame, so the
		# street jumped in whole instead of fading up. Two frames later the drawing is cheap again; no keys meanwhile.
		# The black has to be up for that: the dawn walk ends on its own veil, which leaves with its scene, so arriving
		# from it the town showed at full light for these frames and then dropped to black to fade in (integrator,
		# 2026-10-26, pass 8: one bright frame between two dark ones in the re-shoot's luminance log).
		if not get_tree().root.has_node(UI.FADE_NAME):
			UI._fade_rect(get_tree(), 1.0)
		busy = true
		for k in 2:
			await get_tree().process_frame
			if not is_inside_tree():
				return
		busy = false
		_lap("under black")
	if lifts:
		UI.fade_in(get_tree())
	if carded:
		set_process(true)
	_card_down()
	_lap("save and fade")
	ready_ms["total"] = (Time.get_ticks_usec() - began) / 1000.0
	# A player's town: what the board and the doors will need, after the fade (T1). Not in a headless check: one that
	# quits while a thread is still reading dungeon.gd gets a parse error from the half-read script.
	if poll_input and DisplayServer.get_name() != "headless":
		_warm_up(get_tree())


## The street's view: a 384x216 SubViewport drawn at 3x by a sprite, with the world inside it.
func _make_view() -> void:
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


## A 2 px stand-in drawn with the street's ink shader while the card waits (T5), freed when the street is put in.
func _warm_finish() -> void:
	var dot := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	dot.fill(Color(0, 0, 0, 1))
	var m := ShaderMaterial.new()
	m.shader = WorldFinish.SHADER
	m.set_shader_parameter("detail_mask", ImageTexture.create_from_image(dot))
	m.set_shader_parameter("detail_ink", 0.55)
	var warm := Sprite2D.new()
	warm.name = "WarmFinish"
	warm.texture = ImageTexture.create_from_image(dot)
	warm.material = m
	_world.add_child(warm)


## After the arrival's fade (Claude, 2026-10-24, pass 6 T1 / L6-15): dungeon.gd (the board's lists of places and
## items) and the room scene are read on a thread, then the board's requests are built one a frame (_bits_of), so the
## first Job Board and the first door of a session do no loading of their own. Static, on the tree: a door taken
## before it is done leaves it to finish quietly, with no town to come back to.
static func _warm_up(tree: SceneTree) -> void:
	await tree.create_timer(UI.motion_secs(0.25)).timeout
	await _read_on_thread(tree, [Jobs.DUNGEON, ROOM_SCENE])
	# Each client's creature record (its name for the title), with the moves and pictures it pulls in: the first
	# Cinderhide read alone took about 400 ms on the main thread.
	var jobs := _board_preview()
	var clients: Array = []
	for j in jobs:
		var path := String(Lines.of(int(j["line"]))["forms"][int(j["stage"])][1])
		if not clients.has(path):
			clients.append(path)
	await _read_on_thread(tree, clients)
	for j in jobs:
		_bits_of(j)
		await tree.process_frame
	await _rooms_ahead(tree)
	await _walkway_ahead(tree)


## The Hollow's walkway made ahead (Claude, 2026-10-26, pass 8 T6 / LH8-09): setting out for The Hollow held one frame
## for about 1.0 s (990 to 1004 ms, 1381 ms in this pass's window probe) while hollow_approach.gd finished the riverbank
## painting (267 ms) and its mask (84 ms) and the entrance painting with its mask (580 ms). When the way down leads
## there next, the warm-up, as _rooms_ahead does, reads the paintings here on the main thread (where an exported game's
## imported textures hand back their pixels), finishes them on a worker thread (the finish math is the scripts' own,
## unchanged), makes each texture on the main thread a frame apart, and leaves them in the scripts' own session caches
## (waking_bank.gd _finished and _mask, hollow_entrance_finish.gd _kept_pair), under the keys those caches check, so the
## walkway's _ready finds them made. The scripts and the walkway scene are read on a thread first.
const BANK_SCRIPT := "res://scripts/ui/waking_bank.gd"
const BANK_FINISH := "res://scripts/ui/waking_bank_finish.gd"
const ENTRANCE_FINISH := "res://scripts/ui/hollow_entrance_finish.gd"
const ENTRANCE_ART := "res://assets/sprites/world/waking_bank_2026_10_10/entrance_native.png"   # hollow_approach.gd ENTRANCE


## Whether the way down leads to the walkway next: The Hollow, not yet beaten, with the story's hold off it.
static func walkway_next() -> bool:
	var rec: Dictionary = TeamState.data
	var beaten: Array = rec.get("beaten", [])
	var parcel := String(rec.get("story", {}).get("parcel", ""))
	return "first" in beaten and not "hollow" in beaten and parcel != "recovered"


static func _walkway_ahead(tree: SceneTree) -> void:
	if not walkway_next():
		return
	await _read_on_thread(tree, [BANK_SCRIPT, BANK_FINISH, ENTRANCE_FINISH, APPROACH_SCENE])
	var bank: Script = _kept.get(BANK_SCRIPT)
	var bank_finish: Script = _kept.get(BANK_FINISH)
	var entrance: Script = _kept.get(ENTRANCE_FINISH)
	if bank == null or bank_finish == null or entrance == null:
		return
	var bank_img: Image = bank.detailed_image()
	await tree.process_frame
	var ent_img: Image = bank.detailed_image(ENTRANCE_ART)
	var bank_key := hash(bank_img.get_data()) if bank_img != null else 0
	var ent_key := hash(ent_img.get_data()) if ent_img != null else 0
	var need_bank: bool = bank_img != null and (bank.get("_finished") == null or int(bank.get("_finished_key")) != bank_key)
	var need_mask: bool = bank_img != null and (bank.get("_mask") == null or int(bank.get("_mask_key")) != bank_key)
	var need_ent: bool = ent_img != null and ((entrance.get("_kept_pair") as Array).is_empty() or int(entrance.get("_kept_key")) != ent_key)
	if not (need_bank or need_mask or need_ent):
		return
	var made := {}
	var task := WorkerThreadPool.add_task(func() -> void:
		if need_bank:
			made["bank"] = bank_finish.finished_image(bank_img)
		if need_mask:
			made["mask"] = bank_finish.mask(bank_img)
		if need_ent:
			made["ent"] = [entrance.finished_image(ent_img), entrance.mask(ent_img)], false, "Hollow walkway")
	while not WorkerThreadPool.is_task_completed(task):
		await tree.process_frame
	WorkerThreadPool.wait_for_task_completion(task)
	if made.has("bank"):
		bank.set("_finished", ImageTexture.create_from_image(made["bank"]))
		bank.set("_finished_key", bank_key)
		await tree.process_frame
	if made.has("mask"):
		bank.set("_mask", ImageTexture.create_from_image(made["mask"]))
		bank.set("_mask_key", bank_key)
		await tree.process_frame
	if made.has("ent"):
		entrance.set("_kept_pair", [ImageTexture.create_from_image(made["ent"][0]), ImageTexture.create_from_image(made["ent"][1])])
		entrance.set("_kept_key", ent_key)


## The party's walkway pictures (T6), the ones hollow_approach.gd shows (its first three, each from its small set, else
## its dungeon set, facing east, north and the two ways between, still and walking): asked for on loader threads as the
## screen goes dark for the walkway, so its _ready takes them from the threads (hollow_approach.gd _tex).
func approach_paths() -> Array:
	var out: Array = []
	for m in party.slice(0, 3):
		var form: String = Lines.of(int(m[0]))["forms"][int(m[1])][0]
		var dir := "res://assets/sprites/arena/%s/small/" % form
		if not ResourceLoader.exists(dir + "s.png"):
			dir = "res://assets/sprites/arena/%s/dungeon/" % form
		for f in ["e", "n", "ne", "nw"]:
			out.append(dir + "%s.png" % f)
			for k in 8:
				out.append(dir + "walk_%s_f%d.png" % [f, k])
	return out.filter(func(p: String) -> bool: return ResourceLoader.exists(p))


## The rooms' first pictures made ahead (Claude, 2026-10-26, pass 7 T2 / LF7-04): the Hall's upper and lower floors,
## then the Home, one room at a time through TownRoom.prepare's halves, painted on a worker thread (prepared_parts)
## and kept on this one a frame later (keep_prepared), so the street never waits on them. Painting them here on the
## main thread would hold the street still for up to 0.9 s a room. An exported game reads the rooms' art only on the
## main thread (town_room.gd art_off_main), so there the rooms stay painted at their doors, under the fade, as before.
const ROOM_SCRIPT := "res://scripts/town/town_room.gd"
const ROOMS_AHEAD := ["hall", "hall_low", "home"]


static func _rooms_ahead(tree: SceneTree) -> void:
	var rooms: Script = load(ROOM_SCRIPT)
	if rooms == null or not rooms.call("art_off_main"):
		return
	for id: String in ROOMS_AHEAD:
		if rooms.call("prepared", id):
			continue
		var made := {}
		var task := WorkerThreadPool.add_task(func() -> void: made["parts"] = rooms.call("prepared_parts", id), false, "Highbank's room " + id)
		while not WorkerThreadPool.is_task_completed(task):
			await tree.process_frame
		WorkerThreadPool.wait_for_task_completion(task)
		rooms.call("keep_prepared", id, made.get("parts", []))
		await tree.process_frame


## Ask for each path on a thread, wait for them all a frame at a time, and keep them for the session.
static func _read_on_thread(tree: SceneTree, paths: Array) -> void:
	_request(paths)
	await _collect(tree, paths)


## The two halves of _read_on_thread (Claude, 2026-10-26, pass 7 T1), so an arrival can ask for its sprites before the
## street is painted and collect them after: a path kept, or asked for already, is not asked for again.
static func _request(paths: Array) -> void:
	for path: String in paths:
		if not _kept.has(path) and ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			ResourceLoader.load_threaded_request(path)


static func _collect(tree: SceneTree, paths: Array) -> void:
	for path: String in paths:
		while not _kept.has(path) and ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await tree.process_frame
		_keep(path)


## The resource a threaded read finished, kept for the session; null when it failed or was never asked for.
static func _keep(path: String) -> Resource:
	if not _kept.has(path) and ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED:
		_kept[path] = ResourceLoader.load_threaded_get(path)
	return _kept.get(path, null)


## A scene by path: the kept one, the one a thread is reading (waited for), else a plain load.
static func _scene_of(path: String) -> PackedScene:
	if not _kept.has(path) and ResourceLoader.load_threaded_get_status(path) != ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		var res := ResourceLoader.load_threaded_get(path)
		if res is PackedScene:
			_kept[path] = res
	var kept: Variant = _kept.get(path, null)
	return kept if kept is PackedScene else load(path)


## What the board will list when it opens: the jobs carried, then today's requests (posted the way Jobs.refresh posts
## them, without writing the record).
static func _board_preview() -> Array:
	var rec: Dictionary = TeamState.data
	var runs: int = int(rec.get("cleared", 0)) + int(rec.get("faints", 0))
	var board: Array = rec.get("board", []) if rec.has("board") and int(rec.get("board_for", -1)) == runs else Jobs.post(runs + 1)
	var out: Array = rec.get("jobs", []).duplicate()
	out.append_array(board)
	return out


## A request's slow pieces, built once (T1). Keyed by everything they are read from, so an older save's request with
## the same id still gets its own.
static func _bits_of(j: Dictionary) -> Dictionary:
	var key := "%s|%s|%s|%s|%s|%s|%s|%s" % [j.get("id", ""), j.get("kind", ""), j.get("line", ""), j.get("stage", ""), j.get("floor", ""), j.get("reward", ""), j.get("item", ""), Jobs.hollow_of(j)]
	if not _job_bits.has(key):
		_job_bits[key] = {"title": Jobs.title(j), "place": Jobs.place_text(j), "item": Jobs.item_name(j["reward"]),
			"face": UI.portrait_3x(Jobs.client_form(j)), "icon": UI.item_icon(String(j["reward"]))}
	return _job_bits[key]


## The place card on the session's first arrival (Claude, 2026-10-24, pass 4 T4): the floor card's look
## (dungeon.gd _draw_card), the town's name in the title face in its gold on black, over the fade of the scene
## before. It goes with the black as the street fades in.
const CARD_COL := Color(0.95, 0.85, 0.6)
const CARD_NAME := "HIGHBANK"
var _card: CanvasLayer = null


func _card_up() -> void:
	_card = CanvasLayer.new()
	_card.name = "PlaceCard"
	_card.layer = UI.FADE_LAYER + 1
	var card := Node2D.new()
	card.name = "Card"
	_card.add_child(card)
	var black := ColorRect.new()
	black.color = Color.BLACK
	black.size = Vector2(1152, 648)
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(black)
	var words := Node2D.new()
	words.draw.connect(func() -> void: UI.say(words, Vector2(0, 292), CARD_NAME, "title", CARD_COL, 1152, HORIZONTAL_ALIGNMENT_CENTER))
	card.add_child(words)
	add_child(_card)
	# A courier's lantern under the name, its flame stepping between three shapes at uneven moments (T1), so a long
	# build reads as a light burning, never a stuck screen. Its own tween keeps it going while the town is not processing.
	var lamp := Node2D.new()
	lamp.name = "Lantern"
	lamp.position = CARD_LAMP_AT
	lamp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	lamp.set_meta("step", 0)
	lamp.set_meta("pulse", 0.0)
	lamp.draw.connect(func() -> void: _draw_card_lamp(lamp, int(lamp.get_meta("step")), float(lamp.get_meta("pulse"))))
	card.add_child(lamp)


## The card's lantern lit (T5): its flame's steps and the glow's breath start once the card's first frames are drawn,
## so the long first frame is spent on a still card.
func _card_light() -> void:
	var lamp: Node2D = _card.get_node_or_null("Card/Lantern") if _card != null else null
	if lamp == null:
		return
	var tw := lamp.create_tween().set_loops()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	for st: Array in CARD_FLICKER:
		tw.tween_callback(func() -> void:
			lamp.set_meta("step", int(st[0]))
			lamp.queue_redraw())
		tw.tween_interval(float(st[1]))
	# While the card waits on the street (T5 / L14), the glow round the glass swells and settles, a slow breath of
	# CARD_PULSE seconds, so a long wait reads as a light working and not a stopped screen. Reduce motion keeps the glow
	# still; the flame's own steps go on.
	if not UI.reduce_motion():
		var breath := lamp.create_tween().set_loops()
		_card_breath = breath
		breath.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		breath.tween_method(func(v: float) -> void:
			lamp.set_meta("pulse", v)
			lamp.queue_redraw(), 0.0, 1.0, CARD_PULSE * 0.5).set_trans(Tween.TRANS_SINE)
		breath.tween_method(func(v: float) -> void:
			lamp.set_meta("pulse", v)
			lamp.queue_redraw(), 1.0, 0.0, CARD_PULSE * 0.5).set_trans(Tween.TRANS_SINE)


## The card's lantern (T1), drawn in whole pixels at the street's 3x: a ring, a brass cap and base, and the glass with
## its flame. [flame shape, seconds held], stepped like the Home's fire (town_room.gd LIGHTS).
const CARD_LAMP_AT := Vector2(560, 330)   # the lantern's top left: under the name, centred (11 px wide at 3x)
const CARD_FLICKER := [[0, 0.21], [1, 0.13], [0, 0.34], [2, 0.17], [1, 0.27], [0, 0.11], [1, 0.4], [2, 0.15], [0, 0.29], [1, 0.19]]
const CARD_LAMP := ["....kkk....", "...k...k...", "....kkk....", "..kkkkkkk..", ".kbllllbbk.", ".kkkkkkkkk.",
	"..kgggggk..", "..kgggggk..", "..kgggggk..", "..kgggggk..", "..kgggggk..", "..kgggggk..",
	".kkkkkkkkk.", ".kbllllbbk.", "..kkkkkkk.."]
const CARD_FLAMES := [
	[".....", "..o..", ".omo.", ".mcm.", ".mcm.", "..o.."],
	["...o.", "..mo.", ".mcm.", ".mcm.", ".mcm.", "..o.."],
	[".....", ".....", "..o..", ".omo.", ".mcm.", "..o.."],
]
const CARD_GLOW := [0.10, 0.16, 0.07]   # the glow round the glass for each flame: tall burns brightest
const CARD_PULSE := 1.6     # seconds a breath of the glow takes, swelling and settling (T5)
const CARD_PULSE_GAIN := 1.6   # the glow at the top of a breath, times its flame's own
static var _card_glow: ImageTexture = null


static func _draw_card_lamp(c: CanvasItem, step: int, pulse := 0.0) -> void:
	var px := 3.0
	if _card_glow == null:   # four stepped rings of warm light, made once
		var r := 16
		var img := Image.create(2 * r + 1, 2 * r + 1, false, Image.FORMAT_RGBA8)
		for y in 2 * r + 1:
			for x in 2 * r + 1:
				var d := Vector2(x - r, y - r).length() / float(r)
				if d < 1.0:
					img.set_pixel(x, y, Color(1.0, 0.71, 0.35, floorf((1.0 - d) * 4.0) / 4.0))
		_card_glow = ImageTexture.create_from_image(img)
	var glow_at := Vector2(5.5 - 16.5, 9.0 - 16.5) * px
	var glow: float = CARD_GLOW[step] * lerpf(1.0, CARD_PULSE_GAIN, pulse)
	c.draw_texture_rect(_card_glow, Rect2(glow_at, Vector2(33, 33) * px), false, Color(1, 1, 1, glow))
	var pal := {"k": UI.INK, "b": UI.EDGE, "l": UI.EDGE_LIGHT, "g": Color("#3a2a1c"),
		"o": Color("#c8781e"), "m": Color("#f2c14e"), "c": Color("#fff0b0")}
	for y in CARD_LAMP.size():
		var row: String = CARD_LAMP[y]
		for x in row.length():
			if pal.has(row[x]):
				c.draw_rect(Rect2(Vector2(x, y) * px, Vector2(px, px)), pal[row[x]])
	var flame: Array = CARD_FLAMES[step]
	for y in flame.size():
		var row: String = flame[y]
		for x in row.length():
			if pal.has(row[x]):
				c.draw_rect(Rect2(Vector2(3 + x, 6 + y) * px, Vector2(px, px)), pal[row[x]])


## The wait is over (T5): the glow stops breathing and settles, before the street's first frames, the build's longest;
## the flame keeps its stepped flicker, whose steps are held 0.11 to 0.4 s anyway, so a long frame there does not show.
var _card_breath: Tween = null


func _card_settle() -> void:
	if _card_breath != null and _card_breath.is_valid():
		_card_breath.kill()
	_card_breath = null
	var lamp: Node = _card.get_node_or_null("Card/Lantern") if _card != null else null
	if lamp != null:
		lamp.set_meta("pulse", 0.0)
		lamp.queue_redraw()


## The card fades as UI.fade_in lifts the black (the same 0.2 s), then it is freed.
func _card_down() -> void:
	if _card == null:
		return
	var layer := _card
	_card = null
	var tw := layer.create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(layer.get_node("Card"), "modulate:a", 0.0, UI.motion_secs(0.2))
	tw.tween_callback(layer.queue_free)


## The street's picture and its finish (world_finish.gd's ink shader), painted on the session's first arrival and
## kept (Claude, 2026-10-23, T1 / LO-03: painting is 4 to 5 s of a 5 to 6 s arrival). `steps` gets each painting
## step's milliseconds when it paints. Since pass 5 (T10) the picture is read from disk when a session before painted it,
## and saved when this one paints; `version` stands in for STREET_VERSION (a probe passes another to see it repaint).
static func street_picture(steps: Dictionary = {}, version := STREET_VERSION) -> Dictionary:
	var key := _street_key(version)
	if not _street.has(key):
		var job := {"steps": steps}
		_street_images(key, job)
		_street_keep(key, job, steps)
	return _street[key]


## The street painted on a worker thread (Claude, 2026-10-26, pass 7 T1 / L7-03): painting was 4 s of one frame under
## the place card. The worker makes Images only (_street_images); the art the painters read through UI.res_image is
## read first, here on the main thread, where an exported game's imported textures hand back their pixels
## (_street_art); the textures and the finish are made on the main thread once the worker is done (_street_keep). It
## waits a frame at a time, so the card keeps drawing. Static, on the tree: a town freed meanwhile leaves the picture
## kept for the next arrival.
static func street_on_thread(tree: SceneTree, steps: Dictionary = {}) -> void:
	var key := _street_key()
	if _street.has(key):
		return
	if _painting:   # a bake already under way (bake_ahead, T5): wait for it rather than paint a second street
		while _painting:
			await tree.process_frame
		if _street.has(key):
			return
	_painting = true
	await _street_on_thread(tree, key, steps)
	_painting = false


## The street is being painted on a worker (T5): a second asker waits for that picture instead of painting its own.
static var _painting := false


## The street baked ahead, while the scene before Highbank plays (Claude, 2026-10-26, pass 8 T5 / L14 and L15): the
## first arrival held the place card about 5.4 s in a window while the street was painted. A scene that leads to
## Highbank (the road talk, scripts/mouth_escape.gd) calls this as it starts; the worker paints (or reads the picture
## from disk) while the talk plays, only the textures are made on the main thread, and Highbank then arrives with its
## street kept, without the card. If the talk ends first, the arrival's card waits on this same worker, its lantern
## pulsing. Not in a headless run: a check could quit with the worker still painting.
static func bake_ahead(tree: SceneTree) -> void:
	if tree == null or DisplayServer.get_name() == "headless" or _painting or _street.has(_street_key()):
		return
	_painting = true
	_request(STREET_ART_SCRIPTS)
	await _collect(tree, STREET_ART_SCRIPTS)   # street_on_thread reads their art on the main thread first
	await _street_on_thread(tree, _street_key(), {})
	_painting = false


static func _street_on_thread(tree: SceneTree, key: String, steps: Dictionary) -> void:
	var t := Time.get_ticks_usec()
	_street_art()
	steps["street: art read"] = _since(t)
	var job := {"steps": {}}
	var task := WorkerThreadPool.add_task(func() -> void: _street_images(key, job), false, "Highbank's street")
	while not WorkerThreadPool.is_task_completed(task):
		await tree.process_frame
	WorkerThreadPool.wait_for_task_completion(task)   # done already; this lets the pool free the task
	steps.merge(job["steps"])
	if not _street.has(key) and job.get("img") is Image:   # a check that painted on the main thread meanwhile keeps its own
		_street_keep(key, job, steps)


## The art the street's painters read through UI.res_image (world_tile_art.gd and town_detail_art.gd keep it), read on
## the main thread before the worker paints: off the main thread res_image only finds a PNG on disk, which an exported
## game does not carry. The building painters read theirs with load(...).get_image(), which the renderer answers on
## the next frame, and the worker waits for it.
const STREET_ART_SCRIPTS := ["res://scripts/town/world_tile_art.gd", "res://scripts/town/town_detail_art.gd"]


static func _street_art() -> void:
	var tiles: Script = load(STREET_ART_SCRIPTS[0])
	var detail: Script = load(STREET_ART_SCRIPTS[1])
	for id in tiles.get_script_constant_map()["SIZES"]:
		tiles.call("image", id)
	for id in detail.get_script_constant_map()["SIZES"]:
		detail.call("image", id)


## The street's Images and no textures, so this may run on a worker thread: the picture read from disk, else painted
## and saved, and the finish's mask. Fills job["img"], job["mask"], job["from_disk"]; times go in job["steps"].
static func _street_images(key: String, job: Dictionary) -> void:
	var steps: Dictionary = job["steps"]
	var img := _street_from_disk(key, steps)
	job["from_disk"] = img != null
	if img == null:
		img = paint(steps)
		_street_to_disk(key, img, steps)
	var t := Time.get_ticks_usec()
	job["mask"] = _finish_mask()
	steps["street: finish mask"] = _since(t)
	job["img"] = img


## On the main thread: the picture's texture and its finish (world_finish.gd's ink shader), kept for the session.
static func _street_keep(key: String, job: Dictionary, steps: Dictionary) -> void:
	var t := Time.get_ticks_usec()
	var finish := ShaderMaterial.new()
	finish.shader = WorldFinish.SHADER
	finish.set_shader_parameter("detail_mask", ImageTexture.create_from_image(job["mask"]))
	finish.set_shader_parameter("detail_ink", 0.55)
	_street = {key: {"tex": ImageTexture.create_from_image(job["img"]), "finish": finish, "from_disk": job["from_disk"]}}   # one layout at a time
	steps["street: textures"] = _since(t)


## What the street's picture depends on: the layout's size, bands, lanes and places.
static func _layout_key() -> String:
	return "%dx%d|%d" % [Layout.W, Layout.H, str([Layout.BANDS, Layout.PATHS, Layout.PLACES]).hash()]


## The layout, the street's version and its sources' modified times: a change to any of them is a new picture.
static func _street_key(version := STREET_VERSION) -> String:
	if _sources_stamp == "":
		var times := PackedStringArray()
		for path: String in STREET_SOURCES:
			if path.ends_with("/"):
				for f in DirAccess.get_files_at(path):
					times.append("%s=%d" % [f, FileAccess.get_modified_time(path + f)])
			else:   # a script an export has remapped is not there by this name: it counts as unchanged
				times.append(str(FileAccess.get_modified_time(path)) if FileAccess.file_exists(path) else "-")
		_sources_stamp = ",".join(times).md5_text()
	return "%s|v%d|%s" % [_layout_key(), version, _sources_stamp]


static func _street_file(key: String) -> String:
	return STREET_DIR.path_join("highbank_%s.png" % key.md5_text())


## The street saved by an earlier session for this key, or null. A file that will not load or is the wrong size is
## removed, and the street is painted again.
static func _street_from_disk(key: String, steps: Dictionary) -> Image:
	var path := _street_file(key)
	if not FileAccess.file_exists(path):
		return null
	var t := Time.get_ticks_usec()
	var img := Image.load_from_file(path)
	if img == null or img.get_size() != Vector2i(Layout.W * T, Layout.H * T):
		DirAccess.remove_absolute(path)
		return null
	if img.get_format() != Image.FORMAT_RGBA8:
		img.convert(Image.FORMAT_RGBA8)
	steps["street: read from disk"] = _since(t)
	return img


## Save the painted street for later sessions: written to a temporary file, then renamed, so a quit mid-write never
## leaves half a picture under the real name; pictures saved for an older key are removed. A failed write only costs
## the next session a repaint.
static func _street_to_disk(key: String, img: Image, steps: Dictionary) -> void:
	var t := Time.get_ticks_usec()
	var path := _street_file(key)
	var tmp := path + ".tmp"
	DirAccess.make_dir_recursive_absolute(STREET_DIR)
	if img.save_png(tmp) != OK:
		DirAccess.remove_absolute(tmp)
		return
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	if DirAccess.rename_absolute(tmp, path) != OK:
		DirAccess.remove_absolute(tmp)
		return
	for f in DirAccess.get_files_at(STREET_DIR):
		if f.begins_with("highbank_") and STREET_DIR.path_join(f) != path:
			DirAccess.remove_absolute(STREET_DIR.path_join(f))
	steps["street: saved to disk"] = _since(t)


## world_finish.gd's ink mask (the cliff ledges and their stair crossings) without the lanes' borders: the lanes
## now fray into the ground (highbank_painter.gd, T2), and ink along their old rectangles would rule the line back in.
static func _finish_mask() -> Image:
	var m: Image = WorldFinish.mask().duplicate()
	for r in Layout.PATHS:
		for ty in range(r.position.y, r.end.y):
			if Layout.band_of(ty) != "cliff":
				m.fill_rect(Rect2i(r.position.x * T, ty * T, r.size.x * T, T), Color.BLACK)
	return m


static func _since(t: int) -> float:
	return (Time.get_ticks_usec() - t) / 1000.0


## Shut open-air places keep their ground closed (Claude, 2026-10-23, T5 / LO-04): while SHUT holds the Training
## Yard, its gate and its ring are solid, so the leader stops at the rope and E, facing the gate, reads the board.
## Only this street's grid: town_layout.gd's contract keeps the Yard an open area for when it opens.
func _close_shut_areas() -> void:
	for p in Layout.PLACES:
		if p["kind"] == "area" and SHUT.has(p["service"]):
			var r: Rect2i = p["rect"]
			for y in range(r.position.y, r.end.y):
				for x in range(r.position.x, r.end.x):
					grid[y * Layout.W + x] = Layout.WALL


## The stand-in picture: terrain bands, cliffs, the river, lanes, then each place as a block. Codex
## replaces this with art drawn to the same rects. `steps` gets each stage's milliseconds (T1).
static func paint(steps: Dictionary = {}) -> Image:
	var t := Time.get_ticks_usec()
	var blockout := paint_blockout()
	steps["street: blockout"] = _since(t)
	var ground := blockout
	t = Time.get_ticks_usec()
	if ResourceLoader.exists("res://scripts/town/highbank_ground_painter.gd"):
		ground = load("res://scripts/town/highbank_ground_painter.gd").paint(blockout)
	steps["street: ground painter"] = _since(t)
	t = Time.get_ticks_usec()
	# The dungeons' treatment over Codex's ground, leaving Codex's places as they are (Claude, 2026-10-10).
	if ResourceLoader.exists("res://scripts/town/highbank_painter.gd"):
		ground = load("res://scripts/town/highbank_painter.gd").paint(ground)
	steps["street: turf pass"] = _since(t)
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
	var set := _set_of(form)
	var still := {}
	var walk := {}   # facing -> the walk cycle (the dungeon set's 8 frames), so the team walks, not slides
	for f in Arena.FACINGS:
		still[f] = _tex("res://assets/sprites/arena/%s/%s/%s.png" % [form, set, f])
		var frames: Array = []
		for k in 8:
			var frame := _tex("res://assets/sprites/arena/%s/%s/walk_%s_f%d.png" % [form, set, f, k])
			if frame != null:
				frames.append(frame)
		walk[f] = frames
	var e := {"line": line, "stage": stage, "form": form, "pos": pos, "node": node, "sprite": sprite, "still": still, "walk": walk,
		"facing": "s", "walk_t": 0.0, "walk_clock": 0.0}
	_place(e)
	return e


## The town set: every creature half again its dungeon size, so the world reads bigger than a dungeon
## floor (Preston, 2026-10-10: "they look too small"; built by build_dungeon_set.py --set=town --scale=1.5).
static func _set_of(form: String) -> String:
	if ResourceLoader.exists("res://assets/sprites/arena/%s/town/s.png" % form):
		return "town"
	return "dungeon" if ResourceLoader.exists("res://assets/sprites/arena/%s/dungeon/s.png" % form) else "small"


## Every picture _make reads for the party (Claude, 2026-10-26, pass 7 T1): asked for on loader threads while the
## street paints, so the team's sprites are not read one by one on the main thread after it (0.4 s in a window).
func _team_paths() -> Array:
	var out: Array = []
	for m in party:
		var form: String = Lines.of(int(m[0]))["forms"][int(m[1])][0]
		var dir := "res://assets/sprites/arena/%s/%s/" % [form, _set_of(form)]
		for f in Arena.FACINGS:
			out.append(dir + "%s.png" % f)
			for k in 8:
				out.append(dir + "walk_%s_f%d.png" % [f, k])
	return out.filter(func(p: String) -> bool: return not _held.has(p) and ResourceLoader.exists(p))


## Knocked flat: its lying-down sleep pose (the action frames), from the town set if built.
func _down_tex(e: Dictionary) -> Texture2D:
	for set in ["town", "dungeon"]:
		var tex := _tex("res://assets/sprites/arena/%s/%s/sleep_s_f0.png" % [e["form"], set])
		if tex != null:
			return tex
	return e["still"][e["facing"]]


## A sprite by path, held for the session (T11 above), or null when there is none.
static func _tex(path: String) -> Texture2D:
	if not _held.has(path):
		_held[path] = load(path) if ResourceLoader.exists(path) else null
	return _held[path]


## Hold what a townsfolk creature was made with (board_scene.gd and scene_kit.gd load their own), so the next arrival
## and the rooms find it in the cache too.
func _hold(e: Dictionary) -> void:
	var all: Array = e.get("still", {}).values()
	for frames in e.get("walk", {}).values():
		all.append_array(frames)
	for tex in all:
		if tex is Texture2D and tex.resource_path != "" and not _held.has(tex.resource_path):
			_held[tex.resource_path] = tex


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


## Where a follower may stand (Claude, 2026-10-23, T4): open ground outside every building's and spot's footprint.
## The leader may step onto a door tile to use it; a partner never stands in the doorway or on the facade.
func follower_ok(t: Vector2i) -> bool:
	if not open_at(t):
		return false
	for p in Layout.PLACES:
		if p["kind"] in ["building", "spot"] and p["rect"].has_point(t):
			return false
	return true


## Where a partner may stand still (Claude, 2026-10-26, pass 8 T1 / L01): where a follower may stand, and not on the
## row along a building's foot beside its doorway. A creature there is drawn over the facade's stone base and reads as
## standing on the building (Skimlet on the Wayline Hall's foundation, and on Home's front). A lane (the Hall's steps)
## and the tile straight in front of a door stay open. The walk's trail may still cross the row; arrivals, the team
## gathering and the settling after a scene (settle_team) keep off it when they can.
func rest_ok(t: Vector2i) -> bool:
	return follower_ok(t) and not on_facade_row(t)


static func on_facade_row(t: Vector2i) -> bool:
	for p in Layout.PLACES:
		var r: Rect2i = p["rect"]
		if p["kind"] != "building" or t.y != r.end.y or t.x < r.position.x or t.x >= r.end.x:
			continue
		if Layout.door_tiles(p).has(t + Vector2i(0, -1)):
			return false
		for lane: Rect2i in Layout.PATHS:
			if lane.has_point(t):
				return false
		return true
	return false


## What a facade's row costs a tile in arrival_tiles' choice (T1): more than any overlap two sprites may keep, less
## than one hiding half another, so a partner takes the row only when the street round it is that crowded.
const FACADE_COST := 0.5


## After a scene (T1 / L01): a partner the scene left on a footprint or a door tile (the board scene can knock one onto
## the Hall's doorway), on a facade's row, or on a tile another member has, steps to the nearest free tile round the
## one ahead of it where a partner may stand still; the rest stay where the scene put them. Called when a scene hands
## the street back (_process), and by the checks.
func settle_team() -> void:
	if team.size() < 2 or not is_inside_tree():
		return
	var taken: Array = [team[0]["pos"]]
	var tw: Tween = null
	var held := not busy   # no steps while partners settle, unless someone else holds the keys already
	for k in range(1, team.size()):
		var e: Dictionary = team[k]
		var at: Vector2i = e["pos"]
		if rest_ok(at) and not taken.has(at):
			taken.append(at)
			continue
		var to := _rest_tile(taken[k - 1], at, taken)
		taken.append(to)
		if to == at:
			continue
		e["facing"] = _facing_of((to - at).clamp(Vector2i(-1, -1), Vector2i(1, 1)))
		e["pos"] = to
		e["walk_t"] = STEP_TIME * 2.0 + 0.06
		var node: Node2D = e["node"]
		var follow := func(p: Vector2) -> void:
			node.position = p
			node.z_index = int(p.y)
		if tw == null:
			tw = create_tween().set_parallel()
			if held:
				busy = true
		tw.tween_method(follow, node.position, _px(to), STEP_TIME * 2.0)
	if tw != null:
		await tw.finished
		for e in team:
			e["walk_t"] = 0.0
			_place(e)
		if held:
			busy = false


## The free tile one or two rings round `ahead` where a partner may stand still, nearest to `near`; else where a
## follower may stand (_follow_tile).
func _rest_tile(ahead: Vector2i, near: Vector2i, taken: Array) -> Vector2i:
	for ring in [1, 2]:
		var best := Vector2i(-1, -1)
		var best_d := INF
		for y in range(-ring, ring + 1):
			for x in range(-ring, ring + 1):
				var t: Vector2i = ahead + Vector2i(x, y)
				if maxi(absi(x), absi(y)) != ring or taken.has(t) or not rest_ok(t):
					continue
				var dist := Vector2(t - near).length()
				if dist < best_d:
					best = t
					best_d = dist
		if best_d < INF:
			return best
	return _follow_tile(near, near, ahead, taken)


## Where a follower goes: `want` (the tile the one ahead left) if a follower may stand there and nobody has it;
## else where it stands (`at`), if that is free and still one tile from the one ahead (`ahead`); else the free tile
## round the one ahead nearest to it, then one ring further out. `taken` holds the tiles given out already.
func _follow_tile(want: Vector2i, at: Vector2i, ahead: Vector2i, taken: Array) -> Vector2i:
	if follower_ok(want) and not taken.has(want):
		return want
	var gap: Vector2i = (at - ahead).abs()
	if follower_ok(at) and not taken.has(at) and maxi(gap.x, gap.y) <= 1:
		return at
	for ring in [1, 2]:
		var best := Vector2i(-1, -1)
		var best_d := INF
		for y in range(-ring, ring + 1):
			for x in range(-ring, ring + 1):
				var t: Vector2i = ahead + Vector2i(x, y)
				if maxi(absi(x), absi(y)) != ring or not follower_ok(t) or taken.has(t):
					continue
				var dist := Vector2(t - at).length()
				if dist < best_d:
					best = t
					best_d = dist
		if best_d < INF:
			return best
	# Hemmed in on both rings (Claude, 2026-10-24, pass 6 T4 / L6-18): the nearest free ground further out, so a
	# follower never ends on a tile another member has been given. Its own tile only when there is none at all.
	if not taken.has(at) and follower_ok(at):
		return at
	var seen := {ahead: true}
	var queue: Array = [ahead]
	while not queue.is_empty() and seen.size() < 400:
		var c: Vector2i = queue.pop_front()
		if c != ahead and follower_ok(c) and not taken.has(c):
			return c
		for d in DIRS:
			var nb: Vector2i = c + d
			if not seen.has(nb) and open_at(nb):
				seen[nb] = true
				queue.append(nb)
	return at


## Where the team stands on arriving (Claude, 2026-10-24, pass 5 T6 / LV-15): the leader on `at`, facing down the
## street; each partner one tile behind the one ahead, the way the team came (north: out of a door, or up from the
## Hollow to the Hall's steps), else the nearest tile round that one that is not ahead of it. So the line is a tile
## apart from the first frame and the first steps south keep it so; no partner stands on another's tile. Before,
## a partner stood beside the leader and a third on the far side, and the first step crossed it over the others.
## Since pass 6 (Claude, 2026-10-24, T4 / L6-18) the line runs straight: each partner first takes the next tile the
## way the line already runs, then straight back, then along the row (west, then east), and a back diagonal last. Out
## of Home's door the fourth had taken the back diagonal by the wall, a tile out of the row the others stood in.
const BEHIND := [Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(-1, -1), Vector2i(1, -1)]
## Since pass 7 (Claude, 2026-10-26, T8 / L7-21) the line is spaced by the sprites themselves: `boxes` holds each
## member's opaque box round its feet (_boxes), and a tile is taken only if it and no member placed already cover
## more than OVERLAP_MAX of the smaller one's box (_overlap). The tiles are tried in the order above, one tile from
## the one ahead first, then two (a gap behind a wide creature, the tile between open); when none is clear, the least
## covered. The walk's one-tile trail (_follow_tile) is unchanged: a member two back closes up on the first step.
## `run` is the way the line leaves the leader (north: out of a door, or up the Hall's steps from the Hollow), `ways`
## the ways it may turn after it, one tile and then two, and `more` the ways tried only after those (the team gathering
## at the Mouth, _gather). OVERLAP_MAX is under the plan's quarter, so a line that only just keeps clear still reads
## as two creatures.
const OVERLAP_MAX := 0.15


## Since pass 8 (Claude, 2026-10-26, T1 / L01) a tile on a facade's row (on_facade_row) costs FACADE_COST on top of its
## overlap, and when every way behind is a footprint or a facade's row, the ways ahead (AHEAD_WAYS) are tried last:
## out of Home's door the line had stood along Home's front, now it steps down onto the street. A tile taken from
## those last ways does not turn the line, so the next partner looks behind again.
const AHEAD_WAYS := [Vector2i(-1, 1), Vector2i(1, 1), Vector2i(0, 1)]


func arrival_tiles(at: Vector2i, n: int, boxes: Array = [], run := Vector2i(0, -1), ways: Array = BEHIND, more: Array = []) -> Array:
	var out: Array = [at]
	for k in range(1, n):
		var ahead: Vector2i = out[k - 1]
		var pick := Vector2i(-1, -1)
		var least := INF
		var tries: Array = []
		for tier in [[run] + ways, more, AHEAD_WAYS]:
			for gap in [1, 2]:
				for d: Vector2i in tier:
					tries.append([d, gap, tier == AHEAD_WAYS])
		for tr in tries:
			var d: Vector2i = tr[0]
			var t: Vector2i = ahead + d * int(tr[1])
			if not follower_ok(t) or out.has(t) or (int(tr[1]) == 2 and not open_at(ahead + d)):
				continue
			var worst := _worst_overlap(t, k, out, boxes) + (0.0 if rest_ok(t) else FACADE_COST)
			if worst <= OVERLAP_MAX:
				pick = t
				if not tr[2]:
					run = d
				break
			if worst < least:
				least = worst
				pick = t
		if pick == Vector2i(-1, -1):   # boxed in: the nearest free tile round the one ahead, as a walk would give
			pick = _follow_tile(ahead + Vector2i(0, -1), ahead + Vector2i(0, -1), ahead, out)
		out.append(pick)
	return out


## The most that member `k` standing on `t` and any member already placed (`out`) cover of each other, 0 when the
## boxes are not known.
static func _worst_overlap(t: Vector2i, k: int, out: Array, boxes: Array) -> float:
	var worst := 0.0
	if k < boxes.size():
		for j in mini(out.size(), boxes.size()):
			worst = maxf(worst, _overlap(boxes[k], t, boxes[j], out[j]))
	return worst


## How much two sprites' boxes cover of each other, as a share of the smaller box: 0 apart, 1 one hidden behind the
## other. Stricter than a share of the wider one (the plan's measure), which let a small partner vanish behind a big one.
static func _overlap(ea: Rect2, ta: Vector2i, eb: Rect2, tb: Vector2i) -> float:
	var ra := Rect2(ea.position + Vector2(ta) * T, ea.size)
	var rb := Rect2(eb.position + Vector2(tb) * T, eb.size)
	return ra.intersection(rb).get_area() / maxf(1.0, minf(ra.get_area(), rb.get_area()))


## Each member's opaque box round its feet as it stands now, facing as it faces.
func _boxes() -> Array:
	return team.map(func(e: Dictionary) -> Rect2: return _extent_of(e["still"][e["facing"]]))


## A still's opaque box round the feet it stands on, read once a picture: _place centres the sprite 4 px above its
## texture's foot (T8).
static var _extents := {}


static func _extent_of(tex: Texture2D) -> Rect2:
	if tex == null:
		return Rect2(-12, -24, 24, 24)
	var key := tex.resource_path if tex.resource_path != "" else str(tex.get_instance_id())
	if not _extents.has(key):
		var size := tex.get_size()
		var used := Rect2(Vector2.ZERO, size)
		var img := tex.get_image()
		if img != null and not img.is_empty():
			used = Rect2(img.get_used_rect())
		_extents[key] = Rect2(used.position + Vector2(-size.x * 0.5, -size.y + 4.0), used.size)
	return _extents[key]


## The partners gather round the leader when the way down asks something (Claude, 2026-10-26, pass 7 T8 / LF7-09):
## the walk's trail had left a wide partner standing on the leader's head at the Mouth. Each steps to the tile
## arrival_tiles gives and turns the way the leader faces. The Mouth is at the foot of the map, where the camera stops:
## under the list, which hangs from the top of the screen, the team gathers along the bank beside and below the leader
## (DOWN_WAYS) and only then on the rows above; over a line of story, which sits at the foot of the screen, the other
## way round (UP_WAYS first).
const DOWN_WAYS := [Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 0)]
const UP_WAYS := [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, -1), Vector2i(1, 0)]
## The line at a building's door (T1): back out from the doorway first, then to the sides of it.
const DOOR_WAYS := [Vector2i(0, 1), Vector2i(-1, 1), Vector2i(1, 1), Vector2i(-1, 0), Vector2i(1, 0)]


func _gather(ways: Array = DOWN_WAYS, more: Array = UP_WAYS) -> void:
	if team.size() < 2 or not is_inside_tree():
		return
	var lead: Vector2i = team[0]["pos"]
	var look: String = team[0]["facing"]
	var boxes: Array = team.map(func(e: Dictionary) -> Rect2: return _extent_of(e["still"][look]))   # as they will stand
	var tiles := arrival_tiles(lead, team.size(), boxes, ways[0], ways, more)
	var tw: Tween = null
	for k in range(1, team.size()):
		var e: Dictionary = team[k]
		var to: Vector2i = tiles[k]
		if to == e["pos"]:
			continue
		e["facing"] = _facing_of((to - e["pos"]).clamp(Vector2i(-1, -1), Vector2i(1, 1)))
		e["pos"] = to
		e["walk_t"] = STEP_TIME * 2.0 + 0.06
		var node: Node2D = e["node"]
		var follow := func(p: Vector2) -> void:
			node.position = p
			node.z_index = int(p.y)
		if tw == null:
			tw = create_tween().set_parallel()   # bound to the town: a town freed meanwhile ends it, and this with it
		tw.tween_method(follow, node.position, _px(to), STEP_TIME * 2.0)
	if tw == null:
		return
	await tw.finished
	for e in team:
		e["facing"] = look
		e["walk_t"] = 0.0
		_place(e)


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
	# Not when that tile is in a building's footprint (a door tile the leader stood on) or already given out this
	# step (the leader stepping back into a partner): then _follow_tile keeps it one tile back on free ground
	# (Claude, 2026-10-23, T4 / L21: a partner stood on the Hall's facade).
	var taken: Array = [to]
	for k in range(1, team.size()):
		var goal: Vector2i = _follow_tile(trail[k - 1], team[k]["pos"], team[k - 1]["pos"], taken)
		taken.append(goal)
		var fd: Vector2i = (goal - team[k]["pos"]).clamp(Vector2i(-1, -1), Vector2i(1, 1))
		if fd != Vector2i.ZERO:
			team[k]["facing"] = _facing_of(fd)
		team[k]["pos"] = goal
	for e in team:
		if _px(e["pos"]) != e["node"].position:
			e["walk_t"] = STEP_TIME + 0.06   # walk while it moves (a held key keeps the cycle going)
		else:
			e["sprite"].texture = e["still"][e["facing"]]
		create_tween().tween_property(e["node"], "position", _px(e["pos"]), STEP_TIME)
	await get_tree().create_timer(STEP_TIME).timeout
	for e in team:
		_place(e)
	if Layout.place_at(to).get("kind", "") == "building":
		# At a door the line stands clear (T1 / L01): straight back from the doorway the partners stood one over another
		# (one hidden behind the next on the Hall's steps); they step aside where their sprites keep apart.
		await _gather(DOOR_WAYS, [])
		if not is_inside_tree():
			return
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
		_ui_sfx("close")   # E on a sign or a news line closes it, as Esc does (T6)
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
	elif p["service"] == "growth":
		_sfx("presence_swell")   # the shrine hums, it has no door (Claude, 2026-10-24, pass 5 T7 / LV-29)
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
const WAY_ROW := 52   # px from one Hollow's row to the next: a client's face fits each
const WAY_TAB_GAIN := 26   # px the way down's rows rise once its heading is on the name tab (pass 7 T5)


## What each row of the way down shows beside its name (Claude, 2026-10-24, pass 5 T8 / LV-33), with the board's own
## marks and no new words: how deep the Hollow goes in the board's floor notation ("B4F"), set on the brass tab the
## board marks taken requests with once that Hollow is cleared, and the faces of the clients waiting in it for the
## requests the team has taken, as the board draws them.
func way_marks() -> Array:
	var rec := _record()
	var beaten: Array = rec.get("beaten", [])
	var dungeons: Dictionary = load(Jobs.DUNGEON).get_script_constant_map()["DUNGEONS"]
	var out: Array = []
	for r in REPLAYS:
		var id: String = r[0]
		var faces: Array = []
		for j in Jobs.waiting_in(rec, id).slice(0, Jobs.TAKE_MAX):
			faces.append(_bits_of(j)["face"])   # built after the arrival, with the board's (pass 6 T1)
		out.append({"floors": "B%dF" % int(dungeons[id]["floors"]) if dungeons.has(id) else "", "cleared": id in beaten, "faces": faces})
	return out


func start_replay(id: String) -> void:
	panel = {}
	TeamState.data["party"] = party.duplicate(true)
	TeamState.autosave()   # what the town changed (jobs, story) is kept even if the run is abandoned
	UI.toast(get_tree(), "The run is kept.")   # setting out, as enter_hollow says it (GS-11; Claude, 2026-10-23, T6)
	if is_inside_tree() and get_tree().current_scene == self:
		# The run is read on a thread under the fade and made after it (Claude, 2026-10-24, pass 6 T2 / L6-15).
		await _leave_to(DUNGEON_SCENE, false, func(dg: Node) -> void:
			TeamState.give_to(dg)
			dg.dungeon = id
			dg.replay = true
			dg.return_to_town = true)
	else:
		set_meta("entered", id)   # the checks read this instead of leaving the scene


## Panels that ask something (grow here? set the stone in? which Hollow?): Esc backs out of the choice with the cancel
## sound; every other panel closes with the menus' close (T6).
const CHOICE_PANELS := ["evolve_ask", "stone_ask", "way_pick"]
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


## Sounds that answer a menu choice (Claude, 2026-10-26, pass 7 T6 / L7-23): "denied" when the Storage is at its cap
## or the satchel is full at the board. They play on the "UI" bus at the ticks' level, with the menus' other sounds,
## not on the effects bus; town_room.gd routes them the same way.
const MENU_SOUNDS := ["denied"]


func _sfx(name: String, keep := false) -> void:
	last_sfx = name
	var path := "res://assets/audio/sfx/dungeon/%s.wav" % name
	if not ResourceLoader.exists(path):
		return   # a missing take stays quiet rather than playing a null stream (GS-21)
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	p.bus = &"UI" if name in MENU_SOUNDS else &"SFX"
	p.volume_db = UI.TICK_DB if name in MENU_SOUNDS else -4.0
	p.finished.connect(p.queue_free)
	if keep and is_inside_tree():   # on the root, so a door plays on past the change of scene (Claude, 2026-10-24, rooms RM5)
		p.autoplay = true
		get_tree().root.add_child.call_deferred(p)
		return
	add_child(p)
	p.play()


## The town's track by where the leader is: Highbank's theme on the bluff, the Hall's march around
## Wayline Hall, the ferry landing's quiet theme on the terraces below the cliff.
func music_track() -> String:
	var p: Vector2i = team[0]["pos"]
	if p.y >= 19:
		return "ferry_landing"
	if Rect2i(17, 0, 14, 9).has_point(p):
		return "wayline_hall"
	return "highbank"


## The street's track waits for the leader to stay (Claude, 2026-10-24, pass 6 T3 / L6-17): walking along the Hall's
## edge started the Hall's march and Highbank's theme by turns, four starts in four seconds. Now a new zone's track
## starts only once the leader has been in that zone MUSIC_SETTLE seconds; until then the track playing goes on, and
## stepping back into its own zone forgets the change. On arriving, and when something else had the music (a scene's
## theme, the end card's), the street's track starts at once. The zones and their tracks are as they were.
const MUSIC_SETTLE := 2.0
const STREET_TRACKS := ["highbank", "wayline_hall", "ferry_landing"]
var music_next := ""      # the zone's track waiting to start, or ""
var _music_wait := 0.0    # seconds the leader still has to stay for it


func _music_update(at_once := false) -> void:
	if team.is_empty():
		return
	var want := music_track()
	var now := _music_now()
	if want == now:
		music_next = ""
		return
	if at_once or not now in STREET_TRACKS:
		music_next = ""
		Music.play(get_tree(), want)
		return
	if want != music_next:
		music_next = want
		_music_wait = MUSIC_SETTLE


## The track the music player was last asked for ("" before it exists).
func _music_now() -> String:
	return String(Music._inst.want) if Music._inst != null and is_instance_valid(Music._inst) else ""


## Every frame: the waiting track starts once the leader has stayed long enough. A scene, the end card or a menu that
## takes the music meanwhile drops it; they hand the street back through _music_update.
func _music_settle(delta: float) -> void:
	if music_next == "":
		return
	if cutscene or not _music_now() in STREET_TRACKS:
		music_next = ""
		return
	_music_wait -= delta
	if _music_wait <= 0.0:
		var track := music_next
		music_next = ""
		Music.play(get_tree(), track)


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
		# The Hollow with the floor, "Rootbank Warren B3F" (Claude, 2026-10-24, pass 5 T8 / LV-33; it was the floor alone).
		# The title, place, item name, face and icon come built (_bits_of, pass 6 T1).
		var bits := _bits_of(j)
		drawn.append({"job": j, "title": bits["title"], "where": "%s   %s" % [bits["place"], where],
			"reward": "%s x%d   +%d" % [bits["item"], int(j["count"]), int(j["pts"])],
			"face": bits["face"], "icon": bits["icon"],
			"cargo": UI.item_icon("parcel") if j["kind"] == "delivery" else null, "taken": Jobs.is_taken(rec, j)})
	into["rows"] = drawn


## E takes the chosen request or puts it back. The list re-sorts (taken requests first), and the cursor goes with the
## request to its new row, so the highlighted row is the one just taken and a second E puts that same one back
## (Claude, 2026-10-26, pass 7 T4 / L7-10; it stayed on the old row number, on another request). A take the satchel
## refuses (it is full) moves nothing and answers with the denied sound on the menus' bus (T6).
func act_board_pick() -> void:
	var rows: Array = panel["rows"].map(func(r: Dictionary) -> Dictionary: return r["job"]) if panel.has("rows") else board_rows()
	if rows.is_empty():
		return
	var k: int = clampi(int(panel.get("sel", 0)), 0, rows.size() - 1)
	var job: Dictionary = rows[k]
	var was := Jobs.is_taken(_record(), job)
	panel["said"] = Jobs.toggle(_record(), job)
	panel["paid"] = []
	board_rows()   # the order and the tabs changed: rebuild the drawn rows once
	var now: Array = panel.get("rows", [])
	for i in now.size():
		if String(now[i]["job"].get("id", "")) == String(job.get("id", "")):
			panel["sel"] = i
			break
	panel["sel"] = clampi(int(panel["sel"]), 0, maxi(0, now.size() - 1))
	if Jobs.is_taken(_record(), job) == was:
		last_sfx = "denied"
		_sfx("denied")
	else:
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
	# The question alone; the keys are in the hint row under it, for the device in use (Claude, 2026-10-23, T7).
	return {"name": p["name"], "what": "%s is ready to grow. Let it grow here?" % name, "service": "evolve_ask", "k": k}


## The pilot's order (docs/design/pilot-story-2026-10-10.md): Rootbank Warren waits until the guild sends
## the team after the stolen parcel, and The Hollow waits until Starward has the parcel back. A record
## with no parcel story (an older save, a check) is not held back. Returns why not, or "".
func story_gate(dungeon_id: String) -> String:
	_record()   # a record to read, as before
	match _gate_kind(dungeon_id):
		"board":
			return "%s hugs the parcel. \"This is Wayline mail. The Wayline ought to see it before we go anywhere.\" The Job Board is right there." % _partner_name()
		"hall":
			return "%s stops you. \"We can't go chasing them by ourselves. We gotta tell the Hall first.\"" % _partner_name()
		"starward":
			return "%s holds up the parcel. \"Starward's gonna want to see this first.\" The Wayline Hall is up the street." % _partner_name()
	return ""


## Which hold the story puts on a dungeon, read from the record without touching it (the key strip asks every frame;
## Claude, 2026-10-24, pass 6 T5): "board" (show the parcel at the Job Board), "hall" (tell the Hall), "starward"
## (bring the parcel back to Starward), or "" when the way is open.
func _gate_kind(dungeon_id: String) -> String:
	var story: Dictionary = TeamState.data.get("story", {})
	var parcel := String(story.get("parcel", ""))
	if dungeon_id == "first":
		if parcel == "saved":
			return "board"
		if parcel == "stolen" and not story.get("guild_trial", false):
			return "hall"
	elif dungeon_id == "hollow" and parcel == "recovered":
		return "starward"
	return ""


## The dungeon the way down leads to next ("" once the pilot is done and every Hollow is offered), as enter_hollow picks it.
func _next_way() -> String:
	var beaten: Array = TeamState.data.get("beaten", [])
	if "hollow" in beaten:
		return ""
	return "hollow" if "first" in beaten else "first"


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


## Where the camera looks while the stone goes in (Claude, 2026-10-24, pass 5 T5 / LV-17): halfway between the leader
## and the socket, then up as far as the highest head needs, so long as the socket and the light round it stay in
## view. It looked at the socket alone, and the team on the shrine's door was cut off at the top of the screen.
func shrine_look() -> Vector2:
	var sock := _socket_px()
	var look: Vector2 = (team[0]["node"].position + Vector2(0, -12)).lerp(sock + Vector2(0, 22), 0.5)
	var half := Vector2(VIEW) * 0.5
	var top := INF
	for e in team:
		var s: Sprite2D = e["sprite"]
		if s.texture != null:
			top = minf(top, e["node"].position.y + s.position.y - s.texture.get_size().y * 0.5 - 2.0)
	var over := (look.y - half.y) - top   # how far the highest head is above the view
	if over > 0.0:
		var room := (look.y + half.y) - (sock.y + 14.0)   # how far the view may rise with the socket still in it
		look.y -= minf(over, maxf(0.0, room))
	return look


## The stone leaves the leader, settles into the socket, and the shrine wakes in a ring of light.
func install_stone() -> void:
	evolving_now = true   # holds input like the evolution scene
	panel = {}
	shrine_view = true
	cutscene = true   # the HUD steps aside while the stone goes in, so the place panels never cover the team (pass 5 T5)
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
	cutscene = false
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


## Into the growth scene and out of it through black (Claude, 2026-10-24, pass 5 T1 / LV-06; it was a hard cut both
## ways). The frame the player last saw (the shrine's page) is held and fades to black, the scene comes up out of it,
## and at the end the scene goes to black; under the black the creature changes on the street. Then the street comes
## back with the growth's line; after the first growth, closing that line rolls the end card (pass 6 T6).
const EVO_FADE := 0.3


func evolve_at_shrine(k: int) -> void:
	evolving_now = true
	var tree := get_tree()
	_hold_frame()   # before the page closes, so its closing is not seen
	panel = {}
	var rec := _record()
	var ln: int = party[k][0]
	var st: int = party[k][1]
	await UI.fade_out(tree, EVO_FADE)
	_drop_frame()
	var scene: CanvasLayer = load("res://scripts/ui/evolution_scene.gd").new()
	add_child(scene)
	UI.fade_in(tree, EVO_FADE)
	await scene.run(Lines.of(ln)["forms"][st][0], Lines.of(ln)["forms"][st + 1][0],
		load(Lines.of(ln)["forms"][st][1]).creature_name, load(Lines.of(ln)["forms"][st + 1][1]).creature_name, not poll_input)
	await UI.fade_out(tree, EVO_FADE)
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
	# "grew" marks a real growth (install_stone's line shares the service). The street comes back with this line first;
	# after the first growth the end card rolls when it is closed (_close_panel). Pass 5 rolled the card at once on the
	# growth scene's black, so the line was not read until the card was done (Claude, 2026-10-24, pass 6 T6 / L6-23).
	panel = {"name": "Growth Shrine", "what": "%s has grown into %s! %s" % [res["old_name"], res["new_name"], " ".join(notes)], "service": "growth_done", "grew": true}
	UI.fade_in(tree, EVO_FADE)
	evolving_now = false


## The last frame drawn, held over everything under the fade (Claude, 2026-10-24, pass 5 T1): a CanvasLayer just
## below UI.FADE_LAYER with a picture of the screen, so whatever closes under it this frame is not seen. Not in a
## headless run, which draws no frames.
var _frame_hold: CanvasLayer = null


func _hold_frame() -> void:
	if DisplayServer.get_name() == "headless" or not is_inside_tree():
		return
	var img := get_viewport().get_texture().get_image()
	if img == null or img.is_empty():
		return
	_frame_hold = CanvasLayer.new()
	_frame_hold.layer = UI.FADE_LAYER - 1
	var pic := TextureRect.new()
	pic.texture = ImageTexture.create_from_image(img)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_SCALE
	pic.size = get_viewport().get_visible_rect().size
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame_hold.add_child(pic)
	add_child(_frame_hold)


func _drop_frame() -> void:
	if is_instance_valid(_frame_hold):
		_frame_hold.queue_free()
	_frame_hold = null


## Close the open panel (E on a sign, or Esc). Closing a growth's line rolls the end card (scripts/town/pilot_end.gd,
## GS-16) if it is still owed: the street fades to the card's black from the street, after the line has been read
## (pass 6 T6; pass 5 had rolled it before the line).
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
## Since pass 6 (Claude, 2026-10-24, T1 and T2 / L6-15) `next` is the scene's path: it is read on a thread from the
## moment the fade starts (the room scene is kept from the arrival), made once the screen is black, and `setup` fills
## it in before it joins the tree. Before, the room scene (about 360 ms) and the run (about 580 ms) were loaded on the
## frame the door or the gate was used, with the street still on screen. The fade lifts two frames after the change,
## so the new scene's first long frame (a room's build, the way town_room.gd's go_room lifts its own) is spent on black.
func _leave_to(next: String, lifts_itself := false, setup := Callable()) -> void:
	busy = true   # no steps while the screen goes dark
	var tree := get_tree()
	if not _kept.has(next):
		ResourceLoader.load_threaded_request(next)
	# A toast still up from the arrival ("Highbank remembers.") goes before the black, so it does not ride into the
	# Home or the Hall (Claude, 2026-10-24, pass 4 T3 / L32). Every way out comes through here, enter_room too.
	var toast := tree.root.get_node_or_null(UI.TOAST_NAME)
	if toast != null:
		toast.queue_free()
	await UI.fade_out(tree)
	# "The run is kept.", raised as the team sets out, was not in the tree at the line above (UI.toast adds it
	# deferred) and rode into the run over the Hollow's minimap (pass 5 T4 / LV-08). It is in the tree now, under the
	# black: it goes before the scene does. (Holding the street until it had been read broke town_loop_check, which
	# expects the run within 8 frames of the step onto the Mouth; see the pass 5 notes.)
	toast = tree.root.get_node_or_null(UI.TOAST_NAME)
	if toast != null:
		toast.free()
	var scene := _scene_of(next).instantiate()
	if setup.is_valid():
		setup.call(scene)
	tree.change_scene_to_node(scene)
	if not lifts_itself:
		_lift(tree)


## The fade off the next scene, two frames after the change, as town_room.gd lifts its own (R4): the scene builds in
## the frame the change lands, and a fade started before that frame would spend its whole time in it.
static func _lift(tree: SceneTree) -> void:
	await tree.process_frame
	await tree.process_frame
	# Then until the next scene has built, and one frame more (Claude, 2026-10-26, pass 8 R8): the frame after a long
	# build reports the build's time as its delta, and a fade started before it spent its whole time in that one step.
	var guard := 0
	while guard < 30 and (tree.current_scene == null or not tree.current_scene.is_node_ready()):
		await tree.process_frame
		guard += 1
	await tree.process_frame
	UI.fade_in(tree)


## Step inside the Home or the Wayline Hall: a room at the town's scale (scripts/town/town_room.gd).
func enter_room(id: String) -> void:
	_sfx("door", true)   # the 0.66 s door outlasts the fade that frees the town (rooms RM5)
	TeamState.data["party"] = party.duplicate(true)
	if is_inside_tree() and get_tree().current_scene == self:
		# The crew's pictures are read on a thread under the fade too (pass 6): about 160 ms of the Hall's first build.
		var story: Dictionary = TeamState.data.get("story", {})
		SceneKit.read_ahead(GuildCrew.cast_of(id) if story.get("guild_trial", false) else (["starward", "wayling"] if id == "hall" else []))
		await _leave_to(ROOM_SCENE, false, func(room: Node) -> void: room.room_id = id)
	else:
		set_meta("entered_room", id)   # the checks read this instead of leaving the scene


func enter_hollow() -> void:
	if TeamState.data.is_empty():
		TeamState.start(party)
	TeamState.data["party"] = party.duplicate(true)
	TeamState.autosave()   # setting out: the town's changes are kept even if the run is abandoned
	# The next dungeon whose boss is not beaten (the town has one way down for now; Codex's layout
	# can give each its own entrance later).
	var beaten: Array = TeamState.data.get("beaten", [])
	if "hollow" in beaten:   # the pilot is done: any dungeon can be run again (Preston, 2026-10-11)
		panel = {"name": "The way down", "what": "Where to?", "service": "way_pick", "sel": 0, "marks": way_marks()}
		_ui_sfx("open")   # a list opens as the menus do (pass 5 T7 / LV-29)
		_gather()   # the team stands clear of each other while the list is up (T8)
		return
	var id := _next_way()
	var not_yet := story_gate(id)
	if not_yet != "":
		panel = {"name": "The way down", "what": not_yet, "service": "news"}
		set_meta("gated", not_yet)
		_gather(UP_WAYS, DOWN_WAYS)
		return
	UI.toast(get_tree(), "The run is kept.")   # setting out: the autosave above (GS-11)
	if is_inside_tree() and get_tree().current_scene == self:
		if id == "hollow":
			# The Hollow is reached on foot: the riverbank, the walkway node, then its entrance
			# (Preston, 2026-10-10). hollow_approach.gd starts the run itself and lifts the fade.
			# The party's walkway pictures are read on threads under the fade (T6 / LH8-09). Not headless: the dummy
			# renderer gives a picture read on a thread no texture (the pilot check's walk up printed engine errors).
			if DisplayServer.get_name() != "headless":
				_request(approach_paths())
			await _leave_to(APPROACH_SCENE, true)
			return
		# The run is read on a thread under the fade and made after it (Claude, 2026-10-24, pass 6 T2 / L6-15).
		await _leave_to(DUNGEON_SCENE, false, func(dg: Node) -> void:
			TeamState.give_to(dg)
			dg.dungeon = id
			dg.return_to_town = true)
	else:
		set_meta("entered", true)   # the checks read this instead of leaving the scene


var _scene_was := false   # a scene played last frame (settle_team runs when one hands the street back)


func _process(_delta: float) -> void:
	if _scene_was and not cutscene and not evolving_now:
		settle_team()   # T1: partners a scene left on a doorway, a facade's row or a shared tile step clear
	_scene_was = cutscene
	if poll_input and not busy and not evolving_now:
		_poll()
	_npc_idle(_delta)
	_music_settle(_delta)
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
	SceneKit.idle_bob(movers, Time.get_ticks_msec() / 1000.0)   # pass 5 T12: standing creatures breathe
	if not team.is_empty():
		var half := Vector2(VIEW) * 0.5
		if shrine_view and not evolving_now and panel.is_empty():
			shrine_view = false   # back to following the leader once the shrine's line is closed
		var look: Vector2 = shrine_look() if shrine_view else (team[0]["node"].position + Vector2(0, -12))
		if cam_focus != null:
			look = cam_focus
		var focus: Vector2 = look.clamp(half, Vector2(Layout.W, Layout.H) * T - half)
		shake = maxf(0.0, shake - _delta * 12.0)
		_world.position = (half - focus + Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake).round()
	# The Menu button under the walk keys' strip and as wide as it, never over it, as dungeon.gd places it; a scene
	# hides it with the rest of the HUD (Claude, 2026-10-24, pass 4 T1). The open menu hides it itself. An open panel
	# (the board, a sign, the way down) or the shrine's page hides it too: their own hint rows name the keys
	# (Claude, 2026-10-26, pass 8 T9 / LH8-06).
	var menu := get_node_or_null("GamePauseMenu")
	if menu != null and menu.hint != null:
		menu.hint.visible = not cutscene and not menu.overlay.visible and panel.is_empty() and not shrine_view
		var ks := key_strip()
		menu.hint.position = Vector2(ks.position.x, ks.end.y + 4)
		menu.hint.size = Vector2(ks.size.x, 52)
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
		# Closing a panel sounds like closing the pause menu; backing out of a question or a pick stays the cancel
		# (Claude, 2026-10-26, pass 7 T6 / L7-25).
		_ui_sfx("cancel" if panel.get("service", "") in CHOICE_PANELS else "close")
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
		# The heading on the brass name tab over the frame, as the Job Board and the rooms' panels carry theirs (Claude,
		# 2026-10-26, pass 7 T5 / L7-22), and the rows move up into the line it left. The list hangs from the top of the
		# screen where the board does (T8): the Mouth is at the foot of the map, where the camera stops, and a list at
		# the bottom stood over the team gathered there.
		var box := Rect2(196, 64, 760, 92 - WAY_TAB_GAIN + WAY_ROW * REPLAYS.size())
		UI.panel(h, box, 0.95)
		UI.nameplate(h, box.position + Vector2(24, -22), String(panel["name"]), 22)
		var marks: Array = panel.get("marks", [])
		for i in REPLAYS.size():
			var at := box.position + Vector2(48, 78 - WAY_TAB_GAIN + WAY_ROW * i)
			var on: bool = i == int(panel["sel"])
			if on:
				UI.text(h, at - Vector2(24, 0), ">", 20, UI.EDGE_LIGHT)
			UI.text(h, at, String(REPLAYS[i][1]), 20, UI.EDGE_LIGHT if on else UI.TEXT)
			_draw_way_marks(h, marks[i] if i < marks.size() else {}, Vector2(box.end.x - 22, at.y))
		UI.text(h, box.end - Vector2(738, 14), "%s  choose     %s  go     %s  not now" % [SceneKit.pick_keys(), SceneKit.use_key(), UI.binding_text(&"cancel")], 15, UI.MUTED, 716, HORIZONTAL_ALIGNMENT_RIGHT)
	elif not panel.is_empty():
		# A sign or a news line (the arrival's "Back in Highbank" among them) in the talk box's type, the "story" role,
		# laid out as a room's sign is (town_room.gd spot_layout): two rows in the 128 px box, which grows upward a row
		# for each row past two, its foot where it stood, so the words are never cut and never left small in a big box
		# (Claude, 2026-10-26, pass 8 T4 / L11; since 2026-10-23 they were the body role at 19 px, two rows at most).
		# Small type stays for the lists (the board, the Storage, the way down) and for the key hint.
		var lay := sign_layout(String(panel["what"]))
		var box: Rect2 = lay["box"]
		UI.panel(h, box, 0.95)
		UI.nameplate(h, box.position + Vector2(24, -22), String(panel["name"]), 22)
		var rows: PackedStringArray = lay["rows"]
		for i in rows.size():
			UI.say(h, lay["at"] + Vector2(0, float(lay["row_h"]) * i), rows[i], "story", UI.TEXT)
		# The keys of the device in use (2026-10-23): "E  close" on a keyboard, "A  close" on a pad.
		var use := SceneKit.use_key()
		var back := UI.binding_text(&"cancel")
		var hint := ("%s  grow     %s  not now" % [use, back]) if panel.get("service", "") == "evolve_ask" else (("%s  set it in     %s  not now" % [use, back]) if panel.get("service", "") == "stone_ask" else "%s  close" % use)
		UI.text(h, Vector2(box.position.x + 22, box.end.y - 12), hint, 15, UI.MUTED, 716, HORIZONTAL_ALIGNMENT_RIGHT)


## Where a street sign's words go (T4): the numbers of town_room.gd's spot_layout, the rooms' signs, so a sign reads
## the same out on the street and inside (wrapped as UI.dialogue wraps, 30 px in and 40 clear of the right, two rows
## in the 128 px box, the box growing upward a row for each row past two), with the box SIGN_HINT_ROOM taller at the
## top for the street's key hint under the words (a room's sign has the next arrow instead). Its own copy of those
## numbers, so the street never waits on the room script loading. {box, rows, at (the first row's baseline), row_h}.
## Static, so the checks can measure it.
const SIGN_BOX := Rect2(196, 452, 760, 128)
const SIGN_HINT_ROOM := 14.0


static func sign_layout(what: String) -> Dictionary:
	var rows := UI.wrap_text(what, SIGN_BOX.size.x - 70.0, "story").split("\n")
	var row_h := UI.font("story").get_height(UI.type_size("story"))
	var grow := maxf(0.0, rows.size() - 2) * row_h + SIGN_HINT_ROOM
	var box := Rect2(SIGN_BOX.position - Vector2(0, grow), SIGN_BOX.size + Vector2(0, grow))
	return {"box": box, "rows": rows, "at": box.position + Vector2(30, 54), "row_h": row_h}


## One way-down row's marks (way_marks), right-aligned to `right` on the row's text line `right.y`: the floors on the
## board's brass tab for a cleared Hollow (plain and muted otherwise), then to its left a face for each waiting client,
## in the board's face box.
func _draw_way_marks(h: CanvasItem, m: Dictionary, right: Vector2) -> void:
	var x := right.x
	var floors := String(m.get("floors", ""))
	if floors != "":
		if m.get("cleared", false):
			var w := maxf(96.0, UI.font("name").get_string_size(floors, HORIZONTAL_ALIGNMENT_LEFT, -1, UI.type_size("name")).x + 40.0)
			UI.nameplate(h, Vector2(x - w, right.y - 25), floors)
			x -= w + 12
		else:
			var w2 := UI.width_of(floors, 20)
			UI.text(h, Vector2(x - w2, right.y), floors, 20, UI.MUTED)
			x -= w2 + 12
	for face in m.get("faces", []):
		var r := Rect2(x - 48, right.y - 31, 48, 48)
		h.draw_rect(r, UI.PORTRAIT_BG)
		if face != null:
			h.draw_texture_rect(face, r, false)
		h.draw_rect(r, UI.EDGE, false, 1.0)
		x -= 54


## The walk keys, bottom right, on a label-role strip in the panel frame so they read on any ground
## (Claude, 2026-10-22, GS-21; before, bare text over the street). Since 2026-10-23 the keys are the device's:
## "WASD walk   E use" on a keyboard, "Stick walk   A use" on a pad.
## The run line is left out while the story holds the way down at the Job Board (Claude, 2026-10-24, pass 6 T5 /
## L6-21): on the first arrival the Next line sends the team to the board, and the way down only answers that the
## parcel goes there first. It comes back once the board's scene has played. The words are unchanged.
## Since pass 7 (Claude, 2026-10-26, T3 / L7-05) the line is out whenever the story holds the way down, not only at the
## board: between the theft and the trial (tell the Hall) and between the parcel's return and Starward too, so the strip
## never offers a run the Mouth then refuses.
## Since pass 8 (Claude, 2026-10-26, T8 / L20) the use key is the "interact" action's own binding on either device (E,
## or X on a pad), the row Rebind keys lists as "Use / stairs"; SceneKit.use_key gave the pad's A, the Choose row's
## button, which also works here but is not the one the Rebind page names for using. And (T2 / L03) the run line takes
## its place name from town_layout.gd's gate, so the street's plaque, this line and the objective say the same name.
func key_lines() -> Array:
	var lines := ["%s walk   %s use" % [SceneKit.walk_keys(), use_key()]]
	if _gate_kind(_next_way()) == "":
		lines.append("The %s starts a run" % Layout.place_name("gate"))
	return lines


## The walk strip's use key: the binding of "interact", which _poll reads for using (T8); the Choose key when the
## device has none for it (a pad whose X was unbound), since _poll reads that one too.
static func use_key() -> String:
	var k := UI.binding_text(&"interact")
	return k if k != "" else SceneKit.use_key()


## The strip: as wide as its longest line, its foot at 578 so the Menu button fits under it (Claude, 2026-10-24,
## pass 4 T1 / LV-11: from 538 to 600 the button overlapped it by 14 px). One line high when the run line is out
## (pass 6 T5), its foot where it was.
const STRIP_BRASS := 12.0   # px of the panel frame's opaque brass round its weave (frame/panel.png at 3x)


func key_strip() -> Rect2:
	var lines := key_lines()
	var w := 0.0
	for s in lines:
		w = maxf(w, UI.width_in(s, "label"))
	var h := 62.0 - 20.0 * (2 - lines.size())
	return Rect2(Vector2(1146 - w - 40, 578 - h), Vector2(w + 40, h))


## On the full panel with the words at full strength (Claude, 2026-10-26, pass 7 T7 / ACC-05): on the see-through
## panel at 0.95 they read 3.9:1 over the light stone path. The full panel's weave still lets 7.5% of the ground
## through (5.95:1 there), so the panel's own colour backs it inside the brass: about 7:1 on any ground.
func _draw_key_strip(h: CanvasItem) -> void:
	var lines := key_lines()
	var strip := key_strip()
	h.draw_rect(strip.grow(-STRIP_BRASS), UI.PANEL)
	UI.panel(h, strip)
	for k in lines.size():
		UI.say(h, strip.position + Vector2(20, 26 + 20 * k), lines[k], "label", UI.MUTED)


## The board, drawn the Explorers of Sky way: the rank at the top, one row per request with the
## client's headshot, where to go and what it pays; a brass TAKEN tab on the ones in the satchel.
## It draws from the rows built when it opened (_cache_board, LP-12), not from the jobs every frame.
## 960 wide since pass 5 (T8): the where line names the Hollow too, and the longest, a delivery's, is 405 px.
const BOARD_W := 960.0
const BOARD_REWARD_X := 560.0   # the reward's icon, from the row's left; the where line ends 10 px before it
const BOARD_CARGO_X := 70.0     # the parcel's column, from the row's left: right of the face (T7)
const BOARD_TEXT_X := 110.0     # every row's title and where line, right of the parcel's column (T7)


func _draw_board(h: CanvasItem) -> void:
	if not panel.has("rows"):
		board_rows()
	var rows: Array = panel["rows"]
	var box := Rect2((1152.0 - BOARD_W) * 0.5, 64, BOARD_W, 132 + 70 * maxi(1, rows.size()))
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
		# Delivery cargo has its own icon; the reward keeps its existing icon. The parcel has a column of its own
		# on every row, empty on the others, so every title and where line starts at one x (Claude, 2026-10-26,
		# pass 8 T7 / L19; a delivery's words had stepped 40 px right of the rest).
		var cargo: Texture2D = row["cargo"]
		if cargo != null:
			h.draw_texture(cargo, r.position + Vector2(BOARD_CARGO_X, 11))
		var text_w := BOARD_REWARD_X - 10.0 - BOARD_TEXT_X
		UI.text(h, r.position + Vector2(BOARD_TEXT_X, 27), String(row["title"]), 20, UI.EDGE_LIGHT if on else UI.TEXT, text_w)
		# The where line is prose in the body face on every row, delivery or not (LP-24; at size 15 it had
		# fallen to the capital label face).
		UI.say(h, r.position + Vector2(BOARD_TEXT_X, 51), String(row["where"]), "body", UI.MUTED, text_w)
		if row["icon"] != null:
			h.draw_texture(row["icon"], r.position + Vector2(BOARD_REWARD_X, 15))
		UI.text(h, r.position + Vector2(BOARD_REWARD_X + 38, 37), String(row["reward"]), 16, UI.TEXT, 180)
		if row["taken"]:
			UI.nameplate(h, r.position + Vector2(r.size.x - 112, 13), "Taken", 18)
	UI.text(h, box.end + Vector2(-box.size.x + 30, -22), "%s  choose     %s  take or put back     %s  close" % [SceneKit.pick_keys(), SceneKit.use_key(), UI.binding_text(&"cancel")], 15, UI.MUTED, box.size.x - 60, HORIZONTAL_ALIGNMENT_RIGHT)
