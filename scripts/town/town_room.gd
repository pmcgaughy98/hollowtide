extends Node2D
## Rooms inside Highbank's buildings (Claude, 2026-10-10; Preston: "do this for interiors too, I noticed
## main house and courier hall rooms were super small"). Walk in through the Home's or the Wayline Hall's
## door and the team stands in a room at the town's own scale (24 px tiles, the same creatures), painted
## in code like the dungeons (scripts/town/room_painter.gd), with things to use and the door back out.
## Codex's older courier-era rooms (scenes/courier_hall.tscn, courtyard_home.tscn) are untouched.
##   var room = load("res://scenes/town_room.tscn").instantiate(); room.room_id = "home"

const StoragePanel := preload("res://scripts/town/storage_panel.gd")
const RosterPanel := preload("res://scripts/town/roster_panel.gd")
const StorageArt := preload("res://scripts/town/storage_room_art.gd")
const Objective := preload("res://scripts/town/objective.gd")
const Arena := preload("res://scripts/arena/arena_prototype.gd")
const Lines := preload("res://scripts/creatures/lines.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const GuildCrew := preload("res://scripts/town/guild_crew.gd")
const Painter := preload("res://scripts/town/room_painter.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const SceneKit := preload("res://scripts/town/scene_kit.gd")
const GuildScene := preload("res://scripts/town/guild_scene.gd")
const T := 24
const VIEW := Vector2i(384, 216)
const SCALE := 3.0
const STEP_TIME := 0.13
const WALK_FPS := 12.0
const DIRS := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1)]

## Each room: its size in tiles (walls included), its door (on the bottom wall), the furniture that
## blocks walking, and the spots that answer E. The texts are Claude's drafts. A spot's "what_if" is
## [story flag, text]: the text it shows once that flag is set (Claude, 2026-10-22, CR-02).
const ROOMS := {
	"storage": {"name": "Storage", "w": 17, "h": 13, "door": Vector2i(8,12), "town_door": "storage", "floor_top": 3,
		"exit_rect": Rect2i(7,12,3,1),
		"solid": [Rect2i(2,3,3,2), Rect2i(12,3,3,2), Rect2i(6,5,5,2), Rect2i(2,9,2,2), Rect2i(13,9,2,2)],
		"spots": [{"id": "store_counter", "rect": Rect2i(6,5,5,2), "name": "Storage", "service": "storage"}]},

	"home": {"name": "Home", "w": 14, "h": 10, "door": Vector2i(7, 9), "town_door": "home",
		"solid": [Rect2i(1, 2, 3, 2), Rect2i(9, 2, 4, 1), Rect2i(6, 4, 3, 2), Rect2i(1, 7, 2, 2), Rect2i(11, 6, 2, 2)],
		"spots": [
			{"id": "bed", "rect": Rect2i(1, 2, 3, 2), "name": "Moss Bed", "what": "Rest here and the day ends: the team wakes up whole."},
			{"id": "hearth", "rect": Rect2i(9, 2, 4, 1), "name": "Hearth", "what": "Warm stones and a kettle. The light the house is built round."},
			{"id": "table", "rect": Rect2i(6, 4, 3, 2), "name": "Table", "what": "A lantern, a map of the river, the parcel slip from the first job."},
			{"id": "shelf", "rect": Rect2i(1, 7, 2, 2), "name": "Shelf", "what": "Jars of reedberries and a stack of old Wayline reports."},
			{"id": "plants", "rect": Rect2i(11, 6, 2, 2), "name": "Planters", "what": "Clover and a stubborn fern. Someone waters them."}]},
	# The way out is both tiles under the carpet's end (Claude, 2026-10-26, pass 8 R3 / L13): the carpet and the
	# doorway in the Hall art are centred on x 264, the line between tiles 10 and 11, and only tile 11 opened, so a
	# leader walking down the carpet's left half met a wall at the threshold. The door tile moved to 10 with it, so the
	# team comes in on the carpet's middle (leader on 10, the others filling 10 to 12 behind), not off its right edge.
	"hall": {"name": "Wayline Tower", "w": 22, "h": 14, "door": Vector2i(10, 13), "town_door": "hall", "exit_rect": Rect2i(10, 13, 2, 1),
		"solid": [Rect2i(7, 3, 8, 2), Rect2i(2, 2, 2, 1), Rect2i(18, 2, 2, 1), Rect2i(3, 6, 1, 1), Rect2i(18, 6, 1, 1), Rect2i(3, 10, 1, 1), Rect2i(18, 10, 1, 1),
			Rect2i(1, 8, 1, 3), Rect2i(20, 8, 1, 3), Rect2i(5, 7, 2, 2), Rect2i(15, 7, 2, 2), Rect2i(2, 12, 2, 1), Rect2i(18, 12, 2, 1),
			Rect2i(4, 6, 1, 1), Rect2i(17, 6, 1, 1)],
		"spots": [
			{"id": "counter", "rect": Rect2i(7, 3, 8, 2), "name": "Dispatch Counter", "what": "The dispatcher hands out the board's requests and takes reports.", "service": "jobs"},
			{"id": "notices", "rect": Rect2i(2, 2, 2, 1), "name": "Notice Wall", "what": "Sightings, closures, a warning about a crew poaching deliveries."},
			# Once the team are runners the board opens the roster panel (pass 8 R6, roster_panel.gd): who waits at the Hall.
			{"id": "roster", "rect": Rect2i(18, 2, 2, 1), "name": "Roster Board", "what": "Every team on the Wayline, by rank. Yours is near the bottom, for now.", "service_if": ["runner", "roster"]},
			{"id": "benches", "rect": Rect2i(1, 8, 1, 3), "name": "Bench", "what": "Where couriers wait for the river to settle."},
			{"id": "benches2", "rect": Rect2i(20, 8, 1, 3), "name": "Bench", "what": "Scratched initials and a forgotten glove."},
			{"id": "chart", "rect": Rect2i(5, 7, 2, 2), "name": "Chart Table", "what": "The river and its Hollows, pinned where couriers have gone. A new pin sits on the water near Highbank."},
			{"id": "scrolls", "rect": Rect2i(15, 7, 2, 2), "name": "Report Table", "what": "Reports waiting to be filed. One is stamped LATE in red."},
			{"id": "crates", "rect": Rect2i(2, 12, 2, 1), "name": "Parcels", "what": "Deliveries waiting for a runner."},
			{"id": "crates2", "rect": Rect2i(18, 12, 2, 1), "name": "Parcels", "what": "Undeliverable mail. The labels have washed out."}],
		# Down to the Hall floor (Preston, 2026-10-10: two floors, like the guild in Sky).
		"links": [{"rect": Rect2i(14, 10, 2, 2), "to": "hall_low", "at": Vector2i(24, 14), "facing": "w", "sfx": "stairs"}]},
	# The Hall floor, below the work floor (Claude, 2026-10-10; Preston chose two floors, like Sky's guild:
	# public work upstairs, the Guildmaster's chamber, the morning roll call, crew rooms and the mess hall
	# below). Taken from Sky as structure only. Names and lines are Claude's drafts for Preston.
	"hall_low": {"name": "Wayline Tower, lower floor", "w": 30, "h": 18, "door": Vector2i(-1, -1), "landing": Vector2i(24, 14), "hint": "Stairs up, bottom right",
		"solid": [Rect2i(9, 5, 1, 1), Rect2i(20, 5, 1, 1), Rect2i(9, 12, 1, 1), Rect2i(20, 12, 1, 1), Rect2i(3, 12, 6, 2),
			Rect2i(12, 2, 1, 1), Rect2i(17, 2, 1, 1), Rect2i(27, 2, 1, 1), Rect2i(1, 8, 1, 2)],
		"spots": [
			{"id": "chamber_door", "rect": Rect2i(14, 1, 2, 1), "name": "Postmaster's Chamber", "what": "Starward's door."},
			{"id": "rollcall", "rect": Rect2i(12, 7, 6, 4), "name": "Sorting Floor", "what": "The Wayline's mark, set in brass. Every morning the mail is sorted round it and the routes go out."},
			{"id": "duty", "rect": Rect2i(9, 1, 2, 1), "name": "Duty Board", "what": "Today's duties: the door watch, the kitchen, the sweeping. Your names aren't on it yet."},
			{"id": "window_w", "rect": Rect2i(3, 1, 2, 1), "name": "River Window", "what": "The Tower is cut into the bank. Through the glass the river runs a long way down."},
			{"id": "window_e", "rect": Rect2i(25, 1, 2, 1), "name": "River Window", "what": "Rain on the glass, and the far bank green after the flood."},
			{"id": "crew_room", "rect": Rect2i(0, 5, 1, 2), "name": "Crew Room", "what": "Bunks for the Tower's crew. Someone is snoring."},
			{"id": "runners_room", "rect": Rect2i(29, 5, 1, 2), "name": "Runners' Room", "what": "Runners only. The door is locked.",
				"what_if": ["runner", "Your bunks now. Rest here or go on."]},
			{"id": "mess", "rect": Rect2i(3, 12, 6, 2), "name": "Mess Hall", "what": "The long table. Supper is at the end of the day, for whoever made it back."},
			{"id": "hatch", "rect": Rect2i(1, 8, 1, 2), "name": "Kitchen Hatch", "what": "Something with river greens in it is simmering."},
			{"id": "shelf", "rect": Rect2i(27, 2, 1, 1), "name": "Supply Shelf", "what": "Rope, lantern oil, spare satchels, a jar of reedberries."}],
		"links": [{"rect": Rect2i(14, 1, 2, 1), "to": "chamber", "at": Vector2i(8, 8), "facing": "n", "sfx": "door"},
			{"rect": Rect2i(25, 13, 2, 2), "to": "hall", "at": Vector2i(13, 10), "facing": "w", "sfx": "stairs"},
			{"rect": Rect2i(29, 5, 1, 2), "to": "runners", "at": Vector2i(1, 5), "facing": "e", "sfx": "door", "needs": "runner"}]},
	# The runners' room, off the lower floor's east side: the team's own bunks once Starward names them
	# runners (Preston, 2026-10-10: "definitely want runners room"). Sky gives its hero a room in the guild.
	"runners": {"name": "Runners' Room", "w": 14, "h": 10, "door": Vector2i(-1, -1), "landing": Vector2i(1, 5), "hint": "The door leads back to the Tower",
		"solid": [Rect2i(3, 2, 2, 2), Rect2i(8, 2, 2, 2), Rect2i(11, 7, 2, 1), Rect2i(12, 4, 1, 2)],
		"spots": [
			{"id": "bed", "rect": Rect2i(3, 2, 2, 2), "name": "Your Bunk", "what": "Moss and a wool blanket. Rest here and the day ends: the team wakes up whole."},
			{"id": "bunk2", "rect": Rect2i(8, 2, 2, 2), "name": "The Other Bunk", "what": "Already claimed. There's a reedberry on the pillow."},
			{"id": "window", "rect": Rect2i(6, 1, 1, 1), "name": "Window", "what": "The river, and past it the road the flood covered."},
			{"id": "firstrun", "rect": Rect2i(10, 1, 2, 1), "name": "First Run", "what": "The way to Rootbank Warren, inked by hand, with a star where the parcel was found."},
			{"id": "chest", "rect": Rect2i(11, 7, 2, 1), "name": "Runner's Chest", "what": "A satchel strap, a whistle, and two brass Wayline pins."},
			{"id": "pegs", "rect": Rect2i(12, 4, 1, 2), "name": "Coat Pegs", "what": "Two empty pegs, waiting for satchels."}],
		"links": [{"rect": Rect2i(0, 5, 1, 2), "to": "hall_low", "at": Vector2i(28, 6), "facing": "w", "sfx": "door"}]},
	# Starward's chamber, behind the door at the back of the lower floor.
	"chamber": {"name": "Postmaster's Chamber", "w": 17, "h": 11, "door": Vector2i(-1, -1), "landing": Vector2i(8, 8), "hint": "The door leads back down",
		"solid": [Rect2i(7, 3, 3, 2), Rect2i(1, 2, 1, 1), Rect2i(15, 2, 1, 1)],   # 17 wide: tile 8 is the middle
		"spots": [
			{"id": "dais", "rect": Rect2i(7, 3, 3, 2), "name": "The Dais", "what": "Starward's cushion, worn flat in the middle."},
			{"id": "map", "rect": Rect2i(3, 1, 4, 1), "name": "The Whole River", "what": "Every Hollow the Wayline knows, from the springs to the sea. Most of the map is still blank."},
			{"id": "window", "rect": Rect2i(10, 1, 4, 1), "name": "Window", "what": "The whole of Highbank's bank below, and the river past it."},
			{"id": "keepsakes", "rect": Rect2i(1, 2, 1, 1), "name": "Keepsakes", "what": "Old satchels, a cracked lantern, a medal shaped like a star."},
			{"id": "books", "rect": Rect2i(15, 2, 1, 1), "name": "Ledgers", "what": "Every delivery the Tower has ever made, in Wayling's small neat hand."}],
		"links": [{"rect": Rect2i(7, 10, 3, 1), "to": "hall_low", "at": Vector2i(14, 3), "facing": "s", "sfx": "door"}]},
	# The Item Shop and the Scroll Keeper's cellar (Claude, 2026-10-26, placeholder factory lane R; plan call 5): rooms
	# painted as placeholders (room_painter.gd _plain, FURNITURE) while their doors in Highbank stay shut (hub_town.gd
	# SHUT), so only a debug scene comes in. Each the shape of its art slots: the shop 14 x 10 tiles, the cellar 12 x 9;
	# the shelves, racks, counter and table are Grok's slots. Names and lines are Claude's working drafts.
	"shop": {"name": "Item Shop", "w": 14, "h": 10, "door": Vector2i(7, 9), "town_door": "shop",
		"solid": [Rect2i(1, 2, 2, 1), Rect2i(11, 2, 2, 1), Rect2i(5, 4, 4, 2)],
		"spots": [
			{"id": "shop_counter", "rect": Rect2i(5, 4, 4, 2), "name": "Counter", "what": "Huh, nobody's minding the counter. A card on it says they're out restocking."},
			{"id": "shelf_w", "rect": Rect2i(1, 2, 2, 1), "name": "Shelves", "what": "Bare shelves, and clean squares in the dust where the stock sat."},
			{"id": "shelf_e", "rect": Rect2i(11, 2, 2, 1), "name": "Shelves", "what": "Bare shelves, and clean squares in the dust where the stock sat."}]},
	"scrolls_cellar": {"name": "Scroll Keeper's Cellar", "w": 12, "h": 9, "door": Vector2i(6, 8), "town_door": "scrolls",
		"solid": [Rect2i(1, 2, 2, 1), Rect2i(9, 2, 2, 1), Rect2i(5, 4, 2, 1)],
		"spots": [
			{"id": "rack_w", "rect": Rect2i(1, 2, 2, 1), "name": "Scroll Racks", "what": "Pigeonholes of rolled scrolls, every one tagged in tiny, careful writing."},
			{"id": "rack_e", "rect": Rect2i(9, 2, 2, 1), "name": "Scroll Racks", "what": "Pigeonholes of rolled scrolls, every one tagged in tiny, careful writing."},
			{"id": "reading", "rect": Rect2i(5, 4, 2, 1), "name": "Reading Table", "what": "Oh, one's left open, held flat by two river stones. The Keeper's not taking callers yet."}]},
}
const STAIRS_DOWN := Rect2i(14, 10, 2, 2)   # on the Hall's work floor, right of the runner
# The bed (Claude, 2026-10-22, GS-10): the line on the panel when the screen comes back up, and the fade.
const REST_LINE := "Morning. Highbank remembers."
const REST_FADE := 0.35
const REST_HOLD := 1.5    # the dark between the fades: the night (Claude, 2026-10-24, pass 5 RM5: 0.25 read as a blink)
# Waking (Claude, 2026-10-26, pass 7 T6 / L7-24): the shrine's calm swell, low, in place of the dungeon's wake-up,
# which was made for a floor's alarm, not a morning in bed.
const WAKE_SOUND := "presence_swell"
const WAKE_DB := -14.0
const MENU_SOUNDS := ["denied"]   # menu answers on the UI bus (_sfx), as hub_town.gd's
# The key hints, bottom right, key then action in the column style the menus use (W12). The keys are the
# device's (Claude, 2026-10-23): "WASD  walk     E  use" on a keyboard, "Stick  walk     A  use" on a pad.
static func keys_hint() -> String:
	return "%s  walk     %s  use" % [SceneKit.walk_keys(), SceneKit.use_key()]


@export var room_id := "home"
var arrive := Vector2i(-1, -1)   # set when the team comes by stairs or a door from another room
var arrive_facing := "s"
var poll_input := true
var team: Array = []
var busy := false
var panel := {}
var last_sfx := ""   # same UI-sound receipt as the town Storage panel
var grid := PackedByteArray()
var _world: Node2D
var _hud: Node2D
var used_log: Array = []   # spots used, for the checks
# Scenes in rooms (Claude, 2026-10-10): the hooks scripts/town/scene_kit.gd uses, as in hub_town.gd.
var talk: Array = []          # [speaker, line, "form:face"]; E reads on
var cutscene := false
var cam_focus: Variant = null
var npcs: Array = []          # creatures in the room that are not the team
var scene_fx := {}            # a scene's bubbles and props
var force_scenes := false     # the checks set poll_input off; this still lets a scene play
var _labels: Node2D
var _resting := false         # the bed's fade is up: its panel waits until the screen comes back
var rested := false           # the last rest saved the record (the checks read it)
var _tick_frame := {}         # menu sound kind -> the frame it last played
# Each painted room picture, kept for the session (Claude, 2026-10-24, pass 5 RM9 / PERF-05): room id -> [its
# texture, its finish material]. Painting the Hall took about 0.4 s every time the team walked in; the picture
# depends only on the room, so it is painted on the first entry and reused after.
static var _pictures := {}
static var _desk_art: Array = []   # [the Guildmaster's desk texture, its finish], made once (RM9)
var _lights: Array = []            # the Home's hearth and lantern glows (RM8): {node, levels, steps, step, left}
## Each step of _ready in milliseconds, in order (Claude, 2026-10-24, pass 6 T1 / L6-15), as hub_town.gd keeps its
## ready_ms: the probes read where a room's arrival goes (the Hall's door stall was its first picture and furniture).
var ready_ms := {}
var _lap_at := 0


func _lap(step: String) -> void:
	var now := Time.get_ticks_usec()
	ready_ms[step] = (now - _lap_at) / 1000.0
	_lap_at = now


func room() -> Dictionary:
	return ROOMS[room_id]


func _ready() -> void:
	_lap_at = Time.get_ticks_usec()
	var began := _lap_at
	var r := room()
	grid.resize(r["w"] * r["h"])
	for y in r["h"]:
		for x in r["w"]:
			var inside: bool = x >= 1 and x <= r["w"] - 2 and y >= int(r.get("floor_top", 2)) and y <= r["h"] - 2
			grid[y * r["w"] + x] = 1 if inside else 0
	for s in r["solid"]:
		for y in range(s.position.y, s.end.y):
			for x in range(s.position.x, s.end.x):
				grid[y * r["w"] + x] = 0
	if r["door"].x >= 0:
		var exit: Rect2i = r.get("exit_rect", Rect2i(r["door"], Vector2i.ONE))
		for y in range(exit.position.y, exit.end.y):
			for x in range(exit.position.x, exit.end.x):
				grid[y * r["w"] + x] = 1
	for l in r.get("links", []):   # stairs and inner doors are walked onto
		if not _link_ok(l):
			continue
		for y in range(l["rect"].position.y, l["rect"].end.y):
			for x in range(l["rect"].position.x, l["rect"].end.x):
				grid[y * r["w"] + x] = 1
	var view := SubViewport.new()
	view.size = VIEW
	view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	add_child(view)
	var screen := Sprite2D.new()
	screen.texture = view.get_texture()
	screen.centered = false
	screen.scale = Vector2.ONE * SCALE
	screen.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(screen)
	_world = Node2D.new()
	view.add_child(_world)
	_lap("grid and view")
	var dark := ColorRect.new()
	dark.color = Color("#1a1410")
	dark.position = Vector2(-400, -400)
	dark.size = Vector2(r["w"] * T + 800, r["h"] * T + 800)
	_world.add_child(dark)
	var map := Sprite2D.new()
	map.centered = false
	if room_id == "storage":
		map.texture = StorageArt.shell()   # a loaded picture, not painted: the resource cache keeps it
	elif _pictures.has(room_id):
		map.texture = _pictures[room_id][0]   # painted on an earlier entry this session (RM9), or made ahead (prepare)
		map.material = _pictures[room_id][1]
	else:
		_paint_picture(room_id, map)
		_pictures[room_id] = [map.texture, map.material]
	_world.add_child(map)
	_lap("picture")
	if room_id == "storage":
		StorageArt.finish(_world, map)
	if room_id == "hall":
		_guild_desk()
	if room_id == "home":
		_home_lights()
	_lap("desk and lights")
	_lift_furniture(map)   # LP-29: tall furniture in front of a creature behind it
	_lap("furniture lifted")
	# The HUD's own canvas layer, above the room picture: the room and every prop in it are drawn inside the
	# SubViewport `view` on the scene's base layer, so nothing in the room reaches this layer's talk box (pass 8 R2).
	var layer := CanvasLayer.new()
	layer.name = "Hud"
	add_child(layer)
	_hud = Node2D.new()
	_hud.draw.connect(_draw_hud)
	layer.add_child(_hud)
	# The team stands just inside the door, in a short line.
	var party: Array = TeamState.data.get("party", [[0, 0], [1, 0]])
	var d: Vector2i = r["door"]
	if d.x < 0 and arrive.x < 0:
		arrive = r.get("landing", Vector2i(r["w"] / 2, r["h"] - 3))   # a room with no town door: its landing, never off the map
	var facing := arrive_facing if arrive.x >= 0 else "n"
	for k in party.size():
		var e := _make(party[k][0], party[k][1], Vector2i.ZERO)
		e["facing"] = facing
		team.append(e)
	# Spaced by the sprites' own sizes (T8): each member's opaque box round its feet, facing the way it arrives.
	var stands := _arrival_tiles(team.size(), team.map(func(e: Dictionary) -> Rect2: return _extent_of(e["still"][facing])))
	for k in team.size():
		team[k]["pos"] = stands[k]
		_place(team[k])
	# The names a scene's lines use, read on a thread while the room is still under the fade (Claude, 2026-10-26, pass 8
	# R8): the leader's and the partner's, and in the Hall the whole team's and the waiting creatures' for the Roster Board.
	var named: Array = team.slice(0, 2)
	if room_id == "hall":
		named = team + _record().get("roster", [])
	SceneKit.read_names(named)
	_lap("team")
	preload("res://scripts/ui/game_pause_menu.gd").attach(self)
	_labels = Node2D.new()
	_labels.z_index = 2000
	_labels.draw.connect(func() -> void: SceneKit.draw(self, _labels))
	_world.add_child(_labels)
	if room_id == "chamber" and _record().get("story", {}).get("guild_trial", false):
		var star := SceneKit.spawn(self, "starward", Vector2i(8, 3), "s")
		star["lines"] = _starward_lines()
		star["talk_rect"] = Rect2i(7, 3, 3, 2)   # spoken to across the dais, like a counter
	if GuildScene.pending(self):
		GuildScene.place(self)
		if poll_input or force_scenes:
			(func() -> void: GuildScene.run(self)).call_deferred()
	elif GuildCrew.pending(self) and (poll_input or force_scenes):
		(func() -> void: GuildCrew.run(self)).call_deferred()   # the morning mail call (R3, 2026-10-12)
	else:
		GuildCrew.place(self)   # the crew at their posts
	_lap("menus and crew")
	ready_ms["total"] = (Time.get_ticks_usec() - began) / 1000.0


## Where the team stands on arrival (Claude, 2026-10-22, LP-18). Each member gets its own open tile that is not
## a solid rect, the way out, a stair or an inner door. The leader goes in front (Claude, 2026-10-23, R3: it
## stood nearest the door with the partner in its way, and its first step up landed on the partner): through
## the town door it stands two tiles in, by stairs or an inner door on the landing. Each follower then takes the
## tile beside the one ahead that is most behind it, away from the way the team faces, straight back before
## diagonal; a member with no such tile gets the nearest open one, found breadth-first from the first tile.
## Since pass 7 (Claude, 2026-10-26, T8 / L7-21) the sprites space the line: `boxes` holds each member's opaque box
## round its feet (_extent_of), and a tile is taken only if it and no member placed already cover more than OVERLAP_MAX
## of the smaller one's box (_overlap). Of the tiles that keep clear, the one most behind wins as before, then the one
## nearest the leader's line, so a team of narrow creatures zigzags back instead of standing on each other's heads; a
## wide one gets a tile two back (the tile between open) when no tile one back keeps clear, and when none does the
## least covered tile is taken. The walk's one-tile trail (SceneKit.follow) is unchanged: a member two back closes up
## on the first step. OVERLAP_MAX is under a quarter, so a line that only just keeps clear still reads as two creatures.
const OVERLAP_MAX := 0.15


func _arrival_tiles(n: int, boxes: Array = []) -> Array:
	var d: Vector2i = room()["door"]
	var first: Vector2i = arrive if arrive.x >= 0 else d + Vector2i(0, -1)
	var picked: Array = []
	for t in ([arrive] if arrive.x >= 0 else [d + Vector2i(0, -2), d + Vector2i(0, -1)]):
		if _stand_ok(t, picked):
			picked.append(t)
			break
	var back: Vector2i = -DIRS[Arena.FACINGS.find(arrive_facing if arrive.x >= 0 else "n")]
	while not picked.is_empty() and picked.size() < n:
		var ahead: Vector2i = picked[picked.size() - 1]
		var k := picked.size()
		var best := Vector2i(-1, -1)
		var best_score := -INF
		var least := Vector2i(-1, -1)
		var least_cover := INF
		for gap in [1, 2]:
			for o: Vector2i in DIRS:
				var lean := float(o.x * back.x + o.y * back.y)
				var t: Vector2i = ahead + o * gap
				if (gap == 2 and lean <= 0.0) or not _stand_ok(t, picked) or (gap == 2 and not _open(ahead + o)):
					continue
				var off := absi((t - picked[0]).x * back.y - (t - picked[0]).y * back.x)   # tiles off the leader's line
				var score := lean - 0.5 * float(absi(o.x) + absi(o.y)) - 0.1 * float(off)
				var cover := _worst_overlap(t, k, picked, boxes)
				if cover <= OVERLAP_MAX and score > best_score:
					best = t
					best_score = score
				if lean >= 0.0 and cover < least_cover:
					least = t
					least_cover = cover
			if best.x >= 0:
				break   # a tile one back that keeps clear wins over any two back
		if best.x < 0:
			best = least
		if best.x < 0:
			break
		picked.append(best)
	var seen := {first: true}
	var queue: Array = [first]
	while picked.size() < n and not queue.is_empty():
		var c: Vector2i = queue.pop_front()
		if _stand_ok(c, picked):
			picked.append(c)
		for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1)]:
			var nb: Vector2i = c + o
			if not seen.has(nb) and _open(nb):
				seen[nb] = true
				queue.append(nb)
	while picked.size() < n:   # too little floor for the team; no room above is that small
		picked.append(first)
	return picked


## The most that member `k` standing on `t` and any member already placed cover of each other (T8).
static func _worst_overlap(t: Vector2i, k: int, placed: Array, boxes: Array) -> float:
	var worst := 0.0
	if k < boxes.size():
		for j in mini(placed.size(), boxes.size()):
			worst = maxf(worst, _overlap(boxes[k], t, boxes[j], placed[j]))
	return worst


## How much two sprites' boxes cover of each other, as a share of the smaller box: 0 apart, 1 one hidden behind the
## other. Stricter than a share of the wider one (the plan's measure), which let a small partner vanish behind a big one.
static func _overlap(ea: Rect2, ta: Vector2i, eb: Rect2, tb: Vector2i) -> float:
	var ra := Rect2(ea.position + Vector2(ta) * T, ea.size)
	var rb := Rect2(eb.position + Vector2(tb) * T, eb.size)
	return ra.intersection(rb).get_area() / maxf(1.0, minf(ra.get_area(), rb.get_area()))


## A still's opaque box round the feet it stands on, read once a picture: _place centres the sprite 4 px above its
## texture's foot (T8; hub_town.gd keeps the same reading for the street).
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


## A tile a member may stand on: open floor, not a stair or inner door, not the way out, not taken, and not where a
## crew member or townsfolk stands (pass 8 R1: the team re-forms after scenes with the crew still about).
func _stand_ok(t: Vector2i, taken: Array) -> bool:
	var d: Vector2i = room()["door"]
	var way_out: Rect2i = room().get("exit_rect", Rect2i(d, Vector2i.ONE))
	return _open(t) and _link_at(t).is_empty() and not (d.x >= 0 and way_out.has_point(t)) and not t in taken \
		and not npcs.any(func(n: Dictionary) -> bool: return n["pos"] == t)


## Where members 1 to 3 stand behind the leader where it is now (Claude, 2026-10-26, pass 8 R1 and R5 / L01, LH8-04):
## the arrival rule (_arrival_tiles, spaced by the sprites' boxes from _extent_of) run from the leader's own tile as if
## the team had just come in facing `facing`. Index 0 is the leader's tile. [] when the leader's tile is not one an
## arrival may use (a stair, the way out), so callers leave the team as it is.
func trail_tiles(facing: String) -> Array:
	if team.is_empty():
		return []
	var was := arrive
	var was_facing := arrive_facing
	arrive = team[0]["pos"]
	arrive_facing = facing if Arena.FACINGS.has(facing) else "s"
	var stands := _arrival_tiles(team.size(), team.map(func(e: Dictionary) -> Rect2: return _extent_of(e["still"][arrive_facing])))
	arrive = was
	arrive_facing = was_facing
	return stands if not stands.is_empty() and stands[0] == team[0]["pos"] else []


## Set members 1 to 3 on their tiles behind the leader at once, facing `facing` (the bed's night does it under the black;
## a scene does it after its walks, for anyone held up). `stands` from trail_tiles, or worked out here when empty.
func respace(facing: String, stands: Array = []) -> void:
	if stands.is_empty():
		stands = trail_tiles(facing)
	for k in range(1, mini(team.size(), stands.size())):
		var e: Dictionary = team[k]
		e["pos"] = stands[k]
		e["facing"] = facing
		e["walk_t"] = 0.0
		_place(e)


## The first entry paints the picture and finishes it, in the order it always had: the room's art finish, the Hall's
## painted counter taken out, then the Hall floors' finish (it keeps the counter's mask). Static since pass 7 (T2), so
## prepare() makes the same picture before the door is used.
static func _paint_picture(id: String, map: Sprite2D) -> void:
	map.texture = ImageTexture.create_from_image(Painter.paint(id, ROOMS[id]))
	if id == "home":
		preload("res://scripts/town/home_room_art.gd").finish(map)
	elif id == "hall":
		preload("res://scripts/town/hall_room_art.gd").finish(map)
	if id == "hall":
		_clear_counter(map)
	if id in ["hall", "hall_low", "chamber", "runners"]:
		preload("res://scripts/town/hall_floors_art.gd").finish(map, id)


## TownRoom.prepare(id) (Claude, 2026-10-26, pass 7 T2 / LF7-04): make room `id`'s picture, its finish and its
## furniture's shapes now and keep them, so its first entry of the session builds like a later one (the Hall's door
## took 0.35 s and the lower Hall's stairs 1.0 s, nearly all of it these). Painter code is unchanged: this is the
## same work _ready did on a first entry. hub_town.gd's _warm_up makes the Hall's two floors and the Home ahead,
## the painting on a worker thread (prepared_parts) and the keeping on this one (keep_prepared).
static func prepare(id: String) -> void:
	if not prepared(id):
		keep_prepared(id, prepared_parts(id))


## Whether room `id` builds without painting: its picture and furniture are kept (the Storage's are loaded art), and in
## the Hall the Guildmaster's desk too (pass 8 R8).
static func prepared(id: String) -> bool:
	return id == "storage" or not ROOMS.has(id) or (_pictures.has(id) and _lift_shapes.has(id) and (id != "hall" or not _desk_art.is_empty() or not RoomSlots.real(DESK_SLOT)))


## [texture, finish material, furniture pieces, desk art] for room `id`, made without touching this script's caches, so
## it can run on a worker thread while the main one goes on drawing. Off the main thread the art is read from its PNGs
## (UI.res_image), so call it there only when art_off_main() says they are on disk. The desk art ([texture, finish], or
## [] outside the Hall) joined in pass 8 (Claude, 2026-10-26, R8): its sel-out took 30 to 55 ms of the Hall's build.
static func prepared_parts(id: String) -> Array:
	var map := Sprite2D.new()
	_paint_picture(id, map)
	var out := [map.texture, map.material, _shapes_of(id), _make_desk_art() if id == "hall" and _desk_art.is_empty() else []]
	map.free()
	return out


## On the main thread: keep what prepared_parts made, unless the room was entered and painted meanwhile.
static func keep_prepared(id: String, parts: Array) -> void:
	if parts.size() < 3 or not (parts[0] is Texture2D):
		return
	if not _pictures.has(id):
		_pictures[id] = [parts[0], parts[1]]
	if not _lift_shapes.has(id):
		_lift_shapes[id] = parts[2]
	if parts.size() > 3 and parts[3] is Array and (parts[3] as Array).size() == 2 and _desk_art.is_empty():
		_desk_art = parts[3]


## Whether the rooms' art can be read off the main thread: UI.res_image there finds only a PNG on disk, which the
## project has and an exported game does not (it carries the imported textures alone). Since the rooms' art became
## slots (Claude, 2026-10-26, placeholder factory lane R) this reads the Hall's slot, its file or today's: on the main
## thread, so ArtSlots has read its registry before a worker thread asks it anything (room_slots.gd).
static func art_off_main() -> bool:
	var hall := ArtSlots.spec(preload("res://scripts/town/hall_room_art.gd").SLOT)
	return FileAccess.file_exists(String(hall.get("file", ""))) or FileAccess.file_exists(String(hall.get("legacy", "")))


## The team record the town carries (scripts/town/team_state.gd).
func _record() -> Dictionary:
	if TeamState.data.is_empty():
		TeamState.start([[0, 0], [1, 0]])
	return TeamState.data


## `keep` puts the player on the tree's root instead of the room (Claude, 2026-10-24, pass 5 RM5): a door or stair
## sound plays on through the change of scene that frees the room a fade later. A refusal that answers a menu choice
## (the Storage at its cap) plays on the "UI" bus at the ticks' level, as on the street (hub_town.gd MENU_SOUNDS;
## Claude, 2026-10-26, pass 7 T6 / L7-23). `db` sets a quieter take (the bed's waking).
func _sfx(name: String, keep := false, db := -4.0) -> void:
	var path := "res://assets/audio/sfx/dungeon/%s.wav" % name
	if not ResourceLoader.exists(path):
		return
	var menu: bool = name in MENU_SOUNDS
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	p.volume_db = UI.TICK_DB if menu else db
	p.bus = &"UI" if menu else &"SFX"
	p.finished.connect(p.queue_free)
	if keep and is_inside_tree():
		p.autoplay = true   # plays as it joins the root, at the end of this frame
		get_tree().root.add_child.call_deferred(p)
		return
	add_child(p)
	p.play()


func _open(t: Vector2i) -> bool:
	var r := room()
	return t.x >= 0 and t.y >= 0 and t.x < r["w"] and t.y < r["h"] and grid[t.y * r["w"] + t.x] == 1


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
	var walk := {}
	for f in Arena.FACINGS:
		still[f] = load("res://assets/sprites/arena/%s/%s/%s.png" % [form, set, f])
		var frames: Array = []
		for k in 8:
			var p := "res://assets/sprites/arena/%s/%s/walk_%s_f%d.png" % [form, set, f, k]
			if ResourceLoader.exists(p):
				frames.append(load(p))
		walk[f] = frames
	return {"line": line, "stage": stage, "form": form, "pos": pos, "node": node, "sprite": sprite, "still": still, "walk": walk,
		"facing": "s", "walk_t": 0.0, "walk_clock": 0.0}


## The Guildmaster's desk (Preston, 2026-10-10: replace the painted counter, "it doesn't look right", with an
## asset made for the Guildmaster and the scene). The counter is painted out of the Hall picture as floor,
## copied from the stone two tiles below (and from beside the carpet where the carpet ran), and the hand-drawn
## desk (tools/art/guild_desk.py) stands in its place, a row lower, so the picture sits exactly on its solid
## tiles (rows 3 and 4; Preston: "he still goes through it, make it a real obstacle") and row 2 behind it is
## open floor. Creatures sort by their feet (z = y): the desk draws over row 2 (feet 66) and under row 5 (138).
const DESK_AT := Vector2i(168, 70)
const DESK_SLOT := "town.prop.hall.desk"   # its art slot (lane R, 2026-10-26): today's desk_detail_2026_10_10.png
const RoomSlots := preload("res://scripts/town/room_slots.gd")
const OLD_COUNTER := Rect2i(160, 46, 208, 54)


## The painted counter out of the Hall picture, and its ink outline out of the finish's mask, when the desk art is
## there to stand in its place. Part of the first paint, so the kept picture has it already (RM9).
static func _clear_counter(map: Sprite2D) -> void:
	if not RoomSlots.real(DESK_SLOT):
		return
	var img: Image = map.texture.get_image()
	var carpet := Vector2i(226, 302)   # the carpet's columns; stone is taken from beside it there
	for y in range(OLD_COUNTER.position.y, OLD_COUNTER.end.y):
		for x in range(OLD_COUNTER.position.x, OLD_COUNTER.end.x):
			var sx := x - 76 if x >= carpet.x and x < carpet.y else x
			img.set_pixel(x, y, img.get_pixel(sx, y + 52))
	map.texture = ImageTexture.create_from_image(img)
	var mat := map.material as ShaderMaterial
	if mat != null:   # the painted counter's ink outline goes with it
		var mask: Image = preload("res://scripts/town/hall_room_art.gd").mask()
		mask.fill_rect(OLD_COUNTER, Color.BLACK)
		mat.set_shader_parameter("detail_mask", ImageTexture.create_from_image(mask))


## The desk sprite itself, its picture and finish made once a session (RM9). The picture comes through its art slot
## (room_slots.gd), which reads the imported texture an exported game has (Claude, 2026-10-24, pass 5 RM10).
func _guild_desk() -> void:
	if not RoomSlots.real(DESK_SLOT):
		return
	if _desk_art.is_empty():
		_desk_art = _make_desk_art()
		if _desk_art.is_empty():
			return
	var desk := Sprite2D.new()
	desk.centered = false
	desk.texture = _desk_art[0]
	desk.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	desk.material = _desk_art[1]
	desk.position = Vector2(DESK_AT)
	desk.z_index = DESK_AT.y + 46   # its front's foot
	_world.add_child(desk)


## [the desk's sel-out picture, its finish], or [] without the art. Touches no cache, so prepared_parts can make it on
## the town's worker thread (pass 8 R8); _guild_desk makes it here when the Hall is entered before that.
static func _make_desk_art() -> Array:
	if not RoomSlots.real(DESK_SLOT):
		return []
	var desk_image := RoomSlots.image(DESK_SLOT)
	var desk_mask := Image.create(desk_image.get_width(),desk_image.get_height(),false,Image.FORMAT_RGBA8)
	desk_mask.fill(Color.WHITE)
	var desk_finish := ShaderMaterial.new()
	desk_finish.shader = preload("res://scripts/dungeon/dungeon_finish.gdshader")
	desk_finish.set_shader_parameter("detail_mask",ImageTexture.create_from_image(desk_mask))
	desk_finish.set_shader_parameter("detail_ink",0.55)
	return [ImageTexture.create_from_image(preload("res://scripts/art/selout.gd").selout(desk_image)), desk_finish]


## Tall furniture in front of a creature behind it (Claude, 2026-10-23, LP-29). The rooms' furniture is part of
## the room picture, so every creature drew over it, even one standing behind a pillar or beside a bed's far end.
## Each solid piece of the room data that is more than one row deep, or whose art stands up past its tiles (the
## Hall's pillars, ferns and benches), gets a copy of its pixels drawn at its base row's depth, the way creatures
## and the Hall's desk sort by their feet: a creature whose feet are on a row above the base row draws under it,
## one on the base row or below draws over it. The copy is the room picture itself through the room's own finish
## (so its pixels are the picture's exactly), clipped to the piece's shape: the room's prop sprites where it has
## them (the Hall, the lower floor, the chamber, the runners' room), else the piece's own tiles (the Home is one
## painted picture). The Storage's props and the Hall's desk are their own sorted sprites already.
const LIFT_FLAT := ["rug", "runner", "rollcall"]   # props that lie flat on the floor, never in front of anyone
const LIFT_REACH := 6   # a prop stands on a piece when its foot is inside the piece's tiles or this far below them
var lifts: Array = []   # {"rect": the solid rect, "z": its depth, "node": the clip}, one per lifted piece (the checks)
static var _lift_shapes := {}   # room id -> [[solid rect, picture rect, shape], ...], cut once a session


func _lift_furniture(map: Sprite2D) -> void:
	if room_id == "storage" or map.texture == null:
		return
	if not _lift_shapes.has(room_id):
		_lift_shapes[room_id] = _shapes_of(room_id)
	for piece in _lift_shapes[room_id]:
		var rect: Rect2i = piece[0]
		var at: Rect2i = piece[1]
		# The shape, never drawn itself, clips the copy of the picture under it (Godot's clip children).
		var clip := Sprite2D.new()
		clip.centered = false
		clip.texture = piece[2]
		clip.position = Vector2(at.position)
		clip.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
		clip.z_index = (rect.end.y - 1) * T + int(T * 0.5)   # the base row's middle: feet above it sort under
		var copy := Sprite2D.new()
		copy.centered = false
		copy.texture = map.texture
		copy.region_enabled = true
		copy.region_rect = Rect2(at)
		copy.material = map.material   # the same finish, reading the whole picture, so the pixels match
		clip.add_child(copy)
		_world.add_child(clip)
		lifts.append({"rect": rect, "z": clip.z_index, "node": clip})


## The pieces to lift with their shapes as textures, made once a session like the picture (RM9). Static since pass 7
## (T2), so prepare() cuts them ahead.
static func _shapes_of(id: String) -> Array:
	var cut := _furniture_shapes(id)
	for piece in cut:
		piece[2] = ImageTexture.create_from_image(piece[2])
	return cut


## Each piece to lift: [its solid rect, the picture rect its shape covers, the shape (white where the piece is)].
static func _furniture_shapes(id: String) -> Array:
	var props := _room_props(id)
	var out: Array = []
	for s in ROOMS[id]["solid"]:
		var rect: Rect2i = s
		if id == "hall" and rect == Rect2i(7, 3, 8, 2) and RoomSlots.real(DESK_SLOT):
			continue   # the Guildmaster's desk sorts itself
		var tiles := Rect2i(rect.position * T, rect.size * T)
		var stands: Array = props.filter(func(p: Array) -> bool:
			var pr: Rect2i = p[0]
			var across := mini(pr.end.x, tiles.end.x) - maxi(pr.position.x, tiles.position.x)
			return pr.end.y > tiles.position.y and pr.end.y <= tiles.end.y + LIFT_REACH and across * 2 >= pr.size.x)
		if stands.is_empty():
			if rect.size.y < 2:
				continue   # one row with no art standing above it: nothing of it is ever behind a creature
			var whole := Image.create(tiles.size.x, tiles.size.y, false, Image.FORMAT_RGBA8)
			whole.fill(Color.WHITE)
			out.append([rect, tiles, whole])
			continue
		var at: Rect2i = stands[0][0]
		for p in stands:
			at = at.merge(p[0])
		var shape := Image.create(at.size.x, at.size.y, false, Image.FORMAT_RGBA8)
		for p in stands:
			var pr: Rect2i = p[0]
			var img: Image = p[1]
			for y in mini(pr.size.y, img.get_height()):
				for x in mini(pr.size.x, img.get_width()):
					if img.get_pixel(x, y).a > 0.5:   # the props' soft fringe stays floor
						shape.set_pixel(pr.position.x - at.position.x + x, pr.position.y - at.position.y + y, Color.WHITE)
		out.append([rect, at, shape])
	return out


## The prop sprites painted into this room's picture, with where they were painted: [[rect, Image], ...]. The shut
## rooms' furniture joined on 2026-10-26 (lane R): room_painter.gd FURNITURE, Grok's slots.
static func _room_props(id: String) -> Array:
	var out: Array = []
	if id == "hall":
		var art := preload("res://scripts/town/hall_room_art.gd")
		if art.available():
			for p in art.PROPS:
				out.append([p[1], art._prop(p[0])])
	var floors := preload("res://scripts/town/hall_floors_art.gd")
	if floors.PROPS.has(id) and floors.available(id):
		for p in floors.PROPS[id]:
			if not LIFT_FLAT.any(func(w: String) -> bool: return String(p[0]).contains(w)):
				out.append([p[1], floors._prop(p, id)])
	out.append_array(Painter.furniture(id))
	return out


func _px(t: Vector2i) -> Vector2:
	return Vector2(t) * T + Vector2(T * 0.5, T * 0.78)


func _place(e: Dictionary) -> void:
	e["node"].position = _px(e["pos"])
	if e.get("walk_t", 0.0) <= 0.0:
		e["sprite"].texture = e["still"][e["facing"]]
	e["sprite"].position = Vector2(0, -e["sprite"].texture.get_size().y * 0.5 + 4)
	e["node"].z_index = int(e["node"].position.y)


func _facing_of(d: Vector2i) -> String:
	return Arena.FACINGS[DIRS.find(d)] if DIRS.has(d) else "s"


## A creature's place mid-step, drawn at its feet's depth as _place draws it at rest.
func _feet(p: Vector2, node: Node2D) -> void:
	node.position = p
	node.z_index = int(p.y)


## The Home's fire and the lantern on its table (Claude, 2026-10-24, pass 5 RM8 / LV-11): a warm glow added over
## each, at the world's own pixel scale in stepped rings like the painted glows (room_painter.gd _glow), stepping
## between three levels of light (the fire) or two (the wick) at uneven moments. Each step is [level, seconds held].
## The fire's glow sits under every creature (its row is behind the hearth's); the lantern's sits just above the
## table's lifted copy, so it lights the table and anyone in front of the table still draws over it.
const LIGHTS := [
	{"at": Vector2(272, 49), "radius": 30, "col": Color("#ffb45a"), "levels": [0.06, 0.12, 0.18], "z": 2 * T + 12,
		"steps": [[2, 0.21], [1, 0.13], [2, 0.34], [0, 0.17], [1, 0.27], [2, 0.11], [1, 0.4], [0, 0.15], [2, 0.29], [1, 0.19]]},
	{"at": Vector2(194, 112), "radius": 16, "col": Color("#ffe08a"), "levels": [0.08, 0.15], "z": 5 * T + 13,
		"steps": [[1, 0.6], [0, 0.23], [1, 0.9], [0, 0.17], [1, 0.41], [0, 0.12], [1, 1.1]]},
]
static var _glows := {}   # light index -> its stepped glow texture, made once


func _home_lights() -> void:
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	for i in LIGHTS.size():
		var l: Dictionary = LIGHTS[i]
		var r: int = l["radius"]
		if not _glows.has(i):
			var img := Image.create(2 * r + 1, 2 * r + 1, false, Image.FORMAT_RGBA8)
			for y in 2 * r + 1:
				for x in 2 * r + 1:
					var d := Vector2(x - r, y - r).length() / float(r)
					if d < 1.0:
						var c: Color = l["col"]
						c.a = floorf((1.0 - d) * 4.0) / 4.0   # four rings, stepped like pixel art
						img.set_pixel(x, y, c)
			_glows[i] = ImageTexture.create_from_image(img)
		var glow := Sprite2D.new()
		glow.name = "HomeLight%d" % i
		glow.texture = _glows[i]
		glow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		glow.material = add
		glow.centered = false   # on whole pixels: the texture is an odd size
		glow.position = Vector2(l["at"]) - Vector2(r, r)
		glow.z_index = l["z"]
		var first: Array = l["steps"][0]
		glow.modulate.a = float(l["levels"][first[0]])
		_world.add_child(glow)
		_lights.append({"node": glow, "levels": l["levels"], "steps": l["steps"], "step": 0, "left": float(first[1])})


func _flicker(delta: float) -> void:
	for l in _lights:
		l["left"] -= delta
		if l["left"] > 0.0:
			continue
		var steps: Array = l["steps"]
		l["step"] = (int(l["step"]) + 1) % steps.size()
		var st: Array = steps[l["step"]]
		l["left"] += float(st[1])
		(l["node"] as Sprite2D).modulate.a = float(l["levels"][st[0]])


## One step for the leader; the others follow in a chain, one tile back (SceneKit.follow). Stepping onto the
## door leaves the room.
func act_move(d: Vector2i) -> void:
	if busy or cutscene or not panel.is_empty():
		return
	var lead: Dictionary = team[0]
	lead["facing"] = _facing_of(d)
	var to: Vector2i = lead["pos"] + d
	if npcs.any(func(n: Dictionary) -> bool: return n["pos"] == to):   # the crew and townsfolk are solid
		_place(lead)
		return
	if not _open(to) or (d.x != 0 and d.y != 0 and (not _open(lead["pos"] + Vector2i(d.x, 0)) or not _open(lead["pos"] + Vector2i(0, d.y)))):
		_place(lead)
		return
	busy = true
	var trail: Array = team.map(func(e: Dictionary) -> Vector2i: return e["pos"])
	lead["pos"] = to
	# Each follower takes the tile the one ahead left, never the leader's, a teammate's or furniture (Claude,
	# 2026-10-23, R3: before, a follower within a tile stayed put, so the leader could walk onto the partner).
	SceneKit.follow(self, trail)
	for e in team:
		if _px(e["pos"]) != e["node"].position:
			e["walk_t"] = STEP_TIME + 0.06
		# Depth follows the feet every frame, as in SceneKit.walk_to, so a creature crossing a teammate or a lifted
		# piece of furniture changes places with it as it passes, not when the step ends (R3).
		create_tween().tween_method(_feet.bind(e["node"]), e["node"].position, _px(e["pos"]), STEP_TIME)
	await get_tree().create_timer(STEP_TIME).timeout
	for e in team:
		_place(e)
	busy = false
	if room().get("exit_rect", Rect2i(room()["door"], Vector2i.ONE)).has_point(lead["pos"]):
		leave()
		return
	var link := _link_at(lead["pos"])
	if not link.is_empty():
		go_room(link)


## Use what the leader faces: a spot shows its panel; a second press closes it.
func act_use() -> Dictionary:
	if cutscene:
		return {}
	if panel.get("service", "") == "storage":
		act_store(1)
		return {}
	if panel.get("service", "") == "roster":
		act_roster_pick()
		return {}
	if not panel.is_empty():
		_ui_sfx("close")   # E closes a spot's panel as Esc does, with the menus' close (T6)
		panel = {}
		return {}
	var lead: Dictionary = team[0]
	var ahead: Vector2i = lead["pos"] + DIRS[Arena.FACINGS.find(lead["facing"])]
	for n in npcs:
		if n.has("lines") and (n["pos"] == ahead or n.get("talk_rect", Rect2i()).has_point(ahead)):
			_chat(n)
			return {"id": "talk_" + String(n["form"])}
	for s in room()["spots"]:
		if s["rect"].has_point(ahead) or s["rect"].has_point(lead["pos"]):
			if _spot_service(s) == "roster":   # the Roster Board once the team are runners (pass 8 R6)
				panel = RosterPanel.open_panel(self)
				_ui_sfx("open")
				used_log.append(s["id"])
				return s
			panel = {"name": "Storage", "service": "storage", "sel": 0, "said": ""} if s.get("service", "") == "storage" else _spot_panel(s)
			if s.get("service", "") == "storage":
				_ui_sfx("open")   # the menu's own opening sound, as the pause menu's (Claude, 2026-10-24, pass 5 RM5)
			used_log.append(s["id"])
			if s["id"] == "bed":
				_ui_sfx("open")   # the bed's panel opens with the menus' tick, before the night falls (T6)
				rest()
			return s
	return {}


## The service a spot opens now: its "service", or the one "service_if" names once that story flag is set (Claude,
## 2026-10-26, pass 8 R6: the Roster Board is a notice until the team are runners, then it opens the roster panel).
func _spot_service(s: Dictionary) -> String:
	var gate: Array = s.get("service_if", [])
	if gate.size() == 2 and _record().get("story", {}).get(String(gate[0]), false):
		return String(gate[1])
	return String(s.get("service", ""))


## A spot's panel: a copy of the spot, its text swapped for "what_if" once that story flag is set (CR-02),
## and the morning line on a bed (GS-10). Claude, 2026-10-22.
func _spot_panel(s: Dictionary) -> Dictionary:
	var p := s.duplicate()
	var alt: Array = s.get("what_if", [])
	if alt.size() == 2 and _record().get("story", {}).get(String(alt[0]), false):
		p["what"] = String(alt[1])
	if s["id"] == "bed":
		p["what"] = REST_LINE
		p["narration"] = true   # the morning line is narration: the text box, no name plate (pass 4 T7)
	return p


## The bed rests the team (Claude, 2026-10-22, GS-10): the screen fades out, the night passes, the record is
## saved, and the screen comes back on the morning line. The town record holds no HP (every run starts at
## full), so waking up whole needs nothing more. The save is made at once, so a check reads it without
## waiting; the fade runs on the tree, so the screen comes back even if the room is gone by then.
func rest() -> void:
	for e in team:
		e["facing"] = "s"
		_place(e)
	rested = TeamState.autosave()
	if not is_inside_tree():
		return
	_resting = true
	_night(get_tree(), self)


static func _night(tree: SceneTree, host: Node) -> void:
	await UI.fade_out(tree, REST_FADE)
	# Under the black the others settle round the leader (Claude, 2026-10-26, pass 8 R5 / LH8-04): beside the bed the
	# line had bunched against it, and the morning came up on a heap. Each gets its own tile behind the leader.
	if is_instance_valid(host) and host.is_inside_tree() and host.has_method("respace"):
		host.respace("s")
	await tree.create_timer(UI.motion_secs(REST_HOLD)).timeout
	if is_instance_valid(host) and host.is_inside_tree():
		host._sfx(WAKE_SOUND, false, WAKE_DB)   # waking up, softly (pass 7 T6; it was the dungeon's wake.wav)
	# The morning line waits until the black has lifted (Claude, 2026-10-24, pass 4 T7 / LV-34): it drew under it.
	await UI.fade_in(tree, REST_FADE)
	if is_instance_valid(host):
		host.set("_resting", false)


## The stairs or inner door under `t`, or {}.
func _link_at(t: Vector2i) -> Dictionary:
	for l in room().get("links", []):
		if l["rect"].has_point(t) and _link_ok(l):
			return l
	return {}


## A door the story has not opened yet ("needs" names a story flag, e.g. the runners' room needs "runner").
func _link_ok(l: Dictionary) -> bool:
	return not l.has("needs") or _record().get("story", {}).get(l["needs"], false)


## Down the stairs or through a door: the same team, in the next room, on its landing. The screen goes black
## before the next room is built (Claude, 2026-10-23, R4), so its painting sits on black, not on a frozen frame,
## and lifts once the new room has drawn.
func go_room(link: Dictionary) -> void:
	_sfx(String(link.get("sfx", "door")), true)
	used_log.append("to_" + String(link["to"]))
	if is_inside_tree() and get_tree().current_scene == self:
		busy = true   # no steps while the screen goes dark
		if _record().get("story", {}).get("guild_trial", false):
			SceneKit.read_ahead(GuildCrew.cast_of(String(link["to"])))   # the crew's pictures, read under the fade (pass 6)
		var tree := get_tree()
		await UI.fade_out(tree)
		var next: Node = load("res://scenes/town_room.tscn").instantiate()
		next.room_id = link["to"]
		next.arrive = link["at"]
		next.arrive_facing = link["facing"]
		tree.change_scene_to_node(next)
		_lift(tree)
	else:
		set_meta("went", link)   # the checks read this instead of leaving the scene


## The fade off the next room, two frames after the change: the room paints in the frame the change lands, and a
## fade started before that long frame would spend its whole time in it and pop up instead of fading (R4).
static func _lift(tree: SceneTree) -> void:
	await tree.process_frame
	await tree.process_frame
	# Then until the next room has built, and one frame more (Claude, 2026-10-26, pass 8 R8): the frame after a long
	# build reports the build's time as its delta, and a fade started before it spent its whole time in that one step.
	var guard := 0
	while guard < 30 and (tree.current_scene == null or not tree.current_scene.is_node_ready()):
		await tree.process_frame
		guard += 1
	await tree.process_frame
	UI.fade_in(tree)


## A word from someone standing in the room (the team turns to them; E reads on).
func _chat(n: Dictionary) -> void:
	cutscene = true
	SceneKit.face(self, n, team[0])
	await SceneKit.say(self, n["lines"])
	cutscene = false


## What the Guildmaster says in the chamber, by where the story is (Claude's drafts for Preston).
func _starward_lines() -> Array:
	var story: Dictionary = _record().get("story", {})
	if story.get("runner", false):
		return [["Starward", "Runners of the Wayline. The river is longer than any map in this room. Go and see it.", "happy"]]
	if String(story.get("parcel", "")) == "stolen":
		return [["Starward", "Rootbank Warren. Gruntle's crew went to ground there. Bring the parcel home.", "determined"]]
	return [["Starward", "The Tower is open to anyone who carries for it.", "normal"]]


## Back out to Highbank, standing on this building's door. Black first, then Highbank is built (Claude,
## 2026-10-23, R4); Highbank lifts the fade itself in its _ready (hub_town.gd).
func leave() -> void:
	TeamState.data["arrive_at"] = room()["town_door"]
	_sfx("door", true)   # the door out, kept past the change of scene (Claude, 2026-10-24, pass 5 RM5)
	if is_inside_tree() and get_tree().current_scene == self:
		busy = true
		var tree := get_tree()
		await UI.fade_out(tree)
		var town: Node = load("res://scenes/hub_town.tscn").instantiate()
		TeamState.give_to(town)
		tree.change_scene_to_node(town)
	else:
		set_meta("left", true)


func _process(delta: float) -> void:
	if poll_input and not busy:
		_poll()
	var movers: Array = []
	movers.append_array(team)
	movers.append_array(npcs)
	for e in movers:
		if e["walk_t"] > 0.0:
			e["walk_t"] -= delta
			e["walk_clock"] += delta
			var frames: Array = e["walk"].get(e["facing"], [])
			if not frames.is_empty():
				e["sprite"].texture = frames[int(e["walk_clock"] * WALK_FPS) % frames.size()]
			if e["walk_t"] <= 0.0:
				e["sprite"].texture = e["still"][e["facing"]]
	# Standing creatures breathe, the team and anyone else in the room, on the street's beat (Claude, 2026-10-24, pass
	# 5 RM8: SceneKit.idle_bob, T12's helper); the Home's fire and lantern flicker.
	SceneKit.idle_bob(movers, Time.get_ticks_msec() / 1000.0)
	_flicker(delta)
	if not team.is_empty():
		var r := room()
		var half := Vector2(VIEW) * 0.5
		var size := Vector2(r["w"], r["h"]) * T
		var focus: Vector2 = (cam_focus if cam_focus != null else team[0]["node"].position + Vector2(0, -12))
		focus = Vector2(size.x * 0.5 if size.x <= VIEW.x else clampf(focus.x, half.x, size.x - half.x),
			size.y * 0.5 if size.y <= VIEW.y else clampf(focus.y, half.y, size.y - half.y))
		_world.position = (half - focus).round()
	# The Menu button under the key strip and as wide as it, as on Highbank's street (Claude, 2026-10-24, pass 4
	# T1): it sat over the strip's last 4 px and ran past its right edge. A scene hides it with the rest of the HUD,
	# and so does any open panel, the key strip above it going too (Claude, 2026-10-24, pass 5 RM1 / LV-01).
	var menu := get_node_or_null("GamePauseMenu")
	if menu != null and menu.hint != null:
		menu.hint.visible = not cutscene and not menu.overlay.visible and panel.is_empty()
		var ks: Rect2 = hint_now()["strip"]
		menu.hint.position = Vector2(ks.position.x, ks.end.y + 4)
		menu.hint.size = Vector2(ks.size.x, 52)
	_hud.queue_redraw()
	_labels.queue_redraw()


## Every press is an action in the Input Map (Claude, 2026-10-23, factory pass 2: controller support), read
## through ui_style.gd's helpers, as in hub_town.gd: the keyboard keeps E, J or Enter to use, Esc to close, W/S and
## R in the Storage; a pad walks with the stick or D-pad, uses with A or X, closes with B, takes out with Y.
func _poll() -> void:
	if cutscene:   # a scene plays itself; E (or J, Enter, Space) reads its lines
		if not talk.is_empty() and UI.tapped_any(UI.INPUT_ADVANCE):
			if UI.line_done(String(talk[0][1])):
				talk.pop_front()
			else:
				UI.finish_line()   # the first press shows the rest of the line, the next moves on
		return
	if panel.get("service", "") == "storage":
		if UI.tapped(&"move_up"): act_store_move(-1)
		if UI.tapped(&"move_down"): act_store_move(1)
		if UI.tapped(&"page_up"): act_store_page(-1)     # a page of the list (RM1)
		if UI.tapped(&"page_down"): act_store_page(1)
		if UI.tapped(&"take_out"): act_store(-1)
	if panel.get("service", "") == "roster":   # the Roster Board's two lists (pass 8 R6)
		if UI.tapped(&"move_up"): act_roster_move(-1)
		if UI.tapped(&"move_down"): act_roster_move(1)
		if UI.tapped(&"move_left"): act_roster_side(-1)
		if UI.tapped(&"move_right"): act_roster_side(1)
	if UI.tapped_any([&"confirm", &"interact"]):
		act_use()
		return
	if UI.tapped(&"cancel"):
		if panel.get("service", "") == "roster" and RosterPanel.back(self):
			return   # Esc first lets go of a creature picked to swap; the next one closes the board
		if not panel.is_empty():
			# Closing a panel (the Storage, a spot) sounds like closing the pause menu (Claude, 2026-10-26, pass 7 T6 /
			# L7-25); a room's panels ask nothing, so none of them backs out of a choice with the cancel sound.
			_ui_sfx("close")
		panel = {}
	var d := UI.dir8()
	if d != Vector2i.ZERO:
		act_move(d)


func _draw_hud() -> void:
	var h := _hud
	if cutscene:   # a scene: only its lines
		if not talk.is_empty():
			var sl: Array = talk[0]
			var sf: String = String(sl[2]) if sl.size() > 2 else ""
			_solid_under(h, TALK_BOX)
			UI.dialogue(h, TALK_BOX, String(sl[0]), String(sl[1]), UI.dialogue_portrait(sf) if sf != "" else null, Time.get_ticks_msec() / 1000.0, 20, sf.get_slice(":", 1) if ":" in sf else "normal")
		return
	# The place and "Next:" panels and the key strip step aside while a panel is open, as on Highbank's street when
	# the Job Board is up (Claude, 2026-10-24, pass 5 RM3 / LV-03): the Storage list showed the Next line through it.
	if panel.is_empty():
		UI.panel(h, Rect2(6, 6, 330, 54))
		UI.text(h, Vector2(28, 43), String(room()["name"]), 26, UI.EDGE_LIGHT)
		# What to do next, always on screen (Preston, 2026-10-11: "objective tab so players know where to go").
		var goal: Dictionary = Objective.current(TeamState.data.get("story", {}), TeamState.data.get("beaten", []))
		UI.panel(h, Rect2(6, 64, 600, 34), 0.9)
		UI.text(h, Vector2(26, 87), "Next:  " + String(goal["short"]), 16, UI.TEXT, 570)
		_draw_hints(h)
		return
	if panel.get("service", "") == "storage":
		StoragePanel.draw(self, h)
		return
	if panel.get("service", "") == "roster":
		RosterPanel.draw(self, h)
		return
	if not _resting:
		if panel.get("narration", false):   # the bed's morning line: narration, as the riverbank's (pass 4 T7)
			_solid_under(h, TALK_BOX)
			UI.dialogue(h, TALK_BOX, "", String(panel["what"]), null, Time.get_ticks_msec() / 1000.0, 20)
			return
		var lay := spot_layout(String(panel["what"]))
		var box: Rect2 = lay["box"]
		_solid_under(h, box)
		UI.panel(h, box, 0.95)
		UI.nameplate(h, box.position + Vector2(24, -22), String(panel["name"]))
		var rows: PackedStringArray = lay["rows"]
		for k in rows.size():
			UI.say(h, lay["at"] + Vector2(0, k * float(lay["row_h"])), rows[k], "story")
		UI.next_arrow(h, box.end - Vector2(48, 36), Time.get_ticks_msec() / 1000.0)


## The scene lines' box, as UI.dialogue draws it.
const TALK_BOX := Rect2(196, 452, 760, 116)
const SOLID_IN := 9.0   # the frame's brass is opaque 12 px in from its edge; the backing starts under it


## An opaque floor under a talk box or a spot's panel (Claude, 2026-10-26, pass 8 R2 / L02): the panel's woven fill is
## 92 percent opaque, so a pillar or a creature behind the box still showed through it faintly and read as standing on
## the box. The backing is the panel's own colour, inside the brass, so the frame looks the same and hides the room.
static func _solid_under(h: CanvasItem, box: Rect2) -> void:
	h.draw_rect(box.grow(-SOLID_IN), UI.PANEL)


## A spot's panel (Claude, 2026-10-23, R2): its words in the face the scene lines use, the "story" role (on the
## pixel grid at twice its design size, where the panels used the old heading face), wrapped and placed as
## UI.dialogue places a named line. Past two rows the box grows upward a row at a time, so its foot stays where
## the scene lines' box stands and no text is cut (the Chart Table's runs to three).
const SPOT_BOX := Rect2(196, 452, 760, 128)


static func spot_layout(what: String) -> Dictionary:
	var width := SPOT_BOX.size.x - 70.0   # as UI.dialogue: 30 in from the left, 40 clear of the right
	var rows := UI.wrap_text(what, width, "story").split("\n")
	var row_h := UI.font("story").get_height(UI.type_size("story"))
	var extra := maxf(0.0, rows.size() - 2) * row_h
	var box := Rect2(SPOT_BOX.position - Vector2(0, extra), SPOT_BOX.size + Vector2(0, extra))
	return {"box": box, "rows": rows, "at": box.position + Vector2(30, 54), "row_h": row_h}


## The key hints and where the way out is, bottom right on a see-through panel strip (Claude, 2026-10-22,
## GS-21). Laid out inside the strip (Claude, 2026-10-23, R1: "The door leads back out" was cut at the frame
## and "E USE" ran into the corner stud): the strip is sized first, then both lines are right-aligned 12 px
## inside its brass edge, clear of the studs, the way-out line gets the strip's whole text width before it
## steps down a face, and the two rows sit between the top and bottom edges.
## Since 2026-10-24 (Claude, pass 4 T1 and T2, LV-11) the strip is Highbank's (hub_town.gd key_strip): from 516 to
## 578, so the Menu button fits under it, and both lines are in the label face, 20 px apart; the way-out line
## used to step down to the mixed-case prose face when it was the longer one.
const HINT_RIGHT := 1146.0   # the strip's right edge: 6 px in from the screen's, as the top-left panels sit
const HINT_BOTTOM := 578.0
const HINT_H := 62.0
const HINT_EDGE := 12.0      # the frame's brass bevel
const HINT_IN := 24.0        # the text's right end to the strip's: the bevel and 12 px more
const HINT_MIN := 194.0      # the narrowest text column, as before


static func hint_layout(where: String, keys: String) -> Dictionary:
	var where_role := "label"   # the keys' face (T2)
	var width := maxf(HINT_MIN, ceilf(maxf(UI.width_in(keys, "label"), UI.width_in(where, where_role))) + 1.0)
	var strip := Rect2(HINT_RIGHT - width - 2.0 * HINT_IN, HINT_BOTTOM - HINT_H, width + 2.0 * HINT_IN, HINT_H)
	var left := strip.position.x + HINT_IN
	return {"strip": strip, "width": width, "keys": Vector2(left, strip.position.y + 26.0),
		"where": Vector2(left, strip.position.y + 46.0), "where_role": where_role}


## This room's strip as drawn now: its way-out line and the keys of the device in use.
func hint_now() -> Dictionary:
	return hint_layout(String(room().get("hint", "The door leads back out")), keys_hint())


func _draw_hints(h: Node2D) -> void:
	var where := String(room().get("hint", "The door leads back out"))
	var keys := keys_hint()
	var lay := hint_now()
	var col := Color(UI.MUTED, 0.85)
	UI.panel(h, lay["strip"], 0.85)
	UI.say(h, lay["keys"], keys, "label", col, lay["width"], HORIZONTAL_ALIGNMENT_RIGHT)
	UI.say(h, lay["where"], where, lay["where_role"], col, lay["width"], HORIZONTAL_ALIGNMENT_RIGHT)


func storage_rows() -> Array:
	return StoragePanel.entries(self)

func act_store(n: int) -> void:
	StoragePanel.store(self, n)

func act_store_move(dy: int) -> void:
	StoragePanel.select_row(self, dy)

func act_store_page(dir: int) -> void:
	StoragePanel.page(self, dir)

## The Roster Board's panel (pass 8 R6; roster_panel.gd): the cursor, its column, and a pick (swap in, swap out, trade).
func act_roster_move(dy: int) -> void:
	RosterPanel.move(self, dy)

func act_roster_side(dx: int) -> void:
	RosterPanel.side(self, dx)

func act_roster_pick() -> void:
	RosterPanel.pick(self)


## The room's team after the Roster Board changed the record's party (Claude, 2026-10-26, pass 8 R6): the leader stays
## where it stands; the others are made again from the party and set on their tiles behind it.
func refresh_team() -> void:
	var party: Array = _record().get("party", [])
	if team.is_empty() or party.is_empty():
		return
	for k in range(1, team.size()):
		if is_instance_valid(team[k]["node"]):
			team[k]["node"].queue_free()
	team.resize(1)
	var facing := String(team[0]["facing"])
	for k in range(1, party.size()):
		var e := _make(party[k][0], party[k][1], team[0]["pos"])
		e["facing"] = facing
		team.append(e)
	SceneKit.read_names(team)
	var stands := trail_tiles(facing)
	if stands.is_empty():   # the leader on a tile no arrival uses: the nearest free floor round it, breadth-first
		stands = [team[0]["pos"]]
		var seen := {team[0]["pos"]: true}
		var queue: Array = [team[0]["pos"]]
		while stands.size() < team.size() and not queue.is_empty():
			var c: Vector2i = queue.pop_front()
			if _stand_ok(c, stands):
				stands.append(c)
			for o: Vector2i in DIRS:
				if not seen.has(c + o) and _open(c + o):
					seen[c + o] = true
					queue.append(c + o)
	respace(facing, stands)

## Menu sounds through the shared ticks, on the "UI" bus (Claude, 2026-10-22, GS-21): a kind the ticks do
## not know plays nothing instead of loading a missing file. `last_sfx` stays the receipt the checks read.
## One tick of a kind a frame: two in one frame sound as one, and the tick's first player is not yet in the
## tree then (it joins at the frame's end).
func _ui_sfx(name: String) -> void:
	last_sfx = name
	var now := Engine.get_process_frames()
	if int(_tick_frame.get(name, -1)) == now:
		return
	_tick_frame[name] = now
	UI.tick(name)
